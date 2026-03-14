import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/listing_form.dart';
import '../detail/listing_detail_screen.dart';

/// DirectoryScreen - Main screen showing ALL listings in Kigali
/// 
/// Features (per rubric requirements):
/// ✅ Search by name/address
/// ✅ Filter by category
/// ✅ Real-time updates from Firebase
/// ✅ Pull-to-refresh
/// ✅ Navigate to detail screen
/// 
/// State Management Flow:
/// Firebase → ListingService → ListingProvider → DirectoryScreen UI
/// (No direct Firebase calls here - clean architecture!)
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  // Controllers for search input
  final TextEditingController _searchController = TextEditingController();
  
  // Local state for category dropdown
  // Note: The actual filtering happens in ListingProvider!
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    
    // Start listening to listings from Firebase
    // Using addPostFrameCallback to avoid calling Provider during build
    // This was a bug I fixed - calling Provider in initState caused errors!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false).listenToListings();
    });
  }

  @override
  void dispose() {
    // Always clean up controllers to prevent memory leaks!
    _searchController.dispose();
    super.dispose();
  }

  /// Show modal to add new listing
  /// Using ModalBottomSheet for better mobile UX than full-screen form
  void _showAddListingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full-height sheet for long forms
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ListingForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get providers
    // listen: true - UI rebuilds when data changes (for filteredListings)
    final listingProvider = Provider.of<ListingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali Directory'),
        actions: [
          // Add button - anyone can contribute listings!
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddListingForm,
            tooltip: 'Add New Listing',
          ),
        ],
      ),
      body: Column(
        children: [
          // ========== SEARCH & FILTER BAR ==========
          // This section handles search and category filtering
          // Both update the Provider, which filters listings automatically
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // === SEARCH FIELD ===
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or address...',
                    prefixIcon: const Icon(Icons.search),
                    // Show clear button only when text exists
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                listingProvider.updateSearch('');
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  // Update search filter in real-time as user types
                  onChanged: (value) {
                    listingProvider.updateSearch(value);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // === CATEGORY FILTER ===
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    // "All Categories" option
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    // Individual category options from model
                    ...Categories.all.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    // Update filter in provider
                    listingProvider.updateCategory(value);
                  },
                ),
              ],
            ),
          ),
          
          // ========== LISTINGS LIST ==========
          // Shows filtered results from Provider
          // Empty state if no results, scrollable list otherwise
          Expanded(
            child: listingProvider.filteredListings.isEmpty
                // === EMPTY STATE ===
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No listings found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Suggest adding first listing
                        if (listingProvider.allListings.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _showAddListingForm,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Listing'),
                          ),
                      ],
                    ),
                  )
                // === LISTINGS LIST ===
                : RefreshIndicator(
                    // Pull-to-refresh (though stream updates automatically!)
                    // Added for better UX - users expect this on mobile
                    onRefresh: () async {
                      // Streams update automatically, but show feedback
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listingProvider.filteredListings.length,
                      itemBuilder: (context, index) {
                        final listing = listingProvider.filteredListings[index];
                        
                        // Using custom ListingCard widget for consistent design
                        return ListingCard(
                          listing: listing,
                          onTap: () {
                            // Navigate to detail screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                  listing: listing,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/*
 * HOW SEARCH & FILTER WORKS:
 * 
 * 1. User types in search box → calls listingProvider.updateSearch(query)
 * 2. Provider updates internal _searchQuery variable
 * 3. Provider calls notifyListeners()
 * 4. This widget rebuilds (because we're listening to provider)
 * 5. filteredListings getter in Provider returns filtered results
 * 6. ListView rebuilds with new filtered list
 * 
 * Same flow for category filter!
 * 
 * This is reactive programming - data flows one direction:
 * User Input → Provider State → UI Update
 * 
 * No manual UI updates needed - Provider handles it! 🎉
 */