// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turno.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTurnoCollection on Isar {
  IsarCollection<Turno> get turnos => this.collection();
}

const TurnoSchema = CollectionSchema(
  name: r'Turno',
  id: 2167075463769606478,
  properties: {
    r'diferencia': PropertySchema(
      id: 0,
      name: r'diferencia',
      type: IsarType.double,
    ),
    r'fechaFin': PropertySchema(
      id: 1,
      name: r'fechaFin',
      type: IsarType.dateTime,
    ),
    r'fechaInicio': PropertySchema(
      id: 2,
      name: r'fechaInicio',
      type: IsarType.dateTime,
    ),
    r'fondoInicial': PropertySchema(
      id: 3,
      name: r'fondoInicial',
      type: IsarType.double,
    ),
    r'totalContadoEfectivo': PropertySchema(
      id: 4,
      name: r'totalContadoEfectivo',
      type: IsarType.double,
    ),
    r'totalVentasEfectivo': PropertySchema(
      id: 5,
      name: r'totalVentasEfectivo',
      type: IsarType.double,
    ),
    r'totalVentasTarjeta': PropertySchema(
      id: 6,
      name: r'totalVentasTarjeta',
      type: IsarType.double,
    )
  },
  estimateSize: _turnoEstimateSize,
  serialize: _turnoSerialize,
  deserialize: _turnoDeserialize,
  deserializeProp: _turnoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'usuario': LinkSchema(
      id: 4994325832331052202,
      name: r'usuario',
      target: r'Usuario',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _turnoGetId,
  getLinks: _turnoGetLinks,
  attach: _turnoAttach,
  version: '3.1.0+1',
);

int _turnoEstimateSize(
  Turno object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _turnoSerialize(
  Turno object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.diferencia);
  writer.writeDateTime(offsets[1], object.fechaFin);
  writer.writeDateTime(offsets[2], object.fechaInicio);
  writer.writeDouble(offsets[3], object.fondoInicial);
  writer.writeDouble(offsets[4], object.totalContadoEfectivo);
  writer.writeDouble(offsets[5], object.totalVentasEfectivo);
  writer.writeDouble(offsets[6], object.totalVentasTarjeta);
}

Turno _turnoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Turno();
  object.diferencia = reader.readDoubleOrNull(offsets[0]);
  object.fechaFin = reader.readDateTimeOrNull(offsets[1]);
  object.fechaInicio = reader.readDateTime(offsets[2]);
  object.fondoInicial = reader.readDouble(offsets[3]);
  object.id = id;
  object.totalContadoEfectivo = reader.readDoubleOrNull(offsets[4]);
  object.totalVentasEfectivo = reader.readDoubleOrNull(offsets[5]);
  object.totalVentasTarjeta = reader.readDoubleOrNull(offsets[6]);
  return object;
}

P _turnoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _turnoGetId(Turno object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _turnoGetLinks(Turno object) {
  return [object.usuario];
}

void _turnoAttach(IsarCollection<dynamic> col, Id id, Turno object) {
  object.id = id;
  object.usuario.attach(col, col.isar.collection<Usuario>(), r'usuario', id);
}

extension TurnoQueryWhereSort on QueryBuilder<Turno, Turno, QWhere> {
  QueryBuilder<Turno, Turno, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TurnoQueryWhere on QueryBuilder<Turno, Turno, QWhereClause> {
  QueryBuilder<Turno, Turno, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Turno, Turno, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Turno, Turno, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Turno, Turno, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TurnoQueryFilter on QueryBuilder<Turno, Turno, QFilterCondition> {
  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diferencia',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diferencia',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> diferenciaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diferencia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaFin',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaFin',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaFin',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaFin',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaFin',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaFinBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaFin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaInicioEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaInicioGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaInicioLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fechaInicioBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaInicio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fondoInicialEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fondoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fondoInicialGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fondoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fondoInicialLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fondoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> fondoInicialBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fondoInicial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalContadoEfectivoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalContadoEfectivo',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalContadoEfectivoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalContadoEfectivo',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalContadoEfectivoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalContadoEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalContadoEfectivoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalContadoEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalContadoEfectivoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalContadoEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalContadoEfectivoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalContadoEfectivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalVentasEfectivoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalVentasEfectivo',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalVentasEfectivoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalVentasEfectivo',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasEfectivoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalVentasEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalVentasEfectivoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalVentasEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasEfectivoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalVentasEfectivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasEfectivoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalVentasEfectivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasTarjetaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalVentasTarjeta',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalVentasTarjetaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalVentasTarjeta',
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasTarjetaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalVentasTarjeta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition>
      totalVentasTarjetaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalVentasTarjeta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasTarjetaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalVentasTarjeta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> totalVentasTarjetaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalVentasTarjeta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension TurnoQueryObject on QueryBuilder<Turno, Turno, QFilterCondition> {}

extension TurnoQueryLinks on QueryBuilder<Turno, Turno, QFilterCondition> {
  QueryBuilder<Turno, Turno, QAfterFilterCondition> usuario(
      FilterQuery<Usuario> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'usuario');
    });
  }

  QueryBuilder<Turno, Turno, QAfterFilterCondition> usuarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usuario', 0, true, 0, true);
    });
  }
}

