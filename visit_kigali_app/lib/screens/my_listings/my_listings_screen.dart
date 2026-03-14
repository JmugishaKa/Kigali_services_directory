import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/listing_form.dart';
import '../detail/listing_detail_screen.dart';

/// MyListingsScreen - Shows only the current user's listings
/// 
/// Features:
/// ✅ Display user's listings only (filtered by Firebase query)
/// ✅ Edit listing (opens form with existing data)
/// ✅ Delete listing (with confirmation dialog)
/// ✅ Add new listing (FAB button)
/// 
/// This demonstrates Firebase query filtering (createdBy == currentUser.uid)
/// Much more efficient than fetching all and filtering locally!
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Listen to user's listings specifically
    // This uses Firebase orderByChild query to only fetch THIS user's listings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Only fetch if user is authenticated
      if (authProvider.user != null) {
        Provider.of<ListingProvider>(context, listen: false)
            .listenToMyListings(authProvider.user!.uid);
      }
    });
  }

  /// Show form to add new listing
  void _showAddListingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full height for scrolling
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ListingForm(), // No listing = create mode
    );
  }

  /// Show form to edit existing listing
  /// Passes existing listing to form - form handles update vs create
  void _showEditListingForm(listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListingForm(listing: listing), // With listing = edit mode
    );
  }

  /// Delete listing with confirmation
  /// Good UX practice - always confirm destructive actions!
  Future<void> _deleteListing(String id, String name) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text(
          'Are you sure you want to delete "$name"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only delete if user confirmed
    if (confirmed == true && mounted) {
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      
      // Call delete through provider (which calls service)
      // Provider → Service → Firebase
      bool success = await listingProvider.deleteListing(id);
      
      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Listing deleted successfully' 
                  : 'Failed to delete listing'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating, // Modern floating snackbar
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        // Show count in subtitle
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(),
        ),
      ),
      body: listingProvider.myListings.isEmpty
          // ========== EMPTY STATE ==========
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_business,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No listings yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your favorite places in Kigali!',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddListingForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Listing'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          // ========== LISTINGS LIST ==========
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listingProvider.myListings.length,
              itemBuilder: (context, index) {
                final listing = listingProvider.myListings[index];
                
                // ListingCard with edit/delete actions enabled
                // showActions = true adds edit/delete buttons
                return ListingCard(
                  listing: listing,
                  showActions: true, // Show edit/delete buttons
                  onTap: () {
                    // View details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(
                          listing: listing,
                        ),
                      ),
                    );
                  },
                  onEdit: () => _showEditListingForm(listing),
                  onDelete: () => _deleteListing(listing.id, listing.name),
                );
              },
            ),
      
      // ========== FLOATING ACTION BUTTON ==========
      // Quick add button - standard mobile UX pattern
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddListingForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }
}

/*
 * UPDATE vs DELETE FLOW:
 * 
 * UPDATE:
 * 1. User taps edit icon → _showEditListingForm(listing)
 * 2. Form opens pre-filled with existing data
 * 3. User modifies and saves
 * 4. Form calls listingProvider.updateListing()
 * 5. Provider calls listingService.updateListing()
 * 6. Service updates Firebase
 * 7. Firebase stream emits new data
 * 8. Provider rebuilds with updated listing
 * 9. UI automatically shows updated data
 * 
 * DELETE:
 * 1. User taps delete icon → _deleteListing()
 * 2. Confirmation dialog appears (important!)
 * 3. User confirms
 * 4. Provider calls service.deleteListing()
 * 5. Service removes from Firebase
 * 6. Stream emits updated list (without deleted item)
 * 7. UI rebuilds automatically
 * 
 * No manual refresh needed - streams handle everything! 🚀
 */