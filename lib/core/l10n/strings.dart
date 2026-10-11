/// Every user-facing string in English and Urdu.
///
/// Access via [Strings.ofLang] / the `stringsProvider` in state.
/// Numbers are always formatted with Western digits (see core/format.dart).
class Strings {
  const Strings(this.lang);

  /// 'en' or 'ur'.
  final String lang;

  bool get isUrdu => lang == 'ur';

  String _t(String key) {
    final table = _values[lang] ?? _values['en']!;
    return table[key] ?? _values['en']![key] ?? key;
  }

  // ------------------------------------------------------------------
  // App + navigation
  // ------------------------------------------------------------------
  String get appName => _t('appName');
  String get navBills => _t('navBills');
  String get navVault => _t('navVault');
  String get navSettings => _t('navSettings');

  // ------------------------------------------------------------------
  // Home
  // ------------------------------------------------------------------
  String get heroTitle => _t('heroTitle');
  String get heroSub => _t('heroSub');
  String get yourBills => _t('yourBills');
  String get checkBill => _t('checkBill');
  String get scanBill => _t('scanBill');
  String get emptyBillsTitle => _t('emptyBillsTitle');
  String get emptyBillsBody => _t('emptyBillsBody');
  String get emptyBillsCta => _t('emptyBillsCta');
  String get kindElectricity => _t('kindElectricity');
  String get kindGas => _t('kindGas');
  String get kindTelecom => _t('kindTelecom');
  String get kindWater => _t('kindWater');
  String get markPaid => _t('markPaid');
  String get markUnpaid => _t('markUnpaid');

  // ------------------------------------------------------------------
  // Lookup
  // ------------------------------------------------------------------
  String get viewBill => _t('viewBill');
  String get paste => _t('paste');
  String get scanPrinted => _t('scanPrinted');
  String get referenceLabel => _t('referenceLabel');
  String get lookupFootnote => _t('lookupFootnote');
  String get officialSource => _t('officialSource');

  // ------------------------------------------------------------------
  // Bill viewer
  // ------------------------------------------------------------------
  String get blockedLink => _t('blockedLink');
  String get copy => _t('copy');
  String get copied => _t('copied');
  String get savePdf => _t('savePdf');
  String get share => _t('share');
  String get saveBill => _t('saveBill');
  String get savingPdf => _t('savingPdf');
  String get pdfSaved => _t('pdfSaved');
  String get pdfFailed => _t('pdfFailed');
  String get offlineTitle => _t('offlineTitle');
  String get offlineBody => _t('offlineBody');
  String get retry => _t('retry');
  String get close => _t('close');
  String get reload => _t('reload');

  // ------------------------------------------------------------------
  // Save-bill sheet
  // ------------------------------------------------------------------
  String get saveBillTitle => _t('saveBillTitle');
  String get nickname => _t('nickname');
  String get nicknameHint => _t('nicknameHint');
  String get amount => _t('amount');
  String get amountHint => _t('amountHint');
  String get dueDate => _t('dueDate');
  String get dueDateHint => _t('dueDateHint');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get pickDate => _t('pickDate');
  String get clearDate => _t('clearDate');
  String get billSaved => _t('billSaved');
  String get billUpdated => _t('billUpdated');

  // ------------------------------------------------------------------
  // Slip status chips
  // ------------------------------------------------------------------
  String get statusPaid => _t('statusPaid');
  String get statusDueToday => _t('statusDueToday');
  String get statusOverdue => _t('statusOverdue');
  String get statusNoDueDate => _t('statusNoDueDate');
  String statusDueIn(int n) =>
      isUrdu ? '$n ${_t('daysLeft')}' : 'Due in $n ${_t('daysLeft')}';

  // ------------------------------------------------------------------
  // Scan
  // ------------------------------------------------------------------
  String get scanTitle => _t('scanTitle');
  String get scanHint => _t('scanHint');
  String get torchOn => _t('torchOn');
  String get torchOff => _t('torchOff');
  String get gallery => _t('gallery');
  String get cameraPermissionTitle => _t('cameraPermissionTitle');
  String get cameraPermissionBody => _t('cameraPermissionBody');
  String get openSettings => _t('openSettings');
  String get useNumber => _t('useNumber');
  String get confirmCompany => _t('confirmCompany');
  String get tryAgain => _t('tryAgain');
  String get processing => _t('processing');
  String get allowCamera => _t('allowCamera');
  String get noNumberFound => _t('noNumberFound');
  String foundReference(String code) =>
      isUrdu ? '$code کا ریفرنس مل گیا' : 'Found a $code reference';

