
import 'package:flutter/material.dart';
import 'package:flutter_repositories_poc/components/custom_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

Future<List<dynamic>> fetchRepos() async {
  final response = await http.get(
      Uri.parse('https://api.github.com/users/godinhojoao/repos?sort=pushed'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load repositories');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _repos;
  Future<List<dynamic>>? _filteredRepos;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _repos = fetchRepos();
  }

  void _filterRepos(String query) {
    if (query.isEmpty) {
      return setState(() {
        _filteredRepos = null;
      });
    }

    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final filtered = _repos.then((repoList) {
        return repoList
            .where((repo) => (repo['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });

      setState(() {
        _filteredRepos = filtered;
      });
    });
  }

  void _handleNavigation(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  void dispose() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joao Godinho Repositories'),
      ),
      drawer:
          CustomDrawer(onNavigation: _handleNavigation),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterRepos,
              decoration: const InputDecoration(
                labelText: 'Search Repositories',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _filteredRepos ?? _repos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final repoList = snapshot.data as List<dynamic>;

                  return ListView(
                    children: [
                      PaginatedDataTable(
                        header: const Text('GitHub Repositories'),
                        columns: const [
                          DataColumn(label: Text('Owner URL')),
                          DataColumn(label: Text('Owner Name')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Link to Repo')),
                        ],
                        source: _RepositoryDataSource(repoList),
                        rowsPerPage: 10,
                        showFirstLastButtons: true,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RepositoryDataSource extends DataTableSource {
  final List<dynamic> _repoList;

  _RepositoryDataSource(this._repoList);

  Future<void> _launchUrl(String repoName) async {
    final url = Uri.parse('https://github.com/godinhojoao/$repoName');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  DataRow? getRow(int index) {
    final repo = _repoList[index];
    final description = repo['description'] ?? 'No description';
    final truncatedDescription = description.length > 50
        ? '${description.substring(0, 50)}...'
        : description;

    return DataRow(cells: [
      DataCell(Text(repo['owner']['url'])),
      DataCell(Text(repo['owner']['login'])),
      DataCell(Text(repo['name'])),
      DataCell(Text(truncatedDescription ?? 'No description')),
      DataCell(
        ElevatedButton(
          onPressed: () {
            _launchUrl(repo['name']);
          },
          child: const Text('Link'),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _repoList.length;

  @override
  int get selectedRowCount => 0;
}
