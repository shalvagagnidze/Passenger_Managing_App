import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:passenger_managing_app/models/page_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier extends ChangeNotifier {
  List<PageState> pages = [];
  int currentPageIndex = 0;
  
  // Save state whenever it changes
  void updatePages(List<PageState> newPages) {
    pages = newPages;
    _saveState();
    notifyListeners();
  }

  void updateCurrentPageIndex(int index) {
    currentPageIndex = index;
    _saveState();
    notifyListeners();
  }

  // Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final pagesData = pages.map((page) => page.toJson()).toList();
    await prefs.setString('pages_data', jsonEncode(pagesData));
    await prefs.setInt('current_page_index', currentPageIndex);
  }

  // Load state from SharedPreferencesz
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final pagesDataString = prefs.getString('pages_data');
    final savedCurrentPageIndex = prefs.getInt('current_page_index');

    if (pagesDataString != null) {
      final pagesData = jsonDecode(pagesDataString) as List;
      pages = pagesData.map((pageData) => PageState.fromJson(pageData)).toList();
      currentPageIndex = savedCurrentPageIndex ?? 0;
      notifyListeners();
    } else {
      // Initialize with default state if no saved state exists
      pages = [PageState()];
      currentPageIndex = 0;
      notifyListeners();
    }
  }

  // Clear state (useful for testing or reset functionality)
  Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pages_data');
    await prefs.remove('current_page_index');
    pages = [PageState()];
    currentPageIndex = 0;
    notifyListeners();
  }
}