extension TurnoQuerySortBy on QueryBuilder<Turno, Turno, QSortBy> {
  QueryBuilder<Turno, Turno, QAfterSortBy> sortByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByDiferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFechaFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaFin', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFechaFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaFin', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFechaInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaInicio', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFechaInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaInicio', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFondoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fondoInicial', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByFondoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fondoInicial', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalContadoEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalContadoEfectivo', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalContadoEfectivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalContadoEfectivo', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalVentasEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasEfectivo', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalVentasEfectivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasEfectivo', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalVentasTarjeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasTarjeta', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> sortByTotalVentasTarjetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasTarjeta', Sort.desc);
    });
  }
}

extension TurnoQuerySortThenBy on QueryBuilder<Turno, Turno, QSortThenBy> {
  QueryBuilder<Turno, Turno, QAfterSortBy> thenByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByDiferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFechaFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaFin', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFechaFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaFin', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFechaInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaInicio', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFechaInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaInicio', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFondoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fondoInicial', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByFondoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fondoInicial', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalContadoEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalContadoEfectivo', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalContadoEfectivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalContadoEfectivo', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalVentasEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasEfectivo', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalVentasEfectivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasEfectivo', Sort.desc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalVentasTarjeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasTarjeta', Sort.asc);
    });
  }

  QueryBuilder<Turno, Turno, QAfterSortBy> thenByTotalVentasTarjetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasTarjeta', Sort.desc);
    });
  }
}

extension TurnoQueryWhereDistinct on QueryBuilder<Turno, Turno, QDistinct> {
  QueryBuilder<Turno, Turno, QDistinct> distinctByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diferencia');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByFechaFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaFin');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByFechaInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaInicio');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByFondoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fondoInicial');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByTotalContadoEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalContadoEfectivo');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByTotalVentasEfectivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalVentasEfectivo');
    });
  }

  QueryBuilder<Turno, Turno, QDistinct> distinctByTotalVentasTarjeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalVentasTarjeta');
    });
  }
}

extension TurnoQueryProperty on QueryBuilder<Turno, Turno, QQueryProperty> {
  QueryBuilder<Turno, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Turno, double?, QQueryOperations> diferenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diferencia');
    });
  }

  QueryBuilder<Turno, DateTime?, QQueryOperations> fechaFinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaFin');
    });
  }

  QueryBuilder<Turno, DateTime, QQueryOperations> fechaInicioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaInicio');
    });
  }

  QueryBuilder<Turno, double, QQueryOperations> fondoInicialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fondoInicial');
    });
  }

  QueryBuilder<Turno, double?, QQueryOperations>
      totalContadoEfectivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalContadoEfectivo');
    });
  }

  QueryBuilder<Turno, double?, QQueryOperations> totalVentasEfectivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalVentasEfectivo');
    });
  }

  QueryBuilder<Turno, double?, QQueryOperations> totalVentasTarjetaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalVentasTarjeta');
    });
  }
}
