// Archivo: lib/presentation/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:modelo_venta/presentation/screens/admin/backup_dashboard.dart';
import '../../theme/app_colors.dart';
import 'product_admin_screen.dart';
import 'inventory_admin_screen.dart';
import 'reports_screen.dart';
import 'user_admin_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'business_settings_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const ProductAdminScreen();
      case 1:
        return const InventoryAdminScreen();
      case 2:
        // Placeholder para Reportes
        return const ReportsScreen();
      case 3:
        return const UserAdminScreen();
      case 4:
        return const BackupUtils();

      default:
        return const ProductAdminScreen();
    }
  }

  Widget _sideButton({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected
              ? AppColors.textInverted
              : Colors.transparent,
          foregroundColor: selected
              ? AppColors.primary
              : AppColors.textInverted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        ),
        onPressed: () => setState(() => _selectedIndex = index),
        icon: Icon(icon, size: 18),
        label: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 160,
            color: AppColors.primary,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Image(
                    image: AssetImage('lib/assets/images/app_icon.png'),
                    width: 50,
                    height: 50,
                  ),
                ),
                // Opciones como botones
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _sideButton(
                          label: 'Productos',
                          icon: Icons.inventory_2_outlined,
                          index: 0,
                        ),
                        const SizedBox(height: 8),
                        _sideButton(
                          label: 'Inventario',
                          icon: Icons.warehouse_outlined,
                          index: 1,
                        ),
                        const SizedBox(height: 8),
                        _sideButton(
                          label: 'Reportes',
                          icon: Icons.assessment_outlined,
                          index: 2,
                        ),
                        const SizedBox(height: 8),
                        _sideButton(
                          label: 'Usuarios',
                          icon: Icons.people_outline,
                          index: 3,
                        ),
                        const SizedBox(height: 8),
                        _sideButton(
                          label: 'Copia de seguridad',
                          icon: Icons.backup,
                          index: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // Área inferior: ajustes (solo admin) y logout
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(
                        color: AppColors.secondary,
                        indent: 12,
                        endIndent: 12,
                      ),
                      if (authProvider.isAdmin)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.textInverted,
                              side: const BorderSide(color: Colors.transparent),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BusinessSettingsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings, size: 18),
                            label: const Text('Ajustes'),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.accentCta,
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          onPressed: () {
                            authProvider.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Cerrar sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: AppColors.background,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}
