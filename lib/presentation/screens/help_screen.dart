// Archivo: lib/presentation/screens/help_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda - Punto de Venta'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverted,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: AppColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ilustración / imagen superior
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Image.asset(
                        'lib/assets/images/help/pos.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.help_outline,
                          size: 96,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const Text(
                    'Guía rápida - Punto de Venta',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta pantalla resume las acciones y atajos más importantes para operar el POS.',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  // Secciones plegables
                  ExpansionTile(
                    leading: Icon(Icons.keyboard, color: AppColors.primary),
                    title: const Text('Atajos y acciones principales'),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Añadir producto'),
                        subtitle: const Text(
                          'Haz clic en el producto del catálogo.',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.exposure_plus_1),
                        title: const Text('Incrementar cantidad'),
                        subtitle: const Text('Tecla +, Shift + + o PageUp.'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.exposure_minus_1),
                        title: const Text('Disminuir cantidad'),
                        subtitle: const Text('Tecla - o PageDown.'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.payment),
                        title: const Text('Cobrar'),
                        subtitle: const Text('Presiona F1 o Enter.'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.cancel),
                        title: const Text('Cancelar venta'),
                        subtitle: const Text('Presiona Esc.'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  ExpansionTile(
                    leading: Icon(Icons.lightbulb, color: AppColors.primary),
                    title: const Text('Consejos'),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shopping_cart_outlined),
                        title: const Text('Editar en carrito'),
                        subtitle: const Text(
                          'Selecciona un producto en el carrito para editar su cantidad.',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.search),
                        title: const Text('Buscar productos'),
                        subtitle: const Text(
                          'Usa el buscador del catálogo para encontrar productos rápidamente.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  ExpansionTile(
                    leading: Icon(Icons.info_outline, color: AppColors.primary),
                    title: const Text('Más información'),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.support_agent),
                        title: const Text('Soporte'),
                        subtitle: const Text(
                          'Contacta al equipo de soporte para ayuda adicional.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Pulsa la flecha arriba a la izquierda para volver.',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
