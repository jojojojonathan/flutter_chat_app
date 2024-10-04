// Friend.dart
class Friend {
  final String name;
  final String imageUrl;

  Friend({required this.name, required this.imageUrl});

  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      name: data['name'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}