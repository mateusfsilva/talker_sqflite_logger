import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqflite_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockDatabaseExecutor extends Mock implements DatabaseExecutor {}

class MockDatabase extends Mock implements Database {}

class DatabaseExceptionImp extends DatabaseException {
  DatabaseExceptionImp(
    super.message, {
    int? resultCode,
  }) : _resultCode = resultCode;

  final int? _resultCode;

  @override
  int? getResultCode() => _resultCode;

  @override
  Object? result;
}

class SqfliteLoggerSqlEventImp<T> extends SqfliteLoggerSqlEvent<T> {
  SqfliteLoggerSqlEventImp({
    required this.client,
    required this.name,
    required this.sql,
    required this.type,
    this.arguments,
    this.result,
    this.sw,
    this.error,
  });

  @override
  final Object? arguments;

  @override
  final DatabaseExecutor client;

  @override
  final Object? error;

  @override
  final String name;

  @override
  final T? result;

  @override
  final String sql;

  @override
  final Stopwatch? sw;

  @override
  final SqliteSqlCommandType type;
}

class SqfliteLoggerDatabaseOpenEventImp extends SqfliteLoggerDatabaseOpenEvent {
  SqfliteLoggerDatabaseOpenEventImp({
    required this.name,
    this.db,
    this.error,
    this.options,
    this.path,
    this.sw,
  });

  @override
  Database? db;

  @override
  Object? error;

  @override
  String name;

  @override
  OpenDatabaseOptions? options;

  @override
  String? path;

  @override
  Stopwatch? sw;
}

class SqfliteLoggerDatabaseCloseEventImp
    extends SqfliteLoggerDatabaseCloseEvent {
  SqfliteLoggerDatabaseCloseEventImp({
    required this.name,
    this.db,
    this.error,
    this.sw,
  });

  @override
  Database? db;

  @override
  Object? error;

  @override
  String name;

  @override
  Stopwatch? sw;
}

class SqfliteLoggerDatabaseDeleteEventImp
    extends SqfliteLoggerDatabaseDeleteEvent {
  SqfliteLoggerDatabaseDeleteEventImp({
    required this.name,
    this.path,
    this.sw,
    this.error,
  });

  @override
  Object? error;

  @override
  String name;

  @override
  String? path;

  @override
  Stopwatch? sw;
}

class SqfliteLoggerBatchEventImp extends SqfliteLoggerBatchEvent {
  SqfliteLoggerBatchEventImp({
    required this.client,
    required this.name,
    required this.operations,
    this.sw,
    this.error,
  });

  @override
  DatabaseExecutor client;

  @override
  Object? error;

  @override
  String name;

  @override
  List<SqfliteLoggerBatchOperation<dynamic>> operations;

  @override
  Stopwatch? sw;
}

class SqfliteLoggerBatchOperationImp<T> extends SqfliteLoggerBatchOperation<T> {
  SqfliteLoggerBatchOperationImp({
    required this.name,
    required this.sql,
    required this.type,
    this.arguments,
    this.result,
    this.error,
  });

  @override
  Object? arguments;

  @override
  Object? error;

  @override
  String name;

  @override
  T? result;

  @override
  String sql;

  @override
  SqliteSqlCommandType type;
}

class SqfliteLoggerInvokeEventImp extends SqfliteLoggerInvokeEvent {
  SqfliteLoggerInvokeEventImp({
    required this.name,
    required this.method,
    this.arguments,
    this.result,
    this.sw,
    this.error,
  });

  @override
  Object? arguments;

  @override
  Object? error;

  @override
  String method;

  @override
  String name;

  @override
  Object? result;

  @override
  Stopwatch? sw;
}

SqfliteLoggerSqlEvent<int> getUpdateEvent({
  required Stopwatch stopwatch,
}) =>
    SqfliteLoggerSqlEventImp<int>(
      client: MockDatabaseExecutor(),
      name: 'update',
      sql: 'UPDATE Test SET name = ?, value = ? WHERE name = ?',
      type: SqliteSqlCommandType.update,
      arguments: [
        'updated name',
        '9876',
        'some name',
      ],
      result: 1,
      sw: stopwatch,
    );

SqfliteLoggerSqlEvent<int> getDeleteEvent({
  required Stopwatch stopwatch,
}) =>
    SqfliteLoggerSqlEventImp<int>(
      client: MockDatabaseExecutor(),
      name: 'delete',
      sql: 'DELETE FROM Test WHERE name = ?',
      type: SqliteSqlCommandType.delete,
      arguments: [
        'another name',
      ],
      result: 0,
      sw: stopwatch,
    );

