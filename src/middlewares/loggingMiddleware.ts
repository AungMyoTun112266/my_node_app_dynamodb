import { Request, Response, NextFunction } from 'express';

// Logging middleware to log request details
export const loggingMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // Log request details
  console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl} - Request Body:`, req.body);

  // Capture the response status code
  res.on('finish', () => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl} - ${res.statusCode}`);
  });

  // Continue to the next middleware or route handler
  next();
};
