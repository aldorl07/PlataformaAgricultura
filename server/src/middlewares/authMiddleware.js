const jwt = require('jsonwebtoken');
const User = require('../models/User');
const logger = require('../utils/logger');

const protect = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No autorizado, no se proporcionó token'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'No autorizado, el usuario no existe'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    logger.error(`Error en autenticación: ${error.message}`);
    return res.status(401).json({
      success: false,
      message: 'No autorizado, token inválido o expirado'
    });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `El rol (${req.user ? req.user.role : 'desconocido'}) no está autorizado para acceder a esta ruta`
      });
    }
    next();
  };
};

module.exports = { protect, authorize };
