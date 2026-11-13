/// Registry of garment categories and their measurement / style fields.
///
/// Each graduation garment has its own relevant fields (no generic form):
/// numeric fields are centimetres, choice fields are dropdowns, and every
/// label exists in English and Amharic. Values are stored as a JSON map
/// per order item (measurement snapshot) and per saved measurement record.
library;

enum FieldType { number, text, choice }

class FieldOption {
  const FieldOption(this.value, this.en, this.am);
  final String value;
  final String en;
  final String am;
}

class GarmentField {
  const GarmentField(this.key, this.en, this.am, this.type,
      [this.options = const []]);
  final String key;
  final String en;
  final String am;
  final FieldType type;
  final List<FieldOption> options;

  String label(bool isAm) => isAm ? am : en;
}

class GarmentDef {
  const GarmentDef(this.key, this.en, this.am, this.measurements,
      [this.styles = const []]);
  final String key;
  final String en;
  final String am;
  final List<GarmentField> measurements;
  final List<GarmentField> styles;

  String label(bool isAm) => isAm ? am : en;
}

GarmentField _n(String key, String en, String am) =>
    GarmentField(key, en, am, FieldType.number);

GarmentField _c(String key, String en, String am, List<FieldOption> options) =>
    GarmentField(key, en, am, FieldType.choice, options);

final _fitting = GarmentField('fitting', 'Fitting preference',
    'የፊቲንግ ምርጫ', FieldType.choice, [
  FieldOption('slim', 'Slim', 'ጥብቅ'),
  FieldOption('regular', 'Regular', 'መደበኛ'),
  FieldOption('loose', 'Loose', 'ሰፊ'),
]);

final _collarType = _c('collar_type', 'Collar type', 'የኮሌር ዓይነት', [
  FieldOption('classic', 'Classic', 'ክላሲክ'),
  FieldOption('spread', 'Spread', 'ስፕሬድ'),
  FieldOption('button_down', 'Button-down', 'ቡተን-ዳውን'),
  FieldOption('mandarin', 'Mandarin', 'ማንዳሪን'),
]);

final _buttonCount = _c('button_config', 'Buttons', 'የአዝራር ብዛት', [
  FieldOption('1', '1 button', '1 አዝራር'),
  FieldOption('2', '2 buttons', '2 አዝራር'),
  FieldOption('3', '3 buttons', '3 አዝራር'),
]);

