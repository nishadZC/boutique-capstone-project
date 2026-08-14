import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import * as dotenv from 'dotenv';
import { userRoutes } from './routes/users';
import { connectDB } from './database/connection';
import { metricsMiddleware, setupMetrics, boutiqueTotalUsers } from './metrics';
import { query } from './database/connection';

dotenv.config({ path: './.env' });

const app = express();
const PORT = process.env.PORT || 3006;

app.use(helmet());
app.use(cors());
app.use(express.json());

setupMetrics(app, { serviceName: 'user-service', serviceVersion: '1.0.0' });

app.use(metricsMiddleware);

app.use('', userRoutes);

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

const startServer = async () => {
  try {
    await connectDB();
    
    // Poll the database every 60 seconds to update the total users metric
    setInterval(async () => {
      try {
        const result = await query('SELECT COUNT(*) FROM users');
        const count = parseInt(result.rows[0].count, 10);
        boutiqueTotalUsers.set(count);
      } catch (err) {
        console.error('Failed to poll total users metric:', err);
      }
    }, 60000);
    
    // Run an initial poll immediately
    try {
      const result = await query('SELECT COUNT(*) FROM users');
      const count = parseInt(result.rows[0].count, 10);
      boutiqueTotalUsers.set(count);
    } catch (err) {
      console.error('Failed to run initial metric poll:', err);
    }

    app.listen(PORT, () => {
      console.log(`User service running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start user service:', error);
    process.exit(1);
  }
};

startServer();
