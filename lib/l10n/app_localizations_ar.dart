// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome_back => 'مرحبا بعودتك';

  @override
  String get notLoggedInTitle => 'غير مسجل الدخول';

  @override
  String get notLoggedInSubtitle => 'يرجى تسجيل الدخول للمتابعة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmCancelMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تم التأكيد';

  @override
  String get loginFailedError => 'فشل تسجيل الدخول:';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get owner => 'مالك';

  @override
  String get tenant => 'مستأجر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsHint => 'تفعيل/تعطيل الإشعارات';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get privacyPolicy => 'سياسة الخصوصية وشروط الخدمة';
}
