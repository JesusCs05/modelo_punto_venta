// Archivo: lib/presentation/screens/abrir_turno_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/turno_provider.dart';
import '../theme/app_colors.dart';
import 'pos_screen.dart'; // Destino final

class AbrirTurnoScreen extends StatefulWidget {
  const AbrirTurnoScreen({super.key});

  @override
  State<AbrirTurnoScreen> createState() => _AbrirTurnoScreenState();
}

class _AbrirTurnoScreenState extends State<AbrirTurnoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fondoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _abrirTurno() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final fondoInicial = double.tryParse(_fondoController.text) ?? 0.0;
      final authProvider = context.read<AuthProvider>();
      final turnoProvider = context.read<TurnoProvider>();
      final currentContext = context; // Guardar context

      if (authProvider.currentUser == null) {
        throw Exception("No hay usuario logueado para abrir turno.");
      }

      // Llamar al provider para crear el turno en la BD
      await turnoProvider.abrirTurno(authProvider.currentUser!, fondoInicial);

      if (!currentContext.mounted) return;

      // Navegar a la pantalla de ventas (POS)
      Navigator.of(currentContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PosScreen()),
        (route) => false, // Limpiar historial
      );

    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.accentDanger),
      );
    }
  }

  @override
  void dispose() {
    _fondoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            color: AppColors.cardBackground,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Abrir Turno',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bienvenido, ${authProvider.currentUser?.nombre ?? 'Cajero'}.',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _fondoController,
                      decoration: InputDecoration(
                        labelText: 'Fondo de Caja Inicial',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el fondo inicial';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _abrirTurno,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textInverted,
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: AppColors.textInverted)
                            : const Text('Iniciar Turno', style: TextStyle(fontSize: 18)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
