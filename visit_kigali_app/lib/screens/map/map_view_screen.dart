import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing.dart';
import '../detail/listing_detail_screen.dart';
 
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);
 
  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}
 
class _MapViewScreenState extends State<MapViewScreen> {
  Set<Marker> _markers = {};
  Listing? _selectedListing;
 
  // Kigali coordinates as default center
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false).listenToListings();
    });
  }
 
  void _createMarkers(List<Listing> listings) {
    _markers = listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
          onTap: () {
            setState(() {
              _selectedListing = listing;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedListing = listing;
          });
        },
      );
    }).toSet();
  }
 
  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    _createMarkers(listingProvider.allListings);
 
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          
          // Category Filter Chips at Top
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: listingProvider.selectedCategory == null,
                        onSelected: (_) {
                          listingProvider.updateCategory(null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...Categories.all.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: listingProvider.selectedCategory == category,
                            onSelected: (_) {
                              listingProvider.updateCategory(category);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Selected Listing Info Card at Bottom
          if (_selectedListing != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(
                          listing: _selectedListing!,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedListing!.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedListing!.category,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedListing!.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedListing = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}