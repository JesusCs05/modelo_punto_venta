// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVentaCollection on Isar {
  IsarCollection<Venta> get ventas => this.collection();
}

const VentaSchema = CollectionSchema(
  name: r'Venta',
  id: -2270150413385075991,
  properties: {
    r'fechaHora': PropertySchema(
      id: 0,
      name: r'fechaHora',
      type: IsarType.dateTime,
    ),
    r'metodoPago': PropertySchema(
      id: 1,
      name: r'metodoPago',
      type: IsarType.string,
    ),
    r'referenciaTarjeta': PropertySchema(
      id: 2,
      name: r'referenciaTarjeta',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 3,
      name: r'total',
      type: IsarType.double,
    )
  },
  estimateSize: _ventaEstimateSize,
  serialize: _ventaSerialize,
  deserialize: _ventaDeserialize,
  deserializeProp: _ventaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'usuario': LinkSchema(
      id: 7988594514704869727,
      name: r'usuario',
      target: r'Usuario',
      single: true,
    ),
    r'detalles': LinkSchema(
      id: 7537348132011293429,
      name: r'detalles',
      target: r'VentaDetalle',
      single: false,
      linkName: r'venta',
    )
  },
  embeddedSchemas: {},
  getId: _ventaGetId,
  getLinks: _ventaGetLinks,
  attach: _ventaAttach,
  version: '3.1.0+1',
);

int _ventaEstimateSize(
  Venta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.metodoPago.length * 3;
  {
    final value = object.referenciaTarjeta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _ventaSerialize(
  Venta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.fechaHora);
  writer.writeString(offsets[1], object.metodoPago);
  writer.writeString(offsets[2], object.referenciaTarjeta);
  writer.writeDouble(offsets[3], object.total);
}

Venta _ventaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Venta();
  object.fechaHora = reader.readDateTime(offsets[0]);
  object.id = id;
  object.metodoPago = reader.readString(offsets[1]);
  object.referenciaTarjeta = reader.readStringOrNull(offsets[2]);
  object.total = reader.readDouble(offsets[3]);
  return object;
}

P _ventaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaGetId(Venta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaGetLinks(Venta object) {
  return [object.usuario, object.detalles];
}

void _ventaAttach(IsarCollection<dynamic> col, Id id, Venta object) {
  object.id = id;
  object.usuario.attach(col, col.isar.collection<Usuario>(), r'usuario', id);
  object.detalles
      .attach(col, col.isar.collection<VentaDetalle>(), r'detalles', id);
}

extension VentaQueryWhereSort on QueryBuilder<Venta, Venta, QWhere> {
  QueryBuilder<Venta, Venta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VentaQueryWhere on QueryBuilder<Venta, Venta, QWhereClause> {
  QueryBuilder<Venta, Venta, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Venta, Venta, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Venta, Venta, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Venta, Venta, QAfterWhereClause> idBetween(
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

extension VentaQueryFilter on QueryBuilder<Venta, Venta, QFilterCondition> {
  QueryBuilder<Venta, Venta, QAfterFilterCondition> fechaHoraEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> fechaHoraGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> fechaHoraLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> fechaHoraBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaHora',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Venta, Venta, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Venta, Venta, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodoPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metodoPago',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> metodoPagoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metodoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenciaTarjeta',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition>
      referenciaTarjetaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenciaTarjeta',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition>
      referenciaTarjetaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenciaTarjeta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenciaTarjeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenciaTarjeta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> referenciaTarjetaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenciaTarjeta',
        value: '',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition>
      referenciaTarjetaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenciaTarjeta',
        value: '',
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> totalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> totalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> totalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> totalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension VentaQueryObject on QueryBuilder<Venta, Venta, QFilterCondition> {}

extension VentaQueryLinks on QueryBuilder<Venta, Venta, QFilterCondition> {
  QueryBuilder<Venta, Venta, QAfterFilterCondition> usuario(
      FilterQuery<Usuario> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'usuario');
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> usuarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usuario', 0, true, 0, true);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detalles(
      FilterQuery<VentaDetalle> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'detalles');
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'detalles', length, true, length, true);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'detalles', 0, true, 0, true);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'detalles', 0, false, 999999, true);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'detalles', 0, true, length, include);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'detalles', length, include, 999999, true);
    });
  }

  QueryBuilder<Venta, Venta, QAfterFilterCondition> detallesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'detalles', lower, includeLower, upper, includeUpper);
    });
  }
}

extension VentaQuerySortBy on QueryBuilder<Venta, Venta, QSortBy> {
  QueryBuilder<Venta, Venta, QAfterSortBy> sortByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByFechaHoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByMetodoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByMetodoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByReferenciaTarjeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaTarjeta', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByReferenciaTarjetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaTarjeta', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension VentaQuerySortThenBy on QueryBuilder<Venta, Venta, QSortThenBy> {
  QueryBuilder<Venta, Venta, QAfterSortBy> thenByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByFechaHoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByMetodoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByMetodoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByReferenciaTarjeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaTarjeta', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByReferenciaTarjetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaTarjeta', Sort.desc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<Venta, Venta, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension VentaQueryWhereDistinct on QueryBuilder<Venta, Venta, QDistinct> {
  QueryBuilder<Venta, Venta, QDistinct> distinctByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaHora');
    });
  }

  QueryBuilder<Venta, Venta, QDistinct> distinctByMetodoPago(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodoPago', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Venta, Venta, QDistinct> distinctByReferenciaTarjeta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenciaTarjeta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Venta, Venta, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension VentaQueryProperty on QueryBuilder<Venta, Venta, QQueryProperty> {
  QueryBuilder<Venta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Venta, DateTime, QQueryOperations> fechaHoraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaHora');
    });
  }

  QueryBuilder<Venta, String, QQueryOperations> metodoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoPago');
    });
  }

  QueryBuilder<Venta, String?, QQueryOperations> referenciaTarjetaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaTarjeta');
    });
  }

  QueryBuilder<Venta, double, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
