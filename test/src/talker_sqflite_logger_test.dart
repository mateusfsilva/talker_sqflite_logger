import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqflite_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talker/talker.dart';
import 'package:talker_sqflite_logger/talker_sqflite_logger.dart';
import 'package:test/test.dart';

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

  const path = inMemoryDatabasePath;

  setUpAll(() async {
    sqfliteFfiInit();

    registerFallbackValue(FakeTalkerLog());
    registerFallbackValue(FakeSqfliteLoggerSqlEvent<dynamic>());
    registerFallbackValue(FakeTalkerSqfliteLoggerSettings());
    registerFallbackValue(FakeSqfliteLoggerDatabaseOpenEvent());
    registerFallbackValue(FakeSqfliteLoggerDatabaseCloseEvent());
    registerFallbackValue(FakeSqfliteLoggerDatabaseDeleteEvent());
    registerFallbackValue(FakeSqfliteLoggerBatchEvent());
    registerFallbackValue(FakeSqfliteLoggerInvokeEvent());
    registerFallbackValue(LogLevel.debug);
  });

  setUp(() async {
    talker = MockTalker();
  });

  group('TalkerSqfliteDatabaseFactory', () {
    test('can be instantiated', () {
      expect(TalkerSqfliteDatabaseFactory(), isNotNull);
    });
  });

  group('SqfliteLoggerSqlEvent', () {
    test(
        'When log is disabled '
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

    // test(
    //     'When log is enabled '
    //     'And printSqlEvents is true '
    //     'Then call SqfliteSqlEventLog', () async {
    //   const settings = TalkerSqfliteLoggerSettings(
    //     printDatabaseOpenEvents: true,
    //   );
    //   factory = TalkerSqfliteDatabaseFactory(
    //     talker: talker,
    //     settings: settings,
    //   );

    //   when(
    //     () => talker.logTyped(
    //       any(),
    //       logLevel: any(named: 'logLevel'),
    //     ),
    //   ).thenReturn(null);

    //   when(
    //     () => talker.logTyped(
    //       SqfliteDatabaseOpenEventLog(
    //         event: any(named: 'event'),
    //         settings: settings,
    //       ),
    //     ),
    //   ).thenReturn(null);

    //   await factory.openDatabase(
    //     path: path,
    //     factory: databaseFactoryFfi,
    //   );

    //   // verify(
    //   //   () => talker.logTyped(
    //   //     SqfliteDatabaseOpenEventLog(
    //   //       event: any(named: 'event'),
    //   //       settings: settings,
    //   //     ),
    //   //   ),
    //   // ).called(1);

    //   verifyNever(() => talker.logTyped(any())).called(1);
    // });
  });
}
