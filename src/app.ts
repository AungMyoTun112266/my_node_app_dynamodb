import express from 'express';
import bodyParser from 'body-parser';
import userRoutes from './routes/userRoutes';
// import { authMiddleware } from './middlewares/authMiddleware';

const app = express();

app.use(bodyParser.json());
// app.use(authMiddleware);
app.use('/api', userRoutes);

// Health check endpoint
app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'OK', message: 'Service is up and running!' });
});

export default app;