SqfliteLoggerSqlEvent<List<Map<String, Object?>>> getQueryEvent({
  required Stopwatch stopwatch,
}) =>
    SqfliteLoggerSqlEventImp<List<Map<String, Object?>>>(
      client: MockDatabaseExecutor(),
      name: 'query',
      sql: 'SELECT id, name, value, num '
          'FROM Test '
          'WHERE name = ? '
          'ORDER BY name',
      type: SqliteSqlCommandType.query,
      arguments: ['some name'],
      result: [
        {
          'id': 1,
          'name': 'some name',
          'value': 1234,
          'num': 456.789,
        },
      ],
      sw: stopwatch,
    );

SqfliteLoggerSqlEvent<dynamic> getErrorEvent({
  required Stopwatch stopwatch,
}) =>
    SqfliteLoggerSqlEventImp<dynamic>(
      client: MockDatabaseExecutor(),
      name: 'execute',
      sql: 'SELECT * FROM NotExistTable',
      type: SqliteSqlCommandType.execute,
      sw: stopwatch,
      error: DatabaseExceptionImp(
        'SqliteException(1): while executing, no such table: NotExistTable, '
        'SQL logic error (code 1)\nCausing statement: SELECT * FROM N…',
        resultCode: 1,
      ),
    );

SqfliteLoggerDatabaseOpenEvent getOpenDatabaseEvent({
  required Stopwatch stopwatch,
  OpenDatabaseOptions? options,
  Object? error,
}) =>
    SqfliteLoggerDatabaseOpenEventImp(
      name: 'openDatabase',
      path: ':memory:',
      sw: stopwatch,
      options: options,
      error: error,
    );

SqfliteLoggerDatabaseCloseEvent getCloseDatabaseEvent({
  required Database db,
  required Stopwatch stopwatch,
  Object? error,
}) =>
    SqfliteLoggerDatabaseCloseEventImp(
      name: 'closeDatabase',
      db: db,
      sw: stopwatch,
      error: error,
    );

SqfliteLoggerDatabaseDeleteEvent getDeleteDatabaseEvent({
  required Stopwatch stopwatch,
  Object? error,
}) =>
    SqfliteLoggerDatabaseDeleteEventImp(
      name: 'deleteDatabase',
      path: ':memory:',
      sw: stopwatch,
      error: error,
    );

SqfliteLoggerBatchOperation<int> getCreateTableEvent({
  required String name,
  required String sql,
  required SqliteSqlCommandType type,
  Object? error,
}) =>
    SqfliteLoggerBatchOperationImp<int>(
      name: name,
      sql: sql,
      type: type,
      error: error,
    );

SqfliteLoggerBatchOperation<int> getInsertEvent({
  required String name,
  required String sql,
  required SqliteSqlCommandType type,
  Object? arguments,
  int? result,
  Object? error,
}) =>
    SqfliteLoggerBatchOperationImp<int>(
      name: name,
      sql: sql,
      type: type,
      arguments: arguments,
      result: result,
      error: error,
    );

SqfliteLoggerBatchEvent getBatchEvent({
  required Stopwatch stopwatch,
  Object? error,
}) =>
    SqfliteLoggerBatchEventImp(
      client: MockDatabaseExecutor(),
      name: 'batch',
      operations: [
        getCreateTableEvent(
          name: 'execute',
          sql: 'CREATE TABLE Test '
              '(id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)',
          type: SqliteSqlCommandType.execute,
        ),
        getInsertEvent(
          name: 'execute',
          sql: 'INSERT INTO Test '
              '(name, value, num) VALUES(?, ?, ?)',
          type: SqliteSqlCommandType.execute,
          arguments: ['some name', 1234, 456.789],
          result: 1,
          error: error,
        ),
      ],
      sw: stopwatch,
      error: error,
    );

SqfliteLoggerInvokeEvent getInvokeEvent({
  required String method,
  required Stopwatch stopwatch,
  Object? arguments,
  Object? result,
  Object? error,
}) =>
    SqfliteLoggerInvokeEventImp(
      name: 'invoke',
      method: method,
      arguments: arguments,
      result: result,
      sw: stopwatch,
      error: error,
    );
