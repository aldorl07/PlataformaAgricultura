const mongoose = require('mongoose');

const SalesLogProductSchema = new mongoose.Schema({
  name: { type: String, required: true },
  cropType: { type: String, required: true },
  quantity: { type: Number, required: true },
  unit: { type: String, required: true },
  unitPrice: { type: Number, required: true },
  lineTotal: { type: Number, required: true }
}, { _id: false });

const SalesLogSchema = new mongoose.Schema({
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
    unique: true,
    immutable: true
  },
  transactionDate: {
    type: Date,
    required: true,
    default: Date.now,
    immutable: true
  },
  farmer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    immutable: true
  },
  buyer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    immutable: true
  },
  products: [SalesLogProductSchema],
  totalAmount: {
    type: Number,
    required: true,
    immutable: true
  },
  totalVolumeKg: {
    type: Number,
    required: true,
    immutable: true
  },
  platformFeePaid: {
    type: Number,
    immutable: true
  },
  estimatedSavingsVsIntermediary: {
    type: Number,
    immutable: true
  },
  savingsPercent: {
    type: Number,
    immutable: true
  },
  farmerNetRevenue: {
    type: Number,
    immutable: true
  },
  farmerCommunity: {
    type: String,
    immutable: true
  }
}, {
  timestamps: { createdAt: true, updatedAt: false } // No update timestamps as it is read-only
});

// Disable update operations at mongoose validation level
SalesLogSchema.pre('save', function(next) {
  if (!this.isNew) {
    return next(new Error('Los registros de ventas son inalterables y no se pueden modificar.'));
  }
  next();
});

// Indexes
SalesLogSchema.index({ transactionDate: -1 });
SalesLogSchema.index({ farmer: 1 });
SalesLogSchema.index({ farmerCommunity: 1 });

module.exports = mongoose.model('SalesLog', SalesLogSchema);
