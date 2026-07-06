import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../services/telegram_service.dart';
import '../services/file_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _botInfo;
  bool _loadingBot = true;

  @override
  void initState() {
    super.initState();
    _loadBotInfo();
  }

  Future<void> _loadBotInfo() async {
    final info = await TelegramService.instance.getBotInfo();
    setState(() {
      _botInfo      = info;
      _loadingBot   = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = FileStorageService.instance.getStats();
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        title: const Text('الإعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bot Card
          _buildBotCard(),
          const SizedBox(height: 16),
          // Stats
          _buildStatsCard(stats),
          const SizedBox(height: 16),
          // About
          _buildAboutCard(),
          const SizedBox(height: 16),
          // Danger
          _buildDangerCard(),
        ],
      ),
    );
  }

  Widget _buildBotCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_rounded,
                  color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              const Text('معلومات البوت',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Spacer(),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _botInfo != null
                      ? AppConstants.greenColor
                      : AppConstants.redColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _loadingBot ? 'جاري التحقق...' : _botInfo != null ? 'متصل' : 'غير متصل',
                style: TextStyle(
                  color: _botInfo != null
                      ? AppConstants.greenColor
                      : AppConstants.redColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          if (_loadingBot)
            const Center(child: CircularProgressIndicator(
                color: AppConstants.primaryColor))
          else if (_botInfo != null) ...[
            _infoRow('اسم البوت', '@${_botInfo!['username'] ?? 'N/A'}'),
            _infoRow('الاسم', _botInfo!['first_name'] ?? 'N/A'),
            _infoRow('Bot ID', '${_botInfo!['id'] ?? 'N/A'}'),
            _infoRow('Chat ID', AppConstants.chatId),
          ] else
            Text('تعذر الاتصال بالبوت',
                style: TextStyle(color: AppConstants.redColor)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final totalMB = (stats['size'] as int) / (1024 * 1024);
    final sizeStr = totalMB >= 1024
        ? '${(totalMB / 1024).toStringAsFixed(2)} GB'
        : '${totalMB.toStringAsFixed(1)} MB';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppConstants.primaryColor),
              SizedBox(width: 8),
              Text('إحصائيات',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          _infoRow('إجمالي الملفات', '${stats['total']}'),
          _infoRow('الصور', '${stats['images']}'),
          _infoRow('الفيديوهات', '${stats['videos']}'),
          _infoRow('الموسيقى', '${stats['audios']}'),
          _infoRow('المستندات', '${stats['docs']}'),
          _infoRow('الحجم الكلي', sizeStr),
          _infoRow('المساحة المتاحة', '∞ غير محدود'),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppConstants.primaryColor),
              SizedBox(width: 8),
              Text('حول التطبيق',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          _infoRow('الاسم', 'CloudGram'),
          _infoRow('الإصدار', '1.0.0'),
          _infoRow('المطور', 'ebra7im-coder'),
          _infoRow('المنصة', 'Flutter (Android & iOS)'),
          _infoRow('التخزين', 'Telegram Bot API'),
        ],
      ),
    );
  }

  Widget _buildDangerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.redColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppConstants.redColor),
              SizedBox(width: 8),
              Text('منطقة الخطر',
                  style: TextStyle(
                      color: AppConstants.redColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmClearCache(),
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppConstants.redColor),
              label: const Text('مسح ذاكرة التخزين المؤقت',
                  style: TextStyle(color: AppConstants.redColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppConstants.redColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    Get.dialog(AlertDialog(
      backgroundColor: AppConstants.cardDark,
      title: const Text('تأكيد', style: TextStyle(color: Colors.white)),
      content: const Text(
        'هل تريد مسح قاعدة البيانات المحلية؟\n(لن يؤثر على الملفات في تيليجرام)',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إلغاء',
              style: TextStyle(color: AppConstants.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            Get.snackbar('تم', 'تم مسح الذاكرة المؤقتة',
                backgroundColor: AppConstants.greenColor,
                colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.redColor),
          child: const Text('مسح', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
