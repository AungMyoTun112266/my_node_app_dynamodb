import express from 'express';
import bodyParser from 'body-parser';
import userRoutes from './routes/userRoutes';
import { loggingMiddleware } from './middlewares/loggingMiddleware';
import errorHandler from './middlewares/errorHandler';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
// import { authMiddleware } from './middlewares/authMiddleware';

const app = express();


// Customize Helmet configuration
app.use(helmet({
    contentSecurityPolicy: {
      useDefaults: true,
      directives: {
        ...helmet.contentSecurityPolicy.getDefaultDirectives(),
        'img-src': ["'self'", 'data:'],
        'script-src': ["'self'"],
      },
    },
    crossOriginOpenerPolicy: { policy: 'same-origin' },
    crossOriginResourcePolicy: { policy: 'same-origin' },
    referrerPolicy: { policy: 'no-referrer' },
    strictTransportSecurity: { maxAge: 31536000, includeSubDomains: true },
    xssFilter: true,
  }));


const limiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
  });
app.use(limiter);

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
