// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_report.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyReportCollection on Isar {
  IsarCollection<WeeklyReport> get weeklyReports => this.collection();
}

const WeeklyReportSchema = CollectionSchema(
  name: r'WeeklyReport',
  id: 3079724255683139525,
  properties: {
    r'aiSummary': PropertySchema(
      id: 0,
      name: r'aiSummary',
      type: IsarType.string,
    ),
    r'categoryBreakdownJson': PropertySchema(
      id: 1,
      name: r'categoryBreakdownJson',
      type: IsarType.string,
    ),
    r'generatedAt': PropertySchema(
      id: 2,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'totalExpense': PropertySchema(
      id: 3,
      name: r'totalExpense',
      type: IsarType.double,
    ),
    r'weekEndDate': PropertySchema(
      id: 4,
      name: r'weekEndDate',
      type: IsarType.dateTime,
    ),
    r'weekStartDate': PropertySchema(
      id: 5,
      name: r'weekStartDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _weeklyReportEstimateSize,
  serialize: _weeklyReportSerialize,
  deserialize: _weeklyReportDeserialize,
  deserializeProp: _weeklyReportDeserializeProp,
  idName: r'id',
  indexes: {
    r'weekStartDate': IndexSchema(
      id: 7906057668223877157,
      name: r'weekStartDate',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'weekStartDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weeklyReportGetId,
  getLinks: _weeklyReportGetLinks,
  attach: _weeklyReportAttach,
  version: '3.1.0+1',
);

int _weeklyReportEstimateSize(
  WeeklyReport object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiSummary.length * 3;
  bytesCount += 3 + object.categoryBreakdownJson.length * 3;
  return bytesCount;
}

void _weeklyReportSerialize(
  WeeklyReport object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiSummary);
  writer.writeString(offsets[1], object.categoryBreakdownJson);
  writer.writeDateTime(offsets[2], object.generatedAt);
  writer.writeDouble(offsets[3], object.totalExpense);
  writer.writeDateTime(offsets[4], object.weekEndDate);
  writer.writeDateTime(offsets[5], object.weekStartDate);
}

WeeklyReport _weeklyReportDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyReport(
    aiSummary: reader.readString(offsets[0]),
    categoryBreakdownJson: reader.readString(offsets[1]),
    generatedAt: reader.readDateTime(offsets[2]),
    id: id,
    totalExpense: reader.readDouble(offsets[3]),
    weekEndDate: reader.readDateTime(offsets[4]),
    weekStartDate: reader.readDateTime(offsets[5]),
  );
  return object;
}

P _weeklyReportDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyReportGetId(WeeklyReport object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weeklyReportGetLinks(WeeklyReport object) {
  return [];
}

void _weeklyReportAttach(
    IsarCollection<dynamic> col, Id id, WeeklyReport object) {
  object.id = id;
}

extension WeeklyReportByIndex on IsarCollection<WeeklyReport> {
  Future<WeeklyReport?> getByWeekStartDate(DateTime weekStartDate) {
    return getByIndex(r'weekStartDate', [weekStartDate]);
  }

  WeeklyReport? getByWeekStartDateSync(DateTime weekStartDate) {
    return getByIndexSync(r'weekStartDate', [weekStartDate]);
  }

  Future<bool> deleteByWeekStartDate(DateTime weekStartDate) {
    return deleteByIndex(r'weekStartDate', [weekStartDate]);
  }

  bool deleteByWeekStartDateSync(DateTime weekStartDate) {
    return deleteByIndexSync(r'weekStartDate', [weekStartDate]);
  }

  Future<List<WeeklyReport?>> getAllByWeekStartDate(
      List<DateTime> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'weekStartDate', values);
  }

  List<WeeklyReport?> getAllByWeekStartDateSync(
      List<DateTime> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'weekStartDate', values);
  }

  Future<int> deleteAllByWeekStartDate(List<DateTime> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'weekStartDate', values);
  }

  int deleteAllByWeekStartDateSync(List<DateTime> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'weekStartDate', values);
  }

  Future<Id> putByWeekStartDate(WeeklyReport object) {
    return putByIndex(r'weekStartDate', object);
  }

  Id putByWeekStartDateSync(WeeklyReport object, {bool saveLinks = true}) {
    return putByIndexSync(r'weekStartDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWeekStartDate(List<WeeklyReport> objects) {
    return putAllByIndex(r'weekStartDate', objects);
  }

  List<Id> putAllByWeekStartDateSync(List<WeeklyReport> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'weekStartDate', objects, saveLinks: saveLinks);
  }
}

