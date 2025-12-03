import 'package:flutter/material.dart';
import '../../../data/collections/gasto.dart';
import '../../../main.dart';
import '../../theme/app_colors.dart';

class RegistrarGastoForm extends StatefulWidget {
  final int turnoId;
  final int usuarioId;
  final VoidCallback? onGastoRegistrado;

  const RegistrarGastoForm({
    super.key,
    required this.turnoId,
    required this.usuarioId,
    this.onGastoRegistrado,
  });

  @override
  State<RegistrarGastoForm> createState() => _RegistrarGastoFormState();
}

class _RegistrarGastoFormState extends State<RegistrarGastoForm> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _montoController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _registrarGasto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final gasto = Gasto()
      ..monto = double.parse(_montoController.text)
      ..descripcion = _descController.text.trim()
      ..fecha = DateTime.now()
      ..turnoId = widget.turnoId
      ..usuarioId = widget.usuarioId;
    await isar.writeTxn(() async {
      await isar.gastos.put(gasto);
    });
    setState(() => _isSaving = false);

    if (widget.onGastoRegistrado != null) widget.onGastoRegistrado!();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gasto registrado correctamente'),
          backgroundColor: AppColors.primary,
        ),
      );
      // Cerrar el diálogo después de registrar
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registrar Gasto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese el monto';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(
                    Icons.description,
                    color: AppColors.secondary,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ingrese una descripción';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Guardando...' : 'Registrar'),
                  onPressed: _isSaving ? null : _registrarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
