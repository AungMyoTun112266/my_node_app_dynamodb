import { Request, Response, NextFunction } from 'express';

// Global error handling middleware
const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack); // Log the error stack trace

  // Determine the status code and message
  const statusCode = err.status || 500;
  const message = err.message || 'Internal Server Error';

  // Send the error response
  res.status(statusCode).json({
    error: {
      message,
      // Optionally, include more details for development
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
};

export default errorHandler;
