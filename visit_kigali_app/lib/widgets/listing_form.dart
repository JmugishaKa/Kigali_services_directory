import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';  // This has Categories class
import '../providers/listing_provider.dart';
import '../providers/auth_provider.dart';

/// ListingForm - For creating OR editing listings
/// 
/// This was HARD to get right! Had to handle two modes:
/// - CREATE mode (when listing is null)
/// - EDIT mode (when listing is provided)
/// 
/// The tricky part was pre-filling the form in edit mode while keeping
/// validation working. Spent hours debugging why coordinates wouldn't update! 😅
/// 
/// Used in: Directory screen (create) and My Listings screen (edit)
class ListingForm extends StatefulWidget {
  final Listing? listing; // null = create new, filled = edit existing

  const ListingForm({Key? key, this.listing}) : super(key: key);

  @override
  State<ListingForm> createState() => _ListingFormState();
}

class _ListingFormState extends State<ListingForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for each input field
  // Had to create separate controllers for EVERY field - no shortcuts! 
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  
  String? _selectedCategory;  // Dropdown value

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data (edit mode) or empty (create mode)
    // The ?? operator is a lifesaver here! Took me a while to figure this pattern out
    _nameController = TextEditingController(text: widget.listing?.name ?? '');
    _addressController = TextEditingController(text: widget.listing?.address ?? '');
    _contactController = TextEditingController(text: widget.listing?.contact ?? '');
    _descriptionController = TextEditingController(text: widget.listing?.description ?? '');
    
    // Convert coordinates to string for text fields (they're stored as doubles)
    _latitudeController = TextEditingController(
      text: widget.listing?.latitude.toString() ?? ''
    );
    _longitudeController = TextEditingController(
      text: widget.listing?.longitude.toString() ?? ''
    );
    
    // Set dropdown to existing category if editing
    _selectedCategory = widget.listing?.category;
  }

  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers to prevent memory leaks!
    // I forgot this once and the app got really slow after opening/closing forms multiple times
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    // Check if form is valid before proceeding
    if (!_formKey.currentState!.validate()) {
      return;  // Stop here in case the validation fails
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);

   //Parsing the coordinates from text fields

  final latitude = double.parse(_latitudeController.text.trim());
  final longitude = double.parse(_longitudeController.text.trim());
    // Build listing object from form data
    // I Have to be careful with the ID - empty string for new, existing ID for edit
  final newListing = Listing(
    id: widget.listing?.id ?? '',
    name: _nameController.text.trim(),
    category: _selectedCategory!, // validated as not null
    address: _addressController.text.trim(),
    contact: _contactController.text.trim(),
    description: _descriptionController.text.trim(),
    latitude: latitude,
    longitude: longitude,
    createdBy: authProvider.user!.uid,
    createdAt: widget.listing?.createdAt ?? DateTime.now(),  
);

    bool success;
    
    // Different logic for UPDATE vs CREATE
    // Took me a bit to realize I needed to check widget.listing != null
    if (widget.listing != null) {
      // EDIT MODE: Update existing listing
      success = await listingProvider.updateListing(widget.listing!.id, newListing);
    } else {
      // CREATE MODE: Create new listing
      success = await listingProvider.createListing(newListing);
    }

    // Show feedback to user
    if (mounted) {  // Check widget is still in tree before showing snackbar
      if (success) {
        // Success! Close form and show success message
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.listing != null 
                  ? 'Listing updated successfully! 🎉' 
                  : 'Listing created successfully! 🎉'
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,  // Looks nicer than default
          ),
        );
      } else {
        // Failed - show error but keep form open so they can try again
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(listingProvider.error ?? 'Failed to save listing 😞'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.listing != null ? 'Edit Listing' : 'Add New Listing',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Java House Kimihurura',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: Categories.all.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  hintText: 'e.g., KN 4 Ave, Kigali',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Contact Field
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact (Optional)',
                  hintText: 'e.g., +250788123456',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Tell us more about this place...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // === COORDINATES SECTION ===
              // Getting coordinates was confusing at first!
              // You have to long-press on Google Maps to get them
              Text(
                'Location Coordinates',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Two fields side by side for lat/long
              // Using Row with Expanded to split space evenly
              Row(
                children: [
                  // Latitude Field (North/South position)
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,  // Allow decimal points
                        signed: true,   // Allow negative numbers (for southern hemisphere)
                      ),
                      decoration: InputDecoration(
                        labelText: 'Latitude *',
                        hintText: '-1.9536',  // Example Kigali latitude
                        prefixIcon: const Icon(Icons.my_location),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        // Make sure it's actually a number
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Longitude Field (East/West position)
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Longitude *',
                        hintText: '30.0606',  // Example Kigali longitude
                        prefixIcon: const Icon(Icons.explore),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Help box explaining how to get coordinates
              // Added this because people kept asking me how to find coordinates! 😅
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Long-press on Google Maps to get coordinates',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: listingProvider.isLoading ? null : _saveListing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: listingProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.listing != null ? 'Update Listing' : 'Create Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}