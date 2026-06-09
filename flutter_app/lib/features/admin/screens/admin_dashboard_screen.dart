import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/service_locator.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/sales_log_model.dart';
import '../../auth/models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _researchData;
  List<SalesLogModel> _salesLogs = [];
  List<UserModel> _farmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ServiceLocator.firestoreService.getResearchDashboardData();
      final logs = await ServiceLocator.firestoreService.getSalesLogs();
      final farmers = await ServiceLocator.firestoreService.getFarmers();
      
      setState(() {
        _researchData = data;
        _salesLogs = logs;
        _farmers = farmers;
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _toggleFarmerVerification(UserModel farmer, bool val) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await ServiceLocator.firestoreService.updateFarmerVerification(farmer.id, val, auth.currentUser!.id);
    await _loadDashboardData(); // reload
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Productor verificado con éxito' : 'Verificación retirada'),
          backgroundColor: AppColors.primaryLight,
        ),
      );
    }
  }

  Future<void> _exportSPSSCSV() async {
    final buffer = StringBuffer();
    // Headers matching SPSS Consistency Matrix variables
    buffer.writeln('TransactionID,Timestamp,FarmerID,FarmerCommunity,BuyerID,TotalVolumeKg,TotalAmount,PlatformFee,SavingsVsIntermediary,SavingsPercent,FarmerNetRevenue');
    
    for (final log in _salesLogs) {
      buffer.writeln(
        '${log.id},${log.transactionDate.toIso8601String()},${log.farmerId},${log.farmerCommunity},${log.buyerId},${log.totalVolumeKg},${log.totalAmount},${log.platformFeePaid},${log.estimatedSavingsVsIntermediary},${log.savingsPercent},${log.farmerNetRevenue}'
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/chupaca_directo_spss_dataset.csv');
      await file.writeAsString(buffer.toString());

      // Share dataset
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exportación de datos de investigación Chupaca Directo - UNCP 2026',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar datos: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force dark mode context for research analytics panel
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔬 Dashboard de Investigación Científica'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Exportar Dataset CSV (SPSS)',
              onPressed: _salesLogs.isNotEmpty ? _exportSPSSCSV : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header text
                    _buildScientificHeader(),
                    const SizedBox(height: 32),

                    // Row 1: X Variable (Independent - Accessibility, Usability, Reach)
                    _buildIndependentVariablesRow(),
                    const SizedBox(height: 32),

                    // Map & District Density Section
                    _buildMapAndDensitySection(),
                    const SizedBox(height: 32),

                    // Row 2: Y Variable (Dependent - Profitability, Marketing Costs, Margins)
                    _buildDependentVariablesRow(),
                    const SizedBox(height: 32),

                    // Row 3: Producer Verification Panel (RF-03)
                    _buildVerificationPanel(),
                    const SizedBox(height: 32),

                    // Row 4: Sales Logs Immutable Viewer (RF-10)
                    _buildSalesLogGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScientificHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISEÑO METODOLÓGICO: PRE-EXPERIMENTAL (PRE/POST TEST) · N = 30 PRODUCTORES',
            style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitoreo en tiempo real de la hipótesis: "La implementación de una plataforma de comercio electrónico directo incrementa significativamente el margen neto y reduce los costos de comercialización de los agricultores de Chupaca, Junín - 2026."',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const Divider(height: 20, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Análisis Estadístico: T-Student para muestras emparejadas', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ElevatedButton.icon(
                onPressed: _exportSPSSCSV,
                icon: const Icon(Icons.table_view_outlined, size: 16),
                label: const Text('Descargar Matriz Consistencia (CSV)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIndependentVariablesRow() {
    final x1 = _researchData?['X1_accessibility'] ?? {};
    final x2 = _researchData?['X2_usability'] ?? {};
    final x3 = _researchData?['X3_marketReach'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VARIABLE INDEPENDIENTE (X): Plataforma Comercio Directo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            // X1: Accessibility
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('X1: Accesibilidad Móvil', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Carga Promedio: ${x1['avgLoadTime']}s', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 4),
                    Text('Tráfico Móvil (Rural): ${x1['mobilePercent']}%', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Disp. Testeados: ${x1['deviceCompatibility']} modelos', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            // X2: Usability
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('X2: Usabilidad / Adopción', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Abandono Registro: ${x2['registrationAbandonRate']}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    const SizedBox(height: 4),
                    Text('Tiempo 1era Transacción: ${x2['avgFirstTransactionTime']} min', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Sesiones Activas: ${x2['sessionsCount']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            // X3: Reach
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('X3: Alcance de Mercado', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Productores: ${x3['totalFarmers']} (Reg) / ${x3['verifiedFarmers']} (Verif)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 4),
                    Text('Compradores: ${x3['totalBuyers']}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Cobertura: ${x3['districtsWithFarmers']} distritos de 9', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapAndDensitySection() {
    final reach = _researchData?['X3_marketReach'] ?? {};
    final densities = reach['farmersPerDistrict'] as Map? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CustomPainter Heatmap
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Text(
                    'Mapa de Densidad de Productores - Chupaca',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: CustomPaint(
                      painter: DistrictMapPainter(densities: Map<String, int>.from(densities)),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Districts list density details
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Densidad por Distritos', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...AppConstants.communities.map((c) {
                    final count = densities[c] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c, style: const TextStyle(fontSize: 12)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: count > 0 ? AppColors.primaryLight : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$count prod.', style: TextStyle(fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDependentVariablesRow() {
    final y1 = _researchData?['Y1_salesRevenue'] ?? {};
    final y2 = _researchData?['Y2_marketingCosts'] ?? {};
    final y3 = _researchData?['Y3_profitMargins'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VARIABLE DEPENDIENTE (Y): Rentabilidad y Costos de Comercialización',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            // Y1: Sales Revenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Y1: Volumen de Ventas', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Total Acumulado: S/. ${y1['totalSales'] != null ? y1['totalSales'].toStringAsFixed(2) : "0.00"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 4),
                    Text('Transacciones: ${y1['transactionCount']}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Ingreso Promedio Tx: S/. ${y1['avgRevenuePerTransaction'] != null ? y1['avgRevenuePerTransaction'].toStringAsFixed(0) : "0"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            // Y2: Intermediation costs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Y2: Costos de Comercialización', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Intermediación Saved: ${y2['savingsPercent']?.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 4),
                    Text('Ahorro Total: S/. ${y2['totalSavingsGenerated'] != null ? y2['totalSavingsGenerated'].toStringAsFixed(0) : "0"}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Comisión Media Cobrada: S/. ${y2['avgPlatformCostPerTx'] != null ? y2['avgPlatformCostPerTx'].toStringAsFixed(1) : "0"} (2%)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            // Y3: Profit margins
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Y3: Márgenes de Ganancia', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Margen Promedio: ${y3['avgNetMarginPerFarmer']?.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 4),
                    Text('Comparativa: Pre (${y3['preTestAvgMargin']}%) vs Post (${y3['postTestAvgMargin']?.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Relación Ingreso/Costo: ${y3['incomeToTotalCostRatio']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Panel de Verificación de Productores (RF-03)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text('${_farmers.length} productores registrados', style: const TextStyle(color: AppColors.primaryLight, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('DNI')),
                  DataColumn(label: Text('Comunidad')),
                  DataColumn(label: Text('Experiencia')),
                  DataColumn(label: Text('Estado de Verificación')),
                ],
                rows: _farmers.map((farmer) {
                  final isVerified = farmer.farmerProfile?.isVerified ?? false;
                  return DataRow(
                    cells: [
                      DataCell(Text(farmer.fullName)),
                      DataCell(Text(farmer.farmerProfile?.dni ?? '')),
                      DataCell(Text(farmer.farmerProfile?.community ?? '')),
                      DataCell(Text('${farmer.farmerProfile?.experienceYears ?? 0} años')),
                      DataCell(
                        Switch(
                          value: isVerified,
                          activeThumbColor: AppColors.primaryLight,
                          onChanged: (val) => _toggleFarmerVerification(farmer, val),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesLogGrid() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registro de Ventas e Instrumento Inmutable (RF-10)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Este registro no puede ser editado ni eliminado por ningún rol', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share, size: 14),
                  label: const Text('Exportar SPSS'),
                  onPressed: _exportSPSSCSV,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _salesLogs.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No hay registros de transacciones consolidadas.'),
                  ))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID Transacción')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Productor')),
                        DataColumn(label: Text('Comunidad')),
                        DataColumn(label: Text('Monto Total')),
                        DataColumn(label: Text('Volumen (kg)')),
                        DataColumn(label: Text('Ahorro vs Interm.')),
                      ],
                      rows: _salesLogs.map((log) {
                        return DataRow(
                          cells: [
                            DataCell(Text('#${log.id.substring(0, 8)}')),
                            DataCell(Text(DateFormat('dd/MM/yyyy').format(log.transactionDate))),
                            DataCell(Text(log.farmerId)),
                            DataCell(Text(log.farmerCommunity)),
                            DataCell(Text('S/. ${log.totalAmount.toStringAsFixed(2)}')),
                            DataCell(Text('${log.totalVolumeKg.toInt()} kg')),
                            DataCell(Text('${log.savingsPercent.toStringAsFixed(0)}%')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DistrictMapPainter extends CustomPainter {
  final Map<String, int> densities;

  DistrictMapPainter({required this.densities});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 1.5;

    // We draw stylized districts in a schematic grid layout representing the Chupaca district topology.
    // Districts: 
    // Top: Yanacancha, San Juan de Jarpa, Huachac
    // Mid: Ahuac, Chupaca, Huamancaca Chico
    // Bot: Tres de Diciembre, San Juan de Iscos, Chongos Bajo

    final w = size.width / 3;
    final h = size.height / 3;

    final layout = [
      ['Yanacancha', 'San Juan de Jarpa', 'Huachac'],
      ['Ahuac', 'Chupaca', 'Huamancaca Chico'],
      ['Tres de Diciembre', 'San Juan de Iscos', 'Chongos Bajo'],
    ];

    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        final district = layout[y][x];
        final count = densities[district] ?? 0;
        
        // Define color based on density counts
        if (count > 2) {
          paint.color = AppColors.primaryDark;
        } else if (count > 0) {
          paint.color = AppColors.primaryLight.withValues(alpha: 0.6);
        } else {
          paint.color = const Color(0xFF2C2C2C);
        }

        final rect = Rect.fromLTWH(x * w + 4, y * h + 4, w - 8, h - 8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

        // Text Drawing
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${district.substring(0, 6)}.\n($count)',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(maxWidth: w - 16);
        textPainter.paint(
          canvas,
          Offset(x * w + w / 2 - textPainter.width / 2, y * h + h / 2 - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
