// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimiento_inventario.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMovimientoInventarioCollection on Isar {
  IsarCollection<MovimientoInventario> get movimientoInventarios =>
      this.collection();
}

const MovimientoInventarioSchema = CollectionSchema(
  name: r'MovimientoInventario',
  id: -7869619496146237102,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'fecha': PropertySchema(
      id: 1,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'tipoMovimiento': PropertySchema(
      id: 2,
      name: r'tipoMovimiento',
      type: IsarType.string,
    )
  },
  estimateSize: _movimientoInventarioEstimateSize,
  serialize: _movimientoInventarioSerialize,
  deserialize: _movimientoInventarioDeserialize,
  deserializeProp: _movimientoInventarioDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'producto': LinkSchema(
      id: -82554066409543313,
      name: r'producto',
      target: r'Producto',
      single: true,
    ),
    r'usuario': LinkSchema(
      id: 437236405415517382,
      name: r'usuario',
      target: r'Usuario',
      single: true,
    ),
    r'venta': LinkSchema(
      id: 431089771704830217,
      name: r'venta',
      target: r'Venta',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _movimientoInventarioGetId,
  getLinks: _movimientoInventarioGetLinks,
  attach: _movimientoInventarioAttach,
  version: '3.1.0+1',
);

int _movimientoInventarioEstimateSize(
  MovimientoInventario object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.tipoMovimiento.length * 3;
  return bytesCount;
}

void _movimientoInventarioSerialize(
  MovimientoInventario object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeDateTime(offsets[1], object.fecha);
  writer.writeString(offsets[2], object.tipoMovimiento);
}

MovimientoInventario _movimientoInventarioDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MovimientoInventario();
  object.cantidad = reader.readLong(offsets[0]);
  object.fecha = reader.readDateTime(offsets[1]);
  object.id = id;
  object.tipoMovimiento = reader.readString(offsets[2]);
  return object;
}

P _movimientoInventarioDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _movimientoInventarioGetId(MovimientoInventario object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _movimientoInventarioGetLinks(
    MovimientoInventario object) {
  return [object.producto, object.usuario, object.venta];
}

void _movimientoInventarioAttach(
    IsarCollection<dynamic> col, Id id, MovimientoInventario object) {
  object.id = id;
  object.producto.attach(col, col.isar.collection<Producto>(), r'producto', id);
  object.usuario.attach(col, col.isar.collection<Usuario>(), r'usuario', id);
  object.venta.attach(col, col.isar.collection<Venta>(), r'venta', id);
}

extension MovimientoInventarioQueryWhereSort
    on QueryBuilder<MovimientoInventario, MovimientoInventario, QWhere> {
  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MovimientoInventarioQueryWhere
    on QueryBuilder<MovimientoInventario, MovimientoInventario, QWhereClause> {
  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterWhereClause>
      idBetween(
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

extension MovimientoInventarioQueryFilter on QueryBuilder<MovimientoInventario,
    MovimientoInventario, QFilterCondition> {
  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> cantidadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> cantidadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> cantidadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> cantidadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> fechaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> fechaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> fechaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> fechaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoMovimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
          QAfterFilterCondition>
      tipoMovimientoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
          QAfterFilterCondition>
      tipoMovimientoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoMovimiento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoMovimiento',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> tipoMovimientoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoMovimiento',
        value: '',
      ));
    });
  }
}

extension MovimientoInventarioQueryObject on QueryBuilder<MovimientoInventario,
    MovimientoInventario, QFilterCondition> {}

extension MovimientoInventarioQueryLinks on QueryBuilder<MovimientoInventario,
    MovimientoInventario, QFilterCondition> {
  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> producto(FilterQuery<Producto> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'producto');
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> productoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'producto', 0, true, 0, true);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> usuario(FilterQuery<Usuario> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'usuario');
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> usuarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usuario', 0, true, 0, true);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> venta(FilterQuery<Venta> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'venta');
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario,
      QAfterFilterCondition> ventaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'venta', 0, true, 0, true);
    });
  }
}

extension MovimientoInventarioQuerySortBy
    on QueryBuilder<MovimientoInventario, MovimientoInventario, QSortBy> {
  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      sortByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }
}

extension MovimientoInventarioQuerySortThenBy
    on QueryBuilder<MovimientoInventario, MovimientoInventario, QSortThenBy> {
  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QAfterSortBy>
      thenByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }
}

extension MovimientoInventarioQueryWhereDistinct
    on QueryBuilder<MovimientoInventario, MovimientoInventario, QDistinct> {
  QueryBuilder<MovimientoInventario, MovimientoInventario, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QDistinct>
      distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<MovimientoInventario, MovimientoInventario, QDistinct>
      distinctByTipoMovimiento({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoMovimiento',
          caseSensitive: caseSensitive);
    });
  }
}

extension MovimientoInventarioQueryProperty on QueryBuilder<
    MovimientoInventario, MovimientoInventario, QQueryProperty> {
  QueryBuilder<MovimientoInventario, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MovimientoInventario, int, QQueryOperations> cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<MovimientoInventario, DateTime, QQueryOperations>
      fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<MovimientoInventario, String, QQueryOperations>
      tipoMovimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoMovimiento');
    });
  }
}
