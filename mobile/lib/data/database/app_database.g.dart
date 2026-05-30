// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppStateTableTable extends AppStateTable
    with TableInfo<$AppStateTableTable, AppStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppStateTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppStateTableTable createAlias(String alias) {
    return $AppStateTableTable(attachedDatabase, alias);
  }
}

class AppStateTableData extends DataClass
    implements Insertable<AppStateTableData> {
  final String key;
  final String value;
  const AppStateTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppStateTableCompanion toCompanion(bool nullToAbsent) {
    return AppStateTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppStateTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppStateTableData copyWith({String? key, String? value}) =>
      AppStateTableData(key: key ?? this.key, value: value ?? this.value);
  AppStateTableData copyWithCompanion(AppStateTableCompanion data) {
    return AppStateTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppStateTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppStateTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppStateTableCompanion extends UpdateCompanion<AppStateTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppStateTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppStateTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppStateTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppStateTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppStateTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppStateTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoursesTableTable extends CoursesTable
    with TableInfo<$CoursesTableTable, CoursesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _enrollCodeMeta = const VerificationMeta(
    'enrollCode',
  );
  @override
  late final GeneratedColumn<String> enrollCode = GeneratedColumn<String>(
    'enroll_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    section,
    description,
    room,
    enrollCode,
    state,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoursesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('enroll_code')) {
      context.handle(
        _enrollCodeMeta,
        enrollCode.isAcceptableOrUnknown(data['enroll_code']!, _enrollCodeMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoursesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoursesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      )!,
      enrollCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enroll_code'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoursesTableTable createAlias(String alias) {
    return $CoursesTableTable(attachedDatabase, alias);
  }
}

class CoursesTableData extends DataClass
    implements Insertable<CoursesTableData> {
  final String id;
  final String name;
  final String section;
  final String description;
  final String room;
  final String enrollCode;
  final String state;
  final DateTime updatedAt;
  const CoursesTableData({
    required this.id,
    required this.name,
    required this.section,
    required this.description,
    required this.room,
    required this.enrollCode,
    required this.state,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['section'] = Variable<String>(section);
    map['description'] = Variable<String>(description);
    map['room'] = Variable<String>(room);
    map['enroll_code'] = Variable<String>(enrollCode);
    map['state'] = Variable<String>(state);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoursesTableCompanion toCompanion(bool nullToAbsent) {
    return CoursesTableCompanion(
      id: Value(id),
      name: Value(name),
      section: Value(section),
      description: Value(description),
      room: Value(room),
      enrollCode: Value(enrollCode),
      state: Value(state),
      updatedAt: Value(updatedAt),
    );
  }

  factory CoursesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoursesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      section: serializer.fromJson<String>(json['section']),
      description: serializer.fromJson<String>(json['description']),
      room: serializer.fromJson<String>(json['room']),
      enrollCode: serializer.fromJson<String>(json['enrollCode']),
      state: serializer.fromJson<String>(json['state']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'section': serializer.toJson<String>(section),
      'description': serializer.toJson<String>(description),
      'room': serializer.toJson<String>(room),
      'enrollCode': serializer.toJson<String>(enrollCode),
      'state': serializer.toJson<String>(state),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CoursesTableData copyWith({
    String? id,
    String? name,
    String? section,
    String? description,
    String? room,
    String? enrollCode,
    String? state,
    DateTime? updatedAt,
  }) => CoursesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    section: section ?? this.section,
    description: description ?? this.description,
    room: room ?? this.room,
    enrollCode: enrollCode ?? this.enrollCode,
    state: state ?? this.state,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CoursesTableData copyWithCompanion(CoursesTableCompanion data) {
    return CoursesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      section: data.section.present ? data.section.value : this.section,
      description: data.description.present
          ? data.description.value
          : this.description,
      room: data.room.present ? data.room.value : this.room,
      enrollCode: data.enrollCode.present
          ? data.enrollCode.value
          : this.enrollCode,
      state: data.state.present ? data.state.value : this.state,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoursesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('section: $section, ')
          ..write('description: $description, ')
          ..write('room: $room, ')
          ..write('enrollCode: $enrollCode, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    section,
    description,
    room,
    enrollCode,
    state,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoursesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.section == this.section &&
          other.description == this.description &&
          other.room == this.room &&
          other.enrollCode == this.enrollCode &&
          other.state == this.state &&
          other.updatedAt == this.updatedAt);
}

class CoursesTableCompanion extends UpdateCompanion<CoursesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> section;
  final Value<String> description;
  final Value<String> room;
  final Value<String> enrollCode;
  final Value<String> state;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CoursesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.section = const Value.absent(),
    this.description = const Value.absent(),
    this.room = const Value.absent(),
    this.enrollCode = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesTableCompanion.insert({
    required String id,
    required String name,
    this.section = const Value.absent(),
    this.description = const Value.absent(),
    this.room = const Value.absent(),
    this.enrollCode = const Value.absent(),
    this.state = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CoursesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? section,
    Expression<String>? description,
    Expression<String>? room,
    Expression<String>? enrollCode,
    Expression<String>? state,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (section != null) 'section': section,
      if (description != null) 'description': description,
      if (room != null) 'room': room,
      if (enrollCode != null) 'enroll_code': enrollCode,
      if (state != null) 'state': state,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? section,
    Value<String>? description,
    Value<String>? room,
    Value<String>? enrollCode,
    Value<String>? state,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoursesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      description: description ?? this.description,
      room: room ?? this.room,
      enrollCode: enrollCode ?? this.enrollCode,
      state: state ?? this.state,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (enrollCode.present) {
      map['enroll_code'] = Variable<String>(enrollCode.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('section: $section, ')
          ..write('description: $description, ')
          ..write('room: $room, ')
          ..write('enrollCode: $enrollCode, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTableTable extends AssignmentsTable
    with TableInfo<$AssignmentsTableTable, AssignmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creationTimeMeta = const VerificationMeta(
    'creationTime',
  );
  @override
  late final GeneratedColumn<String> creationTime = GeneratedColumn<String>(
    'creation_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updateTimeMeta = const VerificationMeta(
    'updateTime',
  );
  @override
  late final GeneratedColumn<String> updateTime = GeneratedColumn<String>(
    'update_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _maxPointsMeta = const VerificationMeta(
    'maxPoints',
  );
  @override
  late final GeneratedColumn<double> maxPoints = GeneratedColumn<double>(
    'max_points',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _workTypeMeta = const VerificationMeta(
    'workType',
  );
  @override
  late final GeneratedColumn<String> workType = GeneratedColumn<String>(
    'work_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _alternateLinkMeta = const VerificationMeta(
    'alternateLink',
  );
  @override
  late final GeneratedColumn<String> alternateLink = GeneratedColumn<String>(
    'alternate_link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _materialsJsonMeta = const VerificationMeta(
    'materialsJson',
  );
  @override
  late final GeneratedColumn<String> materialsJson = GeneratedColumn<String>(
    'materials_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    state,
    dueDate,
    creationTime,
    updateTime,
    maxPoints,
    workType,
    alternateLink,
    courseId,
    courseName,
    materialsJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('creation_time')) {
      context.handle(
        _creationTimeMeta,
        creationTime.isAcceptableOrUnknown(
          data['creation_time']!,
          _creationTimeMeta,
        ),
      );
    }
    if (data.containsKey('update_time')) {
      context.handle(
        _updateTimeMeta,
        updateTime.isAcceptableOrUnknown(data['update_time']!, _updateTimeMeta),
      );
    }
    if (data.containsKey('max_points')) {
      context.handle(
        _maxPointsMeta,
        maxPoints.isAcceptableOrUnknown(data['max_points']!, _maxPointsMeta),
      );
    }
    if (data.containsKey('work_type')) {
      context.handle(
        _workTypeMeta,
        workType.isAcceptableOrUnknown(data['work_type']!, _workTypeMeta),
      );
    }
    if (data.containsKey('alternate_link')) {
      context.handle(
        _alternateLinkMeta,
        alternateLink.isAcceptableOrUnknown(
          data['alternate_link']!,
          _alternateLinkMeta,
        ),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    }
    if (data.containsKey('materials_json')) {
      context.handle(
        _materialsJsonMeta,
        materialsJson.isAcceptableOrUnknown(
          data['materials_json']!,
          _materialsJsonMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      creationTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creation_time'],
      )!,
      updateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}update_time'],
      )!,
      maxPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_points'],
      )!,
      workType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_type'],
      )!,
      alternateLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_link'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      materialsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materials_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $AssignmentsTableTable createAlias(String alias) {
    return $AssignmentsTableTable(attachedDatabase, alias);
  }
}

class AssignmentsTableData extends DataClass
    implements Insertable<AssignmentsTableData> {
  final String id;
  final String title;
  final String description;
  final String state;
  final String dueDate;
  final String creationTime;
  final String updateTime;
  final double maxPoints;
  final String workType;
  final String alternateLink;
  final String courseId;
  final String courseName;
  final String materialsJson;
  final DateTime cachedAt;
  const AssignmentsTableData({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
    required this.dueDate,
    required this.creationTime,
    required this.updateTime,
    required this.maxPoints,
    required this.workType,
    required this.alternateLink,
    required this.courseId,
    required this.courseName,
    required this.materialsJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['state'] = Variable<String>(state);
    map['due_date'] = Variable<String>(dueDate);
    map['creation_time'] = Variable<String>(creationTime);
    map['update_time'] = Variable<String>(updateTime);
    map['max_points'] = Variable<double>(maxPoints);
    map['work_type'] = Variable<String>(workType);
    map['alternate_link'] = Variable<String>(alternateLink);
    map['course_id'] = Variable<String>(courseId);
    map['course_name'] = Variable<String>(courseName);
    map['materials_json'] = Variable<String>(materialsJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  AssignmentsTableCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      state: Value(state),
      dueDate: Value(dueDate),
      creationTime: Value(creationTime),
      updateTime: Value(updateTime),
      maxPoints: Value(maxPoints),
      workType: Value(workType),
      alternateLink: Value(alternateLink),
      courseId: Value(courseId),
      courseName: Value(courseName),
      materialsJson: Value(materialsJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory AssignmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      state: serializer.fromJson<String>(json['state']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      creationTime: serializer.fromJson<String>(json['creationTime']),
      updateTime: serializer.fromJson<String>(json['updateTime']),
      maxPoints: serializer.fromJson<double>(json['maxPoints']),
      workType: serializer.fromJson<String>(json['workType']),
      alternateLink: serializer.fromJson<String>(json['alternateLink']),
      courseId: serializer.fromJson<String>(json['courseId']),
      courseName: serializer.fromJson<String>(json['courseName']),
      materialsJson: serializer.fromJson<String>(json['materialsJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'state': serializer.toJson<String>(state),
      'dueDate': serializer.toJson<String>(dueDate),
      'creationTime': serializer.toJson<String>(creationTime),
      'updateTime': serializer.toJson<String>(updateTime),
      'maxPoints': serializer.toJson<double>(maxPoints),
      'workType': serializer.toJson<String>(workType),
      'alternateLink': serializer.toJson<String>(alternateLink),
      'courseId': serializer.toJson<String>(courseId),
      'courseName': serializer.toJson<String>(courseName),
      'materialsJson': serializer.toJson<String>(materialsJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  AssignmentsTableData copyWith({
    String? id,
    String? title,
    String? description,
    String? state,
    String? dueDate,
    String? creationTime,
    String? updateTime,
    double? maxPoints,
    String? workType,
    String? alternateLink,
    String? courseId,
    String? courseName,
    String? materialsJson,
    DateTime? cachedAt,
  }) => AssignmentsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    state: state ?? this.state,
    dueDate: dueDate ?? this.dueDate,
    creationTime: creationTime ?? this.creationTime,
    updateTime: updateTime ?? this.updateTime,
    maxPoints: maxPoints ?? this.maxPoints,
    workType: workType ?? this.workType,
    alternateLink: alternateLink ?? this.alternateLink,
    courseId: courseId ?? this.courseId,
    courseName: courseName ?? this.courseName,
    materialsJson: materialsJson ?? this.materialsJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  AssignmentsTableData copyWithCompanion(AssignmentsTableCompanion data) {
    return AssignmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      state: data.state.present ? data.state.value : this.state,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      creationTime: data.creationTime.present
          ? data.creationTime.value
          : this.creationTime,
      updateTime: data.updateTime.present
          ? data.updateTime.value
          : this.updateTime,
      maxPoints: data.maxPoints.present ? data.maxPoints.value : this.maxPoints,
      workType: data.workType.present ? data.workType.value : this.workType,
      alternateLink: data.alternateLink.present
          ? data.alternateLink.value
          : this.alternateLink,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      materialsJson: data.materialsJson.present
          ? data.materialsJson.value
          : this.materialsJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('state: $state, ')
          ..write('dueDate: $dueDate, ')
          ..write('creationTime: $creationTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('maxPoints: $maxPoints, ')
          ..write('workType: $workType, ')
          ..write('alternateLink: $alternateLink, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('materialsJson: $materialsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    state,
    dueDate,
    creationTime,
    updateTime,
    maxPoints,
    workType,
    alternateLink,
    courseId,
    courseName,
    materialsJson,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.state == this.state &&
          other.dueDate == this.dueDate &&
          other.creationTime == this.creationTime &&
          other.updateTime == this.updateTime &&
          other.maxPoints == this.maxPoints &&
          other.workType == this.workType &&
          other.alternateLink == this.alternateLink &&
          other.courseId == this.courseId &&
          other.courseName == this.courseName &&
          other.materialsJson == this.materialsJson &&
          other.cachedAt == this.cachedAt);
}

class AssignmentsTableCompanion extends UpdateCompanion<AssignmentsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> state;
  final Value<String> dueDate;
  final Value<String> creationTime;
  final Value<String> updateTime;
  final Value<double> maxPoints;
  final Value<String> workType;
  final Value<String> alternateLink;
  final Value<String> courseId;
  final Value<String> courseName;
  final Value<String> materialsJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const AssignmentsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.state = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.maxPoints = const Value.absent(),
    this.workType = const Value.absent(),
    this.alternateLink = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.materialsJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.state = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.maxPoints = const Value.absent(),
    this.workType = const Value.absent(),
    this.alternateLink = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.materialsJson = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       cachedAt = Value(cachedAt);
  static Insertable<AssignmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? state,
    Expression<String>? dueDate,
    Expression<String>? creationTime,
    Expression<String>? updateTime,
    Expression<double>? maxPoints,
    Expression<String>? workType,
    Expression<String>? alternateLink,
    Expression<String>? courseId,
    Expression<String>? courseName,
    Expression<String>? materialsJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (state != null) 'state': state,
      if (dueDate != null) 'due_date': dueDate,
      if (creationTime != null) 'creation_time': creationTime,
      if (updateTime != null) 'update_time': updateTime,
      if (maxPoints != null) 'max_points': maxPoints,
      if (workType != null) 'work_type': workType,
      if (alternateLink != null) 'alternate_link': alternateLink,
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (materialsJson != null) 'materials_json': materialsJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? state,
    Value<String>? dueDate,
    Value<String>? creationTime,
    Value<String>? updateTime,
    Value<double>? maxPoints,
    Value<String>? workType,
    Value<String>? alternateLink,
    Value<String>? courseId,
    Value<String>? courseName,
    Value<String>? materialsJson,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return AssignmentsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      state: state ?? this.state,
      dueDate: dueDate ?? this.dueDate,
      creationTime: creationTime ?? this.creationTime,
      updateTime: updateTime ?? this.updateTime,
      maxPoints: maxPoints ?? this.maxPoints,
      workType: workType ?? this.workType,
      alternateLink: alternateLink ?? this.alternateLink,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      materialsJson: materialsJson ?? this.materialsJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<String>(creationTime.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<String>(updateTime.value);
    }
    if (maxPoints.present) {
      map['max_points'] = Variable<double>(maxPoints.value);
    }
    if (workType.present) {
      map['work_type'] = Variable<String>(workType.value);
    }
    if (alternateLink.present) {
      map['alternate_link'] = Variable<String>(alternateLink.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (materialsJson.present) {
      map['materials_json'] = Variable<String>(materialsJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('state: $state, ')
          ..write('dueDate: $dueDate, ')
          ..write('creationTime: $creationTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('maxPoints: $maxPoints, ')
          ..write('workType: $workType, ')
          ..write('alternateLink: $alternateLink, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('materialsJson: $materialsJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MailsTableTable extends MailsTable
    with TableInfo<$MailsTableTable, MailsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MailsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fromAddrMeta = const VerificationMeta(
    'fromAddr',
  );
  @override
  late final GeneratedColumn<String> fromAddr = GeneratedColumn<String>(
    'from_addr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _toAddrMeta = const VerificationMeta('toAddr');
  @override
  late final GeneratedColumn<String> toAddr = GeneratedColumn<String>(
    'to_addr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _attachmentsJsonMeta = const VerificationMeta(
    'attachmentsJson',
  );
  @override
  late final GeneratedColumn<String> attachmentsJson = GeneratedColumn<String>(
    'attachments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _serverCreatedAtMeta = const VerificationMeta(
    'serverCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverCreatedAt =
      GeneratedColumn<DateTime>(
        'server_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    subject,
    fromAddr,
    toAddr,
    date,
    snippet,
    body,
    attachmentsJson,
    serverCreatedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mails';
  @override
  VerificationContext validateIntegrity(
    Insertable<MailsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('from_addr')) {
      context.handle(
        _fromAddrMeta,
        fromAddr.isAcceptableOrUnknown(data['from_addr']!, _fromAddrMeta),
      );
    }
    if (data.containsKey('to_addr')) {
      context.handle(
        _toAddrMeta,
        toAddr.isAcceptableOrUnknown(data['to_addr']!, _toAddrMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('attachments_json')) {
      context.handle(
        _attachmentsJsonMeta,
        attachmentsJson.isAcceptableOrUnknown(
          data['attachments_json']!,
          _attachmentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('server_created_at')) {
      context.handle(
        _serverCreatedAtMeta,
        serverCreatedAt.isAcceptableOrUnknown(
          data['server_created_at']!,
          _serverCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverCreatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MailsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MailsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      fromAddr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_addr'],
      )!,
      toAddr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_addr'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      attachmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachments_json'],
      )!,
      serverCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_created_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $MailsTableTable createAlias(String alias) {
    return $MailsTableTable(attachedDatabase, alias);
  }
}

class MailsTableData extends DataClass implements Insertable<MailsTableData> {
  final String id;
  final String threadId;
  final String subject;
  final String fromAddr;
  final String toAddr;
  final String date;
  final String snippet;
  final String body;
  final String attachmentsJson;
  final DateTime serverCreatedAt;
  final DateTime cachedAt;
  const MailsTableData({
    required this.id,
    required this.threadId,
    required this.subject,
    required this.fromAddr,
    required this.toAddr,
    required this.date,
    required this.snippet,
    required this.body,
    required this.attachmentsJson,
    required this.serverCreatedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['subject'] = Variable<String>(subject);
    map['from_addr'] = Variable<String>(fromAddr);
    map['to_addr'] = Variable<String>(toAddr);
    map['date'] = Variable<String>(date);
    map['snippet'] = Variable<String>(snippet);
    map['body'] = Variable<String>(body);
    map['attachments_json'] = Variable<String>(attachmentsJson);
    map['server_created_at'] = Variable<DateTime>(serverCreatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  MailsTableCompanion toCompanion(bool nullToAbsent) {
    return MailsTableCompanion(
      id: Value(id),
      threadId: Value(threadId),
      subject: Value(subject),
      fromAddr: Value(fromAddr),
      toAddr: Value(toAddr),
      date: Value(date),
      snippet: Value(snippet),
      body: Value(body),
      attachmentsJson: Value(attachmentsJson),
      serverCreatedAt: Value(serverCreatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory MailsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MailsTableData(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      subject: serializer.fromJson<String>(json['subject']),
      fromAddr: serializer.fromJson<String>(json['fromAddr']),
      toAddr: serializer.fromJson<String>(json['toAddr']),
      date: serializer.fromJson<String>(json['date']),
      snippet: serializer.fromJson<String>(json['snippet']),
      body: serializer.fromJson<String>(json['body']),
      attachmentsJson: serializer.fromJson<String>(json['attachmentsJson']),
      serverCreatedAt: serializer.fromJson<DateTime>(json['serverCreatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'subject': serializer.toJson<String>(subject),
      'fromAddr': serializer.toJson<String>(fromAddr),
      'toAddr': serializer.toJson<String>(toAddr),
      'date': serializer.toJson<String>(date),
      'snippet': serializer.toJson<String>(snippet),
      'body': serializer.toJson<String>(body),
      'attachmentsJson': serializer.toJson<String>(attachmentsJson),
      'serverCreatedAt': serializer.toJson<DateTime>(serverCreatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  MailsTableData copyWith({
    String? id,
    String? threadId,
    String? subject,
    String? fromAddr,
    String? toAddr,
    String? date,
    String? snippet,
    String? body,
    String? attachmentsJson,
    DateTime? serverCreatedAt,
    DateTime? cachedAt,
  }) => MailsTableData(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    subject: subject ?? this.subject,
    fromAddr: fromAddr ?? this.fromAddr,
    toAddr: toAddr ?? this.toAddr,
    date: date ?? this.date,
    snippet: snippet ?? this.snippet,
    body: body ?? this.body,
    attachmentsJson: attachmentsJson ?? this.attachmentsJson,
    serverCreatedAt: serverCreatedAt ?? this.serverCreatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  MailsTableData copyWithCompanion(MailsTableCompanion data) {
    return MailsTableData(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      subject: data.subject.present ? data.subject.value : this.subject,
      fromAddr: data.fromAddr.present ? data.fromAddr.value : this.fromAddr,
      toAddr: data.toAddr.present ? data.toAddr.value : this.toAddr,
      date: data.date.present ? data.date.value : this.date,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      body: data.body.present ? data.body.value : this.body,
      attachmentsJson: data.attachmentsJson.present
          ? data.attachmentsJson.value
          : this.attachmentsJson,
      serverCreatedAt: data.serverCreatedAt.present
          ? data.serverCreatedAt.value
          : this.serverCreatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MailsTableData(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('subject: $subject, ')
          ..write('fromAddr: $fromAddr, ')
          ..write('toAddr: $toAddr, ')
          ..write('date: $date, ')
          ..write('snippet: $snippet, ')
          ..write('body: $body, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    threadId,
    subject,
    fromAddr,
    toAddr,
    date,
    snippet,
    body,
    attachmentsJson,
    serverCreatedAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MailsTableData &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.subject == this.subject &&
          other.fromAddr == this.fromAddr &&
          other.toAddr == this.toAddr &&
          other.date == this.date &&
          other.snippet == this.snippet &&
          other.body == this.body &&
          other.attachmentsJson == this.attachmentsJson &&
          other.serverCreatedAt == this.serverCreatedAt &&
          other.cachedAt == this.cachedAt);
}

class MailsTableCompanion extends UpdateCompanion<MailsTableData> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> subject;
  final Value<String> fromAddr;
  final Value<String> toAddr;
  final Value<String> date;
  final Value<String> snippet;
  final Value<String> body;
  final Value<String> attachmentsJson;
  final Value<DateTime> serverCreatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const MailsTableCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.subject = const Value.absent(),
    this.fromAddr = const Value.absent(),
    this.toAddr = const Value.absent(),
    this.date = const Value.absent(),
    this.snippet = const Value.absent(),
    this.body = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.serverCreatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MailsTableCompanion.insert({
    required String id,
    this.threadId = const Value.absent(),
    this.subject = const Value.absent(),
    this.fromAddr = const Value.absent(),
    this.toAddr = const Value.absent(),
    this.date = const Value.absent(),
    this.snippet = const Value.absent(),
    this.body = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    required DateTime serverCreatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serverCreatedAt = Value(serverCreatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<MailsTableData> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? subject,
    Expression<String>? fromAddr,
    Expression<String>? toAddr,
    Expression<String>? date,
    Expression<String>? snippet,
    Expression<String>? body,
    Expression<String>? attachmentsJson,
    Expression<DateTime>? serverCreatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (subject != null) 'subject': subject,
      if (fromAddr != null) 'from_addr': fromAddr,
      if (toAddr != null) 'to_addr': toAddr,
      if (date != null) 'date': date,
      if (snippet != null) 'snippet': snippet,
      if (body != null) 'body': body,
      if (attachmentsJson != null) 'attachments_json': attachmentsJson,
      if (serverCreatedAt != null) 'server_created_at': serverCreatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MailsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? threadId,
    Value<String>? subject,
    Value<String>? fromAddr,
    Value<String>? toAddr,
    Value<String>? date,
    Value<String>? snippet,
    Value<String>? body,
    Value<String>? attachmentsJson,
    Value<DateTime>? serverCreatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return MailsTableCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      subject: subject ?? this.subject,
      fromAddr: fromAddr ?? this.fromAddr,
      toAddr: toAddr ?? this.toAddr,
      date: date ?? this.date,
      snippet: snippet ?? this.snippet,
      body: body ?? this.body,
      attachmentsJson: attachmentsJson ?? this.attachmentsJson,
      serverCreatedAt: serverCreatedAt ?? this.serverCreatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (fromAddr.present) {
      map['from_addr'] = Variable<String>(fromAddr.value);
    }
    if (toAddr.present) {
      map['to_addr'] = Variable<String>(toAddr.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (attachmentsJson.present) {
      map['attachments_json'] = Variable<String>(attachmentsJson.value);
    }
    if (serverCreatedAt.present) {
      map['server_created_at'] = Variable<DateTime>(serverCreatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MailsTableCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('subject: $subject, ')
          ..write('fromAddr: $fromAddr, ')
          ..write('toAddr: $toAddr, ')
          ..write('date: $date, ')
          ..write('snippet: $snippet, ')
          ..write('body: $body, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppStateTableTable appStateTable = $AppStateTableTable(this);
  late final $CoursesTableTable coursesTable = $CoursesTableTable(this);
  late final $AssignmentsTableTable assignmentsTable = $AssignmentsTableTable(
    this,
  );
  late final $MailsTableTable mailsTable = $MailsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appStateTable,
    coursesTable,
    assignmentsTable,
    mailsTable,
  ];
}

typedef $$AppStateTableTableCreateCompanionBuilder =
    AppStateTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppStateTableTableUpdateCompanionBuilder =
    AppStateTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppStateTableTable,
          AppStateTableData,
          $$AppStateTableTableFilterComposer,
          $$AppStateTableTableOrderingComposer,
          $$AppStateTableTableAnnotationComposer,
          $$AppStateTableTableCreateCompanionBuilder,
          $$AppStateTableTableUpdateCompanionBuilder,
          (
            AppStateTableData,
            BaseReferences<
              _$AppDatabase,
              $AppStateTableTable,
              AppStateTableData
            >,
          ),
          AppStateTableData,
          PrefetchHooks Function()
        > {
  $$AppStateTableTableTableManager(_$AppDatabase db, $AppStateTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppStateTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppStateTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppStateTableTable,
      AppStateTableData,
      $$AppStateTableTableFilterComposer,
      $$AppStateTableTableOrderingComposer,
      $$AppStateTableTableAnnotationComposer,
      $$AppStateTableTableCreateCompanionBuilder,
      $$AppStateTableTableUpdateCompanionBuilder,
      (
        AppStateTableData,
        BaseReferences<_$AppDatabase, $AppStateTableTable, AppStateTableData>,
      ),
      AppStateTableData,
      PrefetchHooks Function()
    >;
typedef $$CoursesTableTableCreateCompanionBuilder =
    CoursesTableCompanion Function({
      required String id,
      required String name,
      Value<String> section,
      Value<String> description,
      Value<String> room,
      Value<String> enrollCode,
      Value<String> state,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CoursesTableTableUpdateCompanionBuilder =
    CoursesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> section,
      Value<String> description,
      Value<String> room,
      Value<String> enrollCode,
      Value<String> state,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CoursesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollCode => $composableBuilder(
    column: $table.enrollCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollCode => $composableBuilder(
    column: $table.enrollCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<String> get enrollCode => $composableBuilder(
    column: $table.enrollCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CoursesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTableTable,
          CoursesTableData,
          $$CoursesTableTableFilterComposer,
          $$CoursesTableTableOrderingComposer,
          $$CoursesTableTableAnnotationComposer,
          $$CoursesTableTableCreateCompanionBuilder,
          $$CoursesTableTableUpdateCompanionBuilder,
          (
            CoursesTableData,
            BaseReferences<_$AppDatabase, $CoursesTableTable, CoursesTableData>,
          ),
          CoursesTableData,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableTableManager(_$AppDatabase db, $CoursesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<String> enrollCode = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesTableCompanion(
                id: id,
                name: name,
                section: section,
                description: description,
                room: room,
                enrollCode: enrollCode,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> section = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<String> enrollCode = const Value.absent(),
                Value<String> state = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CoursesTableCompanion.insert(
                id: id,
                name: name,
                section: section,
                description: description,
                room: room,
                enrollCode: enrollCode,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTableTable,
      CoursesTableData,
      $$CoursesTableTableFilterComposer,
      $$CoursesTableTableOrderingComposer,
      $$CoursesTableTableAnnotationComposer,
      $$CoursesTableTableCreateCompanionBuilder,
      $$CoursesTableTableUpdateCompanionBuilder,
      (
        CoursesTableData,
        BaseReferences<_$AppDatabase, $CoursesTableTable, CoursesTableData>,
      ),
      CoursesTableData,
      PrefetchHooks Function()
    >;
typedef $$AssignmentsTableTableCreateCompanionBuilder =
    AssignmentsTableCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      Value<String> state,
      Value<String> dueDate,
      Value<String> creationTime,
      Value<String> updateTime,
      Value<double> maxPoints,
      Value<String> workType,
      Value<String> alternateLink,
      Value<String> courseId,
      Value<String> courseName,
      Value<String> materialsJson,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$AssignmentsTableTableUpdateCompanionBuilder =
    AssignmentsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> state,
      Value<String> dueDate,
      Value<String> creationTime,
      Value<String> updateTime,
      Value<double> maxPoints,
      Value<String> workType,
      Value<String> alternateLink,
      Value<String> courseId,
      Value<String> courseName,
      Value<String> materialsJson,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$AssignmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTableTable> {
  $$AssignmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creationTime => $composableBuilder(
    column: $table.creationTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxPoints => $composableBuilder(
    column: $table.maxPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialsJson => $composableBuilder(
    column: $table.materialsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssignmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTableTable> {
  $$AssignmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creationTime => $composableBuilder(
    column: $table.creationTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxPoints => $composableBuilder(
    column: $table.maxPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialsJson => $composableBuilder(
    column: $table.materialsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssignmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTableTable> {
  $$AssignmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get creationTime => $composableBuilder(
    column: $table.creationTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxPoints =>
      $composableBuilder(column: $table.maxPoints, builder: (column) => column);

  GeneratedColumn<String> get workType =>
      $composableBuilder(column: $table.workType, builder: (column) => column);

  GeneratedColumn<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get materialsJson => $composableBuilder(
    column: $table.materialsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$AssignmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentsTableTable,
          AssignmentsTableData,
          $$AssignmentsTableTableFilterComposer,
          $$AssignmentsTableTableOrderingComposer,
          $$AssignmentsTableTableAnnotationComposer,
          $$AssignmentsTableTableCreateCompanionBuilder,
          $$AssignmentsTableTableUpdateCompanionBuilder,
          (
            AssignmentsTableData,
            BaseReferences<
              _$AppDatabase,
              $AssignmentsTableTable,
              AssignmentsTableData
            >,
          ),
          AssignmentsTableData,
          PrefetchHooks Function()
        > {
  $$AssignmentsTableTableTableManager(
    _$AppDatabase db,
    $AssignmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> creationTime = const Value.absent(),
                Value<String> updateTime = const Value.absent(),
                Value<double> maxPoints = const Value.absent(),
                Value<String> workType = const Value.absent(),
                Value<String> alternateLink = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> materialsJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsTableCompanion(
                id: id,
                title: title,
                description: description,
                state: state,
                dueDate: dueDate,
                creationTime: creationTime,
                updateTime: updateTime,
                maxPoints: maxPoints,
                workType: workType,
                alternateLink: alternateLink,
                courseId: courseId,
                courseName: courseName,
                materialsJson: materialsJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> creationTime = const Value.absent(),
                Value<String> updateTime = const Value.absent(),
                Value<double> maxPoints = const Value.absent(),
                Value<String> workType = const Value.absent(),
                Value<String> alternateLink = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> materialsJson = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                state: state,
                dueDate: dueDate,
                creationTime: creationTime,
                updateTime: updateTime,
                maxPoints: maxPoints,
                workType: workType,
                alternateLink: alternateLink,
                courseId: courseId,
                courseName: courseName,
                materialsJson: materialsJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssignmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentsTableTable,
      AssignmentsTableData,
      $$AssignmentsTableTableFilterComposer,
      $$AssignmentsTableTableOrderingComposer,
      $$AssignmentsTableTableAnnotationComposer,
      $$AssignmentsTableTableCreateCompanionBuilder,
      $$AssignmentsTableTableUpdateCompanionBuilder,
      (
        AssignmentsTableData,
        BaseReferences<
          _$AppDatabase,
          $AssignmentsTableTable,
          AssignmentsTableData
        >,
      ),
      AssignmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$MailsTableTableCreateCompanionBuilder =
    MailsTableCompanion Function({
      required String id,
      Value<String> threadId,
      Value<String> subject,
      Value<String> fromAddr,
      Value<String> toAddr,
      Value<String> date,
      Value<String> snippet,
      Value<String> body,
      Value<String> attachmentsJson,
      required DateTime serverCreatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$MailsTableTableUpdateCompanionBuilder =
    MailsTableCompanion Function({
      Value<String> id,
      Value<String> threadId,
      Value<String> subject,
      Value<String> fromAddr,
      Value<String> toAddr,
      Value<String> date,
      Value<String> snippet,
      Value<String> body,
      Value<String> attachmentsJson,
      Value<DateTime> serverCreatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$MailsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MailsTableTable> {
  $$MailsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromAddr => $composableBuilder(
    column: $table.fromAddr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAddr => $composableBuilder(
    column: $table.toAddr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentsJson => $composableBuilder(
    column: $table.attachmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MailsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MailsTableTable> {
  $$MailsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromAddr => $composableBuilder(
    column: $table.fromAddr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAddr => $composableBuilder(
    column: $table.toAddr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentsJson => $composableBuilder(
    column: $table.attachmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MailsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MailsTableTable> {
  $$MailsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get fromAddr =>
      $composableBuilder(column: $table.fromAddr, builder: (column) => column);

  GeneratedColumn<String> get toAddr =>
      $composableBuilder(column: $table.toAddr, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get attachmentsJson => $composableBuilder(
    column: $table.attachmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$MailsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MailsTableTable,
          MailsTableData,
          $$MailsTableTableFilterComposer,
          $$MailsTableTableOrderingComposer,
          $$MailsTableTableAnnotationComposer,
          $$MailsTableTableCreateCompanionBuilder,
          $$MailsTableTableUpdateCompanionBuilder,
          (
            MailsTableData,
            BaseReferences<_$AppDatabase, $MailsTableTable, MailsTableData>,
          ),
          MailsTableData,
          PrefetchHooks Function()
        > {
  $$MailsTableTableTableManager(_$AppDatabase db, $MailsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MailsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MailsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MailsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> fromAddr = const Value.absent(),
                Value<String> toAddr = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> snippet = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> attachmentsJson = const Value.absent(),
                Value<DateTime> serverCreatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MailsTableCompanion(
                id: id,
                threadId: threadId,
                subject: subject,
                fromAddr: fromAddr,
                toAddr: toAddr,
                date: date,
                snippet: snippet,
                body: body,
                attachmentsJson: attachmentsJson,
                serverCreatedAt: serverCreatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> threadId = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> fromAddr = const Value.absent(),
                Value<String> toAddr = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> snippet = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> attachmentsJson = const Value.absent(),
                required DateTime serverCreatedAt,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => MailsTableCompanion.insert(
                id: id,
                threadId: threadId,
                subject: subject,
                fromAddr: fromAddr,
                toAddr: toAddr,
                date: date,
                snippet: snippet,
                body: body,
                attachmentsJson: attachmentsJson,
                serverCreatedAt: serverCreatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MailsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MailsTableTable,
      MailsTableData,
      $$MailsTableTableFilterComposer,
      $$MailsTableTableOrderingComposer,
      $$MailsTableTableAnnotationComposer,
      $$MailsTableTableCreateCompanionBuilder,
      $$MailsTableTableUpdateCompanionBuilder,
      (
        MailsTableData,
        BaseReferences<_$AppDatabase, $MailsTableTable, MailsTableData>,
      ),
      MailsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppStateTableTableTableManager get appStateTable =>
      $$AppStateTableTableTableManager(_db, _db.appStateTable);
  $$CoursesTableTableTableManager get coursesTable =>
      $$CoursesTableTableTableManager(_db, _db.coursesTable);
  $$AssignmentsTableTableTableManager get assignmentsTable =>
      $$AssignmentsTableTableTableManager(_db, _db.assignmentsTable);
  $$MailsTableTableTableManager get mailsTable =>
      $$MailsTableTableTableManager(_db, _db.mailsTable);
}
