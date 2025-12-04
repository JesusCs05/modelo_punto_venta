// Archivo: lib/presentation/screens/admin/user_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/usuario.dart';
import '../../theme/app_colors.dart';
import 'user_form_modal.dart';

class UserAdminScreen extends StatefulWidget {
  const UserAdminScreen({super.key});

  @override
  State<UserAdminScreen> createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  static const int _pageSize = 50;
  int _currentPage = 0;
  String _busqueda = '';
  final TextEditingController _busquedaController = TextEditingController();

  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  int _totalUsuarios = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);

    try {
      var allUsuarios = await isar.usuarios.where().sortByNombre().findAll();

      // Filtrar por búsqueda
      if (_busqueda.isNotEmpty) {
        allUsuarios = allUsuarios.where((u) {
          final nombreMatch = u.nombre.toLowerCase().contains(
            _busqueda.toLowerCase(),
          );
          final usernameMatch = u.username.toLowerCase().contains(
            _busqueda.toLowerCase(),
          );
          return nombreMatch || usernameMatch;
        }).toList();
      }

      _totalUsuarios = allUsuarios.length;

      // Paginar
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allUsuarios.length);
      _usuarios = allUsuarios.sublist(
        startIndex.clamp(0, allUsuarios.length),
        endIndex,
      );

      // Cargar roles
      for (var usuario in _usuarios) {
        await usuario.rol.load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar usuarios: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _siguientePagina() {
    if ((_currentPage + 1) * _pageSize < _totalUsuarios) {
      setState(() => _currentPage++);
      _cargarUsuarios();
    }
  }

  void _paginaAnterior() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _cargarUsuarios();
    }
  }

  void _buscar() {
    setState(() => _currentPage = 0);
    _cargarUsuarios();
  }

  void _limpiarBusqueda() {
    setState(() {
      _busqueda = '';
      _busquedaController.clear();
      _currentPage = 0;
    });
    _cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    final paginaActual = _currentPage + 1;
    final totalPaginas = (_totalUsuarios / _pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón crear y búsqueda
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  mostrarModalFormularioUsuario(
                    context,
                    null,
                  ).then((_) => _cargarUsuarios());
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Crear Nuevo Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o usuario',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _limpiarBusqueda,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _busqueda = value);
                  },
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _buscar,
                icon: const Icon(Icons.filter_list),
                label: const Text('Buscar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Información de paginación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando ${_usuarios.length} de $_totalUsuarios usuarios',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              if (totalPaginas > 1)
                Text(
                  'Página $paginaActual de $totalPaginas',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tabla de usuarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _usuarios.isEmpty
                ? const Center(
                    child: Text(
                      'No hay usuarios creados.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Card(
                    color: AppColors.cardBackground,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildUsersTable(context),
                  ),
          ),

          // Controles de paginación
          if (totalPaginas > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _paginaAnterior : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Página anterior',
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Página $paginaActual de $totalPaginas',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: (_currentPage + 1) * _pageSize < _totalUsuarios
                        ? _siguientePagina
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Página siguiente',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: constraints.maxWidth * 0.08,
              headingRowColor: WidgetStateProperty.all(
                AppColors.primary.withAlpha(26),
              ),
              columns: const [
                DataColumn(label: Text('Nombre Completo')),
                DataColumn(label: Text('Nombre de Usuario')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: _usuarios.map((usuario) {
                final rolNombre = usuario.rol.value?.nombre ?? 'Sin Rol';
                return DataRow(
                  cells: [
                    DataCell(Text(usuario.nombre)),
                    DataCell(Text(usuario.username)),
                    DataCell(Text(rolNombre)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              mostrarModalFormularioUsuario(
                                context,
                                usuario,
                              ).then((_) => _cargarUsuarios());
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.accentCta,
                            ),
                            onPressed: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final confirmar = await _mostrarConfirmacion(
                                context,
                                usuario.nombre,
                              );
                              if (confirmar ?? false) {
                                if (usuario.id == 1) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No se puede eliminar al administrador principal.',
                                      ),
                                      backgroundColor: AppColors.accentCta,
                                    ),
                                  );
                                  return;
                                }
                                await isar.writeTxn(() async {
                                  await isar.usuarios.delete(usuario.id);
                                });
                                if (context.mounted) {
                                  _cargarUsuarios();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Desactivar',
              style: TextStyle(color: AppColors.accentCta),
            ),
          ),
        ],
      ),
    );
  }
}
