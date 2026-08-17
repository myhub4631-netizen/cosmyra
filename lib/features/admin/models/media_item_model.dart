import 'dart:convert';

/// Model representing a Media Asset in the Cosmyra Media Library
class MediaItem {
  final String id;
  final String name;
  final String url;
  final String category; // 'Products', 'Banners', 'Logos', 'Promos', 'General'
  final int sizeBytes;
  final String dimensions;
  final String fileType;
  final DateTime uploadedAt;

  const MediaItem({
    required this.id,
    required this.name,
    required this.url,
    this.category = 'General',
    this.sizeBytes = 1024 * 150,
    this.dimensions = '1000 x 1000 px',
    this.fileType = 'PNG',
    required this.uploadedAt,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Media Asset').toString(),
      url: (json['url'] ?? json['image_url'] ?? '').toString(),
      category: (json['category'] ?? 'General').toString(),
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? (json['size'] as num?)?.toInt() ?? 150000,
      dimensions: (json['dimensions'] ?? '1000 x 1000 px').toString(),
      fileType: (json['file_type'] ?? json['fileType'] ?? 'PNG').toString(),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'category': category,
        'size_bytes': sizeBytes,
        'dimensions': dimensions,
        'file_type': fileType,
        'uploaded_at': uploadedAt.toIso8601String(),
      };

  MediaItem copyWith({
    String? id,
    String? name,
    String? url,
    String? category,
    int? sizeBytes,
    String? dimensions,
    String? fileType,
    DateTime? uploadedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      category: category ?? this.category,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      dimensions: dimensions ?? this.dimensions,
      fileType: fileType ?? this.fileType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
