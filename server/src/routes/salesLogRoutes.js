const express = require('express');
const { getSalesLogs, exportSalesLogsCSV, getSalesAnalytics } = require('../controllers/salesLogController');
const { protect, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(protect);
router.use(authorize('admin'));

router.get('/', getSalesLogs);
router.get('/export', exportSalesLogsCSV);
router.get('/analytics', getSalesAnalytics);

module.exports = router;
