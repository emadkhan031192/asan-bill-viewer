import 'bill_status.dart';

/// A bill the user saved from the Bill Viewer. Stored on-device only.
class SavedBill {
  SavedBill({
    required this.id,
    required this.providerId,
    required this.reference,
    required this.nickname,
    this.amountRs,
    this.dueDate,
    this.paid = false,
    required this.updatedAt,
  });

  final String id;
  final String providerId;

  /// Digits only.
  final String reference;
  final String nickname;
  final int? amountRs;
  final DateTime? dueDate;
  final bool paid;
  final DateTime updatedAt;

  /// Last 4 digits, for the "CODE ••••1234" line on the slip.
  String get last4 => reference.length <= 4
      ? reference
      : reference.substring(reference.length - 4);

  DueStatus statusAt(DateTime now) =>
      dueStatusOf(paid: paid, dueDate: dueDate, now: now);

  SavedBill copyWith({
    String? nickname,
    int? amountRs,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? paid,
    DateTime? updatedAt,
  }) {
    return SavedBill(
      id: id,
      providerId: providerId,
      reference: reference,
      nickname: nickname ?? this.nickname,
      amountRs: amountRs ?? this.amountRs,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      paid: paid ?? this.paid,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'reference': reference,
        'nickname': nickname,
        'amountRs': amountRs,
        'dueDate': dueDate?.toIso8601String(),
        'paid': paid,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SavedBill.fromJson(Map<String, dynamic> json) => SavedBill(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        reference: json['reference'] as String,
        nickname: json['nickname'] as String,
        amountRs: (json['amountRs'] as num?)?.toInt(),
        dueDate: json['dueDate'] == null
            ? null
            : DateTime.parse(json['dueDate'] as String),
        paid: json['paid'] as bool? ?? false,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Sort key: due date ascending, entries without a due date last,
  /// then most recently updated first.
  static int sortByDueDate(SavedBill a, SavedBill b) {
    if (a.dueDate == null && b.dueDate == null) {
      return b.updatedAt.compareTo(a.updatedAt);
    }
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    final c = a.dueDate!.compareTo(b.dueDate!);
    if (c != 0) return c;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
