import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const ArcheanApp());
}

class ArcheanApp extends StatelessWidget {
  const ArcheanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archean',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService api = ApiService();
  final TextEditingController qCtrl = TextEditingController();
  List<dynamic> results = [];
  Map<String, List<dynamic>> groups = {};
  bool indexing = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final files = await api.files();
      final Map<String, List<dynamic>> map = {};
      for (var f in files) {
        final name = f['name'] as String;
        final cat = _categoryFor(name);
        map.putIfAbsent(cat, () => []).add(f);
      }
      setState(() => groups = map);
    } catch (e) {
      // ignore
    }
  }

  String _categoryFor(String filename) {
    // simple category: prefix before first underscore or space
    final n = filename;
    if (n.contains('_')) return n.split('_')[0];
    if (n.contains(' ')) return n.split(' ')[0];
    return 'Misc';
  }

  Future<void> doSearch() async {
    final q = qCtrl.text.trim();
    if (q.isEmpty) return;
    final res = await api.search(q);
    setState(() => results = res);
  }

  Future<void> doReindex() async {
    setState(() => indexing = true);
    try {
      await api.reindex();
      await _loadFiles();
    } finally {
      setState(() => indexing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 240,
              color: Colors.grey[100],
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Categories', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: ListView(
                      children: groups.keys.map((k) {
                        final items = groups[k]!;
                        return ExpansionTile(
                          title: Text(k),
                          children: items
                              .map((it) => ListTile(
                                    title: Text(it['name']),
                                    onTap: () {
                                      // open file link in new tab
                                      final url = '${api.baseUrl}/file/${Uri.encodeComponent(it['name'])}';
                                      // ignore: deprecated_member_use
                                      _launchURL(url);
                                    },
                                  ))
                              .toList(),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: indexing ? null : doReindex,
                        child: Text(indexing ? 'Indexing...' : 'Reindex')),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Archean — Document Search', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextField(controller: qCtrl, decoration: const InputDecoration(hintText: 'Search regulations...'))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: doSearch, child: const Text('Search'))
                    ]),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, idx) {
                          final r = results[idx];
                          return Card(
                            child: ListTile(
                              title: Text(r['filename'] ?? 'file'),
                              subtitle: Text(r['snippet'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () {
                                  final url = '${api.baseUrl}/file/${Uri.encodeComponent(r['filename'])}';
                                  // ignore: deprecated_member_use
                                  _launchURL(url);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Quick Stage (FAQs)', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('• Add FAQs here in future'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// small URL launcher fallback for web
void _launchURL(String url) {
  // For web, open in new tab
  // ignore: undefined_prefixed_name
  // using dart:html directly is avoided to keep this generic; use window.open via JS interop would be ideal
  // Quick approach: use `dart:html` when compiling to web
  // ignore: avoid_web_libraries_in_flutter
  try {
    // ignore: undefined_prefixed_name
    // ignore: avoid_dynamic_calls
    (print)(url); // fallback: print URL to console
  } catch (e) {}
}
