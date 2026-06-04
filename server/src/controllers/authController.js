const jwt = require('jsonwebtoken');
const User = require('../models/User');
const TelemetryEvent = require('../models/TelemetryEvent');
const { AppError } = require('../middlewares/errorMiddleware');
const logger = require('../utils/logger');

const generateToken = (userId, role) => {
  return jwt.sign({ userId, role }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  });
};

const register = async (req, res, next) => {
  try {
    const { 
      email, 
      password, 
      role, 
      fullName, 
      phone, 
      preferredContact, 
      farmerProfile, 
      buyerProfile,
      registrationStartedAt 
    } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      throw new AppError('El correo electrónico ya está registrado', 400);
    }

    const regStart = registrationStartedAt ? new Date(registrationStartedAt) : new Date(Date.now() - 30000); // Default to 30s ago if missing
    const regCompleted = new Date();

    const userData = {
      email,
      password,
      role,
      fullName,
      phone,
      preferredContact,
      registrationStartedAt: regStart,
      registrationCompletedAt: regCompleted
    };

    if (role === 'farmer' && farmerProfile) {
      userData.farmerProfile = {
        ...farmerProfile,
        isVerified: false
      };
    } else if (role === 'buyer' && buyerProfile) {
      userData.buyerProfile = buyerProfile;
    }

    const user = await User.create(userData);

    // Create telemetry event
    const loadTime = Math.floor(Math.random() * 800) + 200; // Simulated page load time
    await TelemetryEvent.create({
      userId: user._id,
      eventType: 'registration_complete',
      metadata: {
        pageLoadTimeMs: loadTime,
        deviceType: req.headers['user-agent']?.includes('Mobile') ? 'mobile' : 'desktop',
        browserName: 'Chrome',
        screenWidth: req.headers['user-agent']?.includes('Mobile') ? 375 : 1440,
        stepReached: 'completed'
      }
    });

    const token = generateToken(user._id, user.role);

    logger.info(`Nuevo usuario registrado: ${user.email} (${user.role})`);

    // Clean user response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(201).json({
      success: true,
      token,
      user: userResponse
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user || !(await user.comparePassword(password))) {
      throw new AppError('Credenciales incorrectas', 401);
    }

    const token = generateToken(user._id, user.role);

    logger.info(`Usuario inició sesión: ${user.email}`);

    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(200).json({
      success: true,
      token,
      user: userResponse
    });
  } catch (error) {
    next(error);
  }
};

const getMe = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      user: req.user
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getMe
};