final gradShirt = GarmentDef('grad_shirt', 'Graduation shirt', 'የምረቃ ሸሚዝ', [
  _n('shirt_length', 'Shirt length', 'የሸሚዝ ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('neck', 'Neck', 'አንገት'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('short_sleeve_length', 'Short sleeve length', 'አጫጭር የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('elbow', 'Elbow', 'የጭንብ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('front_length', 'Front length', 'የፊት ርዝመት'),
  _n('back_length', 'Back length', 'የኋላ ርዝመት'),
  _n('bottom_width', 'Shirt bottom width', 'ግርጌ ስፋት'),
  _n('cuff_width', 'Cuff width', 'ካፍ ስፋት'),
], [
  _c('shirt_style', 'Shirt style', 'የሸሚዝ ቅርጽ', [
    FieldOption('plain', 'Plain', 'ቀላል'),
    FieldOption('formal', 'Formal', 'መደበኛ'),
    FieldOption('tailored', 'Tailored fit', 'ተስተካክሎ የተሰፍረ'),
  ]),
  _collarType,
  _c('sleeve_type', 'Sleeve type', 'የእጅ ዓይነት', [
    FieldOption('long', 'Long sleeve', 'ረዥም እጅ'),
    FieldOption('short', 'Short sleeve', 'አጫጭር እጅ'),
  ]),
  _c('button_style', 'Button style', 'የአዝራር ቅርጽ', [
    FieldOption('plain', 'Plain', 'ቀላል'),
    FieldOption('hidden', 'Hidden placket', 'የተሰወረ'),
    FieldOption('decorative', 'Decorative', 'የተለያየ ጌጣጌጥ'),
  ]),
  _fitting,
]);

final gradTrouser = GarmentDef('grad_trouser', 'Graduation trouser', 'የምረቃ ሱሪ', [
  _n('trouser_length', 'Trouser length', 'የሱሪ ርዝመት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('thigh', 'Thigh', 'የጉልበት ላይ ዙሪያ'),
  _n('knee', 'Knee', 'የጉልበት ዙሪያ'),
  _n('bottom', 'Bottom / leg opening', 'ግርጌ ስፋት'),
  _n('crotch_depth', 'Crotch depth', 'የክሮች ጥልቀት'),
  _n('front_rise', 'Front rise', 'ፊት ራይዝ'),
  _n('back_rise', 'Back rise', 'ኋላ ራይዝ'),
  _n('inseam', 'Inseam', 'የውስጥ ርዝመት'),
  _n('outseam', 'Outseam', 'የውጭ ርዝመት'),
  _n('calf', 'Calf', 'የበስር ዙሪያ'),
  _n('seat', 'Seat', 'የመቀመጫ ዙሪያ'),
], [
  _c('trouser_style', 'Trouser style', 'የሱሪ ቅርጽ', [
    FieldOption('classic', 'Classic', 'ክላሲክ'),
    FieldOption('slim', 'Slim', 'ጥብቅ'),
    FieldOption('tapered', 'Tapered', 'ወደ ታች ያጠራ'),
  ]),
  _c('waist_style', 'Waist style', 'የወገብ ዓይነት', [
    FieldOption('plain', 'Plain', 'ቀላል'),
    FieldOption('belt', 'Belt loops', 'የጫማ ቀለበት'),
    FieldOption('pleated', 'Pleated', 'ብልብልጅ'),
    FieldOption('elastic', 'Elastic', 'ላስቲክ'),
  ]),
  _c('pocket_style', 'Pocket style', 'የኪስ ዓይነት', [
    FieldOption('side', 'Side pockets', 'የጎን ኪስ'),
    FieldOption('back', 'Back pockets', 'የኋላ ኪስ'),
    FieldOption('both', 'Side + back', 'ጎንና ኋላ'),
  ]),
  _fitting,
]);

final gradJacket = GarmentDef('grad_jacket', 'Graduation jacket', 'የምረቃ ጃኬት', [
  _n('jacket_length', 'Jacket length', 'የጃኬት ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('sleeve', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('neck', 'Neck', 'አንገት'),
  _n('back_width', 'Back width', 'የኋላ ስፋት'),
  _n('front_width', 'Front width', 'የፊት ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
], [
  _c('jacket_style', 'Jacket style', 'የጃኬት ቅርጽ', [
    FieldOption('single', 'Single breasted', 'ነጠላ ደረት'),
    FieldOption('double', 'Double breasted', 'ጥምር ደረት'),
  ]),
  _c('lapel', 'Lapel style', 'የላፔል ዓይነት', [
    FieldOption('notch', 'Notch lapel', 'ኖች'),
    FieldOption('peak', 'Peak lapel', 'ፒክ'),
    FieldOption('shawl', 'Shawl collar', 'ሻውል'),
  ]),
  _buttonCount,
  _fitting,
]);

final gradWaistcoat = GarmentDef(
    'grad_waistcoat', 'Graduation waistcoat', 'የምረቃ ዌዝኮት', [
  _n('waistcoat_length', 'Waistcoat length', 'የዌዝኮት ርዝመት'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('back_width', 'Back width', 'የኋላ ስፋት'),
  _n('front_width', 'Front width', 'የፊት ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('neck', 'Neck', 'አንገት'),
], [
  _c('waistcoat_style', 'Waistcoat style', 'የዌዝኮት ቅርጽ', [
    FieldOption('classic', 'Classic', 'ክላሲክ'),
    FieldOption('v_neck', 'V-neck', 'ቪ-አንገት'),
  ]),
  _buttonCount,
  _fitting,
]);

final gradGown = GarmentDef('grad_gown', 'Graduation gown / robe', 'የምረቃ ጎን', [
  _n('gown_length', 'Gown length', 'የጎን ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('sleeve', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('sleeve_opening', 'Sleeve opening', 'የእጅ መክፈቻ ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('neck_opening', 'Neck opening', 'የአንገት መክፈቻ'),
  _n('gown_width', 'Gown width', 'የጎን ስፋት'),
  _n('head', 'Head (cap size)', 'የራስ ዙሪያ'),
], [
  _c('gown_style', 'Gown style', 'የጎን ቅርጽ', [
    FieldOption('classic', 'Classic', 'ክላሲክ'),
    FieldOption('open_front', 'Open front', 'የተከፈተ ፊት'),
  ]),
  _c('with_cap', 'Cap', 'ካፕ', [
    FieldOption('yes', 'With cap', 'ከካፕ ጋር'),
    FieldOption('no', 'Without cap', 'ያለ ካፕ'),
  ]),
]);

// ----- Suit garments (the shop's primary work) -----
// Suit garments reuse the same measurement fields as graduation wear,
// under their own keys so saved measurement history stays separate.

final suitJacket = GarmentDef(
    'suit_jacket', 'Suit jacket', 'የሱት ጃኬት',
    gradJacket.measurements, gradJacket.styles);

final suitTrouser = GarmentDef(
    'suit_trouser', 'Suit trouser', 'የሱት ሱሪ',
    gradTrouser.measurements, gradTrouser.styles);

final suitShirt = GarmentDef(
    'suit_shirt', 'Suit shirt', 'የሱት ሸሚዝ',
    gradShirt.measurements, gradShirt.styles);

final suitWaistcoat = GarmentDef(
    'suit_waistcoat', 'Suit waistcoat', 'የሱት ዌዝኮት',
    gradWaistcoat.measurements, gradWaistcoat.styles);

/// A clothing category the shop works on (Suits is the primary one).
class ClothingCategory {
  const ClothingCategory(this.key, this.en, this.am, this.garments);
  final String key;
  final String en;
  final String am;
  final List<GarmentDef> garments;

  String label(bool isAm) => isAm ? am : en;
}

final suitsCategory = ClothingCategory(
    'suits', 'Suits', 'ሱቶች',
    [suitJacket, suitTrouser, suitShirt, suitWaistcoat]);

final graduationCategory = ClothingCategory(
    'graduation_men', 'Male graduation wear', 'የወንድ ምረቃ ልብስ',
    [gradShirt, gradTrouser, gradJacket, gradWaistcoat, gradGown]);

/// Order of this list = order shown in the app (suits first, primary).
final List<ClothingCategory> clothingCategories = [
  suitsCategory,
  graduationCategory,
];

/// Every garment across all categories (for filters and lookups).
final List<GarmentDef> allGarments = [
  for (final category in clothingCategories) ...category.garments,
];

GarmentDef? garmentByKey(String key) {
  for (final g in allGarments) {
    if (g.key == key) return g;
  }
  return null;
}

ClothingCategory? categoryByKey(String key) {
  for (final c in clothingCategories) {
    if (c.key == key) return c;
  }
  return null;
}

/// Label for an order's category value ('suits', 'graduation_men',
/// or legacy 'general' rows whose garment type lives in [styleKey]).
String categoryValueLabel(String? category, bool isAm, {String styleKey = ''}) {
  final cat = categoryByKey(category ?? '');
  if (cat != null) return cat.label(isAm);
  if (category == 'graduation_men') {
    return isAm ? 'የወንድ ምረቃ ልብስ' : 'Male graduation wear';
  }
  return switch (styleKey) {
    'suit' => isAm ? 'ሱት' : 'Suit',
    'shirt' => isAm ? 'ሸሚዝ' : 'Shirt',
    'trousers' => isAm ? 'ሱሪ' : 'Trousers',
    'dress' => isAm ? 'ለሴቶች ልብስ' : 'Dress',
    'traditional' => isAm ? 'ሐበሻ ልብስ' : 'Traditional',
    _ => isAm ? 'ሌላ' : 'Other',
  };
}

/// Ethiopian regions for the customer address dropdown.
const List<FieldOption> ethiopianRegions = [
  FieldOption('addis_ababa', 'Addis Ababa', 'አዲስ አበባ'),
  FieldOption('afar', 'Afar', 'አፋር'),
  FieldOption('amhara', 'Amhara', 'አማራ'),
  FieldOption('benishangul', 'Benishangul-Gumuz', 'ቤንሻንጉል-ጉምዝ'),
  FieldOption('dire_dawa', 'Dire Dawa', 'ድሬዳዋ'),
  FieldOption('gambela', 'Gambela', 'ጋምቤላ'),
  FieldOption('harari', 'Harari', 'ሐረሪ'),
  FieldOption('oromia', 'Oromia', 'ኦሮሚያ'),
  FieldOption('somali', 'Somali', 'ሶማሌ'),
  FieldOption('sidama', 'Sidama', 'ሲዳማ'),
  FieldOption('south_west', 'South West Ethiopia', 'ደቡብ ምዕራብ ኢትዮጵያ'),
  FieldOption('snnpr', 'SNNPR', 'ደቡብ ኢትዮጵያ'),
  FieldOption('tigray', 'Tigray', 'ትግራይ'),
];

String regionLabel(String? value, bool isAm) {
  for (final r in ethiopianRegions) {
    if (r.value == value) return isAm ? r.am : r.en;
  }
  return value ?? '';
}

const List<FieldOption> genderOptions = [
  FieldOption('male', 'Male', 'ወንድ'),
  FieldOption('female', 'Female', 'ሴት'),
];

const List<FieldOption> customerTypeOptions = [
  FieldOption('new', 'New customer', 'አዲስ ደንበኛ'),
  FieldOption('returning', 'Returning customer', 'የድሮ ደንበኛ'),
];

String optionLabel(List<FieldOption> options, String? value, bool isAm) {
  for (final o in options) {
    if (o.value == value) return isAm ? o.am : o.en;
  }
  return value ?? '';
}
