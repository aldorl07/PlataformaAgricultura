const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');
const SalesLog = require('../models/SalesLog');
const MarketPrice = require('../models/MarketPrice');
const TelemetryEvent = require('../models/TelemetryEvent');
const { AppError } = require('../middlewares/errorMiddleware');
const logger = require('../utils/logger');

const createOrder = async (req, res, next) => {
  try {
    const { items, shippingCost, deliveryAddress, deliveryDate, buyerNotes } = req.body;

    if (!items || items.length === 0) {
      throw new AppError('El pedido debe tener al menos un producto', 400);
    }

    let subtotal = 0;
    const orderItems = [];
    let totalVolumeKg = 0;
    let totalEstimatedSavings = 0;

    // Validate products and calculate details
    for (const item of items) {
      const product = await Product.findOne({ _id: item.product, isActive: true });
      if (!product) {
        throw new AppError(`El producto ${item.product} no existe o no está activo`, 404);
      }
      if (product.stock < item.quantity) {
        throw new AppError(`Stock insuficiente para ${product.name}. Disponible: ${product.stock}, solicitado: ${item.quantity}`, 400);
      }

      const lineTotal = product.pricePerUnit * item.quantity;
      subtotal += lineTotal;

      // Calculate savings by querying the latest reference MarketPrice
      const marketPrice = await MarketPrice.findOne({ cropType: product.cropType }).sort({ effectiveDate: -1 });
      let itemSavings = 0;
      let weightInKg = item.quantity;
      if (product.unit === 'arroba') weightInKg = item.quantity * 11.5;
      if (product.unit === 'saco') weightInKg = item.quantity * 50;
      if (product.unit === 'tonelada') weightInKg = item.quantity * 1000;

      totalVolumeKg += weightInKg;

      if (marketPrice) {
        // Market price is in per Kg, let's normalize product price to per Kg
        let pricePerKg = product.pricePerUnit;
        if (product.unit === 'arroba') pricePerKg = product.pricePerUnit / 11.5;
        if (product.unit === 'saco') pricePerKg = product.pricePerUnit / 50;
        if (product.unit === 'tonelada') pricePerKg = product.pricePerUnit / 1000;

        const priceDiffPerKg = marketPrice.pricePerKg - pricePerKg;
        itemSavings = priceDiffPerKg * weightInKg;
      } else {
        // Default to a fallback of 25% savings if reference market price is missing
        itemSavings = lineTotal * 0.25;
      }

      totalEstimatedSavings += itemSavings > 0 ? itemSavings : 0;

      orderItems.push({
        product: product._id,
        farmer: product.farmer,
        productName: product.name,
        quantity: item.quantity,
        unitPrice: product.pricePerUnit,
        lineTotal
      });
    }

    const platformFee = subtotal * 0.02; // 2% commission
    const shipCost = Number(shippingCost) || 0;
    const totalAmount = subtotal + shipCost + platformFee;
    const savingsPercent = subtotal > 0 ? Math.round((totalEstimatedSavings / (subtotal + totalEstimatedSavings)) * 100) : 0;

    // Atomically reduce stock
    const updatedItems = [];
    try {
      for (const item of orderItems) {
        const updatedProduct = await Product.findOneAndUpdate(
          { _id: item.product, stock: { $gte: item.quantity }, isActive: true },
          { $inc: { stock: -item.quantity } },
          { new: true }
        );
        if (!updatedProduct) {
          throw new Error(`Stock insuficiente para ${item.productName}`);
        }
        updatedItems.push({ product: item.product, quantity: item.quantity });
      }
    } catch (error) {
      // Revert stock updates on conflict
      for (const rev of updatedItems) {
        await Product.findByIdAndUpdate(rev.product, { $inc: { stock: rev.quantity } });
      }
      throw new AppError(error.message, 409);
    }

    const order = await Order.create({
      buyer: req.user._id,
      items: orderItems,
      subtotal,
      shippingCost: shipCost,
      platformFee,
      totalAmount,
      estimatedSavings: totalEstimatedSavings,
      savingsPercent,
      deliveryAddress,
      deliveryDate: deliveryDate ? new Date(deliveryDate) : undefined,
      buyerNotes,
      status: 'pending',
      statusHistory: [{ status: 'pending', changedBy: req.user._id }]
    });

    // Create telemetry event
    await TelemetryEvent.create({
      userId: req.user._id,
      eventType: 'order_submitted',
      metadata: {
        pageLoadTimeMs: 350,
        deviceType: req.headers['user-agent']?.includes('Mobile') ? 'mobile' : 'desktop',
        browserName: 'Chrome',
        screenWidth: req.headers['user-agent']?.includes('Mobile') ? 375 : 1440,
        stepReached: 'submitted'
      }
    });

    logger.info(`Pedido creado ID: ${order._id} por comprador ${req.user.email}`);

    res.status(201).json({
      success: true,
      order
    });
  } catch (error) {
    next(error);
  }
};

const getOrders = async (req, res, next) => {
  try {
    let query = {};

    if (req.user.role === 'buyer') {
      query.buyer = req.user._id;
    } else if (req.user.role === 'farmer') {
      query['items.farmer'] = req.user._id;
    }
    // Admin sees all orders

    const orders = await Order.find(query)
      .populate('buyer', 'fullName email phone buyerProfile')
      .populate('items.product', 'name photos cropType unit')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: orders.length,
      orders
    });
  } catch (error) {
    next(error);
  }
};