extension WeeklyReportQueryWhereSort
    on QueryBuilder<WeeklyReport, WeeklyReport, QWhere> {
  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhere> anyWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'weekStartDate'),
      );
    });
  }
}

extension WeeklyReportQueryWhere
    on QueryBuilder<WeeklyReport, WeeklyReport, QWhereClause> {
  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause> idBetween(
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

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause>
      weekStartDateEqualTo(DateTime weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekStartDate',
        value: [weekStartDate],
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause>
      weekStartDateNotEqualTo(DateTime weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause>
      weekStartDateGreaterThan(
    DateTime weekStartDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [weekStartDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause>
      weekStartDateLessThan(
    DateTime weekStartDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [],
        upper: [weekStartDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterWhereClause>
      weekStartDateBetween(
    DateTime lowerWeekStartDate,
    DateTime upperWeekStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [lowerWeekStartDate],
        includeLower: includeLower,
        upper: [upperWeekStartDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeeklyReportQueryFilter
    on QueryBuilder<WeeklyReport, WeeklyReport, QFilterCondition> {
  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      aiSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryBreakdownJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryBreakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryBreakdownJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryBreakdownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      categoryBreakdownJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryBreakdownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      generatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      generatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      totalExpenseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      totalExpenseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      totalExpenseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      totalExpenseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalExpense',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekEndDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekEndDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekEndDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekEndDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekStartDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekStartDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterFilterCondition>
      weekStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeeklyReportQueryObject
    on QueryBuilder<WeeklyReport, WeeklyReport, QFilterCondition> {}

extension WeeklyReportQueryLinks
    on QueryBuilder<WeeklyReport, WeeklyReport, QFilterCondition> {}

extension WeeklyReportQuerySortBy
    on QueryBuilder<WeeklyReport, WeeklyReport, QSortBy> {
  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByCategoryBreakdownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBreakdownJson', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByCategoryBreakdownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBreakdownJson', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByTotalExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByWeekEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> sortByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      sortByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension WeeklyReportQuerySortThenBy
    on QueryBuilder<WeeklyReport, WeeklyReport, QSortThenBy> {
  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByCategoryBreakdownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBreakdownJson', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByCategoryBreakdownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBreakdownJson', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByTotalExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByWeekEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy> thenByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QAfterSortBy>
      thenByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension WeeklyReportQueryWhereDistinct
    on QueryBuilder<WeeklyReport, WeeklyReport, QDistinct> {
  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct> distinctByAiSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiSummary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct>
      distinctByCategoryBreakdownJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryBreakdownJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct> distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct> distinctByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalExpense');
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct> distinctByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekEndDate');
    });
  }

  QueryBuilder<WeeklyReport, WeeklyReport, QDistinct>
      distinctByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartDate');
    });
  }
}

extension WeeklyReportQueryProperty
    on QueryBuilder<WeeklyReport, WeeklyReport, QQueryProperty> {
  QueryBuilder<WeeklyReport, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyReport, String, QQueryOperations> aiSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiSummary');
    });
  }

  QueryBuilder<WeeklyReport, String, QQueryOperations>
      categoryBreakdownJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryBreakdownJson');
    });
  }

  QueryBuilder<WeeklyReport, DateTime, QQueryOperations> generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<WeeklyReport, double, QQueryOperations> totalExpenseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalExpense');
    });
  }

  QueryBuilder<WeeklyReport, DateTime, QQueryOperations> weekEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekEndDate');
    });
  }

  QueryBuilder<WeeklyReport, DateTime, QQueryOperations>
      weekStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartDate');
    });
  }
}
