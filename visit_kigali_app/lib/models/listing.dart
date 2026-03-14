class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contact;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contact,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
  });

  // Convert Realtime Database data to Listing object
  factory Listing.fromRealtimeDatabase(Map<String, dynamic> data) {
    return Listing(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  // Convert Listing object to Map for Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contact': contact,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

/// Available listing categories
/// This is used in dropdowns and filters throughout the app
/// 
/// To add a new category:
/// 1. Add it to this list
/// 2. Add matching icon in ListingCard._getCategoryIcon()
/// 3. Add matching color in ListingCard._getCategoryColor()
class Categories {
  static const List<String> all = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office',
    'Shopping',
    'Entertainment',
  ];
}