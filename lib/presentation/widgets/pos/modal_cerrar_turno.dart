// Archivo: lib/presentation/widgets/pos/modal_cerrar_turno.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:modelo_venta/data/collections/usuario.dart';
import 'package:provider/provider.dart';
import '../../../main.dart'; // Para 'isar'
import '../../../data/collections/venta.dart';
import '../../providers/auth_provider.dart';
import '../../providers/turno_provider.dart';
import '../../screens/login_screen.dart';
import '../../theme/app_colors.dart';

/// Define el resultado del cierre de turno
enum CierreTurnoResultado { exitoso, cancelado }

/// Muestra el modal para realizar el Corte X (RF3.9)
Future<CierreTurnoResultado?> mostrarModalCerrarTurno(BuildContext context) {
  return showDialog<CierreTurnoResultado>(
    context: context,
    barrierDismissible: false, // No se puede cancelar tocando fuera
    builder: (BuildContext dialogContext) {
      // Usamos los providers del context que llama al modal
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<AuthProvider>()),
          ChangeNotifierProvider.value(value: context.read<TurnoProvider>()),
        ],
        child: const _CerrarTurnoContenido(),
      );
    },
  );
}

class _CerrarTurnoContenido extends StatefulWidget {
  const _CerrarTurnoContenido();

  @override
  State<_CerrarTurnoContenido> createState() => _CerrarTurnoContenidoState();
}

class _CerrarTurnoContenidoState extends State<_CerrarTurnoContenido> {
  bool _isLoading = true;
  String? _loadingError;

  // Datos del Corte
  double _fondoInicial = 0.0;
  double _ventasEfectivo = 0.0;
  double _ventasTarjeta = 0.0;
  double _totalEsperadoEfectivo = 0.0;

  final _conteoFisicoController = TextEditingController();
  double _diferencia = 0.0;

  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _calcularCorte();
  }

  /// Consulta Isar para calcular las ventas del turno activo
  Future<void> _calcularCorte() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final turnoProvider = context.read<TurnoProvider>();
      final turno = turnoProvider.turnoActivo;

      if (turno == null) {
        throw Exception('No hay un turno activo para cerrar.');
      }

      // Cargar el usuario del turno
      await turno.usuario.load();
      final usuarioID = turno.usuario.value?.id;
      if (usuarioID == null) {
        throw Exception('El turno no tiene un usuario asociado.');
      }

      // 1. Encontrar todas las ventas de ESTE usuario durante ESTE turno
      final ventasDelTurno = await isar.ventas
          .filter()
          .usuario((q) => q.idEqualTo(usuarioID))
          .fechaHoraGreaterThan(turno.fechaInicio) // Mayores que el inicio
          .findAll();

      // 2. Calcular totales
      double ventasEfectivo = 0.0;
      double ventasTarjeta = 0.0;
      for (final venta in ventasDelTurno) {
        if (venta.metodoPago == 'Efectivo') {
          ventasEfectivo += venta.total;
        } else {
          ventasTarjeta += venta.total;
        }
      }

      setState(() {
        _fondoInicial = turno.fondoInicial;
        _ventasEfectivo = ventasEfectivo;
        _ventasTarjeta = ventasTarjeta;
        _totalEsperadoEfectivo = turno.fondoInicial + ventasEfectivo;
        _isLoading = false;
        // Calcular diferencia inicial (con 0 contado)
        _calcularDiferencia();
      });
    } catch (e) {
      debugPrint("Error calculando corte: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingError = 'Error al calcular el corte: $e';
        });
      }
    }
  }

  void _calcularDiferencia() {
    final conteoFisico = double.tryParse(_conteoFisicoController.text) ?? 0.0;
    setState(() {
      _diferencia = conteoFisico - _totalEsperadoEfectivo;
    });
  }

  /// Llama al provider para cerrar el turno y luego hace logout
  Future<void> _finalizarTurnoYLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final turnoProvider = context.read<TurnoProvider>();
      final authProvider = context.read<AuthProvider>();
      final currentContext = context; // Guardar context

      final conteoFisico = double.tryParse(_conteoFisicoController.text) ?? 0.0;

      // Llama al provider para guardar el Corte X en la BD
      await turnoProvider.cerrarTurno(
        ventasEfectivo: _ventasEfectivo,
        ventasTarjeta: _ventasTarjeta,
        conteoFisicoEfectivo: conteoFisico,
      );

      if (!currentContext.mounted) return;

      // 2. Hacer Logout
      authProvider.logout();

      // 3. Regresar a Login
      Navigator.of(currentContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar turno: ${e.toString()}'),
          backgroundColor: AppColors.accentCta,
        ),
      );
    }
  }

  @override
  void dispose() {
    _conteoFisicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Cierre de Turno (Corte X)',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
          ? Center(
              child: Text(
                _loadingError!,
                style: TextStyle(color: AppColors.accentCta),
              ),
            )
          : _buildForm(),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: (_isLoading || _loadingError != null)
          ? [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(CierreTurnoResultado.cancelado),
                child: const Text('Cerrar'),
              ),
            ]
          : [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(CierreTurnoResultado.cancelado),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed:
                            _finalizarTurnoYLogout, // Llama a la función final
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          foregroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          'Finalizar Turno y Salir',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(
              '(+) Fondo Inicial:',
              _currencyFormat.format(_fondoInicial),
            ),
            _buildRow(
              '(+) Ventas en Efectivo:',
              _currencyFormat.format(_ventasEfectivo),
            ),
            _buildRow(
              '(+) Ventas con Tarjeta:',
              _currencyFormat.format(_ventasTarjeta),
            ),
            const Divider(thickness: 1, height: 20),
            _buildRow(
              '(=) Total Esperado en Caja:',
              _currencyFormat.format(_totalEsperadoEfectivo),
              isTotal: true,
            ),
            const Divider(thickness: 1, height: 20),
            TextFormField(
              controller: _conteoFisicoController,
              decoration: InputDecoration(
                labelText: 'Total Contado Físico (Efectivo)',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) => _calcularDiferencia(),
            ),
            const SizedBox(height: 16),
            _buildRow(
              '(=) Diferencia (Sobrante/Faltante):',
              _currencyFormat.format(_diferencia),
              isTotal: true,
              color: _diferencia == 0 ? AppColors.primary : AppColors.accentCta,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
