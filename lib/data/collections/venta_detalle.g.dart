// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta_detalle.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVentaDetalleCollection on Isar {
  IsarCollection<VentaDetalle> get ventaDetalles => this.collection();
}

const VentaDetalleSchema = CollectionSchema(
  name: r'VentaDetalle',
  id: 39239136131672694,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.long,
    ),
    r'precioUnitarioVenta': PropertySchema(
      id: 1,
      name: r'precioUnitarioVenta',
      type: IsarType.double,
    )
  },
  estimateSize: _ventaDetalleEstimateSize,
  serialize: _ventaDetalleSerialize,
  deserialize: _ventaDetalleDeserialize,
  deserializeProp: _ventaDetalleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'venta': LinkSchema(
      id: 1434628401923234129,
      name: r'venta',
      target: r'Venta',
      single: true,
    ),
    r'producto': LinkSchema(
      id: 8281917133808710499,
      name: r'producto',
      target: r'Producto',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _ventaDetalleGetId,
  getLinks: _ventaDetalleGetLinks,
  attach: _ventaDetalleAttach,
  version: '3.1.0+1',
);

int _ventaDetalleEstimateSize(
  VentaDetalle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _ventaDetalleSerialize(
  VentaDetalle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cantidad);
  writer.writeDouble(offsets[1], object.precioUnitarioVenta);
}

VentaDetalle _ventaDetalleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaDetalle();
  object.cantidad = reader.readLong(offsets[0]);
  object.id = id;
  object.precioUnitarioVenta = reader.readDouble(offsets[1]);
  return object;
}

P _ventaDetalleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaDetalleGetId(VentaDetalle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaDetalleGetLinks(VentaDetalle object) {
  return [object.venta, object.producto];
}

void _ventaDetalleAttach(
    IsarCollection<dynamic> col, Id id, VentaDetalle object) {
  object.id = id;
  object.venta.attach(col, col.isar.collection<Venta>(), r'venta', id);
  object.producto.attach(col, col.isar.collection<Producto>(), r'producto', id);
}

extension VentaDetalleQueryWhereSort
    on QueryBuilder<VentaDetalle, VentaDetalle, QWhere> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VentaDetalleQueryWhere
    on QueryBuilder<VentaDetalle, VentaDetalle, QWhereClause> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterWhereClause> idBetween(
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

extension VentaDetalleQueryFilter
    on QueryBuilder<VentaDetalle, VentaDetalle, QFilterCondition> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      cantidadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      cantidadGreaterThan(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      cantidadLessThan(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      cantidadBetween(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      precioUnitarioVentaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioUnitarioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      precioUnitarioVentaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioUnitarioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      precioUnitarioVentaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioUnitarioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      precioUnitarioVentaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioUnitarioVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension VentaDetalleQueryObject
    on QueryBuilder<VentaDetalle, VentaDetalle, QFilterCondition> {}

extension VentaDetalleQueryLinks
    on QueryBuilder<VentaDetalle, VentaDetalle, QFilterCondition> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> venta(
      FilterQuery<Venta> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'venta');
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      ventaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'venta', 0, true, 0, true);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition> producto(
      FilterQuery<Producto> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'producto');
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterFilterCondition>
      productoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'producto', 0, true, 0, true);
    });
  }
}

extension VentaDetalleQuerySortBy
    on QueryBuilder<VentaDetalle, VentaDetalle, QSortBy> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy>
      sortByPrecioUnitarioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitarioVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy>
      sortByPrecioUnitarioVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitarioVenta', Sort.desc);
    });
  }
}

extension VentaDetalleQuerySortThenBy
    on QueryBuilder<VentaDetalle, VentaDetalle, QSortThenBy> {
  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy>
      thenByPrecioUnitarioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitarioVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QAfterSortBy>
      thenByPrecioUnitarioVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitarioVenta', Sort.desc);
    });
  }
}

extension VentaDetalleQueryWhereDistinct
    on QueryBuilder<VentaDetalle, VentaDetalle, QDistinct> {
  QueryBuilder<VentaDetalle, VentaDetalle, QDistinct> distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<VentaDetalle, VentaDetalle, QDistinct>
      distinctByPrecioUnitarioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioUnitarioVenta');
    });
  }
}

extension VentaDetalleQueryProperty
    on QueryBuilder<VentaDetalle, VentaDetalle, QQueryProperty> {
  QueryBuilder<VentaDetalle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VentaDetalle, int, QQueryOperations> cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<VentaDetalle, double, QQueryOperations>
      precioUnitarioVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioUnitarioVenta');
    });
  }
}
