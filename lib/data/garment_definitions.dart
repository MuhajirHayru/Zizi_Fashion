/// ZIZI FASHION clothing taxonomy + measurement registry.
///
/// Structure: wear group (male/female) -> clothing category -> garment.
/// Every garment references a measurement field set (centimetres) and its
/// own design/style options. Bundles (e.g. three-piece suit) expand into
/// several garments in one tap. All labels are English + Amharic.
library;

enum FieldType { number, text, choice }

enum WearGroup { male, female }

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
  const GarmentDef(
      this.key, this.en, this.am, this.designGroup, this.measurements,
      [this.styles = const [], this.bundleKeys = const []]);
  final String key;
  final String en;
  final String am;

  /// Design-reference image group (shirt/jacket/dress/...).
  final String designGroup;
  final List<GarmentField> measurements;
  final List<GarmentField> styles;

  /// When non-empty, selecting this garment expands into these garment
  /// keys (three-piece suit, trouser suit, graduation suit, ...).
  final List<String> bundleKeys;

  String label(bool isAm) => isAm ? am : en;
  bool get isBundle => bundleKeys.isNotEmpty;
}

class ClothingCategory {
  const ClothingCategory(
      this.key, this.en, this.am, this.wearGroup, this.garments);
  final String key;
  final String en;
  final String am;
  final WearGroup wearGroup;
  final List<GarmentDef> garments;

  String label(bool isAm) => isAm ? am : en;
}

GarmentField _n(String key, String en, String am) =>
    GarmentField(key, en, am, FieldType.number);

GarmentField _c(String key, String en, String am, List<FieldOption> options) =>
    GarmentField(key, en, am, FieldType.choice, options);

// ---------------------------------------------------------------------------
// Measurement field sets
// ---------------------------------------------------------------------------

