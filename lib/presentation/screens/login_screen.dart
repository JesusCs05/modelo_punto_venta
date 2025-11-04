// Archivo: lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'admin/admin_dashboard_screen.dart'; // To navigate to Admin

// --- ISAR Imports ---
import 'package:isar/isar.dart';
import '../../main.dart'; // Import main.dart to access the global 'isar' instance
import '../../data/collections/usuario.dart'; // Import the Usuario collection
// --- End ISAR Imports ---

import 'package:crypto/crypto.dart';
import 'dart:convert';

// --- REMOVE Old Drift/Provider Imports ---
import 'package:provider/provider.dart';
import '/presentation/providers/auth_provider.dart';
import 'abrir_turno_screen.dart';
// import '../../data/db/app_db.dart'; // REMOVE THIS
// --- End Removal ---


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

  // Updated Login Logic using Isar
Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() { _isLoading = true; });

    // 1. Guarda el AuthProvider y el Context ANTES del await
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
        // 2. Llama al AuthProvider para guardar la sesión
        await authProvider.login(usuario); // Esto carga el rol

        // 3. Verifica 'mounted' después del await
        if (!currentContext.mounted) return;

        // 4. Navega usando el estado del provider
        if (authProvider.isAdmin) {
          Navigator.of(currentContext).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
            // No es admin, ir a abrir turno
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
      if (mounted) { // 'mounted' aquí está bien porque 'setState' es parte de este widget
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains mostly the same, only removed Provider call
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
                    const Icon( // Placeholder logo
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

  // Helper methods (_buildLoginButton, _buildInputDecoration) remain unchanged
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
      // FIX: Use withAlpha instead of deprecated withOpacity
      fillColor: AppColors.cardBackground.withAlpha(128), // ~50% opacity
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