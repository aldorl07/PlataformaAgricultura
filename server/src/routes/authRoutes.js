const express = require('express');
const { body } = require('express-validator');
const { register, login, getMe } = require('../controllers/authController');
const { protect } = require('../middlewares/authMiddleware');
const { handleValidationErrors } = require('../middlewares/validationMiddleware');

const router = express.Router();

router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Debe ingresar un correo electrónico válido'),
    body('password').isLength({ min: 8 }).withMessage('La contraseña debe tener al menos 8 caracteres'),
    body('fullName').notEmpty().withMessage('El nombre completo es obligatorio'),
    body('phone').notEmpty().withMessage('El número de teléfono es obligatorio'),
    body('role').isIn(['farmer', 'buyer']).withMessage('El rol especificado es inválido'),
    handleValidationErrors
  ],
  register
);

router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Debe ingresar un correo electrónico válido'),
    body('password').notEmpty().withMessage('La contraseña es obligatoria'),
    handleValidationErrors
  ],
  login
);

router.get('/me', protect, getMe);

module.exports = router;
