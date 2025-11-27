// ignore_for_file: use_build_context_synchronously

// Archivo: lib/presentation/screens/admin/business_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../../data/models/business_info.dart';
import '../../theme/app_colors.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _razonController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _rfcController;

  @override
  void initState() {
    super.initState();
    final info = context.read<BusinessProvider>().info;
    _nombreController = TextEditingController(text: info.nombre);
    _razonController = TextEditingController(text: info.razonSocial);
    _telefonoController = TextEditingController(text: info.telefono);
    _direccionController = TextEditingController(text: info.direccion);
    _rfcController = TextEditingController(text: info.rfc);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razonController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del negocio'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre (visible en ticket)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.textInverted,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _razonController,
                decoration: InputDecoration(
                  labelText: 'Razón social',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rfcController,
                decoration: InputDecoration(
                  labelText: 'RFC (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textInverted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        final scaffold = ScaffoldMessenger.of(context);
                        if (!_formKey.currentState!.validate()) return;
                        final newInfo = BusinessInfo(
                          nombre: _nombreController.text.trim(),
                          razonSocial: _razonController.text.trim(),
                          telefono: _telefonoController.text.trim(),
                          direccion: _direccionController.text.trim(),
                          rfc: _rfcController.text.trim(),
                        );
                        await context.read<BusinessProvider>().save(newInfo);
                        scaffold.showSnackBar(
                          const SnackBar(content: Text('Datos guardados')),
                        );
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCta,
                      foregroundColor: AppColors.textInverted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      await context.read<BusinessProvider>().reset();
                      final info = context.read<BusinessProvider>().info;
                      _nombreController.text = info.nombre;
                      _razonController.text = info.razonSocial;
                      _telefonoController.text = info.telefono;
                      _direccionController.text = info.direccion;
                      _rfcController.text = info.rfc;
                      scaffold.showSnackBar(
                        const SnackBar(
                          content: Text('Restaurado a valores por defecto'),
                        ),
                      );
                    },
                    child: const Text('Restaurar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
