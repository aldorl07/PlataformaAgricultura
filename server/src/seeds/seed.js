require('dotenv').config({ path: path = require('path').join(__dirname, '../../.env') });
const mongoose = require('mongoose');
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const SalesLog = require('../models/SalesLog');
const MarketPrice = require('../models/MarketPrice');
const TelemetryEvent = require('../models/TelemetryEvent');
const connectDB = require('../config/db');
const logger = require('../utils/logger');

const seedData = async () => {
  try {
    logger.info('Iniciando proceso de siembra de base de datos...');

    // Clear existing data
    await User.deleteMany({});
    await Product.deleteMany({});
    await Order.deleteMany({});
    await SalesLog.deleteMany({});
    await MarketPrice.deleteMany({});
    await TelemetryEvent.deleteMany({});
    logger.info('Base de datos limpiada con éxito.');

    // 1. Create Admin User
    const admin = await User.create({
      email: 'admin@chupacadirecto.pe',
      password: 'password123', // Will be hashed automatically by pre-save hook
      role: 'admin',
      fullName: 'Administrador de Investigación UNCP',
      phone: '+51964123456',
      preferredContact: 'email'
    });
    logger.info('Admin creado.');

    // 2. Create 5 Farmer Users (Verified)
    const farmers = [];
    const communities = ['Ahuac', 'Chongos Bajo', 'Huachac', 'Tres de Diciembre', 'San Juan de Iscos'];
    const experience = [12, 8, 20, 15, 6];
    const crops = [
      ['papa', 'maiz', 'habas'],
      ['hortalizas', 'quinua', 'cebada'],
      ['papa', 'quinua', 'arveja'],
      ['maiz', 'hortalizas', 'habas'],
      ['papa', 'cebada', 'arveja']
    ];

    for (let i = 0; i < 5; i++) {
      const farmer = await User.create({
        email: `farmer${i+1}@chupacadirecto.pe`,
        password: 'password123',
        role: 'farmer',
        fullName: `Agricultor ${i+1} - Chupaca`,
        phone: `+5198765432${i}`,
        preferredContact: 'whatsapp',
        farmerProfile: {
          dni: `1234567${i}`,
          community: communities[i],
          plotCoordinates: { lat: -12.0621 + (i * 0.01), lng: -75.3123 - (i * 0.01) },
          experienceYears: experience[i],
          mainCrops: crops[i],
          isVerified: true,
          verifiedAt: new Date(),
          verifiedBy: admin._id
        },
        registrationStartedAt: new Date(Date.now() - (60 * 24 * 60 * 60 * 1000) + (i * 3600000)), // 60 days ago
        registrationCompletedAt: new Date(Date.now() - (60 * 24 * 60 * 60 * 1000) + (i * 3600000) + 15 * 60000) // 15 mins later
      });
      farmers.push(farmer);
    }
    logger.info('5 Agricultores creados y verificados.');

    // 3. Create 3 Buyer Users
    const buyers = [];
    const buyerTypes = ['wholesale_market', 'restaurant', 'retail'];
    const businessNames = ['Distribuidora Mayorista Huancayo', 'Restaurante El Campesino', 'Minimarket Los Andes'];

    for (let i = 0; i < 3; i++) {
      const buyer = await User.create({
        email: `buyer${i+1}@chupacadirecto.pe`,
        password: 'password123',
        role: 'buyer',
        fullName: `Comprador ${i+1} - Junín`,
        phone: `+5195512345${i}`,
        preferredContact: i === 0 ? 'call' : 'whatsapp',
        buyerProfile: {
          businessName: businessNames[i],
          ruc: `1012345678${i}`,
          businessType: buyerTypes[i],
          deliveryAddress: `Av. Giráldez ${123 + i * 200}, Huancayo`
        },
        registrationStartedAt: new Date(Date.now() - (45 * 24 * 60 * 60 * 1000)),
        registrationCompletedAt: new Date(Date.now() - (45 * 24 * 60 * 60 * 1000) + 8 * 60000)
      });
      buyers.push(buyer);
    }
    logger.info('3 Compradores creados.');

    // 4. Create 10 MarketPrice entries (Huancayo Wholesale Reference Prices)
    const cropReference = [
      { cropType: 'papa', cropName: 'Papa Blanca', price: 1.80 },
      { cropType: 'papa', cropName: 'Papa Yungay', price: 2.20 },
      { cropType: 'maiz', cropName: 'Maíz Choclo', price: 3.50 },
      { cropType: 'cebada', cropName: 'Cebada en Grano', price: 2.80 },
      { cropType: 'habas', cropName: 'Habas Verdes', price: 4.20 },
      { cropType: 'hortalizas', cropName: 'Zanahoria', price: 1.90 },
      { cropType: 'hortalizas', cropName: 'Espinaca', price: 3.00 },
      { cropType: 'quinua', cropName: 'Quinua Blanca', price: 8.50 },
      { cropType: 'arveja', cropName: 'Arveja Verde', price: 5.00 },
      { cropType: 'otros', cropName: 'Ajo Macho', price: 12.00 }
    ];

    const marketPrices = [];
    for (const ref of cropReference) {
      const mp = await MarketPrice.create({
        cropType: ref.cropType,
        cropName: ref.cropName,
        marketName: 'Mercado Mayorista de Huancayo',
        pricePerKg: ref.price,
        source: 'MIDAGRI',
        effectiveDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) // 2 days ago
      });
      marketPrices.push(mp);
    }
    logger.info('10 Precios referenciales de mercado (MIDAGRI) creados.');

    // 5. Create 15 Products (3 per farmer)
    const products = [];
    const productTemplates = [
      // Farmer 0 (Ahuac) - papa, maiz, habas
      { name: 'Papa Yungay Orgánica', cropType: 'papa', variety: 'Yungay', unit: 'kg', price: 1.35, stock: 500, desc: 'Papa Yungay cosechada de forma natural en los campos de Ahuac. Sin pesticidas químicos.' },
      { name: 'Maíz Blanco del Valle', cropType: 'maiz', variety: 'Blanco Urubamba', unit: 'saco', price: 95.00, stock: 30, desc: 'Sacos de maíz blanco seco de alta calidad, ideal para mote o harinas. Saco de 50kg.' },
      { name: 'Habas Verdes Frescas', cropType: 'habas', variety: 'Verde Chupaqueña', unit: 'kg', price: 3.20, stock: 200, desc: 'Habas verdes tiernas y grandes. Cosechadas a mano.' },

      // Farmer 1 (Chongos Bajo) - hortalizas, quinua, cebada
      { name: 'Zanahoria Dulce', cropType: 'hortalizas', variety: 'Chantenay', unit: 'kg', price: 1.40, stock: 350, desc: 'Zanahorias dulces y frescas. Muy nutritivas.' },
      { name: 'Quinua Real Orgánica', cropType: 'quinua', variety: 'Blanca de Juli', unit: 'kg', price: 6.50, stock: 150, desc: 'Quinua lavada y seleccionada lista para cocinar.' },
      { name: 'Cebada en Grano Selección', cropType: 'cebada', variety: 'Centenario', unit: 'saco', price: 75.00, stock: 20, desc: 'Cebada de grano entero limpia. Saco de 50kg.' },

      // Farmer 2 (Huachac) - papa, quinua, arveja
      { name: 'Papa Canchán', cropType: 'papa', variety: 'Canchán', unit: 'kg', price: 1.20, stock: 800, desc: 'Papa arenosa canchán, ideal para fritura y caldos.' },
      { name: 'Quinua Roja del Huaytapallana', cropType: 'quinua', variety: 'Pasankalla', unit: 'kg', price: 7.20, stock: 100, desc: 'Quinua roja con alto contenido de antioxidantes.' },
      { name: 'Arveja Verde Tierna', cropType: 'arveja', variety: 'Usui', unit: 'kg', price: 3.90, stock: 180, desc: 'Arvejas frescas dulces desvainadas manualmente.' },

      // Farmer 3 (Tres de Diciembre) - maiz, hortalizas, habas
      { name: 'Maíz Amiláceo Choclo', cropType: 'maiz', variety: 'Choclo Junín', unit: 'saco', price: 110.00, stock: 15, desc: 'Choclos frescos recién cosechados en Tres de Diciembre. Saco de 50kg.' },
      { name: 'Espinaca Hoja Ancha', cropType: 'hortalizas', variety: 'Viroflay', unit: 'kg', price: 2.10, stock: 120, desc: 'Espinaca fresca de hojas anchas y tiernas.' },
      { name: 'Habas Secas Selección', cropType: 'habas', variety: 'Seca de Primera', unit: 'kg', price: 4.80, stock: 150, desc: 'Habas secas ideales para tostados o guisos.' },

      // Farmer 4 (San Juan de Iscos) - papa, cebada, arveja
      { name: 'Papa Huamantanga', cropType: 'papa', variety: 'Huamantanga', unit: 'kg', price: 1.60, stock: 400, desc: 'La reina de las papas arenosas, directo de San Juan de Iscos.' },
      { name: 'Cebada Pelada Calidad A', cropType: 'cebada', variety: 'Pelada', unit: 'kg', price: 2.10, stock: 250, desc: 'Cebada pelada lista para sopa de morón.' },
      { name: 'Arveja Seca Entera', cropType: 'arveja', variety: 'Seca', unit: 'kg', price: 3.50, stock: 300, desc: 'Arvejas secas ideales para sopas y purés.' }
    ];

    const photos = [
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=60', // Potato
      'https://images.unsplash.com/photo-1551754625-70c2a047029e?w=500&auto=format&fit=crop&q=60', // Corn
      'https://images.unsplash.com/photo-1595855759920-86582396756a?w=500&auto=format&fit=crop&q=60', // Broad beans
      'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=60', // Carrots
      'https://images.unsplash.com/photo-1506368249639-73a05d6f6488?w=500&auto=format&fit=crop&q=60', // Quinoa
      'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500&auto=format&fit=crop&q=60'  // Barley
    ];

    for (let i = 0; i < productTemplates.length; i++) {
      const farmerIndex = Math.floor(i / 3);
      const template = productTemplates[i];
      
      let photoUrl = photos[0];
      if (template.cropType === 'maiz') photoUrl = photos[1];
      if (template.cropType === 'habas') photoUrl = photos[2];
      if (template.cropType === 'hortalizas') photoUrl = photos[3];
      if (template.cropType === 'quinua') photoUrl = photos[4];
      if (template.cropType === 'cebada') photoUrl = photos[5];

      const product = await Product.create({
        farmer: farmers[farmerIndex]._id,
        name: template.name,
        cropType: template.cropType,
        variety: template.variety,
        description: template.desc,
        unit: template.unit,
        pricePerUnit: template.price,
        stock: template.stock,
        photos: [photoUrl],
        harvestDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
        isActive: true
      });
      products.push(product);
    }
    logger.info('15 Productos creados para los agricultores.');

    // 6. Create 3 completed Orders with corresponding SalesLog entries
    for (let i = 0; i < 3; i++) {
      const buyer = buyers[i];
      const product = products[i * 3]; // Different products for each order
      const farmer = farmers[i];

      const quantity = 100 + i * 50; // 100kg, 150kg, 200kg
      const itemSubtotal = product.pricePerUnit * quantity;
      const shippingCost = 80 + i * 20;
      const platformFee = itemSubtotal * 0.02;
      const totalAmount = itemSubtotal + shippingCost + platformFee;

      // Calculate weight in kg
      let weightInKg = quantity;
      if (product.unit === 'arroba') weightInKg = quantity * 11.5;
      if (product.unit === 'saco') weightInKg = quantity * 50;
      if (product.unit === 'tonelada') weightInKg = quantity * 1000;

      // Calculate savings compared to market price
      const marketPrice = await MarketPrice.findOne({ cropType: product.cropType }).sort({ effectiveDate: -1 });
      let savings = 0;
      if (marketPrice) {
        let prodPricePerKg = product.pricePerUnit;
        if (product.unit === 'arroba') prodPricePerKg = product.pricePerUnit / 11.5;
        if (product.unit === 'saco') prodPricePerKg = product.pricePerUnit / 50;
        if (product.unit === 'tonelada') prodPricePerKg = product.pricePerUnit / 1000;

        savings = (marketPrice.pricePerKg - prodPricePerKg) * weightInKg;
      } else {
        savings = itemSubtotal * 0.25;
      }
      
      const savingsPercent = Math.round((savings / (itemSubtotal + savings)) * 100);

      // Create Order in 'completed' state
      const order = await Order.create({
        buyer: buyer._id,
        items: [{
          product: product._id,
          farmer: farmer._id,
          productName: product.name,
          quantity,
          unitPrice: product.pricePerUnit,
          lineTotal: itemSubtotal
        }],
        subtotal: itemSubtotal,
        shippingCost,
        platformFee,
        totalAmount,
        estimatedSavings: savings,
        savingsPercent,
        deliveryAddress: buyer.buyerProfile.deliveryAddress,
        deliveryDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 days ago
        buyerNotes: 'Entregar por la mañana, gracias.',
        status: 'completed',
        statusHistory: [
          { status: 'pending', changedBy: buyer._id, changedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
          { status: 'approved', changedBy: farmer._id, changedAt: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000) },
          { status: 'dispatched', changedBy: farmer._id, changedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
          { status: 'completed', changedBy: buyer._id, changedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) }
        ],
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      });

      // Update farmer firstTransactionAt
      await User.findByIdAndUpdate(farmer._id, {
        firstTransactionAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000)
      });

      // Deduct stock
      await Product.findByIdAndUpdate(product._id, { $inc: { stock: -quantity } });

      // Create SalesLog
      await SalesLog.create({
        order: order._id,
        transactionDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        farmer: farmer._id,
        buyer: buyer._id,
        products: [{
          name: product.name,
          cropType: product.cropType,
          quantity,
          unit: product.unit,
          unitPrice: product.pricePerUnit,
          lineTotal: itemSubtotal
        }],
        totalAmount: itemSubtotal,
        totalVolumeKg: weightInKg,
        platformFeePaid: platformFee,
        estimatedSavingsVsIntermediary: savings,
        savingsPercent,
        farmerNetRevenue: itemSubtotal - platformFee,
        farmerCommunity: farmer.farmerProfile.community
      });
    }
    logger.info('3 Pedidos completados y sus respectivos SalesLog creados.');

    // 7. Seed Telemetry events for analytics graphs (funnels, load times)
    const eventTypes = [
      { type: 'page_load', count: 120, meta: () => ({ pageLoadTimeMs: Math.floor(Math.random() * 800) + 1200, deviceType: Math.random() > 0.3 ? 'mobile' : 'desktop' }) },
      { type: 'registration_start', count: 42, meta: () => ({ stepReached: '1' }) },
      { type: 'registration_complete', count: 32, meta: () => ({ stepReached: 'completed' }) },
      { type: 'first_product_publish', count: 20, meta: () => ({}) },
      { type: 'quote_simulation_start', count: 50, meta: () => ({}) },
      { type: 'order_submitted', count: 12, meta: () => ({}) }
    ];

    for (const group of eventTypes) {
      for (let j = 0; j < group.count; j++) {
        await TelemetryEvent.create({
          eventType: group.type,
          metadata: group.meta(),
          timestamp: new Date(Date.now() - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000) // Random day in last 30 days
        });
      }
    }
    logger.info('Eventos de telemetría de prueba creados.');

    logger.info('Proceso de siembra finalizado exitosamente.');
    process.exit(0);
  } catch (error) {
    logger.error(`Error en la siembra de base de datos: ${error.message}`);
    process.exit(1);
  }
};

// Check if run directly
if (require.main === module) {
  connectDB().then(seedData);
}
