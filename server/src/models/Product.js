const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  farmer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'El productor es obligatorio'],
    index: true
  },
  name: {
    type: String,
    required: [true, 'El nombre del producto es obligatorio'],
    trim: true
  },
  cropType: {
    type: String,
    required: [true, 'El tipo de cultivo es obligatorio'],
    enum: ['papa', 'maiz', 'cebada', 'habas', 'hortalizas', 'quinua', 'arveja', 'otros']
  },
  variety: {
    type: String,
    trim: true
  },
  description: {
    type: String
  },
  unit: {
    type: String,
    enum: ['kg', 'arroba', 'saco', 'tonelada'],
    default: 'kg'
  },
  pricePerUnit: {
    type: Number,
    required: [true, 'El precio unitario es obligatorio'],
    min: [0, 'El precio no puede ser negativo']
  },
  stock: {
    type: Number,
    required: [true, 'El stock es obligatorio'],
    min: [0, 'El stock no puede ser negativo']
  },
  photos: [{
    type: String
  }],
  harvestDate: {
    type: Date
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Indexes
ProductSchema.index({ cropType: 1, pricePerUnit: 1 });
ProductSchema.index({ stock: 1 });
ProductSchema.index({ farmer: 1, isActive: 1 });
ProductSchema.index({
  name: 'text',
  variety: 'text',
  description: 'text'
});

module.exports = mongoose.model('Product', ProductSchema);
