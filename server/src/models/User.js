const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'El correo es obligatorio'],
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: [true, 'La contraseña es obligatoria'],
    minlength: [8, 'La contraseña debe tener al menos 8 caracteres']
  },
  role: {
    type: String,
    enum: ['farmer', 'buyer', 'admin'],
    required: [true, 'El rol es obligatorio']
  },
  fullName: {
    type: String,
    required: [true, 'El nombre completo es obligatorio'],
    trim: true
  },
  phone: {
    type: String,
    required: [true, 'El teléfono es obligatorio'] // +51 format
  },
  preferredContact: {
    type: String,
    enum: ['whatsapp', 'call', 'email'],
    default: 'whatsapp'
  },
  // Farmer-specific fields (RF-02)
  farmerProfile: {
    dni: { type: String, trim: true },
    community: {
      type: String,
      enum: [
        'Chupaca', 'Tres de Diciembre', 'Ahuac', 'Chongos Bajo',
        'Huachac', 'Huamancaca Chico', 'San Juan de Iscos',
        'Yanacancha', 'San Juan de Jarpa'
      ]
    },
    plotCoordinates: {
      lat: { type: Number },
      lng: { type: Number }
    },
    experienceYears: { type: Number, min: 0 },
    mainCrops: [{ type: String }],
    isVerified: { type: Boolean, default: false }, // RF-03
    verifiedAt: { type: Date },
    verifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  },
  // Buyer-specific fields
  buyerProfile: {
    businessName: { type: String, trim: true },
    ruc: { type: String, trim: true },
    businessType: {
      type: String,
      enum: ['wholesale_market', 'restaurant', 'exporter', 'retail', 'other']
    },
    deliveryAddress: { type: String, trim: true }
  },
  // Research telemetry (X2: Usability)
  registrationStartedAt: { type: Date },
  registrationCompletedAt: { type: Date },
  firstTransactionAt: { type: Date }
}, {
  timestamps: true
});

// Indexes
UserSchema.index({ email: 1 });
UserSchema.index({ role: 1, 'farmerProfile.community': 1 });
UserSchema.index({ 'farmerProfile.isVerified': 1 });

// Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Instance method to compare password
UserSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
