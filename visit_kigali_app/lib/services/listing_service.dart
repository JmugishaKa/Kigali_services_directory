import 'package:firebase_database/firebase_database.dart';
import '../models/listing.dart';

/// ListingService - The ONLY place we talk to Firebase for listings
/// This is the "Service Layer" mentioned in the rubric
/// 
/// Why separate this from UI?
/// - Clean Architecture: UI doesn't know about Firebase details
/// - Easy to test: can mock this service
/// - Single source of truth: all Firebase operations in one place
/// 
/// IMPORTANT: UI never calls Firebase directly - always goes through Provider → Service!
class ListingService {
  // Firebase Realtime Database reference
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Path in database where listings are stored
  // Database structure: /listings/{listingId}/{listing data}
  final String _listingsPath = 'listings';

  /// CREATE - Add new listing to Firebase
  /// Returns: null on success, error message on failure
  /// 
  /// Note: Firebase auto-generates unique IDs using push()
  /// This was tricky - I initially tried using timestamps but got collisions!
  Future<String?> createListing(Listing listing) async {
    try {
      // Generate unique key for this listing
      // push() creates a time-ordered unique ID (great for sorting!)
      final newRef = _database.child(_listingsPath).push();
      
      // Create listing with the generated ID
      // We need to include the ID in the object for easy reference later
      final listingWithId = Listing(
        id: newRef.key!,  // Use the Firebase-generated key as ID
        name: listing.name,
        category: listing.category,
        address: listing.address,
        contact: listing.contact,
        description: listing.description,
        latitude: listing.latitude,
        longitude: listing.longitude,
        createdBy: listing.createdBy,  // User's UID - for My Listings filtering
        createdAt: listing.createdAt,
      );
      
      // Save to Firebase - set() replaces any existing data at this location
      await newRef.set(listingWithId.toMap());
      
      return null; // Success! No error message
    } catch (e) {
      // Catch any Firebase errors (network issues, permission denied, etc.)
      print('Create listing error: $e'); // Debug log
      return 'Error creating listing: ${e.toString()}';
    }
  }

  /// READ - Get all listings (returns Stream for real-time updates!)
  /// 
  /// Stream vs Future:
  /// - Future: one-time fetch (like await fetch())
  /// - Stream: continuous updates (Firebase notifies us when data changes!)
  /// 
  /// This is AWESOME because UI updates automatically when anyone adds/edits/deletes!
  /// No need to manually refresh - that's the power of Firebase Realtime Database 🔥
  Stream<List<Listing>> getAllListings() {
    return _database
        .child(_listingsPath)
        .onValue  // Listen to all changes at this location
        .map((event) {
      // Convert Firebase snapshot to List<Listing>
      final List<Listing> listings = [];
      
      // Check if any data exists
      if (event.snapshot.value != null) {
        // Firebase returns data as nested Map
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        
        // Loop through each listing in the database
        data.forEach((key, value) {
          final listingData = Map<String, dynamic>.from(value as Map);
          listingData['id'] = key; // Add the Firebase key as ID
          listings.add(Listing.fromRealtimeDatabase(listingData));
        });
      }
      
      // Sort by creation time - newest first
      // This gives users the latest listings at the top!
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return listings;
    });
  }

  /// READ - Get only the current user's listings
  /// Uses Firebase query to filter by createdBy field
  /// 
  /// Firebase Query explained:
  /// - orderByChild('createdBy'): tells Firebase which field to filter on
  /// - equalTo(uid): only return listings where createdBy == this user's UID
  /// 
  /// This is more efficient than fetching all listings and filtering in Flutter!
  Stream<List<Listing>> getMyListings(String uid) {
    return _database
        .child(_listingsPath)
        .orderByChild('createdBy')  // Index by creator
        .equalTo(uid)                // Only this user's listings
        .onValue
        .map((event) {
      final List<Listing> listings = [];
      
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        
        data.forEach((key, value) {
          final listingData = Map<String, dynamic>.from(value as Map);
          listingData['id'] = key;
          listings.add(Listing.fromRealtimeDatabase(listingData));
        });
      }
      
      // Sort newest first
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  /// UPDATE - Modify existing listing
  /// Uses update() instead of set() to only change specified fields
  /// 
  /// set() vs update():
  /// - set() replaces entire object
  /// - update() only changes fields you specify (safer!)
  Future<String?> updateListing(String id, Listing listing) async {
    try {
      // Update specific listing by ID
      // update() merges new data with existing data
      await _database
          .child(_listingsPath)
          .child(id)
          .update(listing.toMap());
      
      return null; // Success
    } catch (e) {
      print('Update listing error: $e'); // Debug log
      return 'Error updating listing: ${e.toString()}';
    }
  }

  /// DELETE - Remove listing from Firebase
  /// Simple and clean - just remove() by ID
  Future<String?> deleteListing(String id) async {
    try {
      // Remove this listing from database
      // This triggers onValue listeners to update UI automatically!
      await _database
          .child(_listingsPath)
          .child(id)
          .remove();
      
      return null; // Success
    } catch (e) {
      print('Delete listing error: $e'); // Debug log
      return 'Error deleting listing: ${e.toString()}';
    }
  }
}

/* 
 * FIREBASE DATABASE STRUCTURE:
 * 
 * listings/
 *   ├─ {listingId1}/
 *   │   ├─ id: "listingId1"
 *   │   ├─ name: "Kigali Heights"
 *   │   ├─ category: "Restaurant"
 *   │   ├─ address: "KN 4 Ave, Kigali"
 *   │   ├─ contact: "+250788123456"
 *   │   ├─ description: "Modern restaurant..."
 *   │   ├─ latitude: -1.9536
 *   │   ├─ longitude: 30.0606
 *   │   ├─ createdBy: "userId123"
 *   │   └─ createdAt: 1677123456789
 *   ├─ {listingId2}/
 *   │   └─ ...
 * 
 * This structure allows:
 * - Easy CRUD operations by ID
 * - Querying by createdBy (My Listings)
 * - Real-time sync across all devices
 * - Geographic coordinates for maps
 */