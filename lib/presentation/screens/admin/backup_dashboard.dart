import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/backup_utils.dart';

class BackupUtils extends StatefulWidget {
  const BackupUtils({Key? key}) : super(key: key);

  @override
  State<BackupUtils> createState() => _BackupUtilsState();
}

class _BackupUtilsState extends State<BackupUtils> {
  Future<void> _doExport(BuildContext context) async {
    try {
      final dest = await exportDatabase(context);
      if (dest != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exportado a: $dest')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exportando: ${e.toString()}'),
          backgroundColor: AppColors.accentDanger,
        ),
      );
    }
  }

  Future<void> _doImport(BuildContext context) async {
    try {
      final imported = await importDatabase(context);
      if (imported != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Importación completada. Reinicia la app si es necesario.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importando: ${e.toString()}'),
          backgroundColor: AppColors.accentDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.paletteLightGray,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Copia de seguridad',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 160,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Exportar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paletteGold,
                      foregroundColor: AppColors.textInverted,
                    ),
                    onPressed: () => _doExport(context),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Importar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paletteNavy,
                      foregroundColor: AppColors.textInverted,
                    ),
                    onPressed: () => _doImport(context),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Ver registros'),
                    onPressed: () {
                      // placeholder: abrir pantalla de logs o detalles si deseas
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de registros pendiente.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Exporta la base de datos a un archivo o importa desde uno existente.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
// class _BackupUtilsState extends State<BackupUtils> {
//   Future<void> _showBackupOptions() async {
//     await showDialog<void>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Copia de seguridad'),
//         content: const Text('Exportar o importar la base de datos.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _export();
//             },
//             child: const Text('Exportar'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _import();
//             },
//             child: const Text('Importar'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancelar'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _export() async {
//     try {
//       final dest = await exportDatabase(context);
//       if (dest != null) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Exportado a: $dest')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error exportando: ${e.toString()}'),
//           backgroundColor: AppColors.accentDanger,
//         ),
//       );
//     }
//   }

//   Future<void> _import() async {
//     try {
//       final imported = await importDatabase(context);
//       if (imported != null) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Importación completada. Reinicia la app si es necesario.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error importando: ${e.toString()}'),
//           backgroundColor: AppColors.accentDanger,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Tooltip(
//       message: 'Copia de seguridad (Exportar/Importar)',
//       child: IconButton(
//         icon: const Icon(Icons.backup),
//         color: AppColors.textInverted,
//         onPressed: _showBackupOptions,
//       ),
//     );
//   }
// }
