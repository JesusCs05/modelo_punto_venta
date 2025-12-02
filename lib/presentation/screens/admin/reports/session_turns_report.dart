// Archivo: lib/presentation/screens/admin/reports/session_turns_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart';
import '../../../../data/collections/turno.dart';
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
                        final diferencia = (t.diferencia ?? 0).toStringAsFixed(
                          2,
                        );

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          title: Text(
                            'Turno #${t.id} - $inicio → $fin',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                'Fondo inicial: \$${t.fondoInicial.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Ventas (Efectivo): \$$ventasEfectivo  •  Ventas (Tarjeta): \$$ventasTarjeta',
                              ),
                              Text(
                                'Contado físico: \$$contado  •  Diferencia: \$$diferencia',
                              ),
                            ],
                          ),
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
