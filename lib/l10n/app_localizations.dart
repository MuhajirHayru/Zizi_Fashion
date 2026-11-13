import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZIZI FASHION'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get tabCustomers;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @openOrders.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get openOrders;

  /// No description provided for @totalOwed.
  ///
  /// In en, this message translates to:
  /// **'Balance owed'**
  String get totalOwed;

  /// No description provided for @currencyBirr.
  ///
  /// In en, this message translates to:
  /// **'Birr'**
  String get currencyBirr;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchHint;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet. Tap + to add one.'**
  String get noCustomers;

  /// No description provided for @newCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomerTitle;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldName;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameRequired;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @confirmDeleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete this customer with all measurements and orders?'**
  String get confirmDeleteCustomer;

  /// No description provided for @confirmDeleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete this order and its payments?'**
  String get confirmDeleteOrder;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurements;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit measurement'**
  String get editMeasurement;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @hip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get hip;

  /// No description provided for @shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get shoulder;

  /// No description provided for @sleeve.
  ///
  /// In en, this message translates to:
  /// **'Sleeve length'**
  String get sleeve;

  /// No description provided for @bicep.
  ///
  /// In en, this message translates to:
  /// **'Bicep'**
  String get bicep;

  /// No description provided for @wrist.
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get wrist;

  /// No description provided for @thigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get thigh;

  /// No description provided for @knee.
  ///
  /// In en, this message translates to:
  /// **'Knee'**
  String get knee;

  /// No description provided for @trouserLength.
  ///
  /// In en, this message translates to:
  /// **'Trouser length'**
  String get trouserLength;

  /// No description provided for @bottomWidth.
  ///
  /// In en, this message translates to:
  /// **'Bottom width'**
  String get bottomWidth;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get editOrder;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet. Tap + to create one.'**
  String get noOrders;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatuses;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get selectCustomer;

  /// No description provided for @pickCustomer.
  ///
  /// In en, this message translates to:
  /// **'Pick a customer'**
  String get pickCustomer;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @styleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get styleOther;

  /// No description provided for @styleSuit.
  ///
  /// In en, this message translates to:
  /// **'Suit'**
  String get styleSuit;

  /// No description provided for @styleShirt.
  ///
  /// In en, this message translates to:
  /// **'Shirt'**
  String get styleShirt;

  /// No description provided for @styleTrousers.
  ///
  /// In en, this message translates to:
  /// **'Trousers'**
  String get styleTrousers;

  /// No description provided for @styleDress.
  ///
  /// In en, this message translates to:
  /// **'Dress'**
  String get styleDress;

  /// No description provided for @styleTraditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get styleTraditional;

  /// No description provided for @fabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric type'**
  String get fabric;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @depositOptional.
  ///
  /// In en, this message translates to:
  /// **'Deposit (optional)'**
  String get depositOptional;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get deliveryDate;

  /// No description provided for @dueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Due this week'**
  String get dueThisWeek;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFitting.
  ///
  /// In en, this message translates to:
  /// **'Fitting'**
  String get statusFitting;

  /// No description provided for @statusSewing.
  ///
  /// In en, this message translates to:
  /// **'Sewing'**
  String get statusSewing;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @statusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get statusCollected;

  /// No description provided for @unknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown customer'**
  String get unknownCustomer;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @advanceNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {status}'**
  String advanceNext(String status);

  /// No description provided for @fullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully paid'**
  String get fullyPaid;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPayments;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get addPayment;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
  String get editPayment;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @developers.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developers;

  /// No description provided for @dataStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'All data is stored on this phone only. No internet connection needed.'**
  String get dataStoredLocally;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask for username and password when opening the app'**
  String get appLockDesc;

  /// No description provided for @createUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Create username & password'**
  String get createUsernamePassword;

  /// No description provided for @changeCredentials.
  ///
  /// In en, this message translates to:
  /// **'Change username & password'**
  String get changeCredentials;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginTitle;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password'**
  String get wrongCredentials;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportData;

  /// No description provided for @stepCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get stepCustomer;

  /// No description provided for @stepGarments.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get stepGarments;

  /// No description provided for @stepMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get stepMeasurements;

  /// No description provided for @stepDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get stepDesign;

  /// No description provided for @stepFabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric'**
  String get stepFabric;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get stepDelivery;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @designReference.
  ///
  /// In en, this message translates to:
  /// **'Design reference photos'**
  String get designReference;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openCamera;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @imageDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get imageDescription;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order registered'**
  String get orderCreated;

  /// No description provided for @lining.
  ///
  /// In en, this message translates to:
  /// **'Lining'**
  String get lining;

  /// No description provided for @maleWear.
  ///
  /// In en, this message translates to:
  /// **'Male wear'**
  String get maleWear;

  /// No description provided for @femaleWear.
  ///
  /// In en, this message translates to:
  /// **'Female wear'**
  String get femaleWear;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @viewMeasurements.
  ///
  /// In en, this message translates to:
  /// **'View measurements'**
  String get viewMeasurements;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer information'**
  String get customerInfo;

  /// No description provided for @statusTimeline.
  ///
  /// In en, this message translates to:
  /// **'Order status timeline'**
  String get statusTimeline;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get updateStatus;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @statTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get statTotalOrders;

  /// No description provided for @statCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get statCustomers;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Tailor Management System'**
  String get tagline;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for choosing ZIZI FASHION'**
  String get thankYou;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order successfully registered!'**
  String get orderSuccessTitle;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @fieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get fieldGender;

  /// No description provided for @fieldAltPhone.
  ///
  /// In en, this message translates to:
  /// **'Alternative phone (optional)'**
  String get fieldAltPhone;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get fieldRegion;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldSubCity.
  ///
  /// In en, this message translates to:
  /// **'Sub-city / Woreda'**
  String get fieldSubCity;

  /// No description provided for @fieldKebele.
  ///
  /// In en, this message translates to:
  /// **'Kebele / specific location (optional)'**
  String get fieldKebele;

  /// No description provided for @fieldCustomerType.
  ///
  /// In en, this message translates to:
  /// **'Customer type'**
  String get fieldCustomerType;

  /// No description provided for @customerFound.
  ///
  /// In en, this message translates to:
  /// **'Customer found — use existing profile?'**
  String get customerFound;

  /// No description provided for @useExistingProfile.
  ///
  /// In en, this message translates to:
  /// **'Use existing profile'**
  String get useExistingProfile;

  /// No description provided for @registerNew.
  ///
  /// In en, this message translates to:
  /// **'Register as new'**
  String get registerNew;

  /// No description provided for @searchPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter customer phone number'**
  String get searchPhoneHint;

  /// No description provided for @autoInfo.
  ///
  /// In en, this message translates to:
  /// **'Automatically recorded by the system'**
  String get autoInfo;

  /// No description provided for @regDate.
  ///
  /// In en, this message translates to:
  /// **'Registration date'**
  String get regDate;

  /// No description provided for @regTime.
  ///
  /// In en, this message translates to:
  /// **'Registration time'**
  String get regTime;

  /// No description provided for @customerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get customerId;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff member'**
  String get staff;

  /// No description provided for @addGarment.
  ///
  /// In en, this message translates to:
  /// **'Add garment'**
  String get addGarment;

  /// No description provided for @completeOutfit.
  ///
  /// In en, this message translates to:
  /// **'Complete graduation outfit'**
  String get completeOutfit;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @garment.
  ///
  /// In en, this message translates to:
  /// **'Garment'**
  String get garment;

  /// No description provided for @noGarments.
  ///
  /// In en, this message translates to:
  /// **'Add at least one garment'**
  String get noGarments;

  /// No description provided for @copyLastMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Copy last measurement'**
  String get copyLastMeasurement;

  /// No description provided for @noPreviousMeasurement.
  ///
  /// In en, this message translates to:
  /// **'No previous measurement saved for this garment'**
  String get noPreviousMeasurement;

  /// No description provided for @fabricColor.
  ///
  /// In en, this message translates to:
  /// **'Fabric color'**
  String get fabricColor;

  /// No description provided for @fabricPattern.
  ///
  /// In en, this message translates to:
  /// **'Fabric pattern'**
  String get fabricPattern;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Additional accessories'**
  String get accessories;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special design instructions'**
  String get specialInstructions;

  /// No description provided for @assignedTailor.
  ///
  /// In en, this message translates to:
  /// **'Assigned tailor'**
  String get assignedTailor;

  /// No description provided for @statusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status history'**
  String get statusHistory;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Garments in this order'**
  String get orderItems;

  /// No description provided for @editMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Edit measurements'**
  String get editMeasurements;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get orderDate;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export filtered (Excel)'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export filtered (PDF)'**
  String get exportPdf;

  /// No description provided for @printSheet.
  ///
  /// In en, this message translates to:
  /// **'Print measurement sheet'**
  String get printSheet;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get noResults;

  /// No description provided for @requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in phone number and name'**
  String get requiredFields;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @measurementSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Measurements taken for this order'**
  String get measurementSnapshot;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @sampleWears.
  ///
  /// In en, this message translates to:
  /// **'Sample wears (fabric)'**
  String get sampleWears;

  /// No description provided for @captureNewSample.
  ///
  /// In en, this message translates to:
  /// **'New sample with camera'**
  String get captureNewSample;

  /// No description provided for @sampleName.
  ///
  /// In en, this message translates to:
  /// **'Sample name'**
  String get sampleName;

  /// No description provided for @pickFabricSample.
  ///
  /// In en, this message translates to:
  /// **'Pick a fabric sample'**
  String get pickFabricSample;

  /// No description provided for @noSamples.
  ///
  /// In en, this message translates to:
  /// **'No fabric samples yet. Capture one with the camera.'**
  String get noSamples;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get cameraError;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get totalPaid;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add staff member'**
  String get addStaff;

  /// No description provided for @staffName.
  ///
  /// In en, this message translates to:
  /// **'Staff name'**
  String get staffName;

  /// No description provided for @activeStaff.
  ///
  /// In en, this message translates to:
  /// **'Active staff'**
  String get activeStaff;

  /// No description provided for @noStaff.
  ///
  /// In en, this message translates to:
  /// **'Add a staff member in Settings first'**
  String get noStaff;

  /// No description provided for @savedPath.
  ///
  /// In en, this message translates to:
  /// **'Saved to:\n{path}'**
  String savedPath(String path);

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to:\n{path}'**
  String exportDone(String path);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create backup'**
  String get exportFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
