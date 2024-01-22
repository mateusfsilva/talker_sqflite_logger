import 'package:sqflite_common/sqflite_logger.dart';

/// {@template talkerSqfliteLoggerSettings}
/// Choose the type of events to show in the logs.
///
/// {@endtemplate}
class TalkerSqfliteLoggerSettings {
  /// {@macro talkerSqfliteLoggerSettings}
  const TalkerSqfliteLoggerSettings({
    this.enabled = true,
    this.printSqlEvents = true,
    this.printSqlArguments = true,
    this.printSqlResults = false,
    this.printSqlElapsedTime = true,
    this.printDatabaseOpenEvents = false,
    this.printOpenDatabaseOptions = false,
    this.printDatabaseCloseEvents = false,
    this.printDatabaseDeleteEvents = false,
    this.printInvokerEvents = true,
    this.printBatchEvents = true,
    this.sqlEventFilter,
    this.sqlBatchEventFilter,
  });

  /// Enable the logs for the Sqflite events;
  final bool enabled;

  /// Print the SQL operations.
  final bool printSqlEvents;

  /// Print the arguments of the SQL operaions.
  final bool printSqlArguments;

  /// Print the result of the SQL operations.
  final bool printSqlResults;

  /// Print the elapsed time of the operations.
  final bool printSqlElapsedTime;

  /// Print the openning database events.
  final bool printDatabaseOpenEvents;

  /// Print the settings used to open the database.
  final bool printOpenDatabaseOptions;

  /// Print the closing database events.
  final bool printDatabaseCloseEvents;

  /// Print the deleteing database events.
  final bool printDatabaseDeleteEvents;

  /// Print the internal events.
  final bool printInvokerEvents;

  /// Print the SQL batch operations.
  final bool printBatchEvents;

  /// Filter the SQL operations to show in the logs.
  final bool Function(SqfliteLoggerSqlEvent<dynamic> event)? sqlEventFilter;

  /// Filter the SQL batch operations to show in the logs.
  final List<bool> Function(
    List<SqfliteLoggerBatchOperation<dynamic>> operations,
  )? sqlBatchEventFilter;
}
