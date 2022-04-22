import 'package:extended/extended.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:meilisearch/meilisearch.dart';

class AdminSearchSettingsScreen extends StatefulWidget {
  const AdminSearchSettingsScreen({Key? key}) : super(key: key);

  static const String routeName = '/searchSettings';

  @override
  _AdminSearchSettingsScreenState createState() =>
      _AdminSearchSettingsScreenState();
}

class _AdminSearchSettingsScreenState extends State<AdminSearchSettingsScreen> {
  List<MeiliSearchIndex> indexes = [];

  @override
  void initState() {
    super.initState();

    initIndexes();
  }

  initIndexes() async {
    try {
      indexes = await SearchService.instance.client.getIndexes();
      if (mounted) setState(() {});
    } catch (e) {
      error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Settings')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              for (MeiliSearchIndex index in indexes)
                IndexSettingForm(
                  indexUid: index.uid,
                  onDeleted: () {
                    alert('Delete', 'Documents deleted');
                    if (mounted) setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndexSettingForm extends StatefulWidget {
  IndexSettingForm({required this.indexUid, this.onDeleted, Key? key})
      : super(key: key);

  final String indexUid;
  final Function()? onDeleted;

  @override
  State<IndexSettingForm> createState() => _IndexSettingFormState();
}

class _IndexSettingFormState extends State<IndexSettingForm>
    with FirestoreMixin {
  final searchablesController = TextEditingController();
  final filtersController = TextEditingController();
  final sortersController = TextEditingController();

  late IndexSettings settings;

  @override
  void initState() {
    super.initState();

    initIndexSettings();
  }

  initIndexSettings() async {
    try {
      settings = await SearchService.instance.client
          .index(widget.indexUid)
          .getSettings();
      if (settings.searchableAttributes != null) {
        searchablesController.text = settings.searchableAttributes!.join(', ');
      }
      if (settings.filterableAttributes != null) {
        filtersController.text = settings.filterableAttributes!.join(', ');
      }
      if (settings.sortableAttributes != null) {
        sortersController.text = settings.sortableAttributes!.join(', ');
      }
      if (mounted) setState(() {});
    } catch (e) {
      error(e);
    }
  }

  updateIndexSettings() async {
    throw 'No more admin indexing. use node.js utility';
    // try {
    //   await SearchService.instance.updateIndexSearchSettings(
    //     index: widget.indexUid,
    //     searchables: searchablesController.text.split(', '),
    //     sortables: sortersController.text.split((', ')),
    //     filterables: filtersController.text.split((', ')),
    //     // rankingRules: [],
    //     // distinctAttribute: '', default to index
    //     // displayedAttributes: ['*'], // default to '*' (all)
    //     // stopWords: [],
    //     // synonyms: { 'word': ['other', 'logan'] },
    //   );
    //   alert('Success!', 'Index settings updated!');
    // } catch (e) {
    //   error(e);
    // }
  }

  deleteIndexDocuments() async {
    try {
      final conf = await confirm(
          'Confirm', 'Delete ${widget.indexUid} index documents?');
      if (!conf) return;

      await SearchService.instance.deleteAllDocuments(widget.indexUid);

      if (widget.onDeleted != null) widget.onDeleted!();
    } catch (e) {
      error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(4),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.indexUid + ' Settings', style: TextStyle(fontSize: 20)),
          Divider(),
          Text('searchable attributes'),
          TextFormField(controller: searchablesController),
          SizedBox(height: 10),
          Text('filterable attributes'),
          TextFormField(controller: filtersController),
          SizedBox(height: 10),
          Text('Sortable attributes'),
          TextFormField(controller: sortersController),
          SizedBox(height: 10),
          ElevatedButton(onPressed: updateIndexSettings, child: Text('UPDATE')),
          ElevatedButton(
              onPressed: deleteIndexDocuments,
              child: Text('DELETE INDEX DOCUMENTS')),
          // ElevatedButton(onPressed: reIndexDocuments, child: Text('RE-INDEX DOCUMENTS')),
        ],
      ),
    );
  }
}
