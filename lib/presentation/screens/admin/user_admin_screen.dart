  // Archivo: lib/presentation/screens/admin/user_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
import '../../../data/collections/usuario.dart';
import '../../theme/app_colors.dart';
import 'user_form_modal.dart'; // Importa el modal que crearemos

class UserAdminScreen extends StatelessWidget {
  const UserAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Stream para escuchar cambios en la colección de usuarios
    final usersStream = isar.usuarios.watchLazy();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Botón "Crear Nuevo Usuario"
          ElevatedButton.icon(
            onPressed: () {
              // Llama al modal en modo "Crear"
              mostrarModalFormularioUsuario(context, null);
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Crear Nuevo Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Tabla de Usuarios
          Expanded(
            child: Card(
              color: AppColors.cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: StreamBuilder<void>(
                stream: usersStream,
                builder: (context, snapshot) {
                  // Consulta Isar dentro del builder
                  final usuarios = isar.usuarios.where().sortByNombre().findAllSync();
                  
                  // Cargar los roles asociados
                  for (final user in usuarios) {
                    user.rol.loadSync();
                  }

                  if (usuarios.isEmpty) {
                    return const Center(
                      child: Text('No hay usuarios creados.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    );
                  }

                  return _buildUsersTable(context, usuarios);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la tabla de usuarios
  Widget _buildUsersTable(BuildContext context, List<Usuario> usuarios) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(26)),
        columns: const [
          DataColumn(label: Text('Nombre Completo')),
          DataColumn(label: Text('Username (Login)')),
          DataColumn(label: Text('Rol')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: usuarios.map((usuario) {
          final rolNombre = usuario.rol.value?.nombre ?? 'Sin Rol';
          return DataRow(
            cells: [
              DataCell(Text(usuario.nombre)),
              DataCell(Text(usuario.username)),
              DataCell(Text(rolNombre)),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {
                      // Llama al modal en modo "Editar"
                      mostrarModalFormularioUsuario(context, usuario);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.accentDanger),
                    onPressed: () async {
                      // Lógica de "Desactivar" (Eliminar) 
                      final confirmar = await _mostrarConfirmacion(context, usuario.nombre);
                      if (confirmar ?? false) {
                        if (usuario.id == 1) { // Protección para no borrar al admin principal
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se puede eliminar al administrador principal.'), backgroundColor: AppColors.accentDanger,)
                           );
                           return;
                        }
                        await isar.writeTxn(() async {
                          await isar.usuarios.delete(usuario.id);
                        });
                      }
                    },
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Helper para confirmar eliminación
  Future<bool?> _mostrarConfirmacion(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Desactivación'),
        content: Text('¿Seguro que deseas desactivar al usuario "$nombre"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Desactivar', style: TextStyle(color: AppColors.accentDanger))),
        ],
      ),
    );
  }
}