// Archivo: lib/presentation/screens/admin/help_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminHelpScreen extends StatelessWidget {
  const AdminHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ilustración superior (fallback a icono si no existe)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.asset(
                      'lib/assets/images/help/reportes.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.admin_panel_settings,
                        size: 92,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const Text(
                  'Guía rápida del Administrador - POS',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este apartado resume las funcionalidades más importantes que debes conocer para administrar y operar el Punto de Venta (POS).',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),

                ExpansionTile(
                  leading: Icon(Icons.person, color: AppColors.primary),
                  title: const Text('Inicio de sesión y roles'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Usa un usuario con rol "Administrador" para acceder a esta sección.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Los permisos controlan el acceso a ajustes, usuarios y reportes.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(Icons.point_of_sale, color: AppColors.primary),
                  title: const Text('Ventas (POS)'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Abrir la pantalla de ventas desde la sección principal de la app.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Selecciona productos por código de barras o buscándolos por nombre.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Aplica cantidades, descuentos y formas de pago antes de finalizar.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Al completar una venta se genera un comprobante y se actualiza el inventario.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Productos'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Crear o editar productos desde "Productos" en el panel de administración.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Campos claves: SKU, nombre, precio y stock inicial.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Usa promociones y precios especiales desde el formulario de producto.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(
                    Icons.warehouse_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Inventario'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Registra entradas y salidas para mantener el stock actualizado.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Consulta movimientos para auditar cambios y detectar discrepancias.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(
                    Icons.assessment_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Reportes'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Genera reportes de ventas, productos y movimientos desde "Reportes".',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Exporta o revisa datos periódicamente para decidir reabastecimientos.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(Icons.security, color: AppColors.primary),
                  title: const Text('Usuarios y seguridad'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Crea cuentas para empleados con permisos limitados cuando corresponda.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'No elimines al administrador principal si es la cuenta por defecto.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(Icons.backup, color: AppColors.primary),
                  title: const Text('Copia de seguridad'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Realiza copias periódicas para evitar pérdida de datos.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Antes de cambios masivos (importaciones, ajustes en lote) haz un backup.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(Icons.checklist, color: AppColors.primary),
                  title: const Text('Buenas prácticas'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Revisa inventario al inicio y cierre del día.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Capacita al personal en el uso del POS y control de efectivo.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Registra notas en movimientos excepcionales para auditoría.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(
                    Icons.build_circle_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Solución de problemas comunes'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Venta no se completa: verifica conexión y saldo del cliente/pago.',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Stock incorrecto: revisa movimientos recientes y comparación física.',
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  leading: Icon(Icons.support_agent, color: AppColors.primary),
                  title: const Text('Contacto y soporte'),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: const [
                    ListTile(
                      title: Text(
                        'Para ayuda adicional, contacta al equipo de soporte o revisa la documentación del proyecto.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
