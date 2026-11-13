// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZIZI FASHION';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCustomers => 'Customers';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabSettings => 'Settings';

  @override
  String get openOrders => 'Open orders';

  @override
  String get totalOwed => 'Balance owed';

  @override
  String get currencyBirr => 'Birr';

  @override
  String get newCustomer => 'New customer';

  @override
  String get newOrder => 'New order';

  @override
  String get searchHint => 'Search by name or phone';

  @override
  String get noCustomers => 'No customers yet. Tap + to add one.';

  @override
  String get newCustomerTitle => 'New customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get fieldName => 'Full name';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldDate => 'Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get deposit => 'Deposit';

  @override
  String get confirmDeleteCustomer =>
      'Delete this customer with all measurements and orders?';

  @override
  String get confirmDeleteOrder => 'Delete this order and its payments?';

  @override
  String get measurements => 'Measurements';

  @override
  String get noMeasurements => 'No measurements yet';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get editMeasurement => 'Edit measurement';

  @override
  String get neck => 'Neck';

  @override
  String get chest => 'Chest';

  @override
  String get waist => 'Waist';

  @override
  String get hip => 'Hip';

  @override
  String get shoulder => 'Shoulder';

  @override
  String get sleeve => 'Sleeve length';

  @override
  String get bicep => 'Bicep';

  @override
  String get wrist => 'Wrist';

  @override
  String get thigh => 'Thigh';

  @override
  String get knee => 'Knee';

  @override
  String get trouserLength => 'Trouser length';

  @override
  String get bottomWidth => 'Bottom width';

  @override
  String get orders => 'Orders';

  @override
  String get editOrder => 'Edit order';

  @override
  String get noOrders => 'No orders yet. Tap + to create one.';

  @override
  String get allStatuses => 'All';

  @override
  String get selectCustomer => 'Customer';

  @override
  String get pickCustomer => 'Pick a customer';

  @override
  String get style => 'Style';

  @override
  String get styleOther => 'Other';

  @override
  String get styleSuit => 'Suit';

  @override
  String get styleShirt => 'Shirt';

  @override
  String get styleTrousers => 'Trousers';

  @override
  String get styleDress => 'Dress';

  @override
  String get styleTraditional => 'Traditional';

  @override
  String get fabric => 'Fabric type';

  @override
  String get totalPrice => 'Total price';

  @override
  String get depositOptional => 'Deposit (optional)';

  @override
  String get deliveryDate => 'Delivery date';

  @override
  String get dueThisWeek => 'Due this week';

  @override
  String get status => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFitting => 'Fitting';

  @override
  String get statusSewing => 'Sewing';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusCollected => 'Collected';

  @override
  String get unknownCustomer => 'Unknown customer';

  @override
  String get overdue => 'Overdue';

  @override
  String advanceNext(String status) {
    return 'Next: $status';
  }

  @override
  String get fullyPaid => 'Fully paid';

  @override
  String get balance => 'Balance';

  @override
  String get paid => 'Paid';

  @override
  String get amount => 'Amount';

  @override
  String get payments => 'Payments';

  @override
  String get noPayments => 'No payments yet';

  @override
  String get addPayment => 'Add payment';

  @override
  String get editPayment => 'Edit payment';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get language => 'Language';

  @override
  String get developers => 'Developers';

  @override
  String get dataStoredLocally =>
      'All data is stored on this phone only. No internet connection needed.';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockDesc =>
      'Ask for username and password when opening the app';

  @override
  String get createUsernamePassword => 'Create username & password';

  @override
  String get changeCredentials => 'Change username & password';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Login to continue';

  @override
  String get wrongCredentials => 'Wrong username or password';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters';

  @override
  String get passwordTooShort => 'Password must be at least 4 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get exportData => 'Export backup';

  @override
  String get stepCustomer => 'Customer';

  @override
  String get stepGarments => 'Garments';

  @override
  String get stepMeasurements => 'Measurements';

  @override
  String get stepFabric => 'Fabric & design';

  @override
  String get stepDelivery => 'Delivery & price';

  @override
  String get fieldGender => 'Gender';

  @override
  String get fieldAltPhone => 'Alternative phone (optional)';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldRegion => 'Region';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldSubCity => 'Sub-city / Woreda';

  @override
  String get fieldKebele => 'Kebele / specific location (optional)';

  @override
  String get fieldCustomerType => 'Customer type';

  @override
  String get customerFound => 'Customer found — use existing profile?';

  @override
  String get useExistingProfile => 'Use existing profile';

  @override
  String get registerNew => 'Register as new';

  @override
  String get searchPhoneHint => 'Enter customer phone number';

  @override
  String get autoInfo => 'Automatically recorded by the system';

  @override
  String get regDate => 'Registration date';

  @override
  String get regTime => 'Registration time';

  @override
  String get customerId => 'Customer ID';

  @override
  String get orderId => 'Order ID';

  @override
  String get staff => 'Staff member';

  @override
  String get addGarment => 'Add garment';

  @override
  String get completeOutfit => 'Complete graduation outfit';

  @override
  String get quantity => 'Quantity';

  @override
  String get garment => 'Garment';

  @override
  String get noGarments => 'Add at least one garment';

  @override
  String get copyLastMeasurement => 'Copy last measurement';

  @override
  String get noPreviousMeasurement =>
      'No previous measurement saved for this garment';

  @override
  String get fabricColor => 'Fabric color';

  @override
  String get fabricPattern => 'Fabric pattern';

  @override
  String get accessories => 'Additional accessories';

  @override
  String get specialInstructions => 'Special design instructions';

  @override
  String get assignedTailor => 'Assigned tailor';

  @override
  String get statusHistory => 'Status history';

  @override
  String get orderItems => 'Garments in this order';

  @override
  String get editMeasurements => 'Edit measurements';

  @override
  String get filters => 'Filters';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get dateRange => 'Date range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get orderDate => 'Order date';

  @override
  String get exportExcel => 'Export filtered (Excel)';

  @override
  String get exportPdf => 'Export filtered (PDF)';

  @override
  String get printSheet => 'Print measurement sheet';

  @override
  String get noResults => 'No matching records';

  @override
  String get requiredFields => 'Please fill in phone number and name';

  @override
  String get enterValidPhone => 'Enter a valid phone number';

  @override
  String get measurementSnapshot => 'Measurements taken for this order';

  @override
  String get updated => 'Updated';

  @override
  String get sampleWears => 'Sample wears (fabric)';

  @override
  String get captureNewSample => 'New sample with camera';

  @override
  String get sampleName => 'Sample name';

  @override
  String get pickFabricSample => 'Pick a fabric sample';

  @override
  String get noSamples => 'No fabric samples yet. Capture one with the camera.';

  @override
  String get cameraError => 'Camera not available';

  @override
  String get totalPaid => 'Total paid';

  @override
  String get addStaff => 'Add staff member';

  @override
  String get staffName => 'Staff name';

  @override
  String get activeStaff => 'Active staff';

  @override
  String get noStaff => 'Add a staff member in Settings first';

  @override
  String savedPath(String path) {
    return 'Saved to:\n$path';
  }

  @override
  String exportDone(String path) {
    return 'Backup saved to:\n$path';
  }

  @override
  String get exportFailed => 'Could not create backup';
}
