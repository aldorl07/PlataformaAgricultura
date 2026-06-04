const mongoose = require('mongoose');

const OrderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  farmer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  productName: {
    type: String,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: [1, 'La cantidad mínima es 1']
  },
  unitPrice: {
    type: Number,
    required: true
  },
  lineTotal: {
    type: Number,
    required: true
  }
});

const StatusHistorySchema = new mongoose.Schema({
  status: {
    type: String,
    required: true
  },
  changedAt: {
    type: Date,
    default: Date.now
  },
  changedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
});

const OrderSchema = new mongoose.Schema({
  buyer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [OrderItemSchema],
  subtotal: {
    type: Number,
    required: true
  },
  shippingCost: {
    type: Number,
    default: 0
  },
  platformFee: {
    type: Number,
    default: 0 // 2% commission
  },
  totalAmount: {
    type: Number,
    required: true
  },
  estimatedSavings: {
    type: Number
  },
  savingsPercent: {
    type: Number
  },
  deliveryAddress: {
    type: String
  },
  deliveryDate: {
    type: Date
  },
  buyerNotes: {
    type: String
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'dispatched', 'completed', 'cancelled'],
    default: 'pending'
  },
  statusHistory: [StatusHistorySchema]
}, {
  timestamps: true
});

// Indexes
OrderSchema.index({ buyer: 1, status: 1 });
OrderSchema.index({ 'items.farmer': 1, status: 1 });
OrderSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Order', OrderSchema);
