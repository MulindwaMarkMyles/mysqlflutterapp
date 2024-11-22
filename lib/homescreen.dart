import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'server.dart';
import 'package:get/get.dart';

class MySqlDataPage extends StatefulWidget {
  @override
  _MySqlDataPageState createState() => _MySqlDataPageState();
}

class _MySqlDataPageState extends State<MySqlDataPage> {
  final MySQLDatabase _databaseService = MySQLDatabase(
    host: "127.0.0.1",
    port: 3306,
    userName: "your username",
    password: "your password",
    databaseName: "hybrid_fitnes",
  );
  List<Map<String, dynamic>> _data = [];
  List<String> _columns = [];
  List<String?> _tableNames = [];
  String? _selectedTable;
  String _customQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _databaseService.connect(); // Connect to the database
      _loadTableNames(); // Load table names after connection
    } catch (e) {
      print("Error connecting to database: $e");
      // You can show an error dialog or message here
    }
  }

  Future<void> _loadTableNames() async {
    List<String?> tableNames = await _databaseService.fetchTableNames();
    setState(() {
      _tableNames = tableNames;
      _selectedTable = _tableNames.isNotEmpty
          ? _tableNames[0]
          : null; // Select the first table by default
    });
    _loadData(); // Load data for the selected table
  }

  Future<void> _loadData() async {
    if (_selectedTable != null) {
      String query = 'SELECT * FROM $_selectedTable';
      List<Map<String, dynamic>> data = await _databaseService.query(query);
      setState(() {
        _data = data;
        _columns = data.isNotEmpty
            ? data[0].keys.toList()
            : []; // Get columns from the first row
      });
    }
  }

  Future<void> _executeCustomQuery() async {
    if (_customQuery.isNotEmpty) {
      try {
        List<Map<String, dynamic>> result =
            await _databaseService.query(_customQuery);
        setState(() {
          _data = result; // Update data with the result of the custom query
          _columns = _data.isNotEmpty
              ? _data.first.keys.toList()
              : []; // Update columns based on the result
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error, please check your query!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        // Handle any errors, e.g., show an error message
      }
    }
  }

  @override
  void dispose() {
    _databaseService
        .close(); // Ensure the connection is closed when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hybrid Fitness Data',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedTable,
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            style: TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.black,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTable = newValue;
                _loadData(); // Load data for the selected table
              });
            },
            items: _tableNames.map<DropdownMenuItem<String>>((String? value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value ?? 'nothing',
                  style: GoogleFonts.poppins(),
                ),
              );
            }).toList(),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Column(
            children: [
              // Custom Query Input Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Colors.blue.shade700,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Colors.blue.shade900,
                        width: 2.0,
                      ),
                    ),
                    hintText: 'Enter your query',
                    hintStyle:
                        TextStyle(fontFamily: GoogleFonts.poppins().fontFamily),
                  ),
                  style:
                      TextStyle(fontFamily: GoogleFonts.poppins().fontFamily),
                  onChanged: (value) {
                    setState(() {
                      _customQuery = value; // Update custom query
                    });
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: _executeCustomQuery,
                  child: Text(
                    'Execute Query',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700, // Background color
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  )),
              SizedBox(height: 10),
            ],
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _data.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        ),
                      ) // Show loading indicator while fetching data
                    : SingleChildScrollView(
                        scrollDirection: Axis
                            .vertical, // Allow vertical scrolling for long lists
                        child: SingleChildScrollView(
                          scrollDirection: Axis
                              .horizontal, // Allow horizontal scrolling for wide tables
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: DataTable(
                              columnSpacing: 10,
                              headingRowColor: WidgetStatePropertyAll(
                                  Colors.blueGrey.shade300),
                              columns: _columns.map((column) {
                                return DataColumn(
                                  label: Text(
                                    column,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                    ),
                                  ),
                                );
                              }).toList(),
                              rows: _data.map((row) {
                                return DataRow(
                                  cells: _columns.map((column) {
                                    return DataCell(Text(
                                      row[column].toString(),
                                      style: GoogleFonts.poppins(),
                                    ));
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                Positioned(
                  right: 20,
                  top: 20,
                  child: Stack(children: [
                    // Circle Layer 1
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.03),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Circle Layer 2
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Circle Layer 3
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]),
                ),
                Positioned(
                  left: 30,
                  bottom: 30,
                  child: Stack(children: [
                    // Circle Layer 1
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Circle Layer 2
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Circle Layer 3
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