  // ------------------------------------------------------------------
  // Vault
  // ------------------------------------------------------------------
  String get vaultTitle => _t('vaultTitle');
  String get onThisPhone => _t('onThisPhone');
  String get searchHint => _t('searchHint');
  String get filterAll => _t('filterAll');
  String get noVaultResults => _t('noVaultResults');
  String get vaultEmptyTitle => _t('vaultEmptyTitle');
  String get vaultEmptyBody => _t('vaultEmptyBody');
  String get deletePdf => _t('deletePdf');
  String get deleteConfirmTitle => _t('deleteConfirmTitle');
  String get deleteConfirmBody => _t('deleteConfirmBody');
  String get delete => _t('delete');
  String get offlineTick => _t('offlineTick');
  String get pdfOpened => _t('pdfOpened');

  // ------------------------------------------------------------------
  // Settings
  // ------------------------------------------------------------------
  String get settingsTitle => _t('settingsTitle');
  String get language => _t('language');
  String get english => _t('english');
  String get urdu => _t('urdu');
  String get theme => _t('theme');
  String get themeAuto => _t('themeAuto');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get trustTitle => _t('trustTitle');
  String get trustSub => _t('trustSub');
  String get privacyTitle => _t('privacyTitle');
  String get privacyBody => _t('privacyBody');
  String get version => _t('version');
  String get loadDemo => _t('loadDemo');
  String get demoLoaded => _t('demoLoaded');
  String get demoNote => _t('demoNote');

  // ------------------------------------------------------------------
  // Months (for Vault grouping)
  // ------------------------------------------------------------------
  String monthName(int month) => _t('month$month');

