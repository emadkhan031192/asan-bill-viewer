/// Single source of truth for every supported utility provider.
///
/// To add a provider, append ONE [BillProvider] entry to [kProviders].
/// Nothing else needs to change: Home tiles, Lookup, the Bill Viewer
/// allowlist, the Vault grouping and the Settings domain list all read
/// from this file.
enum UtilityKind { electricity, gas, telecom, water }

class BillProvider {
  const BillProvider({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameUr,
    required this.kind,
    required this.url,
    required this.allowedDomains,
    required this.minLength,
    required this.maxLength,
    required this.hintEn,
    required this.hintUr,
  });

  /// Stable id, e.g. 'lesco'.
  final String id;

  /// Short code shown on tiles and slips, e.g. 'LESCO'.
  final String code;

  /// Full English name, e.g. 'Lahore Electric Supply Company'.
  final String nameEn;

  /// Urdu name, e.g. 'لیسکو'.
  final String nameUr;

  final UtilityKind kind;

  /// The official bill-lookup page. The in-app viewer opens exactly this.
  final String url;

  /// Domains (and their subdomains) the viewer is allowed to load.
  /// Anything else is blocked inside the Bill Viewer.
  final List<String> allowedDomains;

  /// Inclusive digit-length rule for the reference / account / consumer number.
  final int minLength;
  final int maxLength;

  /// Short helper shown under the input field.
  final String hintEn;
  final String hintUr;

  bool get isFixedLength => minLength == maxLength;
}

const List<BillProvider> kProviders = [
  // ------------------------------------------------------------------
  // Electricity — PITC portal (14-digit reference number)
  // ------------------------------------------------------------------
  BillProvider(
    id: 'lesco',
    code: 'LESCO',
    nameEn: 'Lahore Electric Supply Company',
    nameUr: 'لیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/lescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'gepco',
    code: 'GEPCO',
    nameEn: 'Gujranwala Electric Power Company',
    nameUr: 'گیپکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/gepcobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'fesco',
    code: 'FESCO',
    nameEn: 'Faisalabad Electric Supply Company',
    nameUr: 'فیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/fescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'iesco',
    code: 'IESCO',
    nameEn: 'Islamabad Electric Supply Company',
    nameUr: 'آئیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/iescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'mepco',
    code: 'MEPCO',
    nameEn: 'Multan Electric Power Company',
    nameUr: 'میپکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/mepcobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'pesco',
    code: 'PESCO',
    nameEn: 'Peshawar Electric Supply Company',
    nameUr: 'پیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/pescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'hesco',
    code: 'HESCO',
    nameEn: 'Hyderabad Electric Supply Company',
    nameUr: 'حیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/hescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'sepco',
    code: 'SEPCO',
    nameEn: 'Sukkur Electric Power Company',
    nameUr: 'سیپکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/sepcobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'qesco',
    code: 'QESCO',
    nameEn: 'Quetta Electric Supply Company',
    nameUr: 'کیوسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/qescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),
  BillProvider(
    id: 'tesco',
    code: 'TESCO',
    nameEn: 'Tribal Areas Electric Supply Company',
    nameUr: 'ٹیسکو',
    kind: UtilityKind.electricity,
    url: 'https://bill.pitc.com.pk/tescobill',
    allowedDomains: ['bill.pitc.com.pk', 'pitc.com.pk'],
    minLength: 14,
    maxLength: 14,
    hintEn: '14-digit reference number from any old bill',
    hintUr: 'کسی پرانے بل سے 14 ہندسوں کا ریفرنس نمبر',
  ),

  // ------------------------------------------------------------------
  // Electricity — K-Electric (13-digit account number)
  // ------------------------------------------------------------------
  BillProvider(
    id: 'kelectric',
    code: 'K-Electric',
    nameEn: 'K-Electric',
    nameUr: 'کے الیکٹرک',
    kind: UtilityKind.electricity,
    url: 'https://bill.ke.com.pk',
    allowedDomains: ['bill.ke.com.pk', 'ke.com.pk'],
    minLength: 13,
    maxLength: 13,
    hintEn: '13-digit account number from your KE bill',
    hintUr: 'اپنے کے الیکٹرک بل سے 13 ہندسوں کا اکاؤنٹ نمبر',
  ),

  // ------------------------------------------------------------------
  // Gas
  // ------------------------------------------------------------------
  BillProvider(
    id: 'sngpl',
    code: 'SNGPL',
    nameEn: 'Sui Northern Gas Pipelines Limited',
    nameUr: 'سوئی ناردرن گیس',
    kind: UtilityKind.gas,
    url: 'https://bill.sngpl.com.pk',
    allowedDomains: ['bill.sngpl.com.pk', 'sngpl.com.pk'],
    minLength: 8,
    maxLength: 12,
    hintEn: 'Consumer number from your gas bill (usually 11 digits)',
    hintUr: 'گیس بل سے کنزیومر نمبر (عام طور پر 11 ہندسے)',
  ),
  BillProvider(
    id: 'ssgc',
    code: 'SSGC',
    nameEn: 'Sui Southern Gas Company',
    nameUr: 'سوئی سدرن گیس',
    kind: UtilityKind.gas,
    url: 'https://viewbill.ssgc.com.pk',
    allowedDomains: ['viewbill.ssgc.com.pk', 'ssgc.com.pk'],
    minLength: 10,
    maxLength: 10,
    hintEn: '10-digit customer number from your gas bill',
    hintUr: 'گیس بل سے 10 ہندسوں کا کسٹمر نمبر',
  ),

  // ------------------------------------------------------------------
  // Telecom
  // ------------------------------------------------------------------
  BillProvider(
    id: 'ptcl',
    code: 'PTCL',
    nameEn: 'Pakistan Telecommunication Company Limited',
    nameUr: 'پی ٹی سی ایل',
    kind: UtilityKind.telecom,
    url: 'https://dbill.ptcl.net.pk',
    allowedDomains: ['dbill.ptcl.net.pk', 'ptcl.net.pk'],
    minLength: 10,
    maxLength: 11,
    hintEn: 'Landline number with area code, e.g. 0512345678',
    hintUr: 'ایریا کوڈ کے ساتھ لینڈ لائن نمبر، مثلاً 0512345678',
  ),

  // ------------------------------------------------------------------
  // Water
  // ------------------------------------------------------------------
  BillProvider(
    id: 'wasa_lahore',
    code: 'WASA',
    nameEn: 'WASA Lahore',
    nameUr: 'واسا لاہور',
    kind: UtilityKind.water,
    url: 'https://wasa.lahore.gop.pk',
    allowedDomains: ['wasa.lahore.gop.pk', 'lahore.gop.pk'],
    minLength: 4,
    maxLength: 14,
    hintEn: 'Consumer number from your WASA bill',
    hintUr: 'واسا بل سے کنزیومر نمبر',
  ),
];

/// Lookup by stable [id]. Returns null for unknown ids.
BillProvider? providerById(String id) {
  for (final p in kProviders) {
    if (p.id == id) return p;
  }
  return null;
}

/// Providers grouped for the Home "Check a bill" section, in display order.
Map<UtilityKind, List<BillProvider>> providersByKind() {
  final map = <UtilityKind, List<BillProvider>>{
    for (final k in UtilityKind.values) k: <BillProvider>[],
  };
  for (final p in kProviders) {
    map[p.kind]!.add(p);
  }
  return map;
}

/// Every official domain used by the app (for the Settings trust list).
List<String> allOfficialDomains() {
  final domains = <String>{};
  for (final p in kProviders) {
    domains.add(Uri.parse(p.url).host);
  }
  return domains.toList()..sort();
}
