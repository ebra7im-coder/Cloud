import 'package:flutter/material.dart';
import '../services/file_storage_service.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<CloudFile> _results = [];
  bool _searched = false;

  void _search(String q) {
    setState(() {
      _searched = q.trim().isNotEmpty;
      _results = _searched
          ? FileStorageService.instance.search(q.trim())
          : [];
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('البحث',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ابحث في ملفاتك...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppConstants.primaryColor),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                      onPressed: () {
                        _ctrl.clear();
                        _search('');
                      })
                  : null,
              filled: true,
              fillColor: AppConstants.cardDark,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppConstants.primaryColor, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        // Results
        Expanded(
          child: _searched
              ? _results.isEmpty
                  ? _empty()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      itemBuilder: (_, i) => FileCard(
                        file: _results[i],
                        onRefresh: () => _search(_ctrl.text),
                      ),
                    )
              : _placeholder(),
        ),
      ]),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off_rounded, size: 70, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text('لا نتائج لـ "${_ctrl.text}"',
              style: TextStyle(color: Colors.grey[500])),
        ]),
      );

  Widget _placeholder() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text('ابحث في ملفاتك السحابية',
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ]),
      );
}
