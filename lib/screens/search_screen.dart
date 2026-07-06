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
  final _controller = TextEditingController();
  List<CloudFile> _results = [];
  bool _searched = false;

  void _search(String q) {
    if (q.trim().isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    setState(() {
      _results  = FileStorageService.instance.search(q.trim());
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        title: const Text('بحث', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن ملف...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppConstants.primaryColor),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppConstants.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppConstants.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searched
                ? _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 70, color: Colors.grey[600]),
                            const SizedBox(height: 12),
                            Text('لا توجد نتائج لـ "${_controller.text}"',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) => FileCard(
                          file: _results[i],
                          onRefresh: () => _search(_controller.text),
                        ),
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded,
                            size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text('ابحث في ملفاتك السحابية',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
