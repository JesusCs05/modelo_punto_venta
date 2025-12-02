// Archivo: lib/presentation/widgets/pos/modal_confirmar_envase.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Define el resultado de la selección del modal.
enum ConfirmacionEnvaseResultado { siTraeEnvase, noTraeEnvase, cancelado }

/// Muestra el Pop-up para confirmar si el cliente trae el envase[cite: 186].
/// Retorna un [ConfirmacionEnvaseResultado]
Future<ConfirmacionEnvaseResultado?> mostrarModalConfirmarEnvase(
  BuildContext context,
  String nombreProducto,
) {
  return showDialog<ConfirmacionEnvaseResultado>(
    context: context,
    barrierDismissible: false, // No se puede cerrar tocando fuera
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        // Tarjeta del Modal: Fondo #FFFFFF (Blanco) [cite: 189]
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.recycling, color: AppColors.primary, size: 30),
            SizedBox(width: 12),
            Text(
              'Producto Retornable',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        // Texto: "¿El cliente entregó el envase retornable?" [cite: 190]
        content: Text(
          '¿El cliente entregó el envase vacío para "$nombreProducto"?',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          // Colocar un único contenedor que ocupe todo el ancho disponible
          // y apile los botones verticalmente, centrados.
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildModalButton(
                  context: dialogContext,
                  label: 'SÍ (Solo Líquido)',
                  backgroundColor: AppColors.primary,
                  result: ConfirmacionEnvaseResultado.siTraeEnvase,
                ),
                const SizedBox(height: 12),
                _buildModalButton(
                  context: dialogContext,
                  label: 'NO (Cobrar Envase)',
                  backgroundColor: AppColors.accentCta,
                  result: ConfirmacionEnvaseResultado.noTraeEnvase,
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// Helper para crear los botones del modal
Widget _buildModalButton({
  required BuildContext context,
  required String label,
  required Color backgroundColor,
  required ConfirmacionEnvaseResultado result,
}) {
  return SizedBox(
    height: 60,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: AppColors.textInverted, // #FFFFFF (Blanco)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        Navigator.of(context).pop(result);
      },
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
