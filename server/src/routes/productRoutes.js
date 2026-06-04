const express = require('express');
const { body } = require('express-validator');
const { createProduct, getProducts, getProductById, updateProduct, updateStock, deleteProduct } = require('../controllers/productController');
const { protect, authorize } = require('../middlewares/authMiddleware');
const upload = require('../middlewares/uploadMiddleware');
const { handleValidationErrors } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Public routes
router.get('/', getProducts);
router.get('/:id', getProductById);

// Protected routes (Farmers and Admins)
router.use(protect);

router.post(
  '/',
  authorize('farmer'),
  upload.array('photos', 5),
  [
    body('name').notEmpty().withMessage('El nombre del producto es obligatorio'),
    body('cropType').isIn(['papa', 'maiz', 'cebada', 'habas', 'hortalizas', 'quinua', 'arveja', 'otros']).withMessage('El tipo de cultivo es inválido'),
    body('pricePerUnit').isFloat({ min: 0 }).withMessage('El precio unitario debe ser mayor o igual a 0'),
    body('stock').isInt({ min: 0 }).withMessage('El stock disponible debe ser mayor o igual a 0'),
    handleValidationErrors
  ],
  createProduct
);

router.put(
  '/:id',
  authorize('farmer'),
  upload.array('photos', 5),
  updateProduct
);

router.patch(
  '/:id/stock',
  authorize('farmer'),
  [
    body('stock').isInt({ min: 0 }).withMessage('El stock disponible debe ser mayor o igual a 0'),
    handleValidationErrors
  ],
  updateStock
);

router.delete('/:id', authorize('farmer', 'admin'), deleteProduct);

module.exports = router;
