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
    required this.databaseId,
    this.transactionId,
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

  @override
  final int databaseId;

  @override
  final int? transactionId;
}

class SqfliteLoggerDatabaseOpenEventImp extends SqfliteLoggerDatabaseOpenEvent {
  SqfliteLoggerDatabaseOpenEventImp({
    required this.name,
    this.db,
    this.databaseId,
    this.error,
    this.options,
    this.path,
    this.sw,
  });

  @override
  final Database? db;

  @override
  final Object? error;

  @override
  final String name;

  @override
  final OpenDatabaseOptions? options;

  @override
  final String? path;

  @override
  final Stopwatch? sw;

  @override
  final int? databaseId;
}

class SqfliteLoggerDatabaseCloseEventImp
    extends SqfliteLoggerDatabaseCloseEvent {
  SqfliteLoggerDatabaseCloseEventImp({
    required this.name,
    required this.databaseId,
    this.db,
    this.error,
    this.sw,
  });

  @override
  final Database? db;

  @override
  final Object? error;

  @override
  final String name;

  @override
  final Stopwatch? sw;

  @override
  final int databaseId;
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
  final Object? error;

  @override
  final String name;

  @override
  final String? path;

  @override
  final Stopwatch? sw;
}

class SqfliteLoggerBatchEventImp extends SqfliteLoggerBatchEvent {
  SqfliteLoggerBatchEventImp({
    required this.client,
    required this.databaseId,
    required this.name,
    required this.operations,
    this.transactionId,
    this.sw,
    this.error,
  });

  @override
  final DatabaseExecutor client;

  @override
  final Object? error;

  @override
  final String name;

  @override
  final List<SqfliteLoggerBatchOperation<dynamic>> operations;

  @override
  final Stopwatch? sw;

  @override
  final int databaseId;

  @override
  final int? transactionId;
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
  final Object? arguments;

  @override
  final Object? error;

  @override
  final String name;

  @override
  final T? result;

  @override
  final String sql;

  @override
  final SqliteSqlCommandType type;
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
  final Object? arguments;

  @override
  final Object? error;

  @override
  final String method;

  @override
  final String name;

  @override
  final Object? result;

  @override
  final Stopwatch? sw;
}

SqfliteLoggerSqlEvent<int> getUpdateEvent({
  required Stopwatch stopwatch,
}) =>
    SqfliteLoggerSqlEventImp<int>(
      client: MockDatabaseExecutor(),
      name: 'update',
      sql: 'UPDATE Test SET name = ?, value = ? WHERE name = ?',
      type: SqliteSqlCommandType.update,
      databaseId: 1,
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
  int? transactionId,
}) =>
    SqfliteLoggerSqlEventImp<int>(
      client: MockDatabaseExecutor(),
      name: 'delete',
      sql: 'DELETE FROM Test WHERE name = ?',
      type: SqliteSqlCommandType.delete,
      databaseId: 1,
      transactionId: transactionId,
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
      databaseId: 1,
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
      databaseId: 1,
      sw: stopwatch,
      error: DatabaseExceptionImp(
        'SqliteException(1): while executing, no such table: NotExistTable, '
        'SQL logic error (code 1)\nCausing statement: SELECT * FROM N…',
        resultCode: 1,
      ),
    );

SqfliteLoggerDatabaseOpenEvent getOpenDatabaseEvent({
  required Stopwatch stopwatch,
  int? databaseId,
  OpenDatabaseOptions? options,
  Object? error,
}) =>
    SqfliteLoggerDatabaseOpenEventImp(
      name: 'openDatabase',
      databaseId: databaseId,
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
      databaseId: 1,
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
  int? transactionId,
  Object? error,
}) =>
    SqfliteLoggerBatchEventImp(
      client: MockDatabaseExecutor(),
      databaseId: 1,
      transactionId: transactionId,
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
