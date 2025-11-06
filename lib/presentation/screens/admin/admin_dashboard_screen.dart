// Archivo: lib/presentation/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'product_admin_screen.dart';
import 'inventory_admin_screen.dart';
import 'reports_screen.dart';
import 'user_admin_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import '../../utils/backup_utils.dart';

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
      default:
        return const ProductAdminScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.primary,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Icon(
                Icons.store_mall_directory,
                color: AppColors.textInverted,
                size: 40,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Productos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warehouse_outlined),
                selectedIcon: Icon(Icons.warehouse),
                label: Text('Inventario'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Reportes'), // Index 2
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Usuarios'), // Index 3
              ),
            ],
            // Estilo del texto del menú
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.textInverted,
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Backup button
                      Tooltip(
                        message: 'Copia de seguridad (Exportar/Importar)',
                        child: IconButton(
                          icon: const Icon(Icons.backup),
                          color: AppColors.textInverted,
                          onPressed: () async {
                            // Abrir diálogo con opciones
                            showDialog<void>(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text('Copia de seguridad'),
                                  content: const Text(
                                    'Exportar o importar la base de datos.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop();
                                        try {
                                          final dest = await exportDatabase(
                                            context,
                                          );
                                          if (dest != null) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Exportado a: $dest',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error exportando: ${e.toString()}',
                                              ),
                                              backgroundColor:
                                                  AppColors.accentDanger,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Exportar'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop();
                                        try {
                                          final imported = await importDatabase(
                                            context,
                                          );
                                          if (imported != null) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Importación completada. Reinicia la app si es necesario.',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error importando: ${e.toString()}',
                                              ),
                                              backgroundColor:
                                                  AppColors.accentDanger,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Importar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      Tooltip(
                        message: 'Cerrar sesión',
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.accentDanger,
                          ),
                          onPressed: () {
                            // 1. Obtener el AuthProvider
                            final authProvider = context.read<AuthProvider>();

                            // 2. Llamar a la función de logout
                            authProvider.logout();

                            // 3. Regresar a la pantalla de Login
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- FIX 1 (Línea ~76) ---
            unselectedLabelTextStyle: TextStyle(
              color: AppColors.textInverted.withAlpha(178),
            ),

            selectedIconTheme: const IconThemeData(
              color: AppColors.textInverted,
            ),

            // --- FIX 2 (Línea ~80) ---
            unselectedIconTheme: IconThemeData(
              color: AppColors.textInverted.withAlpha(178),
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
