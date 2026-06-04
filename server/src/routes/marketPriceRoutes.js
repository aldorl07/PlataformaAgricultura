const express = require('express');
const { body } = require('express-validator');
const { getMarketPrices, createOrUpdateMarketPrice, getComparisonTable } = require('../controllers/marketPriceController');
const { protect, authorize } = require('../middlewares/authMiddleware');
const { handleValidationErrors } = require('../middlewares/validationMiddleware');

const router = express.Router();

router.get('/', getMarketPrices);
router.get('/compare', getComparisonTable);

// Admin-only updates
router.post(
  '/',
  protect,
  authorize('admin'),
  [
    body('cropType').notEmpty().withMessage('El tipo de cultivo es obligatorio'),
    body('cropName').notEmpty().withMessage('El nombre del cultivo es obligatorio'),
    body('pricePerKg').isFloat({ min: 0 }).withMessage('El precio referencial por Kg debe ser mayor o igual a 0'),
    handleValidationErrors
  ],
  createOrUpdateMarketPrice
);

module.exports = router;
