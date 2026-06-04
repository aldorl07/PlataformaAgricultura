const mongoose = require('mongoose');

const TelemetryEventSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  sessionId: {
    type: String
  },
  eventType: {
    type: String,
    enum: [
      'page_load', 'registration_start', 'registration_abandon',
      'registration_complete', 'first_product_publish',
      'first_transaction', 'search_performed', 'filter_applied',
      'quote_simulation_start', 'order_submitted'
    ],
    required: true
  },
  metadata: {
    pageLoadTimeMs: { type: Number },
    deviceType: { type: String }, // mobile, desktop, tablet
    browserName: { type: String },
    screenWidth: { type: Number },
    stepReached: { type: String }, // e.g. for registration wizard funnel
    searchQuery: { type: String },
    filtersUsed: [{ type: String }]
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

// Indexes
TelemetryEventSchema.index({ eventType: 1, timestamp: -1 });
TelemetryEventSchema.index({ userId: 1 });

module.exports = mongoose.model('TelemetryEvent', TelemetryEventSchema);
