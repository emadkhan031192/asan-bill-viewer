
class SavedBill {
  String id;
  String label;
  String referenceNo;
  String disco;
  String officialDomain;
  String billCheckUrl;
  String amount;
  String dueDate;
  String lastFetched;
  String pdfPath;
  String group; // Home, Shop, Village

  SavedBill({
    required this.id,
    required this.label,
    required this.referenceNo,
    required this.disco,
    required this.officialDomain,
    required this.billCheckUrl,
    this.amount = '--',
    this.dueDate = '--',
    this.lastFetched = '',
    this.pdfPath = '',
    this.group = 'Home',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'referenceNo': referenceNo,
    'disco': disco,
    'officialDomain': officialDomain,
    'billCheckUrl': billCheckUrl,
    'amount': amount,
    'dueDate': dueDate,
    'lastFetched': lastFetched,
    'pdfPath': pdfPath,
    'group': group,
  };

  factory SavedBill.fromJson(Map<String, dynamic> j) => SavedBill(
    id: j['id'],
    label: j['label'],
    referenceNo: j['referenceNo'],
    disco: j['disco'],
    officialDomain: j['officialDomain'],
    billCheckUrl: j['billCheckUrl'],
    amount: j['amount'] ?? '--',
    dueDate: j['dueDate'] ?? '--',
    lastFetched: j['lastFetched'] ?? '',
    pdfPath: j['pdfPath'] ?? '',
    group: j['group'] ?? 'Home',
  );
}
