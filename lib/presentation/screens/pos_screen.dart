// Archivo: lib/presentation/screens/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_colors.dart';
import '../widgets/pos/catalog_widget.dart';
import '../widgets/pos/cart_widget.dart';
import '../services/window_close_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  @override
  void initState() {
    super.initState();
    // Esta lógica es ESENCIAL y está CORRECTA
    WindowCloseService.posScreenActive = true;
    debugPrint('PosScreen active set to true');
    // Evitar que el sistema cierre la ventana mientras estamos en POS
    // (seteamos preventClose proactivamente para prevenir la carrera
    // entre WM_CLOSE nativo y nuestro handler Dart).
    windowManager.setPreventClose(true).catchError((e) {
      debugPrint('Failed to setPreventClose(true): $e');
    });
  }

  @override
  void dispose() {
    // Esta lógica es ESENCIAL y está CORRECTA
    WindowCloseService.posScreenActive = false;
    debugPrint('PosScreen active set to false');
    // Liberar el bloqueo de cierre cuando salimos de POS
    windowManager.setPreventClose(false).catchError((e) {
      debugPrint('Failed to setPreventClose(false): $e');
    });
    super.dispose();
  }

  // --- 1. ELIMINAR EL MÉTODO _mostrarDialogoConfirmarSalida ---
  // (La lógica ahora vive en main.dart)

  @override
  Widget build(BuildContext context) {
    // --- 2. ELIMINAR EL WIDGET PopScope ---
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 2, child: CartWidget()),
          Expanded(flex: 3, child: CatalogWidget()),
        ],
      ),
    );
  }
}
