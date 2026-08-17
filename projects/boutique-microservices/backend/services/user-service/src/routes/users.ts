import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../database/connection';
import { UserProfile, Address, ServiceResponse } from '../types';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret';

router.get('/profile', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'No token provided' });
    }

    const userId = token;
    
    const result = await query('SELECT id, email, first_name, last_name, role, phone, address, created_at, updated_at FROM users WHERE id = $1', [userId]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ success: false, error: 'Invalid token' });
    }

    const user = result.rows[0];
    
    const preferencesResult = await query('SELECT * FROM user_preferences WHERE user_id = $1', [user.id]);
    const addressesResult = await query('SELECT * FROM addresses WHERE user_id = $1', [user.id]);

    const response: ServiceResponse<UserProfile> = {
      success: true,
      data: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        phone: user.phone,
        address: user.address,
        role: user.role,
        preferences: preferencesResult.rows[0] || {
          currency: 'USD',
          language: 'en',
          newsletter: true,
          promotions: true
        },
        addresses: addressesResult.rows,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    };
    
    res.json(response);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, error: 'Failed to get profile' });
  }
});

router.put('/profile', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'No token provided' });
    }

    const userId = token;
    const { firstName, lastName, phone, address } = req.body;

    await query(
      'UPDATE users SET first_name = $1, last_name = $2, phone = $3, address = $4, updated_at = CURRENT_TIMESTAMP WHERE id = $5',
      [firstName, lastName, phone, address, userId]
    );

    const result = await query('SELECT id, email, first_name, last_name, role, phone, address, created_at, updated_at FROM users WHERE id = $1', [userId]);
    const user = result.rows[0];

    const response: ServiceResponse<UserProfile> = {
      success: true,
      data: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        phone: user.phone,
        address: user.address,
        role: user.role,
        preferences: {
          currency: 'USD',
          language: 'en',
          newsletter: true,
          promotions: true
        },
        addresses: [],
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    };
    
    res.json(response);
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ success: false, error: 'Failed to update profile' });
  }
});

router.post('/addresses', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'No token provided' });
    }

    const userId = token;
    const { street, city, state, zipCode, country, isDefault } = req.body;

    const result = await query(
      'INSERT INTO addresses (user_id, street, city, state, zip_code, country, is_default) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [userId, street, city, state, zipCode, country, isDefault]
    );

    const response: ServiceResponse<Address> = {
      success: true,
      data: result.rows[0]
    };
    
    res.status(201).json(response);
  } catch (error) {
    console.error('Add address error:', error);
    res.status(500).json({ success: false, error: 'Failed to add address' });
  }
});

export { router as userRoutes };
