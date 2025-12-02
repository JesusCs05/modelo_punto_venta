// Archivo: lib/presentation/screens/admin/reports_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// Importa aquí los widgets de cada reporte
import 'reports/session_turns_report.dart';
import 'reports/sales_report.dart';
import 'reports/inventory_report.dart';
import 'reports/packaging_report.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un DefaultTabController para manejar las pestañas
    return DefaultTabController(
      length: 4, // 4 reportes: Turnos, Ventas, Inventario, Envases
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
                // Hacer que el indicador ocupe el ancho de la pestaña y darle
                // más padding horizontal para que la 'pill' morada sea más ancha.
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Aumentar tamaño/espaciado y estilo de las etiquetas para
                // que el tab enfocado (morado) se vea más grande.
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelColor: AppColors.textInverted,
                unselectedLabelColor: AppColors.primary,
                // Más padding vertical para mayor altura, y padding del indicador
                // horizontal amplio para ampliar la 'pill' morada.
                labelPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                indicatorPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 32,
                ),
                tabs: const [
                  Tab(text: 'Turnos', icon: Icon(Icons.schedule, size: 28)),
                  Tab(
                    text: 'Ventas',
                    icon: Icon(Icons.monetization_on_sharp, size: 28),
                  ),
                  Tab(
                    text: 'Inventario',
                    icon: Icon(Icons.inventory, size: 28),
                  ),
                  Tab(text: 'Envases', icon: Icon(Icons.recycling, size: 28)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Contenido de las Pestañas
            Expanded(
              child: TabBarView(
                children: [
                  // Widgets de reporte en el orden: Turnos, Ventas, Inventario, Envases
                  const SessionTurnsReport(),
                  const SalesReport(),
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