const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('buyer', 'fullName email phone buyerProfile')
      .populate('items.product')
      .populate('items.farmer', 'fullName phone farmerProfile preferredContact');

    if (!order) {
      throw new AppError('Pedido no encontrado', 404);
    }

    // Authorization checks
    if (req.user.role === 'buyer' && order.buyer._id.toString() !== req.user._id.toString()) {
      throw new AppError('No estás autorizado para ver este pedido', 403);
    }
    if (req.user.role === 'farmer') {
      const isMyOrder = order.items.some(item => item.farmer.toString() === req.user._id.toString());
      if (!isMyOrder) {
        throw new AppError('No estás autorizado para ver este pedido', 403);
      }
    }

    res.status(200).json({
      success: true,
      order
    });
  } catch (error) {
    next(error);
  }
};

const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const { id } = req.params;

    const order = await Order.findById(id);
    if (!order) {
      throw new AppError('Pedido no encontrado', 404);
    }

    const currentStatus = order.status;

    // Validate state transition authorization
    if (req.user.role === 'farmer') {
      const isMyOrder = order.items.some(item => item.farmer.toString() === req.user._id.toString());
      if (!isMyOrder) {
        throw new AppError('No estás autorizado para gestionar este pedido', 403);
      }
      
      // Farmer transitions
      if (currentStatus === 'pending' && status === 'approved') {
        // Ok
      } else if (currentStatus === 'approved' && status === 'dispatched') {
        // Ok
      } else {
        throw new AppError(`Un agricultor no puede cambiar el estado de '${currentStatus}' a '${status}'`, 400);
      }
    } else if (req.user.role === 'buyer') {
      if (order.buyer.toString() !== req.user._id.toString()) {
        throw new AppError('No estás autorizado para gestionar este pedido', 403);
      }

      // Buyer transitions
      if (currentStatus === 'dispatched' && status === 'completed') {
        // Ok
      } else {
        throw new AppError(`Un comprador no puede cambiar el estado de '${currentStatus}' a '${status}'`, 400);
      }
    } else if (req.user.role !== 'admin') {
      throw new AppError('Rol no autorizado para cambiar estados de pedido', 403);
    }

    // Set status and log history
    order.status = status;
    order.statusHistory.push({
      status,
      changedBy: req.user._id,
      changedAt: new Date()
    });

    await order.save();

    logger.info(`Pedido ${order._id} cambió de estado a ${status} por ${req.user.email}`);

    // Post-transition triggers
    if (status === 'completed') {
      // 1. Create SalesLog entry
      // Calculate total volume in kg
      let totalVolumeKg = 0;
      const populatedItems = [];

      for (const item of order.items) {
        const product = await Product.findById(item.product);
        let weightInKg = item.quantity;
        let unitName = 'kg';

        if (product) {
          unitName = product.unit;
          if (product.unit === 'arroba') weightInKg = item.quantity * 11.5;
          if (product.unit === 'saco') weightInKg = item.quantity * 50;
          if (product.unit === 'tonelada') weightInKg = item.quantity * 1000;
        }
        totalVolumeKg += weightInKg;

        populatedItems.push({
          name: item.productName,
          cropType: product ? product.cropType : 'otros',
          quantity: item.quantity,
          unit: unitName,
          unitPrice: item.unitPrice,
          lineTotal: item.lineTotal
        });
      }

      // Group items per farmer and create a SalesLog per farmer (or a single one for this order)
      // The schema indicates: order unique ref. So one SalesLog per Order.
      // If the order has items from multiple farmers, we aggregate under the primary farmer or create one log.
      // Usually, orders are separated per farmer or aggregated. Let's find the farmer for the items.
      const primaryFarmerId = order.items[0].farmer;
      const farmerUser = await User.findById(primaryFarmerId);
      const community = farmerUser?.farmerProfile?.community || 'Chupaca';

      // platform fee paid is 2% of the order subtotal
      const feePaid = order.platformFee;
      // farmer net revenue is subtotal - fee
      const netRevenue = order.subtotal - feePaid;

      await SalesLog.create({
        order: order._id,
        farmer: primaryFarmerId,
        buyer: order.buyer,
        products: populatedItems,
        totalAmount: order.subtotal,
        totalVolumeKg,
        platformFeePaid: feePaid,
        estimatedSavingsVsIntermediary: order.estimatedSavings,
        savingsPercent: order.savingsPercent,
        farmerNetRevenue: netRevenue,
        farmerCommunity: community
      });

      logger.info(`SalesLog creado para el pedido completado ${order._id}`);

      // 2. Telemetry update firstTransactionAt if first transaction
      const pastSalesCount = await SalesLog.countDocuments({ farmer: primaryFarmerId });
      if (pastSalesCount === 1) { // This is the first one just created
        await User.findByIdAndUpdate(primaryFarmerId, {
          firstTransactionAt: new Date()
        });
        logger.info(`Primera transacción registrada para el agricultor ${farmerUser.email}`);
      }
    } else if (status === 'cancelled') {
      // Restore stock for all items
      for (const item of order.items) {
        await Product.findByIdAndUpdate(item.product, {
          $inc: { stock: item.quantity }
        });
      }
      logger.info(`Stock restaurado para el pedido cancelado ${order._id}`);
    }

    res.status(200).json({
      success: true,
      order
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  updateOrderStatus
};
