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
  List<Turno> _turnosPaginados = [];
  bool _isLoading = false;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final Map<int, int> _domicilioCounts = {};
  final Map<int, double> _gastosPorTurno = {};

  static const int _pageSize = 10;
  int _currentPage = 0;
  int _totalTurnos = 0;

  // Filtros
  String? _filtroDiferencia; // null, 'positivo', 'negativo', 'cero'
  final Set<String> _filtrosActividad =
      {}; // 'efectivo', 'tarjeta', 'gastos', 'domicilio'

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

    // Cargar datos para todos los turnos primero (necesarios para filtrar)
    final Map<int, int> tempDomicilio = {};
    final Map<int, double> tempGastos = {};

    for (final t in all) {
      await t.usuario.load();
      final start = t.fechaInicio;
      final end = t.fechaFin ?? DateTime.now();
      final count = await isar.ventas
          .filter()
          .metodoPagoEqualTo('Domicilio', caseSensitive: false)
          .fechaHoraBetween(start, end, includeLower: true, includeUpper: true)
          .count();
      tempDomicilio[t.id] = count;

      final gastos = await isar.gastos.filter().turnoIdEqualTo(t.id).findAll();
      final totalGastos = gastos.fold<double>(0, (sum, g) => sum + g.monto);
      tempGastos[t.id] = totalGastos;
    }

    _domicilioCounts.addAll(tempDomicilio);
    _gastosPorTurno.addAll(tempGastos);

    // Aplicar filtros
    var turnosFiltrados = all.where((t) {
      // Filtro de diferencia
      if (_filtroDiferencia != null) {
        final diffVal = (t.diferencia ?? 0) - (_gastosPorTurno[t.id] ?? 0);
        if (_filtroDiferencia == 'positivo' && diffVal <= 0) return false;
        if (_filtroDiferencia == 'negativo' && diffVal >= 0) return false;
        if (_filtroDiferencia == 'cero' && diffVal != 0) return false;
      }

      // Filtros de actividad
      if (_filtrosActividad.isNotEmpty) {
        bool cumple = true;
        if (_filtrosActividad.contains('efectivo')) {
          if ((t.totalVentasEfectivo ?? 0) <= 0) cumple = false;
        }
        if (_filtrosActividad.contains('tarjeta')) {
          if ((t.totalVentasTarjeta ?? 0) <= 0) cumple = false;
        }
        if (_filtrosActividad.contains('gastos')) {
          if ((_gastosPorTurno[t.id] ?? 0) <= 0) cumple = false;
        }
        if (_filtrosActividad.contains('domicilio')) {
          if ((_domicilioCounts[t.id] ?? 0) <= 0) cumple = false;
        }
        if (!cumple) return false;
      }

      return true;
    }).toList();

    _totalTurnos = turnosFiltrados.length;

    // Paginar
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, turnosFiltrados.length);
    final turnosPagina = turnosFiltrados.sublist(
      startIndex.clamp(0, turnosFiltrados.length),
      endIndex,
    );
    setState(() {
      _turnos = turnosFiltrados;
      _turnosPaginados = turnosPagina;
      _isLoading = false;
    });
  }

  void _aplicarFiltros() {
    setState(() => _currentPage = 0);
    _loadTurnos();
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroDiferencia = null;
      _filtrosActividad.clear();
      _currentPage = 0;
    });
    _loadTurnos();
  }

  void _siguientePagina() {
    if ((_currentPage + 1) * _pageSize < _totalTurnos) {
      setState(() => _currentPage++);
      _loadTurnos();
    }
  }

  void _paginaAnterior() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _loadTurnos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginaActual = _currentPage + 1;
    final totalPaginas = (_totalTurnos / _pageSize).ceil();

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
                const SizedBox(width: 16),
                if (totalPaginas > 1)
                  Text(
                    'Mostrando ${_turnosPaginados.length} de $_totalTurnos turnos',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                const Spacer(),
                // Filtro de diferencia
                SizedBox(
                  width: 140,
                  height: 40,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _filtroDiferencia,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: const Text(
                      'Diferencia',
                      style: TextStyle(fontSize: 13),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(
                        value: 'positivo',
                        child: Text('Positiva'),
                      ),
                      DropdownMenuItem(
                        value: 'negativo',
                        child: Text('Negativa'),
                      ),
                      DropdownMenuItem(value: 'cero', child: Text('Cero')),
                    ],
                    onChanged: (value) {
                      setState(() => _filtroDiferencia = value);
                      _aplicarFiltros();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Menú de filtros de actividad
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_alt,
                    color: _filtrosActividad.isEmpty ? null : AppColors.primary,
                  ),
                  tooltip: 'Filtrar por actividad',
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: const Text(
                        'Filtrar por:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'efectivo',
                      checked: _filtrosActividad.contains('efectivo'),
                      child: const Text('Ventas Efectivo'),
                      onTap: () {
                        setState(() {
                          if (_filtrosActividad.contains('efectivo')) {
                            _filtrosActividad.remove('efectivo');
                          } else {
                            _filtrosActividad.add('efectivo');
                          }
                        });
                        _aplicarFiltros();
                      },
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'tarjeta',
                      checked: _filtrosActividad.contains('tarjeta'),
                      child: const Text('Ventas Tarjeta'),
                      onTap: () {
                        setState(() {
                          if (_filtrosActividad.contains('tarjeta')) {
                            _filtrosActividad.remove('tarjeta');
                          } else {
                            _filtrosActividad.add('tarjeta');
                          }
                        });
                        _aplicarFiltros();
                      },
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'gastos',
                      checked: _filtrosActividad.contains('gastos'),
                      child: const Text('Con Gastos'),
                      onTap: () {
                        setState(() {
                          if (_filtrosActividad.contains('gastos')) {
                            _filtrosActividad.remove('gastos');
                          } else {
                            _filtrosActividad.add('gastos');
                          }
                        });
                        _aplicarFiltros();
                      },
                    ),
                    CheckedPopupMenuItem<String>(
                      value: 'domicilio',
                      checked: _filtrosActividad.contains('domicilio'),
                      child: const Text('Pedidos a Domicilio'),
                      onTap: () {
                        setState(() {
                          if (_filtrosActividad.contains('domicilio')) {
                            _filtrosActividad.remove('domicilio');
                          } else {
                            _filtrosActividad.add('domicilio');
                          }
                        });
                        _aplicarFiltros();
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Botón limpiar filtros
                if (_filtroDiferencia != null || _filtrosActividad.isNotEmpty)
                  IconButton(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Limpiar filtros',
                    style: IconButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                const SizedBox(width: 8),
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
                      itemCount: _turnosPaginados.length,
                      separatorBuilder: (context, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final t = _turnosPaginados[index];
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalTurnos
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
      ),
    );
  }
}
