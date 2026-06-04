const mongoose = require('mongoose');

const MarketPriceSchema = new mongoose.Schema({
  cropType: {
    type: String,
    required: [true, 'El tipo de cultivo es obligatorio'],
    index: true
  },
  cropName: {
    type: String,
    required: [true, 'El nombre del cultivo es obligatorio']
  },
  marketName: {
    type: String,
    required: [true, 'El nombre del mercado de referencia es obligatorio'],
    default: 'Mercado Mayorista de Huancayo'
  },
  pricePerKg: {
    type: Number,
    required: [true, 'El precio por kg es obligatorio'],
    min: [0, 'El precio no puede ser negativo']
  },
  source: {
    type: String,
    default: 'MIDAGRI'
  },
  effectiveDate: {
    type: Date,
    required: [true, 'La fecha de vigencia es obligatoria'],
    default: Date.now
  }
}, {
  timestamps: true
});

// Indexes
MarketPriceSchema.index({ cropType: 1, effectiveDate: -1 });

module.exports = mongoose.model('MarketPrice', MarketPriceSchema);
