const User = require('../models/User');
const { AppError } = require('../middlewares/errorMiddleware');
const logger = require('../utils/logger');

const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    next(error);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { fullName, phone, preferredContact, farmerProfile, buyerProfile } = req.body;

    const user = await User.findById(req.user._id);

    if (fullName) user.fullName = fullName;
    if (phone) user.phone = phone;
    if (preferredContact) user.preferredContact = preferredContact;

    if (user.role === 'farmer' && farmerProfile) {
      user.farmerProfile = {
        ...user.farmerProfile,
        ...farmerProfile,
        // Make sure verification fields are NOT updated by the farmer
        isVerified: user.farmerProfile.isVerified,
        verifiedAt: user.farmerProfile.verifiedAt,
        verifiedBy: user.farmerProfile.verifiedBy
      };
    } else if (user.role === 'buyer' && buyerProfile) {
      user.buyerProfile = {
        ...user.buyerProfile,
        ...buyerProfile
      };
    }

    await user.save();
    
    const updatedUser = user.toObject();
    delete updatedUser.password;

    res.status(200).json({
      success: true,
      user: updatedUser
    });
  } catch (error) {
    next(error);
  }
};

const toggleVerifyFarmer = async (req, res, next) => {
  try {
    const { id } = req.params;

    const farmer = await User.findById(id);
    if (!farmer) {
      throw new AppError('Agricultor no encontrado', 404);
    }
    if (farmer.role !== 'farmer') {
      throw new AppError('El usuario especificado no es un agricultor', 400);
    }

    // Toggle verification state
    const currentStatus = farmer.farmerProfile.isVerified;
    farmer.farmerProfile.isVerified = !currentStatus;
    
    if (farmer.farmerProfile.isVerified) {
      farmer.farmerProfile.verifiedAt = new Date();
      farmer.farmerProfile.verifiedBy = req.user._id;
      logger.info(`Agricultor verificado: ${farmer.email} por admin ${req.user.email}`);
    } else {
      farmer.farmerProfile.verifiedAt = undefined;
      farmer.farmerProfile.verifiedBy = undefined;
      logger.info(`Verificación removida para agricultor: ${farmer.email} por admin ${req.user.email}`);
    }

    await farmer.save();

    res.status(200).json({
      success: true,
      message: farmer.farmerProfile.isVerified ? 'Agricultor verificado exitosamente' : 'Verificación removida',
      user: farmer
    });
  } catch (error) {
    next(error);
  }
};

const getFarmersList = async (req, res, next) => {
  try {
    const farmers = await User.find({ role: 'farmer' }).select('-password');
    res.status(200).json({
      success: true,
      count: farmers.length,
      farmers
    });
  } catch (error) {
    next(error);
  }
};

const getReachStats = async (req, res, next) => {
  try {
    const totalFarmers = await User.countDocuments({ role: 'farmer' });
    const totalBuyers = await User.countDocuments({ role: 'buyer' });
    const verifiedCount = await User.countDocuments({ role: 'farmer', 'farmerProfile.isVerified': true });

    // Aggregate farmers per community
    const communityAggregation = await User.aggregate([
      { $match: { role: 'farmer' } },
      { $group: { _id: '$farmerProfile.community', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    const farmersPerCommunity = {};
    communityAggregation.forEach(item => {
      if (item._id) {
        farmersPerCommunity[item._id] = item.count;
      }
    });

    res.status(200).json({
      success: true,
      stats: {
        totalFarmers,
        totalBuyers,
        verifiedCount,
        farmersPerCommunity
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProfile,
  updateProfile,
  toggleVerifyFarmer,
  getFarmersList,
  getReachStats
};
