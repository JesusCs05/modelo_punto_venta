// Archivo: lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'admin/admin_dashboard_screen.dart'; 
import 'package:isar/isar.dart';
import '../../main.dart'; 
import '../../data/collections/usuario.dart'; 
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '/presentation/providers/auth_provider.dart';
import 'abrir_turno_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // ... (Tu código de login se queda igual)
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() { _isLoading = true; });

    final authProvider = context.read<AuthProvider>();
    final currentContext = context;

    try {
      final username = _userController.text;
      final password = _passwordController.text;
      final bytes = utf8.encode(password);
      final passwordHash = sha256.convert(bytes).toString();

      final usuario = await isar.usuarios
          .filter()
          .usernameEqualTo(username)
          .passwordHashEqualTo(passwordHash)
          .findFirst();

      if (usuario != null) {
        await authProvider.login(usuario); 

        if (!currentContext.mounted) return;

        if (authProvider.isAdmin) {
          Navigator.of(currentContext).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.of(currentContext).pushReplacement(
            MaterialPageRoute(builder: (context) => const AbrirTurnoScreen()),
          );
        }
      } else {
        if (!currentContext.mounted) return;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: AppColors.accentDanger,
          ),
        );
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: ${e.toString()}'),
          backgroundColor: AppColors.accentDanger,
        ),
      );
    } finally {
      if (mounted) { 
        setState(() { _isLoading = false; });
      }
    }
  }

  // --- 1. ELIMINAR EL MÉTODO _mostrarDialogoConfirmarSalida ---
  // (La lógica ahora vive en main.dart)

  @override
  Widget build(BuildContext context) {
    // --- 2. ELIMINAR EL WIDGET PopScope ---
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon( 
                      Icons.store,
                      size: 100,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _userController,
                      decoration: _buildInputDecoration('Usuario'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? 'Ingrese su usuario' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _buildInputDecoration('Contraseña'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      obscureText: true,
                      validator: (value) => (value?.isEmpty ?? true)
                          ? 'Ingrese su contraseña'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Los métodos _buildLoginButton y _buildInputDecoration se quedan igual
  //
  Widget _buildLoginButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.textInverted),
              )
            : const Text(
                'INGRESAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: AppColors.cardBackground.withAlpha(128), 
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentDanger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentDanger, width: 2.5),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}