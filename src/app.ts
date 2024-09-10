import express from 'express';
import bodyParser from 'body-parser';
import userRoutes from './routes/userRoutes';
import { loggingMiddleware } from './middlewares/loggingMiddleware';
import errorHandler from './middlewares/errorHandler';
// import { authMiddleware } from './middlewares/authMiddleware';

const app = express();

app.use(bodyParser.json());

// app.use(
//     compression({
//       level: 6, //
//       threshold: 0,
//       filter: (req, res) => {
//         if (!req.headers['x-no-compression']) {
//           return compression.filter(req, res);
//         }
//         return false; // Don't apply compression if 'x-no-compression' header is present
//       },
//     })
//   );

// app.use(authMiddleware);
app.use(loggingMiddleware);
app.use('/api', userRoutes);

// Health check endpoint
app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'OK', message: 'Service is up and running!' });
});

app.use(errorHandler);

export default app;
