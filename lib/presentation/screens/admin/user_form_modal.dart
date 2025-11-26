// Archivo: lib/presentation/widgets/admin/user_form_modal.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para 'isar'
import '../../../data/collections/usuario.dart';
import '../../../data/collections/rol.dart';
import '../../theme/app_colors.dart';
// Importaciones para Hashing (RNF4)
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<void> mostrarModalFormularioUsuario(
  BuildContext context,
  Usuario? usuarioExistente,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _UserFormContenido(usuarioExistente: usuarioExistente);
    },
  );
}

class _UserFormContenido extends StatefulWidget {
  final Usuario? usuarioExistente;
  const _UserFormContenido({this.usuarioExistente});

  bool get _esModoEdicion => usuarioExistente != null;

  @override
  State<_UserFormContenido> createState() => _UserFormContenidoState();
}

class _UserFormContenidoState extends State<_UserFormContenido> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<Rol> _rolesList = [];
  Id? _rolSeleccionadoID;

  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() { _isLoading = true; _loadingError = null; });
    try {
      final roles = await isar.rols.where().findAll();
      if (!mounted) return;

      setState(() {
        _rolesList = roles;
        // Pre-llenar en modo edición
        if (widget._esModoEdicion) {
          final u = widget.usuarioExistente!;
          _nombreController.text = u.nombre;
          _usernameController.text = u.username;
          // El rol necesita ser cargado primero
          u.rol.loadSync(); 
          _rolSeleccionadoID = u.rol.value?.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading roles: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = 'Error al cargar roles: $e';
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _guardarUsuario() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validación de contraseña
    if (widget._esModoEdicion == false && password.isEmpty) {
      // Es usuario NUEVO, la contraseña es obligatoria
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La contraseña es obligatoria para usuarios nuevos.'), backgroundColor: AppColors.accentCta,)
      );
      return;
    }
    if (password.isNotEmpty && password != confirmPassword) {
      // Si se escribió una contraseña, debe coincidir
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden.'), backgroundColor: AppColors.accentCta,)
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final rolSeleccionado = await isar.rols.get(_rolSeleccionadoID!);

      await isar.writeTxn(() async {
        final usuarioAGuardar = widget._esModoEdicion
            ? widget.usuarioExistente!
            : Usuario();

        usuarioAGuardar
          ..nombre = _nombreController.text
          ..username = _usernameController.text
          ..rol.value = rolSeleccionado;

        // Lógica de Contraseña (RNF4)
        if (password.isNotEmpty) {
          // Solo actualiza/establece el hash si se proporcionó una nueva contraseña
          final bytes = utf8.encode(password);
          final passwordHash = sha256.convert(bytes).toString();
          usuarioAGuardar.passwordHash = passwordHash;
        }
        
        await isar.usuarios.put(usuarioAGuardar);
        await usuarioAGuardar.rol.save();
      });

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      debugPrint("Error saving user: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar usuario: $e'), backgroundColor: AppColors.accentCta,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget._esModoEdicion ? 'Editar Usuario' : 'Crear Usuario',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.cardBackground,
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
              ? Center(child: Text(_loadingError!, style: TextStyle(color: AppColors.accentCta)))
              : _buildForm(),
      actions: (_isLoading || _loadingError != null)
          ? [ TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')) ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.accentCta)),
              ),
              ElevatedButton(
                onPressed: _guardarUsuario,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted),
                child: const Text('Guardar'),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(_nombreController, 'Nombre Completo'),
              const SizedBox(height: 16),
              _buildTextFormField(_usernameController, 'Username (para login)'),
              const SizedBox(height: 16),
              _buildRolDropdown(),
              const SizedBox(height: 24),
              Text(
                widget._esModoEdicion 
                  ? 'Dejar en blanco para no cambiar la contraseña'
                  : 'Ingrese la contraseña para el nuevo usuario',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildTextFormField(_passwordController, 'Contraseña', isPassword: true, isRequired: !widget._esModoEdicion),
              const SizedBox(height: 16),
              _buildTextFormField(_confirmPasswordController, 'Confirmar Contraseña', isPassword: true, isRequired: !widget._esModoEdicion),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isPassword = false, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo requerido';
        }
        return null;
      },
    );
  }

  Widget _buildRolDropdown() {
    return DropdownButtonFormField<Id>(
      initialValue: _rolSeleccionadoID,
      decoration: InputDecoration(
        labelText: 'Rol de Usuario',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: _rolesList.map((rol) {
        return DropdownMenuItem<Id>(
          value: rol.id,
          child: Text(rol.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _rolSeleccionadoID = value;
        });
      },
      validator: (value) => value == null ? 'Seleccione un rol' : null,
    );
  }
}