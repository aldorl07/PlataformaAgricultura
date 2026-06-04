const Product = require('../models/Product');
const User = require('../models/User');
const { AppError } = require('../middlewares/errorMiddleware');
const logger = require('../utils/logger');

const createProduct = async (req, res, next) => {
  try {
    const { name, cropType, variety, description, unit, pricePerUnit, stock, harvestDate } = req.body;

    const photos = [];
    if (req.files) {
      req.files.forEach(file => {
        photos.push(`/uploads/${file.filename}`);
      });
    }

    const product = await Product.create({
      farmer: req.user._id,
      name,
      cropType,
      variety,
      description,
      unit,
      pricePerUnit: Number(pricePerUnit),
      stock: Number(stock),
      photos,
      harvestDate: harvestDate ? new Date(harvestDate) : undefined
    });

    logger.info(`Producto creado: ${product.name} por el agricultor ${req.user.email}`);

    res.status(201).json({
      success: true,
      product
    });
  } catch (error) {
    next(error);
  }
};

const getProducts = async (req, res, next) => {
  try {
    const { 
      search, 
      cropType, 
      community, 
      minPrice, 
      maxPrice, 
      minStock, 
      verified,
      sortBy,
      order,
      page = 1,
      limit = 20
    } = req.query;

    const query = { isActive: true };

    // Text search
    if (search) {
      query.$text = { $search: search };
    }

    // Crop type filter
    if (cropType) {
      query.cropType = cropType;
    }

    // Price range filter
    if (minPrice || maxPrice) {
      query.pricePerUnit = {};
      if (minPrice) query.pricePerUnit.$gte = Number(minPrice);
      if (maxPrice) query.pricePerUnit.$lte = Number(maxPrice);
    }

    // Min stock filter
    if (minStock) {
      query.stock = { $gte: Number(minStock) };
    }

    // Farmer-related filters (Community and Verification)
    let farmerQuery = { role: 'farmer' };
    let requireFarmerFiltering = false;

    if (community) {
      farmerQuery['farmerProfile.community'] = community;
      requireFarmerFiltering = true;
    }

    if (verified === 'true') {
      farmerQuery['farmerProfile.isVerified'] = true;
      requireFarmerFiltering = true;
    }

    if (requireFarmerFiltering) {
      const matchingFarmers = await User.find(farmerQuery).select('_id');
      const farmerIds = matchingFarmers.map(f => f._id);
      query.farmer = { $in: farmerIds };
    }

    // Pagination
    const skip = (Number(page) - 1) * Number(limit);

    // Sorting
    let sortOptions = {};
    if (sortBy) {
      const sortOrder = order === 'desc' ? -1 : 1;
      sortOptions[sortBy] = sortOrder;
    } else {
      sortOptions.createdAt = -1; // Default newest
    }

    const products = await Product.find(query)
      .populate('farmer', 'fullName phone preferredContact farmerProfile')
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit));

    const total = await Product.countDocuments(query);

    res.status(200).json({
      success: true,
      count: products.length,
      pagination: {
        total,
        page: Number(page),
        pages: Math.ceil(total / Number(limit))
      },
      products
    });
  } catch (error) {
    next(error);
  }
};

const getProductById = async (req, res, next) => {
  try {
    const product = await Product.findOne({ _id: req.params.id, isActive: true })
      .populate('farmer', 'fullName phone preferredContact farmerProfile');

    if (!product) {
      throw new AppError('Producto no encontrado', 404);
    }

    res.status(200).json({
      success: true,
      product
    });
  } catch (error) {
    next(error);
  }
};

const updateProduct = async (req, res, next) => {
  try {
    const { name, cropType, variety, description, unit, pricePerUnit, stock, harvestDate } = req.body;

    const product = await Product.findOne({ _id: req.params.id, isActive: true });
    if (!product) {
      throw new AppError('Producto no encontrado', 404);
    }

    // Verify ownership
    if (product.farmer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      throw new AppError('No tienes permisos para modificar este producto', 403);
    }

    if (name) product.name = name;
    if (cropType) product.cropType = cropType;
    if (variety) product.variety = variety;
    if (description) product.description = description;
    if (unit) product.unit = unit;
    if (pricePerUnit !== undefined) product.pricePerUnit = Number(pricePerUnit);
    if (stock !== undefined) product.stock = Number(stock);
    if (harvestDate) product.harvestDate = new Date(harvestDate);

    if (req.files && req.files.length > 0) {
      const photos = [];
      req.files.forEach(file => {
        photos.push(`/uploads/${file.filename}`);
      });
      product.photos = photos;
    }

    await product.save();

    logger.info(`Producto actualizado: ${product.name}`);

    res.status(200).json({
      success: true,
      product
    });
  } catch (error) {
    next(error);
  }
};

const updateStock = async (req, res, next) => {
  try {
    const { stock } = req.body;

    if (stock === undefined || Number(stock) < 0) {
      throw new AppError('Stock inválido o negativo', 400);
    }

    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, farmer: req.user._id, isActive: true },
      { $set: { stock: Number(stock) } },
      { new: true }
    );

    if (!product) {
      throw new AppError('Producto no encontrado o no estás autorizado', 404);
    }

    logger.info(`Stock de producto actualizado: ${product.name} -> ${product.stock}`);

    res.status(200).json({
      success: true,
      product
    });
  } catch (error) {
    next(error);
  }
};

const deleteProduct = async (req, res, next) => {
  try {
    const product = await Product.findOne({ _id: req.params.id, isActive: true });
    if (!product) {
      throw new AppError('Producto no encontrado', 404);
    }

    // Verify ownership
    if (product.farmer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      throw new AppError('No tienes permisos para eliminar este producto', 403);
    }

    product.isActive = false;
    await product.save();

    logger.info(`Producto eliminado lógicamente: ${product.name}`);

    res.status(200).json({
      success: true,
      message: 'Producto eliminado exitosamente'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createProduct,
  getProducts,
  getProductById,
  updateProduct,
  updateStock,
  deleteProduct
};
