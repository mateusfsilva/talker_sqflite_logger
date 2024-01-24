// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqflite_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talker/talker.dart';
import 'package:talker_sqflite_logger/talker_sqflite_logger.dart';

class MockTalker extends Mock implements Talker {}

class FakeTalkerLog extends Fake implements TalkerLog {}

class FakeSqfliteLoggerSqlEvent<T> extends Fake
    implements SqfliteLoggerSqlEvent<T> {}

class FakeTalkerSqfliteLoggerSettings extends Fake
    implements TalkerSqfliteLoggerSettings {}

class FakeSqfliteLoggerInvokeEvent extends Fake
    implements SqfliteLoggerInvokeEvent {}

class FakeSqfliteLoggerDatabaseOpenEvent extends Fake
    implements SqfliteLoggerDatabaseOpenEvent {}

class FakeSqfliteLoggerDatabaseCloseEvent extends Fake
    implements SqfliteLoggerDatabaseCloseEvent {}

class FakeSqfliteLoggerDatabaseDeleteEvent extends Fake
    implements SqfliteLoggerDatabaseDeleteEvent {}

class FakeSqfliteLoggerBatchEvent extends Fake
    implements SqfliteLoggerBatchEvent {}

void main() {
  late Talker talker;
  late TalkerSqfliteDatabaseFactory factory;
  late Database db;

  const path = inMemoryDatabasePath;

  setUpAll(() async {
    registerFallbackValue(FakeTalkerLog());
    registerFallbackValue(FakeSqfliteLoggerSqlEvent<dynamic>());
    registerFallbackValue(FakeTalkerSqfliteLoggerSettings());
    registerFallbackValue(FakeSqfliteLoggerDatabaseOpenEvent());
    registerFallbackValue(FakeSqfliteLoggerDatabaseCloseEvent());
    registerFallbackValue(FakeSqfliteLoggerDatabaseDeleteEvent());
    registerFallbackValue(FakeSqfliteLoggerBatchEvent());
    registerFallbackValue(FakeSqfliteLoggerInvokeEvent());
    registerFallbackValue(LogLevel.debug);

    sqfliteFfiInit();

    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    talker = MockTalker();
  });

  tearDown(() async {
    await db.close();
  });

  group('TalkerSqfliteDatabaseFactory', () {
    test('can be instantiated', () async {
      factory = TalkerSqfliteDatabaseFactory();

      db = await factory.openDatabase(
        path: path,
      );

      expect(factory, isNotNull);
    });
  });

  group('SqfliteLoggerSqlEvent', () {
    test(
        'When log is disabled '
        'And a query is executed '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      await db.execute(
        'CREATE TABLE Test '
        '(id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'value INTEGER, '
        'num REAL)',
      );

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a query is executed '
        'And printSqlEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printSqlEvents: false,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      await db.execute(
        'CREATE TABLE Test '
        '(id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'value INTEGER, '
        'num REAL)',
      );

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a query is executed '
        'And printSqlEvents is true '
        'Then call SqfliteSqlEventLog', () async {
      const settings = TalkerSqfliteLoggerSettings();
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      await db.execute(
        'CREATE TABLE Test '
        '(id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'value INTEGER, '
        'num REAL)',
      );

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteSqlEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteSqlEventLog>());
    });

    test(
        'When log is enabled '
        'And a query is executed '
        'And sqlEventFilter has a filter bloking all the queries '
        'Then SqfliteSqlEventLog is never called', () async {
      bool sqlEventFilter(SqfliteLoggerSqlEvent<dynamic> event) => false;

      final settings = TalkerSqfliteLoggerSettings(
        sqlEventFilter: sqlEventFilter,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      await db.execute(
        'CREATE TABLE Test '
        '(id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'value INTEGER, '
        'num REAL)',
      );

      verifyNever(
        () => talker.logTyped(any()),
      );
    });

    test(
        'When log is enabled '
        'And a query is executed '
        'And sqlEventFilter has a filter bloking CREATE TABLEs queries '
        'Then SqfliteSqlEventLog is called only once', () async {
      bool sqlEventFilter(SqfliteLoggerSqlEvent<dynamic> event) =>
          !event.sql.contains('CREATE TABLE');

      final settings = TalkerSqfliteLoggerSettings(
        sqlEventFilter: sqlEventFilter,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      await db.execute(
        'CREATE TABLE Test '
        '(id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'value INTEGER, '
        'num REAL)',
      );

      await db.execute('INSERT INTO Test (name, value, num) '
          'VALUES("some name", 1234, 456.789)');

      verify(
        () => talker.logTyped(any()),
      ).called(1);
    });
  });

  group('SqfliteLoggerDatabaseOpenEvent', () {
    test(
        'When log is disabled '
        'And the database is opened '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is opened '
        'And printDatabaseOpenEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings();
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is opened '
        'And printDatabaseOpenEvents is true '
        'Then call SqfliteSqlEventLog', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printDatabaseOpenEvents: true,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteDatabaseOpenEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteDatabaseOpenEventLog>());
    });
  });

  group('SqfliteLoggerDatabaseCloseEvent', () {
    test(
        'When log is disabled '
        'And the database is closed '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      await db.close();

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is closed '
        'And printDatabaseCloseEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings();
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      await db.close();

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is closed '
        'And printDatabaseCloseEvents is true '
        'Then call SqfliteLoggerDatabaseCloseEvent', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printDatabaseCloseEvents: true,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      await db.close();

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteDatabaseCloseEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteDatabaseCloseEventLog>());
    });
  });

  group('SqfliteLoggerDatabaseDeleteEvent', () {
    late String pathFile;

    setUp(() async {
      final dir = await getDatabasesPath();
      pathFile = '$dir/teste.db';
    });

    test(
        'When log is disabled '
        'And the database is deleted '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: pathFile,
        factory: databaseFactory,
      );

      await deleteDatabase(pathFile);

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is deleted '
        'And printDatabaseDeleteEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings();
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: pathFile,
        factory: databaseFactory,
      );

      await deleteDatabase(pathFile);

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And the database is deleted '
        'And printDatabaseDeleteEvents is true '
        'Then call SqfliteDatabaseDeleteEventLog', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printDatabaseDeleteEvents: true,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: pathFile,
        factory: databaseFactory,
      );

      await deleteDatabase(pathFile);

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteDatabaseDeleteEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteDatabaseDeleteEventLog>());
    });
  });

  group('SqfliteLoggerBatchEvent', () {
    setUpAll(() async {
      sqfliteFfiInit();

      databaseFactory = databaseFactoryFfi;
    });

    test(
        'When log is disabled '
        'And a batch of queries is executed '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      final batch = db.batch()
        ..execute(
          'CREATE TABLE Test '
          '(id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'value INTEGER, '
          'num REAL)',
        )
        ..query('Test');

      await batch.commit();

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a batch of queries is executed '
        'And printBatchEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printSqlEvents: false,
        printBatchEvents: false,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
      );

      final batch = db.batch()
        ..execute(
          'CREATE TABLE Test '
          '(id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'value INTEGER, '
          'num REAL)',
        )
        ..query('Test');

      await batch.commit();

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a batch query is executed '
        'And printBatchEvents is true '
        'Then call SqfliteBatchEventLog', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printSqlEvents: false,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      final batch = db.batch()
        ..execute(
          'CREATE TABLE Test '
          '(id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'value INTEGER, '
          'num REAL)',
        )
        ..query('Test');

      await batch.commit();

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteBatchEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteBatchEventLog>());
    });

    test(
        'When log is enabled '
        'And a batch query is executed '
        'And sqlBatchEventFilter has a filter bloking all the queries '
        'Then SqfliteSqlEventLog is never called', () async {
      List<bool> sqlBatchEventFilter(
        List<SqfliteLoggerBatchOperation<dynamic>> operations,
      ) =>
          operations.map((query) => false).toList();

      final settings = TalkerSqfliteLoggerSettings(
        sqlBatchEventFilter: sqlBatchEventFilter,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      final batch = db.batch()
        ..execute(
          'CREATE TABLE Test '
          '(id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'value INTEGER, '
          'num REAL)',
        )
        ..execute('INSERT INTO Test (name, value, num) '
            'VALUES("some name", 1234, 456.789)');

      await batch.commit();

      verifyNever(
        () => talker.logTyped(
          any(that: isA<SqfliteBatchEventLog>()),
        ),
      );
    });

    test(
        'When log is enabled '
        'And a batch query is executed '
        'And sqlBatchEventFilter has a filter bloking CREATE TABLEs queries '
        'Then SqfliteSqlEventLog is called only once', () async {
      List<bool> sqlBatchEventFilter(
        List<SqfliteLoggerBatchOperation<dynamic>> operations,
      ) =>
          operations
              .map((query) => !query.sql.contains('CREATE TABLE'))
              .toList();

      final settings = TalkerSqfliteLoggerSettings(
        sqlBatchEventFilter: sqlBatchEventFilter,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
      );

      final batch = db.batch()
        ..execute(
          'CREATE TABLE Test '
          '(id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'value INTEGER, '
          'num REAL)',
        )
        ..execute('INSERT INTO Test (name, value, num) '
            'VALUES("some name", 1234, 456.789)');

      await batch.commit();

      verify(
        () => talker.logTyped(
          any(that: isA<SqfliteBatchEventLog>()),
        ),
      ).called(1);
    });
  });

  group('SqfliteInvokeEventLog', () {
    setUpAll(() async {
      sqfliteFfiInit();

      databaseFactory = databaseFactoryFfi;
    });

    test(
        'When log is disabled '
        'And a transaction is initied '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(enabled: false);
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
        type: SqfliteDatabaseFactoryLoggerType.invoke,
      );

      await db.devInvokeMethod<dynamic>('debugMode', false);

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a transaction is initied '
        'And printInvokerEvents is false '
        'Then call nothing', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printSqlEvents: false,
        printInvokerEvents: false,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactoryFfi,
        type: SqfliteDatabaseFactoryLoggerType.invoke,
      );

      await db.devInvokeMethod<dynamic>('debugMode', false);

      verifyNever(() => talker.logTyped(any()));
    });

    test(
        'When log is enabled '
        'And a transaction is initied '
        'And printInvokerEvents is true '
        'Then call SqfliteBatchEventLog', () async {
      const settings = TalkerSqfliteLoggerSettings(
        printSqlEvents: false,
        printBatchEvents: false,
      );
      factory = TalkerSqfliteDatabaseFactory(
        talker: talker,
        settings: settings,
      );

      db = await factory.openDatabase(
        path: path,
        factory: databaseFactory,
        type: SqfliteDatabaseFactoryLoggerType.invoke,
      );

      await db.close();
      await deleteDatabase(path);

      final captured = verify(
        () => talker.logTyped(
          captureAny(
            that: isA<SqfliteInvokeEventLog>(),
          ),
        ),
      ).captured;

      expect(captured.last, isA<SqfliteInvokeEventLog>());
    });
  });
}
