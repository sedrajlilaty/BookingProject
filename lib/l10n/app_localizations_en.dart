// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome_back => 'Welcome back';

  @override
  String get notLoggedInTitle => 'Not Logged In';

  @override
  String get notLoggedInSubtitle => 'Please log in to continue';

  @override
  String get logout => 'Logout';

  @override
  String get confirmCancelMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirmed';

  @override
  String get loginFailedError => 'Login failed:';

  @override
  String get profile => 'Profile';

  @override
  String get owner => 'Owner';

  @override
  String get tenant => 'Tenant';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHint => 'Enable/disable notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get privacyPolicy => 'Privacy Policy & Terms of Service';
}