/// Male shirt (14 fields).
final setShirtMen = [
  _n('shirt_length', 'Shirt length', 'የሸሚዝ ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('neck', 'Neck', 'አንገት'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('elbow', 'Elbow', 'የጭንብ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('cuff', 'Cuff', 'ካፍ'),
  _n('front_length', 'Front length', 'የፊት ርዝመት'),
  _n('back_length', 'Back length', 'የኋላ ርዝመት'),
];

/// Graduation shirt adds short sleeve + bottom width.
final setShirtGraduation = [
  ...setShirtMen,
  _n('short_sleeve_length', 'Short sleeve length', 'አጫጭር የእጅ ርዝመት'),
  _n('bottom_width', 'Shirt bottom width', 'ግርጌ ስፋት'),
];

/// Male jacket (12 fields).
final setJacketMen = [
  _n('jacket_length', 'Jacket length', 'የጃኬት ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('back_width', 'Back width', 'የኋላ ስፋት'),
  _n('front_width', 'Front width', 'የፊት ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('neck', 'Neck', 'አንገት'),
];

/// Male trousers (12 fields).
final setTrouserMen = [
  _n('trouser_length', 'Trouser length', 'የሱሪ ርዝመት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('thigh', 'Thigh', 'የጉልበት ላይ ዙሪያ'),
  _n('knee', 'Knee', 'የጉልበት ዙሪያ'),
  _n('bottom', 'Bottom opening', 'ግርጌ ስፋት'),
  _n('crotch_depth', 'Crotch depth', 'የክሮች ጥልቀት'),
  _n('front_rise', 'Front rise', 'ፊት ራይዝ'),
  _n('back_rise', 'Back rise', 'ኋላ ራይዝ'),
  _n('inseam', 'Inseam', 'የውስጥ ርዝመት'),
  _n('outseam', 'Outseam', 'የውጭ ርዝመት'),
  _n('calf', 'Calf', 'የበስር ዙሪያ'),
];

/// Waistcoat (8 fields).
final setWaistcoat = [
  _n('waistcoat_length', 'Waistcoat length', 'የዌዝኮት ርዝመት'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('back_width', 'Back width', 'የኋላ ስፋት'),
  _n('front_width', 'Front width', 'የፊት ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('neck', 'Neck', 'አንገት'),
];

/// Graduation gown / robe (9 fields).
final setGown = [
  _n('gown_length', 'Overall gown length', 'የጎን ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('sleeve_opening', 'Sleeve opening', 'የእጅ መክፈቻ ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('neck_opening', 'Neck opening', 'የአንገት መክፈቻ'),
  _n('gown_width', 'Gown width', 'የጎን ስፋት'),
  _n('head', 'Head (graduation cap)', 'የራስ ዙሪያ'),
];

/// Generic set for traditional / custom designs (12 fields).
final setGeneral = [
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('chest', 'Chest', 'ደረት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('neck', 'Neck', 'አንገት'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('bicep', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('thigh', 'Thigh', 'የጉልበት ላይ ዙሪያ'),
  _n('knee', 'Knee', 'የጉልበት ዙሪያ'),
  _n('trouser_length', 'Trouser length', 'የሱሪ ርዝመት'),
  _n('bottom_width', 'Bottom width', 'ግርጌ ስፋት'),
];

/// Women's dress (19 fields).
final setDressWomen = [
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('bust', 'Bust', 'ጡት'),
  _n('under_bust', 'Under bust', 'ከጡት በታች'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('neck', 'Neck', 'አንገት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('elbow', 'Elbow', 'የጭንብ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('front_length', 'Front length', 'የፊት ርዝመት'),
  _n('back_length', 'Back length', 'የኋላ ርዝመት'),
  _n('bust_height', 'Bust height', 'የጡት ከፍታ'),
  _n('bust_separation', 'Bust separation', 'የጡቶች መካከል'),
  _n('shoulder_to_waist', 'Shoulder to waist', 'ከትከሻ ወደ ወገብ'),
  _n('waist_to_hip', 'Waist to hip', 'ከወገብ ወደ ሂፕ'),
  _n('skirt_length', 'Skirt length', 'የስንጥ ርዝመት'),
  _n('dress_length', 'Full dress length', 'የቀሚስ ርዝመት'),
];

/// Women's blazer (11 fields).
final setBlazerWomen = [
  _n('blazer_length', 'Blazer length', 'የብላዘር ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('bust', 'Bust', 'ጡት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('back_width', 'Back width', 'የኋላ ስፋት'),
  _n('front_width', 'Front width', 'የፊት ስፋት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
];

/// Women's trousers (9 fields).
final setTrouserWomen = [
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('thigh', 'Thigh', 'የጉልበት ላይ ዙሪያ'),
  _n('knee', 'Knee', 'የጉልበት ዙሪያ'),
  _n('trouser_length', 'Trouser length', 'የሱሪ ርዝመት'),
  _n('inseam', 'Inseam', 'የውስጥ ርዝመት'),
  _n('outseam', 'Outseam', 'የውጭ ርዝመት'),
  _n('crotch_depth', 'Crotch depth', 'የክሮች ጥልቀት'),
  _n('bottom', 'Bottom opening', 'ግርጌ ስፋት'),
];

/// Women's skirt (5 fields).
final setSkirtWomen = [
  _n('waist', 'Waist', 'ወገብ'),
  _n('hip', 'Hip', 'ሂፕ'),
  _n('skirt_length', 'Skirt length', 'የስንጥ ርዝመት'),
  _n('waist_to_hip', 'Waist to hip', 'ከወገብ ወደ ሂፕ'),
  _n('bottom', 'Bottom width', 'ግርጌ ስፋት'),
];

/// Women's blouse (9 fields).
final setBlouseWomen = [
  _n('blouse_length', 'Blouse length', 'የብላውዝ ርዝመት'),
  _n('shoulder', 'Shoulder width', 'ትከሻ'),
  _n('bust', 'Bust', 'ጡት'),
  _n('waist', 'Waist', 'ወገብ'),
  _n('neck', 'Neck', 'አንገት'),
  _n('sleeve_length', 'Sleeve length', 'የእጅ ርዝመት'),
  _n('upper_arm', 'Upper arm', 'የእጅ ዙሪያ'),
  _n('wrist', 'Wrist', 'የእጅ አንገት'),
  _n('armhole', 'Armhole', 'የእጅ ቀዳድ ዙሪያ'),
];

// ---------------------------------------------------------------------------
// Style option sets
// ---------------------------------------------------------------------------

final _fitting = _c('fitting', 'Fitting preference', 'የፊቲንግ ምርጫ', [
  FieldOption('slim', 'Slim', 'ጥብቅ'),
  FieldOption('regular', 'Regular', 'መደበኛ'),
  FieldOption('loose', 'Loose', 'ሰፊ'),
]);

final _collarType = _c('collar_type', 'Collar style', 'የኮሌር ዓይነት', [
  FieldOption('classic', 'Classic', 'ክላሲክ'),
  FieldOption('spread', 'Spread', 'ስፕሬድ'),
  FieldOption('button_down', 'Button-down', 'ቡተን-ዳውን'),
  FieldOption('mandarin', 'Mandarin', 'ማንዳሪን'),
]);

final _sleeveType = _c('sleeve_type', 'Sleeve style', 'የእጅ ዓይነት', [
  FieldOption('long', 'Long sleeve', 'ረዥም እጅ'),
  FieldOption('short', 'Short sleeve', 'አጫጭር እጅ'),
]);

final _buttonStyle = _c('button_style', 'Button style', 'የአዝራር ቅርጽ', [
  FieldOption('plain', 'Plain', 'ቀላል'),
  FieldOption('hidden', 'Hidden placket', 'የተሰወረ'),
  FieldOption('decorative', 'Decorative', 'ጌጣጌጥ ያለው'),
]);

final _buttonCount = _c('button_config', 'Buttons', 'የአዝራር ብዛት', [
  FieldOption('1', '1 button', '1 አዝራር'),
  FieldOption('2', '2 buttons', '2 አዝራር'),
  FieldOption('3', '3 buttons', '3 አዝራር'),
]);

final _jacketStyles = [
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
];

final _trouserStyles = [
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
];

final _shirtStyles = [_collarType, _sleeveType, _buttonStyle, _fitting];

final _waistcoatStyles = [
  _c('waistcoat_style', 'Waistcoat style', 'የዌዝኮት ቅርጽ', [
    FieldOption('classic', 'Classic', 'ክላሲክ'),
    FieldOption('v_neck', 'V-neck', 'ቪ-አንገት'),
  ]),
  _buttonCount,
  _fitting,
];

final _gownStyles = [
  _c('gown_style', 'Gown style', 'የጎን ቅርጽ', [
    FieldOption('classic', 'Classic', 'ክላሲክ'),
    FieldOption('open_front', 'Open front', 'የተከፈተ ፊት'),
  ]),
  _c('with_cap', 'Graduation cap', 'ካፕ', [
    FieldOption('yes', 'With cap', 'ከካፕ ጋር'),
    FieldOption('no', 'Without cap', 'ያለ ካፕ'),
  ]),
];

// Women's design options.
final _neckline = _c('neckline', 'Neckline', 'የአንገት ቅርጽ', [
  FieldOption('round', 'Round', 'ሮብ'),
  FieldOption('v_neck', 'V-neck', 'ቪ-አንገት'),
  FieldOption('square', 'Square', 'ካሬ'),
  FieldOption('sweetheart', 'Sweetheart', 'ስዊትሀርት'),
  FieldOption('boat', 'Boat neck', 'ቦት አንገት'),
]);

final _sleeveWomen = _c('sleeve_style', 'Sleeve style', 'የእጅ ዓይነት', [
  FieldOption('sleeveless', 'Sleeveless', 'ያለ እጅ'),
  FieldOption('short', 'Short', 'አጫጭር'),
  FieldOption('three_quarter', 'Three quarter', 'ሶስት ሩብ'),
  FieldOption('long', 'Long', 'ረዥም'),
  FieldOption('puff', 'Puff', 'ፖፍ'),
]);

final _dressShape = _c('dress_shape', 'Dress shape', 'የቀሚስ ቅርጽ', [
  FieldOption('bodycon', 'Bodycon', 'ቦዲኮን'),
  FieldOption('a_line', 'A-line', 'ኤ-ላይን'),
  FieldOption('fitted', 'Fitted', 'የተጣጠፈ'),
  FieldOption('flared', 'Flared', 'የተከፈተ'),
  FieldOption('mermaid', 'Mermaid', 'ሜርመይድ'),
]);

final _waistDesign = _c('waist_design', 'Waist design', 'የወገብ ንድፍ', [
  FieldOption('fitted', 'Fitted', 'የተጣጠፈ'),
  FieldOption('elastic', 'Elastic', 'ላስቲክ'),
  FieldOption('belt', 'Belt', 'ጫማ ቀለበት'),
  FieldOption('empire', 'Empire', 'ኢምፓየር'),
]);

final _backDesign = _c('back_design', 'Back design', 'የኋላ ንድፍ', [
  FieldOption('closed', 'Closed', 'የተዘጋ'),
  FieldOption('open', 'Open', 'የከፈተ'),
  FieldOption('zip', 'Zipper', 'ዚፕ'),
  FieldOption('corset', 'Corset', 'ኮርሴት'),
]);

final _skirtDesign = _c('skirt_design', 'Skirt design', 'የስንጥ ንድፍ', [
  FieldOption('straight', 'Straight', 'ቀጥተኛ'),
  FieldOption('pleated', 'Pleated', 'ብልብልጅ'),
  FieldOption('flared', 'Flared', 'የተከፈተ'),
  FieldOption('slit', 'Slit', 'የተከፈተ ጎን'),
]);

final _lengthType = _c('length', 'Length', 'ርዝመት', [
  FieldOption('mini', 'Mini', 'ሚኒ'),
  FieldOption('knee', 'Knee', 'ጉልበት'),
  FieldOption('midi', 'Midi', 'ሚዲ'),
  FieldOption('maxi', 'Maxi', 'ማክሲ'),
  FieldOption('floor', 'Floor length', 'እስከ መሬት'),
]);

final _decoration = _c('decoration', 'Decoration', 'ጌጣጌጥ', [
  FieldOption('none', 'None', 'የለም'),
  FieldOption('lace', 'Lace', 'ሌስ'),
  FieldOption('beads', 'Beads', 'ማርጤስ'),
  FieldOption('ribbon', 'Ribbon', 'ሪቦን'),
]);

final _embroidery = _c('embroidery', 'Embroidery', 'ስፌት ጌጥ', [
  FieldOption('none', 'None', 'የለም'),
  FieldOption('simple', 'Simple', 'ቀላል'),
  FieldOption('heavy', 'Heavy', 'ከባድ'),
  FieldOption('tibeb', 'Tibeb', 'ጥበብ'),
]);

final _womenCommonStyles = [
  _neckline,
  _sleeveWomen,
  _waistDesign,
  _lengthType,
  _decoration,
  _embroidery,
  _fitting,
];

final _dressStyles = [
  _neckline,
  _sleeveWomen,
  _dressShape,
  _waistDesign,
  _backDesign,
  _skirtDesign,
  _lengthType,
  _decoration,
  _embroidery,
  _fitting,
];

final _blazerStylesWomen = [
  _c('blazer_style', 'Blazer style', 'የብላዘር ቅርጽ', [
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
];

final _skirtStyles = [
  _skirtDesign,
  _lengthType,
  _fitting,
];

// ---------------------------------------------------------------------------
// Garments
// ---------------------------------------------------------------------------

final _gSuitJacket =
    GarmentDef('suit_jacket', 'Suit jacket', 'የሱት ጃኬት', 'jacket',
        setJacketMen, _jacketStyles);
final _gSuitTrouser =
    GarmentDef('suit_trousers', 'Suit trousers', 'የሱት ሱሪ', 'trouser',
        setTrouserMen, _trouserStyles);
final _gThreePieceSuit = GarmentDef(
    'three_piece_suit', 'Three-piece suit', 'ሶስት ቁራጭ ሱት', 'suit',
    [], [], ['suit_jacket', 'suit_waistcoat', 'suit_trousers']);
final _gMensFormalShirt =
    GarmentDef('mens_formal_shirt', 'Formal shirt', 'መደበኛ ሸሚዝ', 'shirt',
        setShirtMen, _shirtStyles);
final _gMensWaistcoat =
    GarmentDef('mens_waistcoat', 'Waistcoat', 'ዌዝኮት', 'waistcoat',
        setWaistcoat, _waistcoatStyles);

final _gGradSuit = GarmentDef(
    'grad_suit', 'Graduation suit', 'የምረቃ ሱት', 'suit',
    [], [], ['grad_jacket', 'grad_trousers']);
final _gGradShirt =
    GarmentDef('grad_shirt', 'Graduation shirt', 'የምረቃ ሸሚዝ', 'shirt',
        setShirtGraduation, _shirtStyles);
final _gGradTrouser =
    GarmentDef('grad_trousers', 'Graduation trousers', 'የምረቃ ሱሪ', 'trouser',
        setTrouserMen, _trouserStyles);
final _gGradJacket =
    GarmentDef('grad_jacket', 'Graduation jacket', 'የምረቃ ጃኬት', 'jacket',
        setJacketMen, _jacketStyles);
final _gGradWaistcoat =
    GarmentDef('grad_waistcoat', 'Graduation waistcoat', 'የምረቃ ዌዝኮት',
        'waistcoat', setWaistcoat, _waistcoatStyles);
final _gGradGown =
    GarmentDef('grad_gown', 'Graduation gown / robe', 'የምረቃ ጎን', 'gown',
        setGown, _gownStyles);

final _gCasualShirt =
    GarmentDef('casual_shirt', 'Casual shirt', 'ቀላል ሸሚዝ', 'shirt',
        setShirtMen, _shirtStyles);
final _gFormalShirt =
    GarmentDef('formal_shirt', 'Formal shirt', 'መደበኛ ሸሚዝ', 'shirt',
        setShirtMen, _shirtStyles);
final _gTraditionalMen =
    GarmentDef('traditional_men', 'Traditional wear', 'ሐበሻ ልብስ',
        'traditional', setGeneral, [_fitting]);
final _gCasualTrouser =
    GarmentDef('casual_trousers', 'Casual trousers', 'ቀላል ሱሪ', 'trouser',
        setTrouserMen, _trouserStyles);
final _gFormalTrouser =
    GarmentDef('formal_trousers', 'Formal trousers', 'መደበኛ ሱሪ', 'trouser',
        setTrouserMen, _trouserStyles);
final _gCustomMen =
    GarmentDef('custom_men', 'Other custom design', 'ሌላ ብጁ ንድፍ', 'other',
        setGeneral, [_fitting]);

final _gTrouserSuit = GarmentDef(
    'trouser_suit', 'Trouser suit', 'የሱሪ ሱት', 'suit',
    [], [], ['womens_blazer', 'womens_trousers']);
final _gSkirtSuit = GarmentDef(
    'skirt_suit', 'Skirt suit', 'የስንጥ ሱት', 'suit',
    [], [], ['womens_blazer', 'womens_skirt']);
final _gThreePieceWomen = GarmentDef(
    'three_piece_women', 'Three-piece suit', 'ሶስት ቁራጭ ሱት', 'suit',
    [], [], ['womens_blazer', 'womens_waistcoat', 'womens_trousers']);
final _gWomensBlazer =
    GarmentDef('womens_blazer', "Women's blazer", 'የሴቶች ብላዘር', 'blazer',
        setBlazerWomen, _blazerStylesWomen);
final _gWomensWaistcoat =
    GarmentDef('womens_waistcoat', "Women's waistcoat", 'የሴቶች ዌዝኮት',
        'waistcoat', setWaistcoat, _waistcoatStyles);

GarmentDef _dress(String key, String en, String am) =>
    GarmentDef(key, en, am, 'dress', setDressWomen, _dressStyles);

final _gDressBodycon = _dress('dress_bodycon', 'Bodycon dress', 'ቦዲኮን ቀሚስ');
final _gDressAline = _dress('dress_aline', 'A-line dress', 'ኤ-ላይን ቀሚስ');
final _gDressMaxi = _dress('dress_maxi', 'Maxi dress', 'ማክሲ ቀሚስ');
final _gDressMidi = _dress('dress_midi', 'Midi dress', 'ሚዲ ቀሚስ');
final _gDressEvening = _dress('dress_evening', 'Evening dress', 'የምሽት ቀሚስ');
final _gDressParty = _dress('dress_party', 'Party dress', 'ፓርቲ ቀሚስ');
final _gDressWedding = _dress('dress_wedding', 'Wedding dress', 'የሠርግ ቀሚስ');
final _gDressGraduation =
    _dress('dress_graduation', 'Graduation dress', 'የምረቃ ቀሚስ');
final _gDressShirt = _dress('dress_shirt', 'Shirt dress', 'ሸሚዝ ቀሚስ');
final _gDressHabesha =
    _dress('dress_habesha', 'Traditional Habesha Kemis', 'ሐበሻ ቀሚስ');
final _gDressCustom = _dress('dress_custom', 'Other custom dress', 'ሌላ ብጁ ቀሚስ');

final _gWomensBlouse =
    GarmentDef('womens_blouse', 'Blouse', 'ብላውዝ', 'blouse',
        setBlouseWomen, _womenCommonStyles);
final _gWomensShirt =
    GarmentDef('womens_shirt', "Women's shirt", 'የሴቶች ሸሚዝ', 'shirt',
        setShirtMen, _shirtStyles);
final _gWomensSkirt =
    GarmentDef('womens_skirt', 'Skirt', 'ስንጥ', 'skirt',
        setSkirtWomen, _skirtStyles);
final _gWomensTrouser =
    GarmentDef('womens_trousers', "Women's trousers", 'የሴቶች ሱሪ', 'trouser',
        setTrouserWomen, _trouserStyles);
final _gWomensCustom =
    GarmentDef('womens_custom', 'Other custom garment', 'ሌላ ብጁ ልብስ', 'other',
        setBlouseWomen, _womenCommonStyles);

// ---------------------------------------------------------------------------
// Categories (male / female groups)
// ---------------------------------------------------------------------------

final mensSuitCategory = ClothingCategory(
    'mens_suit', "Men's suit", 'የወንድ ሱት', WearGroup.male,
    [_gSuitJacket, _gSuitTrouser, _gThreePieceSuit, _gMensFormalShirt,
     _gMensWaistcoat]);

final mensGraduationCategory = ClothingCategory(
    'mens_graduation', "Men's graduation wear", 'የወንድ ምረቃ ልብስ',
    WearGroup.male,
    [_gGradSuit, _gGradShirt, _gGradTrouser, _gGradJacket, _gGradWaistcoat,
     _gGradGown]);

final mensOtherCategory = ClothingCategory(
    'mens_other', "Men's other wear", 'ሌሎች የወንድ ልብሶች', WearGroup.male,
    [_gCasualShirt, _gFormalShirt, _gTraditionalMen, _gCasualTrouser,
     _gFormalTrouser, _gCustomMen]);

final womensSuitCategory = ClothingCategory(
    'womens_suit', "Women's suit", 'የሴቶች ሱት', WearGroup.female,
    [_gTrouserSuit, _gSkirtSuit, _gThreePieceWomen, _gWomensBlazer,
     _gWomensWaistcoat]);

final womensDressesCategory = ClothingCategory(
    'womens_dresses', "Women's dresses", 'የሴቶች ቀሚሶች', WearGroup.female,
    [_gDressBodycon, _gDressAline, _gDressMaxi, _gDressMidi, _gDressEvening,
     _gDressParty, _gDressWedding, _gDressGraduation, _gDressShirt,
     _gDressHabesha, _gDressCustom]);

final womensSeparatesCategory = ClothingCategory(
    'womens_separates', "Women's separate garments", 'የሴቶች ገለልተኛ ልብሶች',
    WearGroup.female,
    [_gWomensBlouse, _gWomensShirt, _gWomensSkirt, _gWomensTrouser,
     _gWomensCustom]);

final List<ClothingCategory> clothingCategories = [
  mensSuitCategory,
  mensGraduationCategory,
  mensOtherCategory,
  womensSuitCategory,
  womensDressesCategory,
  womensSeparatesCategory,
];

/// Design-reference image groups with labels.
final Map<String, FieldOption> designGroups = {
  'shirt': const FieldOption('shirt', 'Shirt design', 'የሸሚዝ ንድፍ'),
  'jacket': const FieldOption('jacket', 'Jacket design', 'የጃኬት ንድፍ'),
  'trouser': const FieldOption('trouser', 'Trouser design', 'የሱሪ ንድፍ'),
  'waistcoat': const FieldOption('waistcoat', 'Waistcoat design', 'የዌዝኮት ንድፍ'),
  'gown': const FieldOption('gown', 'Gown design', 'የጎን ንድፍ'),
  'dress': const FieldOption('dress', 'Dress design', 'የቀሚስ ንድፍ'),
  'blazer': const FieldOption('blazer', 'Blazer design', 'የብላዘር ንድፍ'),
  'skirt': const FieldOption('skirt', 'Skirt design', 'የስንጥ ንድፍ'),
  'suit': const FieldOption('suit', 'Suit design', 'የሱት ንድፍ'),
  'traditional': const FieldOption('traditional', 'Traditional design', 'ባህላዊ ንድፍ'),
  'other': const FieldOption('other', 'Other design reference', 'ሌላ የንድፍ ምሳሌ'),
};

List<GarmentDef> allGarments = [
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

String designGroupLabel(String group, bool isAm) {
  final option = designGroups[group];
  if (option == null) return group;
  return isAm ? option.am : option.en;
}

/// Label for an order's category value. Supports the current taxonomy and
/// legacy v2 categories ('suits', 'graduation_men', 'general').
String categoryValueLabel(String? category, bool isAm, {String styleKey = ''}) {
  final cat = categoryByKey(category ?? '');
  if (cat != null) return cat.label(isAm);
  switch (category) {
    case 'suits':
      return isAm ? 'ሱቶች' : 'Suits';
    case 'graduation_men':
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

String wearGroupLabel(WearGroup group, bool isAm) =>
    group == WearGroup.male
        ? (isAm ? 'የወንድ ልብሶች' : 'Male wear')
        : (isAm ? 'የሴቶች ልብሶች' : 'Female wear');

/// Ethiopian regions (kept for legacy customer data display).
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
