const express = require('express');
const { body } = require('express-validator');
const { createOrder, getOrders, getOrderById, updateOrderStatus } = require('../controllers/orderController');
const { protect } = require('../middlewares/authMiddleware');
const { handleValidationErrors } = require('../middlewares/validationMiddleware');

const router = express.Router();

router.use(protect);

router.post(
  '/',
  [
    body('items').isArray({ min: 1 }).withMessage('El pedido debe contener al menos un producto'),
    body('items.*.product').notEmpty().withMessage('El ID de producto es obligatorio'),
    body('items.*.quantity').isInt({ min: 1 }).withMessage('La cantidad de producto debe ser mínimo 1'),
    body('deliveryAddress').notEmpty().withMessage('La dirección de entrega es obligatoria'),
    handleValidationErrors
  ],
  createOrder
);

router.get('/', getOrders);
router.get('/:id', getOrderById);

router.patch(
  '/:id/status',
  [
    body('status').isIn(['pending', 'approved', 'dispatched', 'completed', 'cancelled']).withMessage('Estado de pedido inválido'),
    handleValidationErrors
  ],
  updateOrderStatus
);

module.exports = router;
