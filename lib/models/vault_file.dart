/// Index entry for a bill PDF stored in the app's private storage.
/// The file itself lives in the vault directory under app documents.
class VaultFile {
  VaultFile({
    required this.id,
    required this.providerId,
    required this.title,
    required this.fileName,
    required this.sizeBytes,
    required this.savedAt,
  });

  final String id;
  final String providerId;
  final String title;
  final String fileName;
  final int sizeBytes;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'title': title,
        'fileName': fileName,
        'sizeBytes': sizeBytes,
        'savedAt': savedAt.toIso8601String(),
      };

  factory VaultFile.fromJson(Map<String, dynamic> json) => VaultFile(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        title: json['title'] as String,
        fileName: json['fileName'] as String,
        sizeBytes: (json['sizeBytes'] as num).toInt(),
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
