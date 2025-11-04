// Archivo: lib/presentation/screens/admin/reports_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// --- Importa aquí los widgets de cada reporte (los crearemos después) ---
import 'reports/sales_report.dart';
import 'reports/top_products_report.dart';
import 'reports/inventory_report.dart';
import 'reports/packaging_report.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un DefaultTabController para manejar las pestañas
    return DefaultTabController(
      length: 4, // 4 reportes
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Título Principal
            const Text(
              'Módulo de Reportes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // 2. Barra de Pestañas
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: AppColors.textInverted,
                unselectedLabelColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Ventas', icon: Icon(Icons.monetization_on_sharp)),
                  Tab(text: 'Más Vendidos', icon: Icon(Icons.star)),
                  Tab(text: 'Inventario', icon: Icon(Icons.inventory)),
                  Tab(text: 'Envases', icon: Icon(Icons.recycling)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Contenido de las Pestañas
            Expanded(
              child: TabBarView(
                children: [
                  // Aquí irán los 4 widgets de reporte
                  // Por ahora, usamos Placeholders:
                  const SalesReport(),
                  const TopProductsReport(),
                  const InventoryReport(),
                  const PackagingReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
