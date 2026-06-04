require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const hpp = require('hpp');
const rateLimit = require('express-rate-limit');
const path = require('path');

const connectDB = require('./src/config/db');
const logger = require('./src/utils/logger');
const { globalErrorHandler } = require('./src/middlewares/errorMiddleware');
const { protect, authorize } = require('./src/middlewares/authMiddleware');
const { getResearchDashboard } = require('./src/controllers/telemetryController');

// Import routes
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes');
const productRoutes = require('./src/routes/productRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const marketPriceRoutes = require('./src/routes/marketPriceRoutes');
const salesLogRoutes = require('./src/routes/salesLogRoutes');
const telemetryRoutes = require('./src/routes/telemetryRoutes');

const app = express();

// Connect to Database
connectDB();

// 1. SECURITY MIDDLEWARES
app.use(helmet({
  crossOriginResourcePolicy: false // Allow loading local uploads from react client
}));
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:5173',
  credentials: true
}));

// Rate limiting for auth routes
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per IP
  message: {
    success: false,
    message: 'Demasiadas peticiones desde esta IP, por favor intente de nuevo más tarde'
  }
});
app.use('/api/auth', authLimiter);

app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Data sanitization against NoSQL query injection
app.use(mongoSanitize());

// Prevent HTTP parameter pollution
app.use(hpp());

// Expose static folders
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 2. TELEMETRY MIDDLEWARE (Structured logs + X-Response-Time header)
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    res.setHeader('X-Response-Time', `${duration}ms`);
    
    logger.info({
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      responseTimeMs: duration,
      userId: req.user ? req.user._id : 'anonymous',
      ip: req.ip
    });
  });

  next();
});

// 3. API ROUTING
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/market-prices', marketPriceRoutes);
app.use('/api/sales-logs', salesLogRoutes);
app.use('/api/telemetry', telemetryRoutes);

// Single dashboard research route
app.get('/api/research/dashboard', protect, authorize('admin'), getResearchDashboard);

// 4. ERROR HANDLING
app.use(globalErrorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  logger.info(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});
