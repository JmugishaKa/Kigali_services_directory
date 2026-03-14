import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();
  
  List<Listing> _allListings = [];
  List<Listing> _myListings = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Listing> get allListings => _allListings;
  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered listings based on search and category
  List<Listing> get filteredListings {
    return _allListings.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.address.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          listing.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Update search query
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Update category filter
  void updateCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Listen to all listings
  void listenToListings() {
    _listingService.getAllListings().listen((listings) {
      _allListings = listings;
      notifyListeners();
    });
  }

  // Listen to user's listings
  void listenToMyListings(String uid) {
    _listingService.getMyListings(uid).listen((listings) {
      _myListings = listings;
      notifyListeners();
    });
  }

  // Create listing
  Future<bool> createListing(Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? error = await _listingService.createListing(listing);

    _isLoading = false;
    _error = error;
    notifyListeners();

    return error == null;
  }

  // Update listing
  Future<bool> updateListing(String id, Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? error = await _listingService.updateListing(id, listing);

    _isLoading = false;
    _error = error;
    notifyListeners();

    return error == null;
  }

  // Delete listing
  Future<bool> deleteListing(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? error = await _listingService.deleteListing(id);

    _isLoading = false;
    _error = error;
    notifyListeners();

    return error == null;
  }
}