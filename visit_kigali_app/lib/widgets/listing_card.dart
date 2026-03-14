import 'package:flutter/material.dart';
import '../models/listing.dart';

/// ListingCard - Reusable card widget for displaying listings
/// 
/// I spent WAY too long getting the colors right on this! 😅
/// Learned a lot about Flutter's Card widget and InkWell for tap effects
/// 
/// Used in: Directory screen AND My Listings screen
/// The showActions parameter controls whether to show edit/delete buttons
/// (Only show them in My Listings where user owns the listing)
class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final bool showActions;  // true = show edit/delete, false = just arrow
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListingCard({
    Key? key,
    required this.listing,
    required this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,  // Small shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),  // Rounded corners look modern!
      ),
      child: InkWell(  // InkWell for ripple effect when tapped
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),  // Match card border
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // === LEFT SIDE: Category Icon ===
              // This took me forever to get right! The colored background was tricky
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // Light version of category color for background
                  color: _getCategoryColor(listing.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(listing.category),
                  color: _getCategoryColor(listing.category),  // Full color for icon
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // === MIDDLE: Listing Info ===
              Expanded(  // Takes up remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Listing Name (bold, bigger)
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,  // Cut off if too long
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Category Badge (small colored pill)
                    // I really like how this looks - the colors make it easy to scan!
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(listing.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getCategoryColor(listing.category).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        listing.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(listing.category),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Address with location pin icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // === RIGHT SIDE: Action Buttons or Arrow ===
              if (showActions) ...[
                // For "My Listings" - show edit and delete buttons
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Button (blue)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue[700],
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    // Delete Button (red)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red[700],
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ] else ...[
                // For regular listings - just show arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Get the right icon for each category
  /// I added more categories than initially planned - kept running into missing ones!
  /// Material Icons has SO many options, just had to find the right ones
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;  // Red cross icon
      case 'Police Station':
        return Icons.local_police;  // Badge icon
      case 'Library':
        return Icons.local_library;  // Book icon
      case 'Restaurant':
        return Icons.restaurant;  // Fork and knife
      case 'Café':
        return Icons.local_cafe;  // Coffee cup
      case 'Park':
        return Icons.park;  // Tree icon
      case 'Tourist Attraction':
        return Icons.tour;  // Flag icon
      case 'Utility Office':
        return Icons.business;  // Building icon
      case 'Shopping':
        return Icons.shopping_bag;  // Shopping bag
      case 'Entertainment':
        return Icons.movie;  // Movie reel
      default:
        return Icons.place;  // Generic pin icon as fallback
    }
  }

  /// Get matching color for each category
  /// Chose colors that make sense - hospital=red, park=green, etc.
  /// This makes it SUPER easy to scan the list visually!
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hospital':
        return Colors.red;  // Emergency/medical = red
      case 'Police Station':
        return Colors.blue;  // Official/authority = blue
      case 'Library':
        return Colors.purple;  // Education/knowledge = purple
      case 'Restaurant':
        return Colors.orange;  // Food/warmth = orange
      case 'Café':
        return Colors.brown;  // Coffee = brown (obviously!)
      case 'Park':
        return Colors.green;  // Nature = green
      case 'Tourist Attraction':
        return Colors.teal;  // Travel/adventure = teal
      case 'Utility Office':
        return Colors.indigo;  // Business/formal = indigo
      case 'Shopping':
        return Colors.pink;  // Fun/retail = pink
      case 'Entertainment':
        return Colors.deepPurple;  // Creative/fun = deep purple
      default:
        return Colors.grey;  // Unknown category = grey
    }
  }
}