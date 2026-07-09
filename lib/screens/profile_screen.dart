// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../controllers/home_controller.dart';
import '../services/telegram_service.dart';
import '../services/file_storage_service.dart';
import '../widgets/glass_card.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _bot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBot();
  }

  Future<void> _loadBot() async {
    try {
      final info = await TelegramService.instance.getBotInfo();
      if (mounted) setState(() { _bot = info; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = FileStorageService.instance.getStats();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildBotCard(),
            SizedBox(height: 16.h),
            _buildStatsCard(stats),
            SizedBox(height: 16.h),
            _buildAboutCard(),
            SizedBox(height: 16.h),
            _buildDangerCard(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBotCard() {
    final statusColor = _bot != null ? Colors.green : AppTheme.secondary;
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.cpu_charge, color: AppTheme.primary, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'معلومات البوت',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _loading ? 'جاري التحميل...' : _bot != null ? 'متصل' : 'غير متصل',
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFF2A3450)),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_bot != null) ...[
              _buildRow('الاسم', '@${_bot!['username'] ?? 'N/A'}'),
              _buildRow('ID البوت', '${_bot!['id'] ?? 'N/A'}'),
              _buildRow('ID المحادثة', AppConstants.chatId),
            ] else
              Center(
                child: Text(
                  'تعذر الاتصال بالبوت',
                  style: GoogleFonts.poppins(color: AppTheme.secondary, fontSize: 13.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> s) {
    final mb = (s['size'] as int) / (1024 * 1024);
    final sizeStr = mb >= 1024
        ? '${(mb / 1024).toStringAsFixed(2)} GB'
        : '${mb.toStringAsFixed(1)} MB';
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.chart_21, color: AppTheme.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'الإحصائيات السحابية',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFF2A3450)),
            _buildRow('إجمالي الملفات', '${s['total']}'),
            _buildRow('الصور', '${s['images']}'),
            _buildRow('الفيديوهات', '${s['videos']}'),
            _buildRow('الموسيقى', '${s['audios']}'),
            _buildRow('المستندات', '${s['docs']}'),
            _buildRow('الحجم الكلي', sizeStr),
            _buildRow('المساحة المتاحة', '∞ غير محدود'),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.info_circle, color: AppTheme.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'حول التطبيق',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFF2A3450)),
            _buildRow('اسم التطبيق', 'CloudVault'),
            _buildRow('الإصدار', '1.0.0'),
            _buildRow('المطور', 'ebra7im-coder'),
            _buildRow('منصة التطوير', 'Flutter'),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerCard() {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.warning_2, color: AppTheme.secondary, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'منطقة الخطر',
                  style: GoogleFonts.poppins(
                    color: AppTheme.secondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFF2A3450)),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmClearCache(),
                icon: const Icon(Iconsax.trash, color: Colors.white),
                label: Text(
                  'مسح البيانات المحلية',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCache() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'تأكيد العملية',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من مسح قاعدة البيانات المحلية؟ ستظل ملفاتك مرفوعة على خوادم السحابية.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await FileStorageService.instance.clearAll();
              try {
                Get.find<HomeController>().loadFiles();
              } catch (_) {}
              Get.snackbar(
                'تم العملية بنجاح',
                'مُسحت البيانات المحلية بالكامل',
                backgroundColor: AppTheme.cardDark,
                colorText: AppTheme.textPrimary,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
            child: Text('مسح', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String key, String val) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13.sp),
          ),
          Text(
            val,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
