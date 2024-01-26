import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:talker_sqflite_logger/src/sqflite_logs.dart';
import 'package:talker_sqflite_logger/src/talker_sqflite_logger_settings.dart';

import '../sqflite_logger.dart';

void main() {
  group('SqfliteSqlEventLog', () {
    test(
        'Given an SQL instructions '
        'And calling a SqfliteSqlEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show type, dbID, SQL, arguments, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getUpdateEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteSqlEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "type": "update",
  "dbID": 1,
  "sql": "UPDATE Test SET name = ?, value = ? WHERE name = ?",
  "arguments": [
    "updated name",
    "9876",
    "some name"
  ],
  "sw": "${stopwatch.elapsed}"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerSqlEventImp<int> update',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-SQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 46);
      expect(message, result);
    });

    test(
        'Given an SQL instructions '
        'And calling a SqfliteSqlEventLog '
        'And setting the printSqlResults to true '
        'And printSqlArguments to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show type, dbID, SQL, result, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings(
        printSqlResults: true,
        printSqlArguments: false,
      );

      final result = '''
{
  "type": "delete",
  "dbID": 1,
  "sql": "DELETE FROM Test WHERE name = ?",
  "result": 0,
  "sw": "${stopwatch.elapsed}"
}''';

      final sqfliteSqlEventLog = SqfliteSqlEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerSqlEventImp<int> delete',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-SQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 46);
      expect(message, result);
    });

    test(
        'Given an SQL instructions '
        'And calling a SqfliteSqlEventLog '
        'And printSqlArguments to false '
        'And printSqlElapsedTime to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show type, dbID, SQL, and result', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings(
        printSqlResults: true,
        printSqlArguments: false,
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "type": "delete",
  "dbID": 1,
  "sql": "DELETE FROM Test WHERE name = ?",
  "result": 0
}''';

      final sqfliteSqlEventLog = SqfliteSqlEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerSqlEventImp<int> delete',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-SQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 46);
      expect(message, result);
    });

    test(
        'Given an SQL instructions '
        'And it is inside a transaction '
        'And calling a SqfliteSqlEventLog '
        'And printSqlArguments to false '
        'And printSqlElapsedTime to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show type, dbID, SQL, and result', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteEvent(
        stopwatch: stopwatch,
        transactionId: 1,
      );
      const settings = TalkerSqfliteLoggerSettings(
        printSqlResults: true,
        printSqlArguments: false,
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "type": "delete",
  "dbID": 1,
  "sql": "DELETE FROM Test WHERE name = ?",
  "txId": 1,
  "result": 0
}''';

      final sqfliteSqlEventLog = SqfliteSqlEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerSqlEventImp<int> delete',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-SQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 46);
      expect(message, result);
    });

    test(
        'Given an SQL instructions '
        'And calling a SqfliteSqlEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show type, dbID, SQL, sw, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getErrorEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings(
        printSqlResults: true,
        printSqlArguments: false,
      );

      final result = '''
{
  "type": "execute",
  "dbID": 1,
  "sql": "SELECT * FROM NotExistTable",
  "sw": "${stopwatch.elapsed}",
  "error": "DatabaseException(SqliteException(1): while executing, no such table: NotExistTable, SQL logic error (code 1)\\nCausing statement: SELECT * FROM N…)"
}''';

      final sqfliteSqlEventLog = SqfliteSqlEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerSqlEventImp<dynamic> execute',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-SQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 46);
      expect(message, result);
    });
  });

  group('SqfliteDatabaseOpenEventLog', () {
    test(
        'Given an new database opened '
        'And calling a SqfliteDatabaseOpenEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show path, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getOpenDatabaseEvent(
        stopwatch: stopwatch,
        databaseId: 1,
      );
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseOpenEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "openDatabase",
  "path": ":memory:",
  "txId": 1,
  "sw": "${stopwatch.elapsed}"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseOpenEventImp openDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseOpen');
      expect(sqfliteSqlEventLog.pen.fcolor, 47);
      expect(message, result);
    });

    test(
        'Given an new database opened '
        'And calling a SqfliteDatabaseOpenEventLog '
        'And setting the printOpenDatabaseOptions to true '
        'And printSqlElapsedTime to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show path, and openDatabaseOptions', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getOpenDatabaseEvent(
        stopwatch: stopwatch,
        options: OpenDatabaseOptions(
          version: 1,
        ),
      );
      const settings = TalkerSqfliteLoggerSettings(
        printOpenDatabaseOptions: true,
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "operation": "openDatabase",
  "path": ":memory:",
  "openDatabaseOptions": {
    "version": 1,
    "onConfigure": null,
    "onCreate": null,
    "onUpgrade": null,
    "onDowngrade": null,
    "onOpen": null,
    "readOnly": false,
    "singleInstance": true
  }
}''';

      final sqfliteSqlEventLog = SqfliteDatabaseOpenEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseOpenEventImp openDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseOpen');
      expect(sqfliteSqlEventLog.pen.fcolor, 47);
      expect(message, result);
    });

    test(
        'Given an new database opened '
        'And calling a SqfliteDatabaseOpenEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'And there is an error '
        'Then logs a message '
        'And it will show path, sw, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getOpenDatabaseEvent(
        stopwatch: stopwatch,
        error: DatabaseExceptionImp('Error opening the database'),
      );
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseOpenEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "openDatabase",
  "path": ":memory:",
  "sw": "${stopwatch.elapsed}",
  "error": "DatabaseException(Error opening the database)"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseOpenEventImp openDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseOpen');
      expect(sqfliteSqlEventLog.pen.fcolor, 47);
      expect(message, result);
    });
  });

  group('SqfliteDatabaseCloseEventLog', () {
    late Database database;

    setUp(() async {
      database = MockDatabase();

      when(
        () => database.path,
      ).thenReturn(
        ':memory:',
      );
    });

    test(
        'Given a database has been closed '
        'And calling a SqfliteDatabaseCloseEventLog '
        'When initializing  closing a database '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show operation, dbID, path, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getCloseDatabaseEvent(db: database, stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseCloseEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "closeDatabase",
  "dbID": 1,
  "path": ":memory:",
  "sw": "${stopwatch.elapsed}"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseCloseEventImp closeDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseClose');
      expect(sqfliteSqlEventLog.pen.fcolor, 48);
      expect(message, result);
    });

    test(
        'Given a database has been closed '
        'And calling a SqfliteDatabaseCloseEventLog '
        'And setting the printSqlElapsedTime to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show operation, dbID, and path', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getCloseDatabaseEvent(db: database, stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings(
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "operation": "closeDatabase",
  "dbID": 1,
  "path": ":memory:"
}''';

      final sqfliteSqlEventLog = SqfliteDatabaseCloseEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseCloseEventImp closeDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseClose');
      expect(sqfliteSqlEventLog.pen.fcolor, 48);
      expect(message, result);
    });

    test(
        'Given a database has been closed '
        'And calling a SqfliteDatabaseCloseEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'And there is an error '
        'Then logs a message '
        'And it will show operation, dbID, path, sw, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getCloseDatabaseEvent(
        db: database,
        stopwatch: stopwatch,
        error: DatabaseExceptionImp('Error closing the database'),
      );
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseCloseEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "closeDatabase",
  "dbID": 1,
  "path": ":memory:",
  "sw": "${stopwatch.elapsed}",
  "error": "DatabaseException(Error closing the database)"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseCloseEventImp closeDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseClose');
      expect(sqfliteSqlEventLog.pen.fcolor, 48);
      expect(message, result);
    });
  });

  group('SqfliteDatabaseDeleteEventLog', () {
    test(
        'Given a database has been deleted '
        'And calling a SqfliteDatabaseDeleteEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show path, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteDatabaseEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseDeleteEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "deleteDatabase",
  "path": ":memory:",
  "sw": "${stopwatch.elapsed}"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseDeleteEventImp deleteDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseDelete');
      expect(sqfliteSqlEventLog.pen.fcolor, 49);
      expect(message, result);
    });

    test(
        'Given a database has been deleted '
        'And calling a SqfliteDatabaseDeleteEventLog '
        'And setting the printSqlElapsedTime to false '
        'When it calls the generateTextMessage() '
        'Then logs a message '
        'And it will show path, and openDatabaseOptions', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteDatabaseEvent(stopwatch: stopwatch);
      const settings = TalkerSqfliteLoggerSettings(
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "operation": "deleteDatabase",
  "path": ":memory:"
}''';

      final sqfliteSqlEventLog = SqfliteDatabaseDeleteEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseDeleteEventImp deleteDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseDelete');
      expect(sqfliteSqlEventLog.pen.fcolor, 49);
      expect(message, result);
    });

    test(
        'Given a database has been deleted '
        'And calling a SqfliteDatabaseDeleteEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls the generateTextMessage() '
        'And there is an error '
        'Then logs a message '
        'And it will show path, sw, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getDeleteDatabaseEvent(
        stopwatch: stopwatch,
        error: DatabaseExceptionImp('Error closing the database'),
      );
      const settings = TalkerSqfliteLoggerSettings();

      final sqfliteSqlEventLog = SqfliteDatabaseDeleteEventLog(
        event: event,
        settings: settings,
      );

      final result = '''
{
  "operation": "deleteDatabase",
  "path": ":memory:",
  "sw": "${stopwatch.elapsed}",
  "error": "DatabaseException(Error closing the database)"
}''';

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerDatabaseDeleteEventImp deleteDatabase',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-DatabaseDelete');
      expect(sqfliteSqlEventLog.pen.fcolor, 49);
      expect(message, result);
    });
  });

  group('SqfliteBatchEventLog', () {
    test(
        'Given a batch query '
        'And calling a SqfliteBatchEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls generateTextMessage() '
        'Then it will return operation, dbID, operations, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getBatchEvent(
        stopwatch: stopwatch,
      );
      const settings = TalkerSqfliteLoggerSettings();

      final result = '''
{
  "operation": "batch",
  "dbID": 1,
  "operations": [
    {
      "type": "execute",
      "sql": "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)"
    },
    {
      "type": "execute",
      "sql": "INSERT INTO Test (name, value, num) VALUES(?, ?, ?)",
      "arguments": [
        "some name",
        1234,
        456.789
      ]
    }
  ],
  "sw": "${stopwatch.elapsed}"
}''';

      final sqfliteSqlEventLog = SqfliteBatchEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerBatchEventImp batch',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-BatchSQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 50);
      expect(message, result);
    });

    test(
        'Given a batch query '
        'And it is inside a transaction '
        'And calling a SqfliteBatchEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls generateTextMessage() '
        'Then it will return operations, dbID, txId, operations, and sw',
        () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getBatchEvent(
        stopwatch: stopwatch,
        transactionId: 1,
      );
      const settings = TalkerSqfliteLoggerSettings();

      final result = '''
{
  "operation": "batch",
  "dbID": 1,
  "txId": 1,
  "operations": [
    {
      "type": "execute",
      "sql": "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)"
    },
    {
      "type": "execute",
      "sql": "INSERT INTO Test (name, value, num) VALUES(?, ?, ?)",
      "arguments": [
        "some name",
        1234,
        456.789
      ]
    }
  ],
  "sw": "${stopwatch.elapsed}"
}''';

      final sqfliteSqlEventLog = SqfliteBatchEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerBatchEventImp batch',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-BatchSQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 50);
      expect(message, result);
    });

    test(
        'Given a batch query '
        'And calling a SqfliteBatchEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'And printSqlElapsedTime is false '
        'When it calls generateTextMessage() '
        'Then it will return operation, dbID, and operations', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getBatchEvent(
        stopwatch: stopwatch,
      );
      const settings = TalkerSqfliteLoggerSettings(
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "operation": "batch",
  "dbID": 1,
  "operations": [
    {
      "type": "execute",
      "sql": "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)"
    },
    {
      "type": "execute",
      "sql": "INSERT INTO Test (name, value, num) VALUES(?, ?, ?)",
      "arguments": [
        "some name",
        1234,
        456.789
      ]
    }
  ]
}''';

      final sqfliteSqlEventLog = SqfliteBatchEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerBatchEventImp batch',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-BatchSQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 50);
      expect(message, result);
    });

    test(
        'Given a batch query '
        'And calling a SqfliteBatchEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'And printSqlElapsedTime is false '
        'And printSqlArguments is false '
        'And printSqlResults is true '
        'When it calls generateTextMessage() '
        'Then it will return operation, dbID, and operations', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getBatchEvent(
        stopwatch: stopwatch,
      );
      const settings = TalkerSqfliteLoggerSettings(
        printSqlElapsedTime: false,
        printSqlArguments: false,
        printSqlResults: true,
      );

      const result = '''
{
  "operation": "batch",
  "dbID": 1,
  "operations": [
    {
      "type": "execute",
      "sql": "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)"
    },
    {
      "type": "execute",
      "sql": "INSERT INTO Test (name, value, num) VALUES(?, ?, ?)",
      "result": 1
    }
  ]
}''';

      final sqfliteSqlEventLog = SqfliteBatchEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerBatchEventImp batch',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-BatchSQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 50);
      expect(message, result);
    });

    test(
        'Given a batch query '
        'And calling a SqfliteBatchEventLog '
        'And using the default TalkerSqfliteLoggerSettings '
        'And printSqlElapsedTime is false '
        'And printSqlArguments is false '
        'When it calls generateTextMessage() '
        'And there is an exception '
        'Then it will return operation, dbID, operations, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getBatchEvent(
        stopwatch: stopwatch,
        error: DatabaseExceptionImp('Error executing a batch operation'),
      );
      const settings = TalkerSqfliteLoggerSettings(
        printSqlElapsedTime: false,
        printSqlArguments: false,
      );

      // ignore: use_raw_strings
      const result = '''
{
  "operation": "batch",
  "dbID": 1,
  "operations": [
    {
      "type": "execute",
      "sql": "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)"
    },
    {
      "type": "execute",
      "sql": "INSERT INTO Test (name, value, num) VALUES(?, ?, ?)",
      "error": "DatabaseException(Error executing a batch operation)"
    }
  ],
  "error": "DatabaseException(Error executing a batch operation)"
}''';

      final sqfliteSqlEventLog = SqfliteBatchEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerBatchEventImp batch',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-BatchSQL');
      expect(sqfliteSqlEventLog.pen.fcolor, 50);
      expect(message, result);
    });
  });

  group('SqfliteInvokeEventLog', () {
    test(
        'Given an internal invoke call '
        'And calling a SqfliteLoggerInvokeEvent '
        'And using the default TalkerSqfliteLoggerSettings '
        'And the printInvokerEvents parameter is true '
        'When it calls generateTextMessage() '
        'Then it will return method, arguments, and sw', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getInvokeEvent(
        method: 'update',
        arguments: [
          'UPDATE Test SET name = ?, value = ? WHERE name = ?',
          ['updated name', '9876', 'some name'],
        ],
        result: 1,
        stopwatch: stopwatch,
      );
      const settings = TalkerSqfliteLoggerSettings();

      final result = '''
{
  "method": "update",
  "arguments": [
    "UPDATE Test SET name = ?, value = ? WHERE name = ?",
    [
      "updated name",
      "9876",
      "some name"
    ]
  ],
  "sw": "${stopwatch.elapsed}"
}''';

      final sqfliteSqlEventLog = SqfliteInvokeEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerInvokeEventImp invoke',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-Invoke');
      expect(sqfliteSqlEventLog.pen.fcolor, 51);
      expect(message, result);
    });

    test(
        'Given an internal invoke call '
        'And calling a SqfliteLoggerInvokeEvent '
        'And using the default TalkerSqfliteLoggerSettings '
        'And the printSqlResults parameter is true '
        'And the printSqlElapsedTime is false '
        'When it calls generateTextMessage() '
        'Then it will return method, argments, and result', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getInvokeEvent(
        method: 'query',
        arguments: [
          'SELECT id, name, value, num FROM Test WHERE name = ? ORDER BY name',
          ['some name'],
        ],
        result: [
          {
            'id': 1,
            'name': 'some name',
            'value': 1234,
            'num': 456.789,
          },
        ],
        stopwatch: stopwatch,
      );
      const settings = TalkerSqfliteLoggerSettings(
        printSqlResults: true,
        printSqlElapsedTime: false,
      );

      const result = '''
{
  "method": "query",
  "arguments": [
    "SELECT id, name, value, num FROM Test WHERE name = ? ORDER BY name",
    [
      "some name"
    ]
  ],
  "result": [
    {
      "id": 1,
      "name": "some name",
      "value": 1234,
      "num": 456.789
    }
  ]
}''';

      final sqfliteSqlEventLog = SqfliteInvokeEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerInvokeEventImp invoke',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-Invoke');
      expect(sqfliteSqlEventLog.pen.fcolor, 51);
      expect(message, result);
    });

    test(
        'Given an internal invoke call '
        'And calling a SqfliteLoggerInvokeEvent '
        'And using the default TalkerSqfliteLoggerSettings '
        'When it calls generateTextMessage() '
        'And there is an error '
        'Then it will return method, arguments, sw, and error', () async {
      final stopwatch = Stopwatch()
        ..start()
        ..stop();
      final event = getInvokeEvent(
        method: 'insert',
        arguments: [
          // ignore: no_adjacent_strings_in_list
          'INSERT INTO Test(name, value, num) '
              'VALUES("some name", 1234, 456.789)',
        ],
        result: 1,
        stopwatch: stopwatch,
        error: DatabaseExceptionImp('Error inserting into the database'),
      );
      const settings = TalkerSqfliteLoggerSettings();

      final result = '''
{
  "method": "insert",
  "arguments": [
    "INSERT INTO Test(name, value, num) VALUES(\\"some name\\", 1234, 456.789)"
  ],
  "sw": "${stopwatch.elapsed}",
  "error": "DatabaseException(Error inserting into the database)"
}''';

      final sqfliteSqlEventLog = SqfliteInvokeEventLog(
        event: event,
        settings: settings,
      );

      final message = sqfliteSqlEventLog.generateTextMessage();

      expect(
        sqfliteSqlEventLog.message,
        'SqfliteLoggerInvokeEventImp invoke',
      );
      expect(sqfliteSqlEventLog.title, 'SQflite-Invoke');
      expect(sqfliteSqlEventLog.pen.fcolor, 51);
      expect(message, result);
    });
  });
}
