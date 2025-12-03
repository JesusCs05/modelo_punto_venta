// Archivo: lib/presentation/screens/admin/reports/session_turns_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart';
import '../../../../data/collections/turno.dart';
import '../../../../data/collections/venta.dart';
import '../../../../data/collections/gasto.dart';
import '../../../theme/app_colors.dart';

class SessionTurnsReport extends StatefulWidget {
  const SessionTurnsReport({super.key});

  @override
  State<SessionTurnsReport> createState() => _SessionTurnsReportState();
}

class _SessionTurnsReportState extends State<SessionTurnsReport> {
  List<Turno> _turnos = [];
  bool _isLoading = false;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final Map<int, int> _domicilioCounts = {};
  final Map<int, double> _gastosPorTurno = {};

  Widget _statTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTurnos();
  }

  Future<void> _loadTurnos() async {
    setState(() {
      _isLoading = true;
    });
    final all = await isar.turnos.where().findAll();
    // Ordenar por fechaInicio desc
    all.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
    // Cargar usuario de cada turno, contar pedidos de domicilio y sumar gastos
    for (final t in all) {
      await t.usuario.load();
      final start = t.fechaInicio;
      final end = t.fechaFin ?? DateTime.now();
      final count = await isar.ventas
          .filter()
          .metodoPagoEqualTo('Domicilio', caseSensitive: false)
          .fechaHoraBetween(start, end, includeLower: true, includeUpper: true)
          .count();
      _domicilioCounts[t.id] = count;

      // Sumar gastos del turno
      final gastos = await isar.gastos.filter().turnoIdEqualTo(t.id).findAll();
      final totalGastos = gastos.fold<double>(0, (sum, g) => sum + g.monto);
      _gastosPorTurno[t.id] = totalGastos;
    }
    setState(() {
      _turnos = all;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Reportes por Turno',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar'),
                  onPressed: _isLoading ? null : _loadTurnos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _turnos.isEmpty
                  ? const Center(child: Text('No hay turnos registrados.'))
                  : ListView.separated(
                      itemCount: _turnos.length,
                      separatorBuilder: (context, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final t = _turnos[index];
                        final inicio = _dateFormat.format(t.fechaInicio);
                        final fin = t.fechaFin != null
                            ? _dateFormat.format(t.fechaFin!)
                            : 'Activo';
                        final ventasEfectivo = (t.totalVentasEfectivo ?? 0)
                            .toStringAsFixed(2);
                        final ventasTarjeta = (t.totalVentasTarjeta ?? 0)
                            .toStringAsFixed(2);
                        final contado = (t.totalContadoEfectivo ?? 0)
                            .toStringAsFixed(2);
                        final gastos = _gastosPorTurno[t.id] ?? 0.0;
                        final gastosStr = gastos.toStringAsFixed(2);
                        final diffVal = (t.diferencia ?? 0) - gastos;
                        final diferencia = diffVal.toStringAsFixed(2);
                        final Color diffColor = diffVal > 0
                            ? AppColors.primary
                            : diffVal < 0
                            ? AppColors.accentCta
                            : AppColors.secondary;
                        final IconData diffIcon = diffVal > 0
                            ? Icons.trending_up
                            : diffVal < 0
                            ? Icons.trending_down
                            : Icons.horizontal_rule;
                        final domicilioCount = _domicilioCounts[t.id] ?? 0;
                        return ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turno #${t.id} - $inicio → $fin',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cajero: ${t.usuario.value?.nombre ?? 'Desconocido'}',
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('Contado físico: \$$contado  '),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: diffColor.withAlpha(31),
                                      border: Border.all(color: diffColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          diffIcon,
                                          size: 16,
                                          color: diffColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Diferencia: \$$diferencia',
                                          style: TextStyle(
                                            color: diffColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          childrenPadding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          children: [
                            const Divider(),
                            _statTile(
                              icon: Icons.savings_outlined,
                              color: AppColors.secondary,
                              label: 'Fondo inicial',
                              value: '\$${t.fondoInicial.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _statTile(
                              icon: Icons.payments,
                              color: AppColors.primary,
                              label: 'Ventas (Efectivo)',
                              value: '\$$ventasEfectivo',
                            ),
                            const SizedBox(height: 8),
                            _statTile(
                              icon: Icons.credit_card,
                              color: AppColors.highlight,
                              label: 'Ventas (Tarjeta)',
                              value: '\$$ventasTarjeta',
                            ),
                            const SizedBox(height: 8),
                            _statTile(
                              icon: Icons.money_off,
                              color: AppColors.accentCta,
                              label: 'Gastos',
                              value: '\$$gastosStr',
                            ),
                            const SizedBox(height: 8),
                            _statTile(
                              icon: Icons.delivery_dining,
                              color: AppColors.accentCta,
                              label: 'Pedidos a domicilio',
                              value: '$domicilioCount',
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
