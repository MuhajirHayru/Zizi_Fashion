// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'ዚዚ ፋሽን';

  @override
  String get tabHome => 'መነሻ';

  @override
  String get tabCustomers => 'ደንበኞች';

  @override
  String get tabOrders => 'ትእዛዞች';

  @override
  String get tabSettings => 'ቅንብሮች';

  @override
  String get openOrders => 'የክፍት ትእዛዞች';

  @override
  String get totalOwed => 'ጠቅላላ ቀሪ ክፍያ';

  @override
  String get currencyBirr => 'ብር';

  @override
  String get newCustomer => 'አዲስ ደንበኛ';

  @override
  String get newOrder => 'አዲስ ትእዛዝ';

  @override
  String get searchHint => 'በስም ወይም በስልክ ቁጥር ይፈልጉ';

  @override
  String get noCustomers => 'እስካሁን ደንበኞች የሉም። ለመጨመር + ይንኩ።';

  @override
  String get newCustomerTitle => 'አዲስ ደንበኛ';

  @override
  String get editCustomer => 'ደንበኛ ማስተካከል';

  @override
  String get fieldName => 'ሙሉ ስም';

  @override
  String get fieldPhone => 'ስልክ';

  @override
  String get fieldNotes => 'ማስታወሻ';

  @override
  String get fieldDate => 'ቀን';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get cancel => 'ተወው';

  @override
  String get delete => 'አጥፋ';

  @override
  String get edit => 'አስተካክል';

  @override
  String get areYouSure => 'እርግጠን ነዎት?';

  @override
  String get nameRequired => 'እባክዎ ስም ያስገቡ';

  @override
  String get deposit => 'ቅድመ ክፍያ';

  @override
  String get confirmDeleteCustomer =>
      'ይህ ደንበኛ ከሁሉም መጠኖችና ትእዛዞቹ ጋር ይጠፋል። ይቀጥላሉ?';

  @override
  String get confirmDeleteOrder => 'ይህ ትእዛዝ ከክፍያዎቹ ጋር ይጠፋል። ይቀጥላሉ?';

  @override
  String get measurements => 'መጠኖች';

  @override
  String get noMeasurements => 'እስካሁን መጠኖች አይታዩም';

  @override
  String get addMeasurement => 'መጠን መጨመር';

  @override
  String get editMeasurement => 'መጠን ማስተካከል';

  @override
  String get neck => 'አንገት';

  @override
  String get chest => 'ደረት';

  @override
  String get waist => 'ወገብ';

  @override
  String get hip => 'ሂፕ';

  @override
  String get shoulder => 'ትከሻ';

  @override
  String get sleeve => 'የእጅ ርዝመት';

  @override
  String get bicep => 'የእጅ ዙሪያ';

  @override
  String get wrist => 'የእጅ አንገት';

  @override
  String get thigh => 'የጉልበት ላይ ዙሪያ';

  @override
  String get knee => 'የጉልበት ዙሪያ';

  @override
  String get trouserLength => 'የሱሪ ርዝመት';

  @override
  String get bottomWidth => 'የሱሪ ግርጌ ስፋት';

  @override
  String get orders => 'ትእዛዞች';

  @override
  String get editOrder => 'ትእዛዝ ማስተካከል';

  @override
  String get noOrders => 'እስካሁን ትእዛዞች የሉም። ለመፍጠር + ይንኩ።';

  @override
  String get allStatuses => 'ሁሉም';

  @override
  String get selectCustomer => 'ደንበኛ';

  @override
  String get pickCustomer => 'ደንበኛ ይምረጡ';

  @override
  String get style => 'ሞዴል';

  @override
  String get styleOther => 'ሌላ';

  @override
  String get styleSuit => 'ሱት';

  @override
  String get styleShirt => 'ሸሚዝ';

  @override
  String get styleTrousers => 'ሱሪ';

  @override
  String get styleDress => 'ለሴቶች ልብስ';

  @override
  String get styleTraditional => 'ሐበሻ ልብስ';

  @override
  String get fabric => 'የጨርቅ ዓይነት';

  @override
  String get totalPrice => 'ጠቅላላ ዋጋ';

  @override
  String get depositOptional => 'ቅድመ ክፍያ (አማራጭ)';

  @override
  String get deliveryDate => 'የመድረሻ ቀን';

  @override
  String get dueThisWeek => 'በዚህ ሳምንት የሚደርሱ';

  @override
  String get status => 'ሁኔታ';

  @override
  String get statusPending => 'አልተጀምረም';

  @override
  String get statusFitting => 'ፊቲንግ';

  @override
  String get statusSewing => 'በስፌት ላይ';

  @override
  String get statusFinished => 'ተጠናቋል';

  @override
  String get statusCollected => 'ተሰብስቧል';

  @override
  String get unknownCustomer => 'ያልታወቀ ደንበኛ';

  @override
  String get overdue => 'የዘገየ';

  @override
  String advanceNext(String status) {
    return 'ቀጣይ፡ $status';
  }

  @override
  String get fullyPaid => 'ሙሉ በሙሉ ተከፍሏል';

  @override
  String get balance => 'ቀሪ ክፍያ';

  @override
  String get paid => 'የተከፈለ';

  @override
  String get amount => 'መጠን';

  @override
  String get payments => 'ክፍያዎች';

  @override
  String get noPayments => 'እስካሁን ክፍያ አልተደረገም';

  @override
  String get addPayment => 'ክፍያ መጨመር';

  @override
  String get editPayment => 'ክፍያ ማስተካከል';

  @override
  String get enterValidAmount => 'ትክክለኛ መጠን ያስገቡ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get developers => 'ገንቢዎች';

  @override
  String get dataStoredLocally =>
      'ሁሉም መረጃ በዚህ ስልክ ውስጥ ብቻ የተመዘገበ ነው። የበይነመረብ ግንኙነት አያስፈልገውም።';

  @override
  String get security => 'ደህንነት';

  @override
  String get appLock => 'የመተግበሪያ መቆልፊያ';

  @override
  String get appLockDesc => 'መተግበሪያውን ሲከፍቱ የተጠቃሚ ስምና የይለፍ ቃል ይጠየቃል።';

  @override
  String get createUsernamePassword => 'የተጠቃሚ ስምና የይለፍ ቃል መፍጠር';

  @override
  String get changeCredentials => 'የተጠቃሚ ስምና የይለፍ ቃል መቀየር';

  @override
  String get fieldUsername => 'የተጠቃሚ ስም';

  @override
  String get fieldPassword => 'የይለፍ ቃል';

  @override
  String get fieldConfirmPassword => 'የይለፍ ቃል አረጋግጥ';

  @override
  String get login => 'ግባ';

  @override
  String get loginTitle => 'ለመቀጠል ይግቡ';

  @override
  String get wrongCredentials => 'የተጠቃሚ ስም ወይም የይለፍ ቃል ተሳስቷል።';

  @override
  String get usernameTooShort => 'የተጠቃሚ ስም ቢሞላ 3 ፊደላት አለበት።';

  @override
  String get passwordTooShort => 'የይለፍ ቃል ቢሞላ 4 ፊደላት አለበት።';

  @override
  String get passwordsDoNotMatch => 'የይለፍ ቃሎቹ አይመሳሰሉም።';

  @override
  String get exportData => 'ቅጂ አውጣ';

  @override
  String get stepCustomer => 'ደንበኛ';

  @override
  String get stepGarments => 'አለባበስ';

  @override
  String get stepMeasurements => 'መጠኖች';

  @override
  String get stepDesign => 'ንድፍ';

  @override
  String get stepFabric => 'ጨርቅ';

  @override
  String get stepDelivery => 'የትእዛዝ መረጃ';

  @override
  String get stepReview => 'ማጣራት';

  @override
  String get designReference => 'የንድፍ ምሳሌ ምስሎች';

  @override
  String get openCamera => 'ካሜራ ክፈት';

  @override
  String get uploadImage => 'ምስል ጫን';

  @override
  String get imageDescription => 'መግለጫ';

  @override
  String get removeImage => 'ምስል አስወግድ';

  @override
  String get orderCreated => 'ትእዛዝ ተመዝግቧል';

  @override
  String get lining => 'ላይኒንግ';

  @override
  String get maleWear => 'የወንድ ልብሶች';

  @override
  String get femaleWear => 'የሴቶች ልብሶች';

  @override
  String get back => 'ተመለስ';

  @override
  String get next => 'ቀጣይ';

  @override
  String get viewMeasurements => 'መጠኖችን ተመልከት';

  @override
  String get orderSummary => 'የትእዛዝ ግምገማ';

  @override
  String get customerInfo => 'የደንበኛ መረጃ';

  @override
  String get statusTimeline => 'የትእዛዝ ሁኔታ ተከታታይ';

  @override
  String get updateStatus => 'ሁኔታ አዘምን';

  @override
  String get viewAll => 'ሁሉንም ይመልከት';

  @override
  String get statTotalOrders => 'ጠቅላላ ትእዛዞች';

  @override
  String get statCustomers => 'ደንበኞች';

  @override
  String get statCompleted => 'የተጠናቀቁ';

  @override
  String get tagline => 'የልብስ ስፌት አስተዳደር ስርዓት';

  @override
  String get thankYou => 'ዚዚ ፋሽንን ስለመረጡን እናመሰግናለን';

  @override
  String get goHome => 'ወደ መነሻ ተመለስ';

  @override
  String get orderSuccessTitle => 'ትእዛዝ በተሳካ ሁኔታ ተመዝግቧል!';

  @override
  String get recentOrders => 'የቅርብ ትእዛዞች';

  @override
  String get registered => 'የተመዘገበበት';

  @override
  String get fieldGender => 'ጾታ';

  @override
  String get fieldAltPhone => 'ተጨማሪ ስልክ (አማራጭ)';

  @override
  String get fieldAddress => 'አድራሻ';

  @override
  String get fieldRegion => 'ክልል';

  @override
  String get fieldCity => 'ከተማ';

  @override
  String get fieldSubCity => 'ክፍለ ከተማ / ወረዳ';

  @override
  String get fieldKebele => 'ቀበሌ / የተለየ ቦታ (አማራጭ)';

  @override
  String get fieldCustomerType => 'የደንበኛ ዓይነት';

  @override
  String get customerFound => 'ደንበኛ ተገኝቷል — ያለውን መገለጫ ልጠቀም?';

  @override
  String get useExistingProfile => 'ያለውን መገለጫ ተጠቀም';

  @override
  String get registerNew => 'እንደ አዲስ መዝግብ';

  @override
  String get searchPhoneHint => 'የደንበኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get autoInfo => 'በራስ-ሰር የተመዘገበ';

  @override
  String get regDate => 'የመዝገብ ቀን';

  @override
  String get regTime => 'የመዝገብ ሰዓት';

  @override
  String get customerId => 'የደንበኛ ቁጥር';

  @override
  String get orderId => 'የትእዛዝ ቁጥር';

  @override
  String get staff => 'ሠራተኛ';

  @override
  String get addGarment => 'ልብስ መጨመር';

  @override
  String get completeOutfit => 'ሙሉ የምረቃ ልብስ';

  @override
  String get quantity => 'ብዛት';

  @override
  String get garment => 'ልብስ';

  @override
  String get noGarments => 'ቢሆንም አንድ ልብስ ይጨምሩ';

  @override
  String get copyLastMeasurement => 'የመጨረሻውን መጠን ቅዳ';

  @override
  String get noPreviousMeasurement => 'ለዚህ ልብስ ያለፈ መጠን አልተመዘገበም';

  @override
  String get fabricColor => 'የጨርቅ ቀለም';

  @override
  String get fabricPattern => 'የጨርቅ ቅርጸት';

  @override
  String get accessories => 'ተጨማሪ አክሰሰሪዎች';

  @override
  String get specialInstructions => 'ልዩ የንድፍ መመሪያ';

  @override
  String get assignedTailor => 'የተመደበ ስፌት ሠራተኛ';

  @override
  String get statusHistory => 'የሁኔታ ታሪክ';

  @override
  String get orderItems => 'በዚህ ትእዛዝ ውስጥ ያሉ ልብሶች';

  @override
  String get editMeasurements => 'መጠኖችን አስተካክል';

  @override
  String get filters => 'ማጣሪያዎች';

  @override
  String get apply => 'ተግብር';

  @override
  String get clear => 'አጽዳ';

  @override
  String get sortNewest => 'አዲስ በፊት';

  @override
  String get sortOldest => 'የድሮ በፊት';

  @override
  String get dateRange => 'የቀን ክልል';

  @override
  String get from => 'ከ';

  @override
  String get to => 'እስከ';

  @override
  String get orderDate => 'የትእዛዝ ቀን';

  @override
  String get exportExcel => 'የተፈለገውን ወደ Excel አውጣ';

  @override
  String get exportPdf => 'የተፈለገውን ወደ PDF አውጣ';

  @override
  String get printSheet => 'የመጠን ማስታወሻ አትም';

  @override
  String get noResults => 'ተመሳሳይ መዝገብ አልተገኘም';

  @override
  String get requiredFields => 'እባክዎ ስልክ ቁጥርና ስም ያስገቡ';

  @override
  String get enterValidPhone => 'ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get measurementSnapshot => 'ለዚህ ትእዛዝ የተወሰዱ መጠኖች';

  @override
  String get updated => 'ተቀይሷል';

  @override
  String get sampleWears => 'የናሙና ልብሶች (ጨርቅ)';

  @override
  String get captureNewSample => 'በካሜራ አዲስ ናሙና';

  @override
  String get sampleName => 'የናሙና ስም';

  @override
  String get pickFabricSample => 'የጨርቅ ናሙና ይምረጡ';

  @override
  String get noSamples => 'እስካሁን የጨርቅ ናሙና የለም። በካሜራ ያዙ።';

  @override
  String get cameraError => 'ካሜራ አልተገኘም';

  @override
  String get totalPaid => 'ጠቅላላ የተከፈለ';

  @override
  String get addStaff => 'ሠራተኛ መጨመር';

  @override
  String get staffName => 'የሠራተኛ ስም';

  @override
  String get activeStaff => 'ንቁ ሠራተኛ';

  @override
  String get noStaff => 'መጀመሪያ በቅንብሮች ውስጥ ሠራተኛ ያክሉ';

  @override
  String savedPath(String path) {
    return 'ተቀምጧል፡\n$path';
  }

  @override
  String exportDone(String path) {
    return 'ቅጂ ተቀምጧል፡\n$path';
  }

  @override
  String get exportFailed => 'ቅጂ ማውጣት አልተሳካም';
}
