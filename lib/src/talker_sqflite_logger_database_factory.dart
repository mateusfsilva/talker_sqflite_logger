import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqflite_logger.dart';
import 'package:talker/talker.dart';
import 'package:talker_sqflite_logger/src/sqflite_logs.dart';
import 'package:talker_sqflite_logger/src/talker_sqflite_logger_settings.dart';

/// {@template talkerSqfliteDatabaseFactory}
/// sqflite library logger on talker base.
///
/// {@endtemplate}
class TalkerSqfliteDatabaseFactory {
  /// {@macro talkerSqfliteDatabaseFactory}
  TalkerSqfliteDatabaseFactory({
    Talker? talker,
    TalkerSqfliteLoggerSettings? settings,
  })  : _settings = settings ?? const TalkerSqfliteLoggerSettings(),
        _talker = talker ?? Talker();

  final Talker _talker;
  final TalkerSqfliteLoggerSettings _settings;
  late SqfliteDatabaseFactoryLogger _factoryWithLogs;

  /// .
  Future<Database> openDatabase({
    required String path,
    OpenDatabaseOptions? options,
    DatabaseFactory? factory,
    SqfliteDatabaseFactoryLoggerType? type =
        SqfliteDatabaseFactoryLoggerType.all,
  }) async {
    _factoryWithLogs = SqfliteDatabaseFactoryLogger(
      factory ?? databaseFactory,
      options: SqfliteLoggerOptions(
        log: _logger,
        type: type,
      ),
    );

    return _factoryWithLogs.openDatabase(
      path,
      options: options,
    );
  }

  ///
  Future<void> deleteDatabase(
    String path,
  ) =>
      _factoryWithLogs.deleteDatabase(path);

  void _logger(SqfliteLoggerEvent event) {
    if (!_settings.enabled) {
      return;
    }

    if (event is SqfliteLoggerSqlEvent) {
      if (_settings.printSqlEvents) {
        final accepted = _settings.sqlEventFilter?.call(event) ?? true;

        if (!accepted) {
          return;
        }

        _talker.logTyped(
          SqfliteSqlEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    } else if (event is SqfliteLoggerDatabaseOpenEvent) {
      if (_settings.printDatabaseOpenEvents) {
        _talker.logTyped(
          SqfliteDatabaseOpenEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    } else if (event is SqfliteLoggerDatabaseCloseEvent) {
      if (_settings.printDatabaseCloseEvents) {
        _talker.logTyped(
          SqfliteDatabaseCloseEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    } else if (event is SqfliteLoggerDatabaseDeleteEvent) {
      if (_settings.printDatabaseDeleteEvents) {
        _talker.logTyped(
          SqfliteDatabaseDeleteEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    } else if (event is SqfliteLoggerBatchEvent) {
      if (_settings.printBatchEvents) {
        var accepted = true;

        if (_settings.sqlBatchEventFilter != null) {
          final size = _settings.sqlBatchEventFilter
                  ?.call(event.operations)
                  .where((element) => element)
                  .length ??
              0;

          accepted = size != 0;
        }

        if (!accepted) {
          return;
        }

        _talker.logTyped(
          SqfliteBatchEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    } else if (event is SqfliteLoggerInvokeEvent) {
      if (_settings.printInvokerEvents) {
        _talker.logTyped(
          SqfliteInvokeEventLog(
            event: event,
            settings: _settings,
          ),
        );
      }
    }
  }
}