  // ------------------------------------------------------------------
  // Tables
  // ------------------------------------------------------------------
  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appName': 'Asan Bill Viewer',
      'navBills': 'Bills',
      'navVault': 'Vault',
      'navSettings': 'Settings',
      'heroTitle': 'Every bill, straight from the source.',
      'heroSub':
          'Bills open on the official utility site. Your numbers stay on this phone.',
      'yourBills': 'Your bills',
      'checkBill': 'Check a bill',
      'scanBill': 'Scan bill',
      'emptyBillsTitle': 'No saved bills yet',
      'emptyBillsBody':
          'Save a bill from the bill viewer and it will appear here as a payment slip, with its due date and status.',
      'emptyBillsCta': 'Check a bill',
      'kindElectricity': 'Electricity',
      'kindGas': 'Gas',
      'kindTelecom': 'Telecom',
      'kindWater': 'Water',
      'markPaid': 'Mark as paid',
      'markUnpaid': 'Mark as unpaid',
      'viewBill': 'View bill',
      'paste': 'Paste',
      'scanPrinted': 'Scan from a printed bill',
      'referenceLabel': 'Reference number',
      'lookupFootnote':
          'The official page opens next. Your number stays pinned at the bottom so you can copy it in. Links outside the official domain are blocked.',
      'officialSource': 'Official source',
      'blockedLink': 'Blocked a link outside the official site',
      'copy': 'Copy',
      'copied': 'Copied',
      'savePdf': 'Save PDF',
      'share': 'Share',
      'saveBill': 'Save bill',
      'savingPdf': 'Saving PDF…',
      'pdfSaved': 'Saved to Vault',
      'pdfFailed': 'Could not save the PDF. Please try again.',
      'offlineTitle': 'You are offline',
      'offlineBody':
          'The bill page needs an internet connection. Your saved bills and Vault still work offline.',
      'retry': 'Retry',
      'close': 'Close',
      'reload': 'Reload',
      'saveBillTitle': 'Save bill',
      'nickname': 'Nickname',
      'nicknameHint': 'e.g. Home, Shop, Ami’s house',
      'amount': 'Amount (Rs)',
      'amountHint': 'Optional',
      'dueDate': 'Due date',
      'dueDateHint': 'Optional',
      'save': 'Save',
      'cancel': 'Cancel',
      'pickDate': 'Pick a date',
      'clearDate': 'Clear',
      'billSaved': 'Bill saved',
      'billUpdated': 'Bill updated',
      'statusPaid': 'Paid',
      'statusDueToday': 'Due today',
      'statusOverdue': 'Overdue',
      'statusNoDueDate': 'No due date',
      'daysLeft': 'days left',
      'scanTitle': 'Scan bill',
      'scanHint': 'Point the camera at the reference or account number on a printed bill.',
      'torchOn': 'Turn torch on',
      'torchOff': 'Turn torch off',
      'gallery': 'Choose from gallery',
      'cameraPermissionTitle': 'Camera access needed',
      'cameraPermissionBody':
          'To scan a printed bill, allow camera access. The scan runs fully on this phone.',
      'openSettings': 'Open settings',
      'useNumber': 'Use this number',
      'confirmCompany': 'Which company is this bill from?',
      'tryAgain': 'Try again',
      'processing': 'Reading…',
      'allowCamera': 'Allow camera',
      'noNumberFound': 'No number found in that image. Try again.',
      'vaultTitle': 'Vault',
      'onThisPhone': 'On this phone',
      'searchHint': 'Search saved PDFs',
      'filterAll': 'All',
      'noVaultResults': 'No PDFs match your search.',
      'vaultEmptyTitle': 'No saved PDFs yet',
      'vaultEmptyBody':
          'When you save a bill as PDF from the bill viewer, it is stored here on this phone.',
      'deletePdf': 'Delete',
      'deleteConfirmTitle': 'Delete this PDF?',
      'deleteConfirmBody': 'The file will be removed from this phone.',
      'delete': 'Delete',
      'offlineTick': 'Saved offline',
      'pdfOpened': 'Opening PDF…',
      'settingsTitle': 'Settings',
      'language': 'Language',
      'english': 'English',
      'urdu': 'اردو',
      'theme': 'Theme',
      'themeAuto': 'Auto',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'trustTitle': 'Where bills come from',
      'trustSub': 'Bills only ever open on these official domains.',
      'privacyTitle': 'Your privacy',
      'privacyBody':
          'Everything stays on this phone. No accounts, no tracking, no analytics. Bills open only on official utility websites.',
      'version': 'Version',
      'loadDemo': 'Load demo bills',
      'demoLoaded': 'Demo bills loaded',
      'demoNote': 'Debug only — never shown in release builds.',
      'month1': 'January',
      'month2': 'February',
      'month3': 'March',
      'month4': 'April',
      'month5': 'May',
      'month6': 'June',
      'month7': 'July',
      'month8': 'August',
      'month9': 'September',
      'month10': 'October',
      'month11': 'November',
      'month12': 'December',
    },
    'ur': {
      'appName': 'آسان بل ویور',
      'navBills': 'بل',
      'navVault': 'والٹ',
      'navSettings': 'ترتیبات',
      'heroTitle': 'ہر بل، براہِ راست اصل ذریعے سے۔',
      'heroSub':
          'بل سرکاری یوٹیلیٹی ویب سائٹ پر کھلتے ہیں۔ آپ کے نمبر اسی فون میں رہتے ہیں۔',
      'yourBills': 'آپ کے بل',
      'checkBill': 'بل چیک کریں',
      'scanBill': 'بل اسکین کریں',
      'emptyBillsTitle': 'ابھی کوئی محفوظ بل نہیں',
      'emptyBillsBody':
          'بل ویور سے کوئی بل محفوظ کریں تو وہ یہاں ادائیگی کی پرچی کی صورت میں نظر آئے گا، آخری تاریخ اور حیثیت کے ساتھ۔',
      'emptyBillsCta': 'بل چیک کریں',
      'kindElectricity': 'بجلی',
      'kindGas': 'گیس',
      'kindTelecom': 'ٹیلی کام',
      'kindWater': 'پانی',
      'markPaid': 'ادا شدہ قرار دیں',
      'markUnpaid': 'غیر ادا شدہ قرار دیں',
      'viewBill': 'بل دیکھیں',
      'paste': 'پیسٹ کریں',
      'scanPrinted': 'چھپے ہوئے بل سے اسکین کریں',
      'referenceLabel': 'ریفرنس نمبر',
      'lookupFootnote':
          'آگے سرکاری صفحہ کھلے گا۔ آپ کا نمبر نیچے لگا رہے گا تاکہ آپ اسے کاپی کر سکیں۔ سرکاری ڈومین سے باہر کے لنکس بلاک ہیں۔',
      'officialSource': 'سرکاری ذریعہ',
      'blockedLink': 'سرکاری سائٹ سے باہر کا لنک بلاک کر دیا گیا',
      'copy': 'کاپی کریں',
      'copied': 'کاپی ہو گیا',
      'savePdf': 'پی ڈی ایف محفوظ کریں',
      'share': 'شیئر کریں',
      'saveBill': 'بل محفوظ کریں',
      'savingPdf': 'پی ڈی ایف محفوظ ہو رہی ہے…',
      'pdfSaved': 'والٹ میں محفوظ ہو گیا',
      'pdfFailed': 'پی ڈی ایف محفوظ نہیں ہو سکی۔ دوبارہ کوشش کریں۔',
      'offlineTitle': 'آپ آف لائن ہیں',
      'offlineBody':
          'بل کا صفحہ کھولنے کے لیے انٹرنیٹ درکار ہے۔ آپ کے محفوظ بل اور والٹ آف لائن بھی کام کرتے ہیں۔',
      'retry': 'دوبارہ کوشش کریں',
      'close': 'بند کریں',
      'reload': 'دوبارہ لوڈ کریں',
      'saveBillTitle': 'بل محفوظ کریں',
      'nickname': 'عرفی نام',
      'nicknameHint': 'مثلاً گھر، دکان',
      'amount': 'رقم (روپے)',
      'amountHint': 'اختیاری',
      'dueDate': 'آخری تاریخ',
      'dueDateHint': 'اختیاری',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'pickDate': 'تاریخ منتخب کریں',
      'clearDate': 'صاف کریں',
      'billSaved': 'بل محفوظ ہو گیا',
      'billUpdated': 'بل اپ ڈیٹ ہو گیا',
      'statusPaid': 'ادا شدہ',
      'statusDueToday': 'آج آخری تاریخ',
      'statusOverdue': 'میعاد گزر گئی',
      'statusNoDueDate': 'آخری تاریخ نہیں',
      'daysLeft': 'دن باقی',
      'scanTitle': 'بل اسکین کریں',
      'scanHint':
          'کیمرہ چھپے ہوئے بل پر موجود ریفرنس یا اکاؤنٹ نمبر کی طرف کریں۔',
      'torchOn': 'ٹارچ آن کریں',
      'torchOff': 'ٹارچ آف کریں',
      'gallery': 'گیلری سے منتخب کریں',
      'cameraPermissionTitle': 'کیمرے کی اجازت درکار ہے',
      'cameraPermissionBody':
          'چھپا ہوا بل اسکین کرنے کے لیے کیمرے کی اجازت دیں۔ اسکین مکمل طور پر اسی فون پر ہوتا ہے۔',
      'openSettings': 'ترتیبات کھولیں',
      'useNumber': 'یہ نمبر استعمال کریں',
      'confirmCompany': 'یہ بل کس کمپنی کا ہے؟',
      'tryAgain': 'دوبارہ کوشش کریں',
      'processing': 'پڑھا جا رہا ہے…',
      'allowCamera': 'کیمرے کی اجازت دیں',
      'noNumberFound': 'اس تصویر میں کوئی نمبر نہیں ملا۔ دوبارہ کوشش کریں۔',
      'vaultTitle': 'والٹ',
      'onThisPhone': 'اسی فون پر',
      'searchHint': 'محفوظ پی ڈی ایف تلاش کریں',
      'filterAll': 'سب',
      'noVaultResults': 'آپ کی تلاش سے کوئی پی ڈی ایف نہیں ملی۔',
      'vaultEmptyTitle': 'ابھی کوئی محفوظ پی ڈی ایف نہیں',
      'vaultEmptyBody':
          'جب آپ بل ویور سے کسی بل کو پی ڈی ایف کے طور پر محفوظ کریں گے تو وہ یہیں اسی فون پر رکھی جائے گی۔',
      'deletePdf': 'حذف کریں',
      'deleteConfirmTitle': 'کیا یہ پی ڈی ایف حذف کریں؟',
      'deleteConfirmBody': 'فائل اس فون سے ہٹا دی جائے گی۔',
      'delete': 'حذف کریں',
      'offlineTick': 'آف لائن محفوظ',
      'pdfOpened': 'پی ڈی ایف کھولی جا رہی ہے…',
      'settingsTitle': 'ترتیبات',
      'language': 'زبان',
      'english': 'English',
      'urdu': 'اردو',
      'theme': 'تھیم',
      'themeAuto': 'خودکار',
      'themeLight': 'روشن',
      'themeDark': 'تاریک',
      'trustTitle': 'بل کہاں سے آتے ہیں',
      'trustSub': 'بل ہمیشہ صرف ان سرکاری ڈومینز پر کھلتے ہیں۔',
      'privacyTitle': 'آپ کی رازداری',
      'privacyBody':
          'سب کچھ اسی فون میں رہتا ہے۔ کوئی اکاؤنٹ نہیں، کوئی ٹریکنگ نہیں، کوئی تجزیات نہیں۔ بل صرف سرکاری یوٹیلیٹی ویب سائٹس پر کھلتے ہیں۔',
      'version': 'ورژن',
      'loadDemo': 'ڈیمو بل لوڈ کریں',
      'demoLoaded': 'ڈیمو بل لوڈ ہو گئے',
      'demoNote': 'صرف ڈیبگ کے لیے — ریلیز میں کبھی نظر نہیں آئیں گے۔',
      'month1': 'جنوری',
      'month2': 'فروری',
      'month3': 'مارچ',
      'month4': 'اپریل',
      'month5': 'مئی',
      'month6': 'جون',
      'month7': 'جولائی',
      'month8': 'اگست',
      'month9': 'ستمبر',
      'month10': 'اکتوبر',
      'month11': 'نومبر',
      'month12': 'دسمبر',
    },
  };
}
