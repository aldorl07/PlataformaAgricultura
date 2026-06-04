const express = require('express');
const { getProfile, updateProfile, toggleVerifyFarmer, getFarmersList, getReachStats } = require('../controllers/userController');
const { protect, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(protect);

router.get('/profile', getProfile);
router.put('/profile', updateProfile);

// Admin-only routes
router.patch('/:id/verify', authorize('admin'), toggleVerifyFarmer);
router.get('/farmers', authorize('admin'), getFarmersList);
router.get('/stats/reach', authorize('admin'), getReachStats);

module.exports = router;
