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
  Map<String, dynamic>? _bot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBot();
  }

  Future<void> _loadBot() async {
    final info = await TelegramService.instance.getBotInfo();
    if (mounted) setState(() { _bot = info; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final stats = FileStorageService.instance.getStats();
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('الإعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _botCard(),
          const SizedBox(height: 14),
          _statsCard(stats),
          const SizedBox(height: 14),
          _aboutCard(),
          const SizedBox(height: 14),
          _dangerCard(),
        ],
      ),
    );
  }

  Widget _botCard() => _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader(
            Icons.smart_toy_rounded,
            'معلومات البوت',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _bot != null ? AppConstants.greenColor : AppConstants.redColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _loading ? '...' : _bot != null ? 'متصل' : 'غير متصل',
                style: TextStyle(
                  color: _bot != null ? AppConstants.greenColor : AppConstants.redColor,
                  fontSize: 12,
                ),
              ),
            ]),
          ),
          const Divider(height: 20, color: Colors.white12),
          if (_loading)
            const Center(child: CircularProgressIndicator(
                color: AppConstants.primaryColor, strokeWidth: 2))
          else if (_bot != null) ...[
            _row('الاسم', '@${_bot!['username'] ?? 'N/A'}'),
            _row('Bot ID', '${_bot!['id'] ?? 'N/A'}'),
            _row('Chat ID', AppConstants.chatId),
          ] else
            Text('تعذر الاتصال',
                style: TextStyle(color: AppConstants.redColor)),
        ]),
      );

  Widget _statsCard(Map<String, dynamic> s) {
    final mb = (s['size'] as int) / (1024 * 1024);
    final sizeStr = mb >= 1024
        ? '${(mb / 1024).toStringAsFixed(2)} GB'
        : '${mb.toStringAsFixed(1)} MB';
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.bar_chart_rounded, 'الإحصائيات'),
        const Divider(height: 20, color: Colors.white12),
        _row('إجمالي الملفات', '${s['total']}'),
        _row('الصور', '${s['images']}'),
        _row('الفيديوهات', '${s['videos']}'),
        _row('الموسيقى', '${s['audios']}'),
        _row('المستندات', '${s['docs']}'),
        _row('الحجم المستخدم', sizeStr),
        _row('المساحة المتاحة', '∞ غير محدود'),
      ]),
    );
  }

  Widget _aboutCard() => _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader(Icons.info_outline_rounded, 'حول التطبيق'),
          const Divider(height: 20, color: Colors.white12),
          _row('التطبيق', 'CloudGram'),
          _row('الإصدار', '1.0.0'),
          _row('المطور', 'ebra7im-coder'),
          _row('التخزين', 'Telegram Bot API'),
          _row('المنصة', 'Flutter (Android & iOS)'),
        ]),
      );

  Widget _dangerCard() => _card(
        borderColor: AppConstants.redColor.withOpacity(.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader(Icons.warning_amber_rounded, 'منطقة الخطر',
              iconColor: AppConstants.redColor,
              titleColor: AppConstants.redColor),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.dialog(AlertDialog(
                backgroundColor: AppConstants.cardDark,
                title: const Text('تأكيد', style: TextStyle(color: Colors.white)),
                content: Text('مسح قاعدة البيانات المحلية؟\n(الملفات في Telegram تبقى)',
                    style: TextStyle(color: Colors.grey[400])),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('إلغاء')),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar('تم', 'مُسحت البيانات المحلية',
                            backgroundColor: AppConstants.greenColor,
                            colorText: Colors.white);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.redColor),
                      child: const Text('مسح',
                          style: TextStyle(color: Colors.white))),
                ],
              )),
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppConstants.redColor),
              label: const Text('مسح البيانات المحلية',
                  style: TextStyle(color: AppConstants.redColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppConstants.redColor.withOpacity(.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      );

  Widget _card(
          {required Widget child, Color? borderColor}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(.06)),
        ),
        child: child,
      );

  Widget _cardHeader(IconData icon, String title,
      {Widget? trailing,
      Color? iconColor,
      Color? titleColor}) =>
      Row(children: [
        Icon(icon, color: iconColor ?? AppConstants.primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  color: titleColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
        if (trailing != null) trailing,
      ]);

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text(v,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ]),
      );
}
