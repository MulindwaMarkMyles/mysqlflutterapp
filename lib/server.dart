import 'package:mysql_client/mysql_client.dart';

class MySQLDatabase {
  final String host;
  final int port;
  final String userName;
  final String password;
  final String databaseName;

  late MySQLConnection _connection;

  MySQLDatabase({
    required this.host,
    required this.port,
    required this.userName,
    required this.password,
    required this.databaseName,
  });

  Future<void> connect() async {
    print("Connecting to MySQL server...");
    _connection = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: userName,
      password: password,
      databaseName: databaseName,
    );

    await _connection.connect();
    print("Connected");
  }

  Future<List<Map<String, dynamic>>> query(String sql) async {
    final result = await _connection.execute(sql);
    List<Map<String, dynamic>> rows = [];

    for (final row in result.rows) {
      rows.add(row.assoc());
    }
    return rows;
  }

  Future<List<String?>> fetchTableNames() async {
    // Query to fetch table names
    var result = await _connection.execute("SHOW TABLES");
    List<String?> tableNames = [];

    for (var row in result.rows) {
      tableNames.add(row.colAt(0));
    }

    return tableNames; // Don't close connection here
  }

  Future<int> update(String sql) async {
    final result = await _connection.execute(sql);
    return result.affectedRows as int; // Return the number of affected rows
  }

  Future<int> insert(String sql) async {
    final result = await _connection.execute(sql);
    return result.lastInsertID as int; // Return the ID of the inserted row
  }

  Future<void> close() async {
    await _connection.close();
    print("Connection closed");
  }
}
