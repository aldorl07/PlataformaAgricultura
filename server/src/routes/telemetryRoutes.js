const express = require('express');
const { recordTelemetryEvent, getTelemetryAnalytics } = require('../controllers/telemetryController');
const { protect, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

// Allow public logging of events (e.g. registration start, page load)
// If a user is logged in, protect middleware can be optional, so we handle optional auth inside controller
// To keep routing simple, we make POST / telemetry public, but if JWT is sent it is parsed.
// Let's make it a public route, but we can verify JWT optionally if we want, or just accept whatever userId is sent.
router.post('/', recordTelemetryEvent);

// Admin-only telemetry analytics
router.get('/analytics', protect, authorize('admin'), getTelemetryAnalytics);

module.exports = router;
