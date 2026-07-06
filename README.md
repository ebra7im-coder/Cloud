# ☁️ CloudGram

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" />
  <img src="https://img.shields.io/badge/Storage-Telegram%20Bot%20API-2AABEE?logo=telegram" />
  <img src="https://img.shields.io/badge/Storage-Unlimited%20%E2%88%9E-brightgreen" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
</p>

> **تخزين سحابي لا محدود** بالاستفادة من مساحة تيليجرام غير المحدودة عبر Telegram Bot API

---

## 📱 لقطات الشاشة

| الرئيسية | الملفات | الرفع | المشغّل |
|:-:|:-:|:-:|:-:|
| Dashboard | Files | Upload | Media Player |

---

## ✨ المميزات

- 📤 **رفع أي نوع ملف** — صور، فيديو، موسيقى، مستندات
- ☁️ **تخزين لا محدود** — بالاستفادة من Telegram Bot API
- 🎥 **مشغّل فيديو مدمج** — Chewie + video_player
- 🎵 **مشغّل موسيقى مدمج** — just_audio مع شريط تحكم كامل
- 🖼 **عرض الصور** — InteractiveViewer مع Zoom
- 📂 **تنظيم بالمجلدات** — تصنيف الملفات في مجلدات
- 🔍 **بحث سريع** — البحث في جميع الملفات
- ❤️ **المفضلة** — حفظ الملفات المهمة
- 📊 **إحصائيات** — عرض حجم الملفات والإحصاءات
- 🔄 **مزامنة** — مزامنة الملفات من تيليجرام
- 🗑 **حذف** — حذف من التطبيق وتيليجرام معاً
- 🌙 **الوضع الداكن** — Dark Theme بتصميم Telegram

---

## 🚀 التقنيات المستخدمة

| التقنية | الاستخدام |
|---------|-----------|
| **Flutter** | إطار العمل الأساسي |
| **Telegram Bot API** | التخزين السحابي |
| **Dio** | رفع الملفات الكبيرة |
| **Hive** | قاعدة البيانات المحلية |
| **GetX** | State Management & Navigation |
| **just_audio** | تشغيل الموسيقى |
| **Chewie + video_player** | تشغيل الفيديو |
| **file_picker** | اختيار الملفات |

---

## ⚙️ إعداد المشروع

### 1. المتطلبات
```bash
flutter --version  # 3.x أو أحدث
```

### 2. استنساخ المشروع
```bash
git clone https://github.com/ebra7im-coder/Cloud.git
cd Cloud
```

### 3. تثبيت الحزم
```bash
flutter pub get
```

### 4. إعداد Bot Token و Chat ID

في ملف `lib/utils/constants.dart`:
```dart
static const String botToken = 'YOUR_BOT_TOKEN';
static const String chatId   = 'YOUR_CHAT_ID';
```

### 5. تشغيل التطبيق
```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

---

## 📦 بناء ملف APK

```bash
flutter build apk --release
# الملف في: build/app/outputs/flutter-apk/app-release.apk
```

## 🍎 بناء iOS

```bash
flutter build ios --release
```

---

## 🤖 إنشاء Telegram Bot

1. افتح تيليجرام وابحث عن **@BotFather**
2. أرسل `/newbot`
3. اختر اسماً وusername للبوت
4. احفظ الـ **Bot Token** المُعطى
5. أرسل رسالة للبوت واحصل على **Chat ID** عبر:
   ```
   https://api.telegram.org/bot{TOKEN}/getUpdates
   ```

---

## 📁 هيكل المشروع

```
lib/
├── main.dart
├── models/
│   ├── file_model.dart          # نموذج الملف
│   └── file_model.g.dart        # Hive Adapter
├── services/
│   ├── telegram_service.dart    # Telegram Bot API
│   └── file_storage_service.dart # قاعدة البيانات المحلية
├── screens/
│   ├── splash_screen.dart       # شاشة البداية
│   ├── home_screen.dart         # الشاشة الرئيسية
│   ├── dashboard_screen.dart    # لوحة التحكم
│   ├── files_screen.dart        # عرض الملفات
│   ├── upload_screen.dart       # رفع الملفات
│   ├── search_screen.dart       # البحث
│   ├── settings_screen.dart     # الإعدادات
│   └── media_viewer_screen.dart # عرض وتشغيل الميديا
├── controllers/
│   └── home_controller.dart     # GetX Controller
├── widgets/
│   ├── file_card.dart           # بطاقة الملف (List)
│   └── file_grid_card.dart      # بطاقة الملف (Grid)
└── utils/
    └── constants.dart           # الثوابت والألوان
```

---

## 👨‍💻 المطور

**ebra7im-coder** — مطور Flutter متخصص في بناء تطبيقات مبتكرة

---

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة **MIT** — انظر ملف [LICENSE](LICENSE) للتفاصيل.

---

<p align="center">صُنع بـ ❤️ و ☕ في مصر 🇪🇬</p>
