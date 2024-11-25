import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PasswordManagerDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasswordManagerDashboard extends StatefulWidget {
  @override
  _PasswordManagerDashboardState createState() =>
      _PasswordManagerDashboardState();
}

class _PasswordManagerDashboardState extends State<PasswordManagerDashboard> {
  List<Map<String, dynamic>> _data = [];
  int _page = 1;
  int _rowsPerPage = 10;
  bool _isLoading = false;

  Future<void> _fetchData(String apiEndpoint) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://your-api-domain/$apiEndpoint?page=$_page');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as List<dynamic>;
        setState(() {
          _data = decodedData.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching data: $error'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _page = pageIndex + 1;
    });
    _fetchData('your-current-endpoint'); // Replace with the current endpoint
  }

  Widget _buildDataTable() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_data.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    return PaginatedDataTable(
      header: Text('Fetched Data'),
      rowsPerPage: _rowsPerPage,
      columns: _data.isNotEmpty
          ? _data[0].keys
              .map((key) => DataColumn(label: Text(key.toUpperCase())))
              .toList()
          : [],
      source: _DataTableSource(_data),
      onPageChanged: (startIndex) => _onPageChanged(startIndex ~/ _rowsPerPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: () => _fetchData('total_passwords'),
                    child: Text('Total Passwords')),
                ElevatedButton(
                    onPressed: () => _fetchData('social_media_passwords'),
                    child: Text('Social Media Passwords')),
                ElevatedButton(
                    onPressed: () => _fetchData('button_3_endpoint'),
                    child: Text('Button 3')),
                ElevatedButton(
                    onPressed: () => _fetchData('button_4_endpoint'),
                    child: Text('Button 4')),
                ElevatedButton(
                    onPressed: () => _fetchData('button_5_endpoint'),
                    child: Text('Button 5')),
                ElevatedButton(
                    onPressed: () => _fetchData('button_6_endpoint'),
                    child: Text('Button 6')),
              ],
            ),
          ),
          Expanded(child: _buildDataTable()),
        ],
      ),
    );
  }
}

class _DataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  _DataTableSource(this._data);

  @override
  DataRow getRow(int index) {
    if (index >= _data.length) return null;

    final row = _data[index];
    return DataRow(cells: row.values.map((value) => DataCell(Text(value.toString()))).toList());
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
