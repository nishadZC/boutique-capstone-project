import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import Snackbar from '@mui/material/Snackbar';
import Alert, { AlertColor } from '@mui/material/Alert';
import Slide, { SlideProps } from '@mui/material/Slide';

type TransitionProps = Omit<SlideProps, 'direction'>;

function SlideTransition(props: TransitionProps) {
  return <Slide {...props} direction="left" />;
}

interface ToastOptions {
  message: string;
  severity?: AlertColor;
  duration?: number;
}

interface ToastContextType {
  showToast: (options: ToastOptions) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

// Map severity to gold-accented border colour
const borderColor: Record<AlertColor, string> = {
  warning: '#d4af37',
  error:   '#e57373',
  success: '#81c784',
  info:    '#64b5f6',
};

export const ToastProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [open, setOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [severity, setSeverity] = useState<AlertColor>('info');
  const [duration, setDuration] = useState(4000);

  const showToast = useCallback(({ message, severity = 'info', duration = 4000 }: ToastOptions) => {
    setMessage(message);
    setSeverity(severity);
    setDuration(duration);
    setOpen(true);
  }, []);

  const handleClose = (_: React.SyntheticEvent | Event, reason?: string) => {
    if (reason === 'clickaway') return;
    setOpen(false);
  };

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <Snackbar
        open={open}
        autoHideDuration={duration}
        onClose={handleClose}
        TransitionComponent={SlideTransition}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        sx={{ mt: 9, mr: 2 }}
      >
        <Alert
          onClose={handleClose}
          severity={severity}
          variant="filled"
          sx={{
            minWidth: 320,
            maxWidth: 420,
            fontSize: '0.875rem',
            fontWeight: 500,
            fontFamily: '"Inter", sans-serif',
            backgroundColor: '#1a1a1a',
            color: '#ffffff',
            borderLeft: `4px solid ${borderColor[severity]}`,
            borderRadius: '8px',
            boxShadow: '0 8px 32px rgba(0,0,0,0.35)',
            '& .MuiAlert-icon': {
              color: borderColor[severity],
            },
            '& .MuiAlert-action .MuiIconButton-root': {
              color: '#aaaaaa',
              '&:hover': { color: '#ffffff' },
            },
          }}
        >
          {message}
        </Alert>
      </Snackbar>
    </ToastContext.Provider>
  );
};

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) throw new Error('useToast must be used within a ToastProvider');
  return context;
};
