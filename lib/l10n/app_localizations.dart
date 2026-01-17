import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aqar App'**
  String get welcomeTitle1;

  /// No description provided for @welcomeSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive platform for renting and leasing apartments'**
  String get welcomeSubtitle1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Apartment'**
  String get welcomeTitle2;

  /// No description provided for @welcomeSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Thousands of apartments available in various areas'**
  String get welcomeSubtitle2;

  /// No description provided for @welcomeTitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure and Easy Booking'**
  String get welcomeTitle3;

  /// No description provided for @welcomeSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Reliable booking process with secure electronic payment'**
  String get welcomeSubtitle3;

  /// No description provided for @welcomeTitle4.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Properties'**
  String get welcomeTitle4;

  /// No description provided for @welcomeSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'For apartment owners: List your property and manage your bookings'**
  String get welcomeSubtitle4;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createAccountButton;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Royal Rent'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (09XXXXXXXX)'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password (at least 8 characters)'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date (YYYY/MM/DD)'**
  String get birthDate;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select account type'**
  String get selectAccountType;

  /// No description provided for @tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get tenant;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get chooseImage;

  /// No description provided for @imageHint.
  ///
  /// In en, this message translates to:
  /// **'Preferably a clear, high-quality image'**
  String get imageHint;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get enterLastName;

  /// No description provided for @selectAccountTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select account type'**
  String get selectAccountTypeError;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enterPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number is incorrect (must start with 09 and consist of 10 digits)'**
  String get invalidPhone;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmPasswordError;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please select birth date'**
  String get selectBirthDate;

  /// No description provided for @uploadIdImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload national ID image'**
  String get uploadIdImage;

  /// No description provided for @uploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Please upload profile picture'**
  String get uploadProfilePicture;

  /// No description provided for @imageSelectError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while selecting the image'**
  String get imageSelectError;

  /// No description provided for @imageCaptureError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while taking the photo'**
  String get imageCaptureError;

  /// No description provided for @waitingAdmin.
  ///
  /// In en, this message translates to:
  /// **'waiting for admin'**
  String get waitingAdmin;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully as'**
  String get accountCreated;

  /// No description provided for @incorrectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Incorrect account type. Please choose owner or tenant'**
  String get incorrectAccountType;

  /// No description provided for @dataError.
  ///
  /// In en, this message translates to:
  /// **'Data error'**
  String get dataError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @failedToConnect.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get failedToConnect;

  /// No description provided for @notLoggedInTitle.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedInTitle;

  /// No description provided for @notLoggedInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get notLoggedInSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmCancelMessage;

  /// No description provided for @loginFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to login'**
  String get loginFailedError;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable notifications'**
  String get notificationsHint;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number (09XXXXXXXX)'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (at least 8 characters)'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number is incorrect (must start with 09 and consist of 10 digits)'**
  String get phoneInvalid;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Please select account type'**
  String get pleaseSelectAccountType;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @dataFormatError.
  ///
  /// In en, this message translates to:
  /// **'Data format error'**
  String get dataFormatError;

  /// No description provided for @failedConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get failedConnectServer;

  /// No description provided for @rateApartment.
  ///
  /// In en, this message translates to:
  /// **'Rate Apartment'**
  String get rateApartment;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'How do you rate your experience in this apartment?'**
  String get rateExperience;

  /// No description provided for @veryBad.
  ///
  /// In en, this message translates to:
  /// **'Very Bad'**
  String get veryBad;

  /// No description provided for @bad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get bad;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @ratingHelps.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps other tenants make better decisions'**
  String get ratingHelps;

  /// No description provided for @myBooking.
  ///
  /// In en, this message translates to:
  /// **'My Booking'**
  String get myBooking;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'totalReviews'**
  String get totalReviews;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'waiting..'**
  String get waiting;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'confirmed'**
  String get confirmed;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'canceled'**
  String get canceled;

  /// No description provided for @noBookingYet.
  ///
  /// In en, this message translates to:
  /// **'There is no booking yet..'**
  String get noBookingYet;

  /// No description provided for @startFirstBooking.
  ///
  /// In en, this message translates to:
  /// **'start your first booking'**
  String get startFirstBooking;

  /// No description provided for @loadingName.
  ///
  /// In en, this message translates to:
  /// **'loading name..'**
  String get loadingName;

  /// No description provided for @loadingLocation.
  ///
  /// In en, this message translates to:
  /// **'loading location..'**
  String get loadingLocation;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @modificationUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Modification under review...'**
  String get modificationUnderReview;

  /// No description provided for @bookingCanceled.
  ///
  /// In en, this message translates to:
  /// **'This booking is canceled'**
  String get bookingCanceled;

  /// No description provided for @apartmentRating.
  ///
  /// In en, this message translates to:
  /// **'Apartment Rating'**
  String get apartmentRating;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @errorFetchingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error fetching reviews'**
  String get errorFetchingReviews;

  /// No description provided for @confirmCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'confirm cancle'**
  String get confirmCancelTitle;

  /// No description provided for @confirmCancelContent.
  ///
  /// In en, this message translates to:
  /// **'are you sure you want to cancle this booking?'**
  String get confirmCancelContent;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @bookingDuration.
  ///
  /// In en, this message translates to:
  /// **'Booking Duration'**
  String get bookingDuration;

  /// No description provided for @bookingStartDate.
  ///
  /// In en, this message translates to:
  /// **'Booking Start Date'**
  String get bookingStartDate;

  /// No description provided for @bookingEndDate.
  ///
  /// In en, this message translates to:
  /// **'Booking End Date'**
  String get bookingEndDate;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'payment method'**
  String get paymentMethod;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @stayDuration.
  ///
  /// In en, this message translates to:
  /// **'day of stay'**
  String get stayDuration;

  /// No description provided for @notePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Note: Your request will be sent to the owner for approval before final booking confirmation.'**
  String get notePendingApproval;

  /// No description provided for @sendBookingRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Booking Request to Owner'**
  String get sendBookingRequest;

  /// No description provided for @selectNumberOfMonths.
  ///
  /// In en, this message translates to:
  /// **'Select Number of Months'**
  String get selectNumberOfMonths;

  /// No description provided for @numberOfMonths.
  ///
  /// In en, this message translates to:
  /// **'Number of Months'**
  String get numberOfMonths;

  /// No description provided for @dailyPrice.
  ///
  /// In en, this message translates to:
  /// **'Daily Price'**
  String get dailyPrice;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @severalMonths.
  ///
  /// In en, this message translates to:
  /// **'Several Months'**
  String get severalMonths;

  /// No description provided for @fifteenDays.
  ///
  /// In en, this message translates to:
  /// **'15 Days'**
  String get fifteenDays;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get eWallet;

  /// No description provided for @alreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'Sorry, these dates are already booked for this apartment. Please choose another date.'**
  String get alreadyBooked;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoriteApartment.
  ///
  /// In en, this message translates to:
  /// **'there is no favorate appartement'**
  String get noFavoriteApartment;

  /// No description provided for @startAddingFavorite.
  ///
  /// In en, this message translates to:
  /// **'start adding your favorate appartement'**
  String get startAddingFavorite;

  /// No description provided for @errorLoadingApartment.
  ///
  /// In en, this message translates to:
  /// **'error in loading appartement'**
  String get errorLoadingApartment;

  /// No description provided for @withoutName.
  ///
  /// In en, this message translates to:
  /// **'without name'**
  String get withoutName;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'unkonown location'**
  String get unknownLocation;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @editBooking.
  ///
  /// In en, this message translates to:
  /// **'edit booking'**
  String get editBooking;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes and Send to Server'**
  String get saveChanges;

  /// No description provided for @modificationRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Modification request sent successfully, awaiting landlord approval'**
  String get modificationRequestSent;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while connecting to the server'**
  String get errorServer;

  /// No description provided for @nightPrice.
  ///
  /// In en, this message translates to:
  /// **'Night Price'**
  String get nightPrice;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area (sq.m) *'**
  String get area;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// No description provided for @numberOfNights.
  ///
  /// In en, this message translates to:
  /// **'Number of Nights'**
  String get numberOfNights;

  /// No description provided for @newTotal.
  ///
  /// In en, this message translates to:
  /// **'New Total'**
  String get newTotal;

  /// No description provided for @bookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmation'**
  String get bookingConfirmation;

  /// No description provided for @bookingRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Booking Request Sent - Awaiting Owner Approval'**
  String get bookingRequestSent;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'booking id'**
  String get bookingId;

  /// No description provided for @whatsNext.
  ///
  /// In en, this message translates to:
  /// **'What\'s Next?'**
  String get whatsNext;

  /// No description provided for @tipEmailConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You will receive a confirmation via email'**
  String get tipEmailConfirmation;

  /// No description provided for @tipOwnerContact.
  ///
  /// In en, this message translates to:
  /// **'The owner will contact you'**
  String get tipOwnerContact;

  /// No description provided for @tipReviewBookings.
  ///
  /// In en, this message translates to:
  /// **'You can review your bookings anytime'**
  String get tipReviewBookings;

  /// No description provided for @tipModify24h.
  ///
  /// In en, this message translates to:
  /// **'You can modify the booking within 24 hours'**
  String get tipModify24h;

  /// No description provided for @viewMyBookings.
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get viewMyBookings;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnHome;

  /// No description provided for @shareBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Share Booking Details'**
  String get shareBookingDetails;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'booking details'**
  String get bookingDetails;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @copyDetails.
  ///
  /// In en, this message translates to:
  /// **'Copy Details'**
  String get copyDetails;

  /// No description provided for @detailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Details copied to clipboard'**
  String get detailsCopied;

  /// No description provided for @bookingInformation.
  ///
  /// In en, this message translates to:
  /// **'booking\'s information'**
  String get bookingInformation;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'booking\'s date'**
  String get bookingDate;

  /// No description provided for @bookingTime.
  ///
  /// In en, this message translates to:
  /// **'booking time'**
  String get bookingTime;

  /// No description provided for @stayDates.
  ///
  /// In en, this message translates to:
  /// **'date of stay'**
  String get stayDates;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'end date'**
  String get endDate;

  /// No description provided for @financialInfo.
  ///
  /// In en, this message translates to:
  /// **'financial information'**
  String get financialInfo;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'price / month'**
  String get pricePerMonth;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'total price'**
  String get totalPrice;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'your rating'**
  String get yourRating;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'cancel booking'**
  String get cancelBooking;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'canceled'**
  String get cancelled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// No description provided for @pendingUpdate.
  ///
  /// In en, this message translates to:
  /// **'pending update'**
  String get pendingUpdate;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get removedFromFavorites;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'bathrooms'**
  String get bathrooms;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'location'**
  String get location;

  /// No description provided for @dateOfAdding.
  ///
  /// In en, this message translates to:
  /// **'Date of adding'**
  String get dateOfAdding;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @whatApartmentToday.
  ///
  /// In en, this message translates to:
  /// **'What apartment are we booking today?'**
  String get whatApartmentToday;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @studios.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get studios;

  /// No description provided for @utility.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get utility;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @condos.
  ///
  /// In en, this message translates to:
  /// **'Condos'**
  String get condos;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE PLAN'**
  String get upgradePlan;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get price;

  /// No description provided for @filterApartments.
  ///
  /// In en, this message translates to:
  /// **'Filter Apartments'**
  String get filterApartments;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, governorate, city...'**
  String get searchHint;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noApartmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No apartments found'**
  String get noApartmentsFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearch;

  /// No description provided for @viewAllApartments.
  ///
  /// In en, this message translates to:
  /// **'View All Apartments'**
  String get viewAllApartments;

  /// No description provided for @addingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Adding Confirmed!'**
  String get addingConfirmed;

  /// No description provided for @appartementAdded.
  ///
  /// In en, this message translates to:
  /// **'Your Appartement is added succesfully.'**
  String get appartementAdded;

  /// No description provided for @goToMyAppartements.
  ///
  /// In en, this message translates to:
  /// **'Go to My Appartements'**
  String get goToMyAppartements;

  /// No description provided for @bookingAndModificationRequests.
  ///
  /// In en, this message translates to:
  /// **'Booking and Modification Requests'**
  String get bookingAndModificationRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests at the moment'**
  String get noPendingRequests;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request #: #'**
  String get requestNumber;

  /// No description provided for @tenantRequestsDateModification.
  ///
  /// In en, this message translates to:
  /// **'Tenant requests date modification'**
  String get tenantRequestsDateModification;

  /// No description provided for @apartmentName.
  ///
  /// In en, this message translates to:
  /// **'Apartment Name *'**
  String get apartmentName;

  /// No description provided for @requestedDates.
  ///
  /// In en, this message translates to:
  /// **'Requested Dates:'**
  String get requestedDates;

  /// No description provided for @updatedTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Updated Total Price:'**
  String get updatedTotalPrice;

  /// No description provided for @approveBooking.
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get approveBooking;

  /// No description provided for @rejectBooking.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get rejectBooking;

  /// No description provided for @approveModification.
  ///
  /// In en, this message translates to:
  /// **'Approve Modification'**
  String get approveModification;

  /// No description provided for @rejectModification.
  ///
  /// In en, this message translates to:
  /// **'Reject Modification'**
  String get rejectModification;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @newModification.
  ///
  /// In en, this message translates to:
  /// **'New Modification'**
  String get newModification;

  /// No description provided for @addApartment.
  ///
  /// In en, this message translates to:
  /// **'Add Apartment'**
  String get addApartment;

  /// No description provided for @apartmentType.
  ///
  /// In en, this message translates to:
  /// **'Apartment Type'**
  String get apartmentType;

  /// No description provided for @apartmentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Apartment Photos'**
  String get apartmentPhotos;

  /// No description provided for @selectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select Governorate *'**
  String get selectGovernorate;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City *'**
  String get selectCity;

  /// No description provided for @selectGovernorateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select governorate first'**
  String get selectGovernorateFirst;

  /// No description provided for @detailedLocation.
  ///
  /// In en, this message translates to:
  /// **'Detailed Location'**
  String get detailedLocation;

  /// No description provided for @numberOfRooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Rooms *'**
  String get numberOfRooms;

  /// No description provided for @numberOfBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Bathrooms *'**
  String get numberOfBathrooms;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @addApartmentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Apartment'**
  String get addApartmentButton;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'You must fill all fields'**
  String get fillAllFields;

  /// No description provided for @apartmentTypeMissing.
  ///
  /// In en, this message translates to:
  /// **'Apartment type'**
  String get apartmentTypeMissing;

  /// No description provided for @apartmentNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Apartment name'**
  String get apartmentNameMissing;

  /// No description provided for @governorateMissing.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorateMissing;

  /// No description provided for @cityMissing.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityMissing;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos for apartment'**
  String get addPhotos;

  /// No description provided for @priceMissing.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceMissing;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'There was an error'**
  String get errorOccurred;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment'**
  String get noNotifications;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Title'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Notification Body'**
  String get notificationBody;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'Time ago'**
  String get timeAgo;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment'**
  String get notificationsEmpty;

  /// No description provided for @anyRooms.
  ///
  /// In en, this message translates to:
  /// **'anyRooms'**
  String get anyRooms;

  /// No description provided for @oneRoom.
  ///
  /// In en, this message translates to:
  /// **'oneRoom'**
  String get oneRoom;

  /// No description provided for @twoRooms.
  ///
  /// In en, this message translates to:
  /// **'2 Rooms'**
  String get twoRooms;

  /// No description provided for @threeRooms.
  ///
  /// In en, this message translates to:
  /// **'3 Rooms'**
  String get threeRooms;

  /// No description provided for @fourPlusRooms.
  ///
  /// In en, this message translates to:
  /// **'+4 Rooms'**
  String get fourPlusRooms;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @bookingApprovalNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Your request will be sent to the owner for approval before final booking confirmation.'**
  String get bookingApprovalNote;

  /// No description provided for @appartementId.
  ///
  /// In en, this message translates to:
  /// **'appartementId'**
  String get appartementId;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysCount;

  /// No description provided for @inDay.
  ///
  /// In en, this message translates to:
  /// **'inDay'**
  String get inDay;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
