// ignore_for_file: strict_raw_type

import 'dart:convert' show JsonEncoder;

import 'package:sqflite_common/sqflite_logger.dart';
import 'package:talker/talker.dart';
import 'package:talker_sqflite_logger/src/talker_sqflite_logger_settings.dart';

/// {@template talkerSqfliteLoggerSettings}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteSqlEventLog extends TalkerLog {
  /// {@macro talkerSqfliteLoggerSettings}
  SqfliteSqlEventLog({
    required SqfliteLoggerSqlEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerSqlEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(46);

  @override
  String get title => 'SQflite-SQL';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  // client, type, sql, arguments?, result?, name, error?
  String _createMessage() {
    final map = <String, dynamic>{};

    map['type'] = _event.type.name;
    map['sql'] = _event.sql;

    if (_settings.printSqlArguments && _event.arguments != null) {
      map['arguments'] = _event.arguments;
    }

    if (_settings.printSqlResults && _event.result != null) {
      map['result'] = _event.result;
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

/// {@template sqfliteDatabaseOpenEventLog}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteDatabaseOpenEventLog extends TalkerLog {
  /// {@macro sqfliteDatabaseOpenEventLog}
  SqfliteDatabaseOpenEventLog({
    required SqfliteLoggerDatabaseOpenEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerDatabaseOpenEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(47);

  @override
  String get title => 'SQflite-DatabaseOpen';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  // options? (OpenDatabaseOptions), path?, db?, sw?, name, error?
  String _createMessage() {
    final map = <String, dynamic>{};

    map['operation'] = 'openDatabase';

    if (_event.path != null) {
      map['path'] = _event.path;
    }

    if (_settings.printOpenDatabaseOptions && _event.options != null) {
      map['openDatabaseOptions'] = <String, dynamic>{
        'version': _event.options?.version ?? 1,
        'onConfigure':
            _event.options?.onConfigure != null ? 'Custom code' : null,
        'onCreate': _event.options?.onCreate != null ? 'Custom code' : null,
        'onUpgrade': _event.options?.onUpgrade != null ? 'Custom code' : null,
        'onDowngrade':
            _event.options?.onDowngrade != null ? 'Custom code' : null,
        'onOpen': _event.options?.onOpen != null ? 'Custom code' : null,
        'readOnly': _event.options?.readOnly,
        'singleInstance': _event.options?.singleInstance,
      };
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

/// {@template SqfliteDatabaseCloseEventLog}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteDatabaseCloseEventLog extends TalkerLog {
  /// {@macro SqfliteDatabaseCloseEventLog}
  SqfliteDatabaseCloseEventLog({
    required SqfliteLoggerDatabaseCloseEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerDatabaseCloseEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(48);

  @override
  String get title => 'SQflite-DatabaseClose';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  // db?, sw?, name, error?
  String _createMessage() {
    final map = <String, dynamic>{};

    map['operation'] = 'closeDatabase';

    if (_event.db?.path != null) {
      map['path'] = _event.db!.path;
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

/// {@template sqfliteDatabaseDeleteEventLog}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteDatabaseDeleteEventLog extends TalkerLog {
  /// {@macro sqfliteDatabaseDeleteEventLog}
  SqfliteDatabaseDeleteEventLog({
    required SqfliteLoggerDatabaseDeleteEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerDatabaseDeleteEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(49);

  @override
  String get title => 'SQflite-DatabaseDelete';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  // path?, sw?, name, error?
  String _createMessage() {
    final map = <String, dynamic>{};

    map['operation'] = 'deleteDatabase';

    if (_event.path != null) {
      map['path'] = _event.path;
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

/// {@template sqfliteBatchEventLog}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteBatchEventLog extends TalkerLog {
  /// {@macro sqfliteBatchEventLog}
  SqfliteBatchEventLog({
    required SqfliteLoggerBatchEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerBatchEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(50);

  @override
  String get title => 'SQflite-BatchSQL';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  // operations (type, sql, arguments?, result?, name, error?), client, sw?,
  // name, error?
  String _createMessage() {
    final map = <String, dynamic>{};
    final operationsJson = <Map<String, dynamic>>[];

    final operationSize = _event.operations.length;

    for (var index = 0; index < operationSize; index++) {
      final operation = _event.operations[index];
      final accepted =
          _settings.sqlBatchEventFilter?.call(_event.operations)[index] ?? true;

      if (!accepted) {
        continue;
      }

      final operationJson = <String, dynamic>{};

      operationJson['type'] = operation.type.name;
      operationJson['sql'] = operation.sql;

      if (_settings.printSqlArguments && operation.arguments != null) {
        operationJson['arguments'] = operation.arguments;
      }

      if (_settings.printSqlResults && operation.result != null) {
        operationJson['result'] = operation.result;
      }

      if (operation.error != null) {
        operationJson['error'] = operation.error.toString();
      }

      operationsJson.add(operationJson);
    }

    if (operationsJson.isNotEmpty) {
      map['operations'] = operationsJson;
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

/// {@template sqfliteInvokeEventLog}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class SqfliteInvokeEventLog extends TalkerLog {
  /// {@macro sqfliteInvokeEventLog}
  SqfliteInvokeEventLog({
    required SqfliteLoggerInvokeEvent event,
    required TalkerSqfliteLoggerSettings settings,
  })  : _event = event,
        _settings = settings,
        super('${event.runtimeType} ${event.name}');

  final SqfliteLoggerInvokeEvent _event;
  final TalkerSqfliteLoggerSettings _settings;

  @override
  AnsiPen get pen => AnsiPen()..xterm(51);

  @override
  String get title => 'SQflite-Invoke';

  @override
  String generateTextMessage() {
    return _createMessage();
  }

  String _createMessage() {
    final map = <String, dynamic>{};

    map['method'] = _event.method;

    if (_settings.printSqlArguments && _event.arguments != null) {
      map['arguments'] = _event.arguments;
    }

    if (_settings.printSqlResults && _event.result != null) {
      map['result'] = _event.result;
    }

    if (_settings.printSqlElapsedTime && _event.sw != null) {
      map['sw'] = _event.sw!.elapsed.toString();
    }

    if (_event.error != null) {
      map['error'] = _event.error.toString();
    }

    return _prettyPrintJson(map);
  }
}

String _prettyPrintJson(Object? json) {
  if (json == null) {
    return '';
  }

  return const JsonEncoder.withIndent('  ').convert(json);
}
