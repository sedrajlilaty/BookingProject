// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

 String get welcome_back => 'مرحبًا بعودتك';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get notLoggedInTitle => 'لم تقم بتسجيل الدخول';

  @override
  String get notLoggedInSubtitle => 'يرجى تسجيل الدخول للوصول إلى ملفك الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmCancelMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تم';

  @override
  String get loginFailedError => 'فشل تسجيل الدخول:';

  @override
  String get owner => 'مالك';

  @override
  String get tenant => 'مستأجر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsHint => 'تشغيل/إيقاف إشعارات التطبيق';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';
}
