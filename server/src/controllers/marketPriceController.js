const MarketPrice = require('../models/MarketPrice');
const Product = require('../models/Product');
const { AppError } = require('../middlewares/errorMiddleware');
const logger = require('../utils/logger');

let priceCache = null;
let cacheTimestamp = 0;
const CACHE_TTL = 60 * 60 * 1000; // 1 hour in ms

const getMarketPrices = async (req, res, next) => {
  try {
    const now = Date.now();

    // Return cached value if valid
    if (priceCache && (now - cacheTimestamp) < CACHE_TTL) {
      return res.status(200).json({
        success: true,
        cached: true,
        prices: priceCache
      });
    }

    // Fetch latest market prices for all crop types
    // Group by cropType and find the latest effectiveDate entry
    const latestMarketPrices = await MarketPrice.aggregate([
      { $sort: { effectiveDate: -1 } },
      {
        $group: {
          _id: '$cropType',
          doc: { $first: '$$ROOT' }
        }
      }
    ]);

    // Aggregate average platform prices
    const platformAverages = await Product.aggregate([
      { $match: { isActive: true, stock: { $gt: 0 } } },
      {
        $group: {
          _id: '$cropType',
          avgPrice: { $avg: '$pricePerUnit' }
        }
      }
    ]);

    const platformAvgMap = {};
    platformAverages.forEach(avg => {
      platformAvgMap[avg._id] = avg.avgPrice;
    });

    const results = latestMarketPrices.map(item => {
      const mp = item.doc;
      const platformAvgPrice = platformAvgMap[mp.cropType] || 0;
      
      // Calculate savings percent: (Market - Platform) / Market
      let savingsPercent = 0;
      if (mp.pricePerKg > 0 && platformAvgPrice > 0) {
        savingsPercent = Math.round(((mp.pricePerKg - platformAvgPrice) / mp.pricePerKg) * 100);
      }

      return {
        cropType: mp.cropType,
        cropName: mp.cropName,
        marketPrice: mp.pricePerKg,
        platformAvgPrice: Number(platformAvgPrice.toFixed(2)),
        savingsPercent: savingsPercent > 0 ? savingsPercent : 0,
        source: mp.source,
        effectiveDate: mp.effectiveDate
      };
    });

    // Save to cache
    priceCache = results;
    cacheTimestamp = now;

    res.status(200).json({
      success: true,
      cached: false,
      prices: results
    });
  } catch (error) {
    next(error);
  }
};

const createOrUpdateMarketPrice = async (req, res, next) => {
  try {
    const { cropType, cropName, pricePerKg, source, effectiveDate } = req.body;

    const marketPrice = await MarketPrice.create({
      cropType,
      cropName,
      pricePerKg: Number(pricePerKg),
      source: source || 'MIDAGRI',
      effectiveDate: effectiveDate ? new Date(effectiveDate) : new Date()
    });

    // Invalidate cache
    priceCache = null;

    logger.info(`Precio referencial de mercado registrado: ${cropType} -> S/. ${pricePerKg}/kg`);

    res.status(201).json({
      success: true,
      marketPrice
    });
  } catch (error) {
    next(error);
  }
};

const getComparisonTable = async (req, res, next) => {
  try {
    // Detailed list of all historical records for side-by-side comparison
    const prices = await MarketPrice.find().sort({ effectiveDate: -1 });
    res.status(200).json({
      success: true,
      count: prices.length,
      prices
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getMarketPrices,
  createOrUpdateMarketPrice,
  getComparisonTable
};
