import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:passenger_managing_app/models/driver.dart';
import 'package:passenger_managing_app/models/page_state.dart';
import 'package:passenger_managing_app/models/passenger_data.dart';
import 'package:passenger_managing_app/services/bus_service.dart';
import 'package:passenger_managing_app/services/driver_service.dart';
import 'package:passenger_managing_app/services/messenger_service.dart';
import 'package:passenger_managing_app/services/time_table_service.dart';
import 'package:passenger_managing_app/utils/screen_state_manager.dart';
import 'package:passenger_managing_app/utils/sorting_utils.dart';
import 'package:passenger_managing_app/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModernHomeScreen extends StatefulWidget {
  final List<PageState> initialPages;
  const ModernHomeScreen({super.key, required this.initialPages});

  @override
  _ModernHomeScreenState createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with WidgetsBindingObserver {
  late List<PageState> pages;
  late PageController _pageController;
  int currentPageIndex = 0;
  // final PageController _pageController = PageController();
  final ScreenStateManager _stateManager = ScreenStateManager();
  //List<PageState> get pages => _stateManager.pages;
  //set pages(List<PageState> value) => _stateManager.pages = value;
  // //List<PageState> pages = [];
  // // List to store page states
  // //int currentPageIndex = 0;
  // int get currentPageIndex => _stateManager.currentPageIndex;
  // set currentPageIndex(int value) => _stateManager.currentPageIndex = value;
  // String copiedData = "";

  final BusService _busService = BusService();
  late final DriverService _driverService;
  // // final FlightService _flightService = FlightService();

  List<Driver> _drivers = [];
  // // Replace _driverOptions with this
  bool _isLoadingDrivers = false;
  bool _isInitialized = false;
  // Future<void> _loadDriversAndFlights() async {
  //   if (!mounted) return;

  //   setState(() => _isLoadingDrivers = true);

  //   try {
  //     // Fetch and sort drivers
  //     final fetchedDrivers = await _driverService.getAllDrivers();
  //     fetchedDrivers
  //         .sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));

  //     // Fetch and sort flights
  //     // final fetchedFlights = await _flightService.getAllFlights();
  //     // fetchedFlights.sort(
  //     //     (a, b) => a.name.compareTo(b.name)); // Sort flights alphabetically

  //     if (!mounted) return;

  //     setState(() {
  //       _drivers = fetchedDrivers;
  //       _isLoadingDrivers = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() => _isLoadingDrivers = false);
  //   }
  // }

  final TimeTableService _timeTableService = TimeTableService();

  // //final List<NightFlight> _nightFlights = [];

  // Future<void> _loadNightFlights() async {
  //   try {
  //     final nightFlights = await _timeTableService.getNightFlights();
  //     if (!mounted) return;

  //     setState(() {
  //       _stateManager.nightFlights = nightFlights;

  //       // Only create new pages if there are no existing pages
  //       if (pages.isEmpty) {
  //         // Create a new page for each night flight
  //         for (var flight in nightFlights) {
  //           final newPage = PageState()
  //             ..selectedDate = flight.date
  //             ..selectedTime = TimeOfDay.fromDateTime(flight.departureTime)
  //             ..selectedTransferOptions = flight.destinations;

  //           pages.add(newPage);

  //           // Set up listener for passenger count
  //           newPage.passengerController
  //               .addListener(() => _updateOnlinePassengers(pages.length - 1));
  //         }

  //         if (pages.isEmpty) {
  //           // Add at least one default page if no night flights found
  //           pages.add(PageState());
  //           pages[0]
  //               .passengerController
  //               .addListener(() => _updateOnlinePassengers(0));
  //         }
  //         _saveState();
  //       }
  //     });
  //     // setState(() {
  //     //   // _nightFlights = nightFlights;
  //     //   _stateManager.nightFlights = nightFlights;
  //     //   // Clear existing pages
  //     //   pages.clear();
  //     //   currentPageIndex = 0;

  //     //   // Create a new page for each night flight
  //     //   for (var flight in nightFlights) {
  //     //     final newPage = PageState()
  //     //       ..selectedDate = flight.date
  //     //       ..selectedTime = TimeOfDay.fromDateTime(flight.departureTime)
  //     //       ..selectedTransferOptions = flight.destinations;

  //     //     pages.add(newPage);

  //     //     // Set up listener for passenger count
  //     //     newPage.passengerController
  //     //         .addListener(() => _updateOnlinePassengers(pages.length - 1));
  //     //   }

  //     //   if (pages.isEmpty) {
  //     //     // Add at least one default page if no night flights found
  //     //     pages.add(PageState());
  //     //     pages[0]
  //     //         .passengerController
  //     //         .addListener(() => _updateOnlinePassengers(0));
  //     //   }
  //     //   _saveState();
  //     // });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error loading flights: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _driverService = DriverService(_busService);

  //   if (!_stateManager.isInitialized) {
  //     // First time initialization
  //     _loadNightFlights();
  //     _loadDriversAndFlights();
  //     _stateManager.isInitialized = true;

  //     // Add initial page if needed
  //     if (pages.isEmpty) {
  //       pages.add(PageState());
  //       pages[0]
  //           .passengerController
  //           .addListener(() => _updateOnlinePassengers(0));
  //     }
  //   } else {
  //     // Just restore existing state
  //     _loadDriversAndFlights(); // Refresh drivers list only
  //     Future.microtask(() {
  //       _pageController.jumpToPage(currentPageIndex);
  //     });
  //   }

  //   // Set up page controller listener
  //   _pageController.addListener(() {
  //     final newPage = _pageController.page?.round() ?? 0;
  //     if (newPage != currentPageIndex) {
  //       setState(() {
  //         currentPageIndex = newPage;
  //       });
  //     }
  //   });
  // }

//  Future<void> _setupPlatformState() async {
//     try {
//       // This will call native platform code to set up any required configurations
//       await platform.invokeMethod('setupAppState');
//     } on PlatformException catch (e) {
//       print('Error setting up platform state: $e');
//     }
//   }
  @override
  void initState() {
    super.initState();
    pages = widget.initialPages;
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    _driverService = DriverService(_busService);
    //_setupPlatformState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;

          _loadInitialData();
        });
      }
    });

    // Future.delayed(Duration.zero, () {
    //   if (mounted) {
    //     setState(() {
    //       for (var page in pages) {
    //         page.recreateControllers();
    //         page.passengerController.addListener(
    //             () => _updateOnlinePassengers(pages.indexOf(page)));
    //       }
    //       _isInitialized = true;
    //     });
    //   }
    // });
    for (var page in pages) {
      page.passengerController
          .addListener(() => _updateOnlinePassengers(pages.indexOf(page)));
    }
    // Only load drivers when we have saved pages
    // _loadDriversOnly();
    //_loadInitialData();

    // Set up controller listener for first page
    if (pages.isNotEmpty) {
      pages[0]
          .passengerController
          .addListener(() => _updateOnlinePassengers(0));
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() => _isLoadingDrivers = true);

    try {
      // Load night flights and drivers in parallel
      await Future.wait([
        _loadNightFlights(),
        _loadDriversAndFlights(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDrivers = false;
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadNightFlights() async {
  try {
    final nightFlights = await _timeTableService.getNightFlights();
    if (!mounted) return;

    setState(() {
      _stateManager.nightFlights = nightFlights;
      
      // Check if we have night flights to process
      if (nightFlights.isNotEmpty) {
        // Check if pages should be recreated 
        // (either we have no pages or existing pages don't match flight data)
        bool shouldCreatePages = pages.isEmpty;
        
        // If we already have pages, check if they match our flight data
        if (!shouldCreatePages && pages.length != nightFlights.length) {
          shouldCreatePages = true;
        }
        
        // Only recreate pages if needed
        if (shouldCreatePages) {
          // Dispose existing pages first
          for (var page in pages) {
            page.dispose();
          }
          
          // Clear existing pages
          pages.clear();
          
          // Create new pages from night flights
          for (var flight in nightFlights) {
            final newPage = PageState()
              ..selectedDate = flight.date
              ..selectedTime = TimeOfDay.fromDateTime(flight.departureTime)
              ..selectedTransferOptions = flight.destinations;

            pages.add(newPage);
            newPage.passengerController
                .addListener(() => _updateOnlinePassengers(pages.length - 1));
          }
          
          // Reset current page index
          currentPageIndex = 0;
          
          // Ensure we have at least one page
          if (pages.isEmpty) {
            pages.add(PageState());
            pages[0]
                .passengerController
                .addListener(() => _updateOnlinePassengers(0));
          }
          
          // Save the updated state
          _saveState();
        }
      } else if (pages.isEmpty) {
        // No night flights but also no pages - create at least one default page
        pages.add(PageState());
        pages[0]
            .passengerController
            .addListener(() => _updateOnlinePassengers(0));
        _saveState();
      }
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading flights: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _loadDriversAndFlights() async {
    if (!mounted) return; // Add check at the beginning

    try {
      setState(() {
        _isLoadingDrivers = true; // Set loading state at start
      });

      final fetchedDrivers = await _driverService.getAllDrivers();
      fetchedDrivers
          .sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));

      if (!mounted) return;

      setState(() {
        _drivers = fetchedDrivers;
        _isLoadingDrivers = false; // Reset loading state on success
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDrivers = false; // Reset loading state on error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading drivers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  @override
  void dispose() {
    for (var page in pages) {
    page.passengerController.removeListener(() => 
      _updateOnlinePassengers(pages.indexOf(page)));
    page.dispose();
  }
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save state on any lifecycle change that might lead to app termination
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveState();
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pagesData = pages.map((page) => page.toJson()).toList();
      final encodedData = jsonEncode(pagesData);

      // Save current state
      await prefs.setString('temp_pages_data', encodedData);

      // Also save a backup
      await prefs.setString('backup_pages_data', encodedData);

      // Save timestamp of last save
      await prefs.setInt(
          'last_save_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      rethrow;
    }
  }

  void _addNewPage() {
    setState(() {
      pages.add(PageState());
      currentPageIndex = pages.length - 1;
      pages[currentPageIndex].passengerController.addListener(
            () => _updateOnlinePassengers(currentPageIndex),
          );
      _saveState();
      _pageController.animateToPage(
        currentPageIndex,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    });
  }

  double _calculateTotalCashAmount() {
    double totalAmount = 0;
    for (var page in pages) {
      // Use the existing toPassengerData method to get the cash amount
      PassengerData pageData = page.toPassengerData();
      totalAmount += pageData.totalCashAmount;
    }
    return totalAmount;
  }

  void _updateCount(String type, bool increment) {
    setState(() {
      PageState page = pages[currentPageIndex];
      switch (type) {
        case 'cash':
          if (increment && page.cashPassengerCount < 99) {
            page.cashPassengerCount++;
          } else if (!increment &&
              page.cashPassengerCount > page.cashChildPassengerCount) {
            page.cashPassengerCount--;
          }
          break;
        case 'card':
          if (increment && page.cardPassengerCount < 99) {
            page.cardPassengerCount++;
          } else if (!increment &&
              page.cardPassengerCount > page.cardChildPassengerCount) {
            page.cardPassengerCount--;
          }
          break;
        case 'wizz':
          if (increment && page.wizzPassengerCount < 99) {
            page.wizzPassengerCount++;
          } else if (!increment && page.wizzPassengerCount > 0) {
            page.wizzPassengerCount--;
          }
          break;
      }
      _updateOnlinePassengers(currentPageIndex);
    });
  }

  void _updateOnlinePassengers(int pageIndex) {
    setState(() {
      PageState page = pages[pageIndex];
      page.passengerCount = int.tryParse(page.passengerController.text) ?? 0;

      final freePassengers =
          int.tryParse(page.freePassengersController.text) ?? 0;

      page.onlinePassengerCount = page.passengerCount -
          (page.cashPassengerCount +
              page.cardPassengerCount +
              page.wizzPassengerCount +
              freePassengers);
      if (page.onlinePassengerCount < 0) page.onlinePassengerCount = 0;

      _saveState();
    });
  }

  void _updateChildCount(String type, bool increment) {
    setState(() {
      PageState page = pages[currentPageIndex];
      switch (type) {
        case 'cash':
          if (increment) {
            if (page.cashChildPassengerCount < 99) {
              page.cashChildPassengerCount++;
              page.cashPassengerCount++;
            }
          } else {
            if (page.cashChildPassengerCount > 0) {
              page.cashChildPassengerCount--;
              page.cashPassengerCount--;
            }
          }
          break;
        case 'card':
          if (increment) {
            if (page.cardChildPassengerCount < 99) {
              page.cardChildPassengerCount++;
              page.cardPassengerCount++;
            }
          } else {
            if (page.cardChildPassengerCount > 0) {
              page.cardChildPassengerCount--;
              page.cardPassengerCount--;
            }
          }
          break;
      }
      _updateOnlinePassengers(currentPageIndex);
    });
  }

  void _updateOnTheWayCash(bool increment) {
    setState(() {
      PageState page = pages[currentPageIndex];
      if (increment && page.onTheWayCashCount < 99) {
        page.onTheWayCashCount++;
      } else if (!increment && page.onTheWayCashCount > 0) {
        page.onTheWayCashCount--;
      }
    });
  }

  void _showCustomDialog(BuildContext context) {
    PageState page = pages[currentPageIndex];
    if (!_validateData()) {
      return;
    }

    double standartRate = 25.0;
    double childRate = 15.0;

    double totalCashAmount =
        (page.cashPassengerCount - page.cashChildPassengerCount) *
                standartRate +
            page.cashChildPassengerCount * childRate;

    double totalCardAmount =
        (page.cardPassengerCount - page.cardChildPassengerCount) *
                standartRate +
            page.cardChildPassengerCount * childRate;

    final data = PassengerData(
      date: page.selectedDate,
      hours: DateTime(
        page.selectedDate.year,
        page.selectedDate.month,
        page.selectedDate.day,
        page.selectedTime.hour,
        page.selectedTime.minute,
      ),
      route: page.selectedTransferOptions,
      bus: '${page.selectedDriverName} ${page.selectedSingleOption}',
      totalPassengers: int.tryParse(page.passengerController.text) ?? 0,
      onlinePassengers: page.onlinePassengerCount,
      cashPassengers: page.cashPassengerCount,
      cashChild: page.cashChildPassengerCount,
      cardPassengers: page.cardPassengerCount,
      cardChild: page.cardChildPassengerCount,
      wizzAirPassengers: page.wizzPassengerCount,
      freePassengers: int.tryParse(page.freePassengersController.text) ?? 0,
      onTheWayPassengers: int.tryParse(page.onTheWayController.text) ?? 0,
      onTheWayCash: page.onTheWayCashCount,
      totalCashAmount: totalCashAmount,
      totalCardAmount: totalCardAmount,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String formattedData = data.toFormattedString();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'რეპორტი',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    formattedData,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Actions
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'დახურვა',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: formattedData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('მონაცემები დაკოპირდა'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'კოპირება',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllPagesDialog(BuildContext context) {
    if (pages.isEmpty) return;

    // Filter out pages without passengers
    final validPages = pages
        .where((page) =>
            page.passengerController.text.isNotEmpty &&
            int.parse(page.passengerController.text) > 0)
        .toList();

    if (validPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('არ არის შევსებული არცერთი გვერდი'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check for pages missing bus driver selection
    final missingDriverPages =
        validPages.where((page) => page.selectedSingleOption.isEmpty).toList();

    // Build the complete string including warning if necessary
    String allPagesData = '';
    if (missingDriverPages.isNotEmpty) {
      allPagesData = 'გთხოვთ აირჩიოთ ავტობუსი შემდეგ გვერდებზე:\n';
      for (int i = 0; i < pages.length; i++) {
        if (missingDriverPages.contains(pages[i])) {
          allPagesData += 'გვერდი ${i + 1}\n';
        }
      }
      allPagesData += '\n';
    }

    // Add the regular data
    allPagesData += validPages
        .map((page) => page.toPassengerData().toFormattedString())
        .join('\n\n');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'სრული რეპორტი',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              if (missingDriverPages.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ზოგიერთ გვერდზე არ არის არჩეული ავტობუსი',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    allPagesData,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Actions
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          final success =
                              await MessengerService.shareToMessenger(
                                  allPagesData);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Messenger არ არის ხელმისაწვდომი'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('გაგზავნის შეცდომა'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.messenger_outline,
                            size: 18,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Messenger',
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: allPagesData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('მონაცემები დაკოპირდა'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'კოპირება',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFlightSelectionDialog(BuildContext context) async {
    if (_stateManager.nightFlights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No flights available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    PageState page = pages[currentPageIndex];
    List<String> tempSelectedFlights = List.from(page.selectedTransferOptions);

    // Create a list of all unique destinations
    Set<String> uniqueDestinations = {};
    for (var flight in _stateManager.nightFlights) {
      for (var destination in flight.destinations) {
        // Split destinations if they contain commas
        destination.split(',').forEach((dest) {
          uniqueDestinations.add(dest.trim());
        });
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'აირჩიეთ რეისი',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: uniqueDestinations.map((destination) {
                            bool isSelected =
                                tempSelectedFlights.contains(destination);
                            return ListTile(
                              title: Text(destination),
                              leading: Icon(
                                Icons.flight_takeoff,
                                color: Colors.blue[700],
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value ?? false) {
                                      if (!tempSelectedFlights
                                          .contains(destination)) {
                                        tempSelectedFlights.add(destination);
                                      }
                                    } else {
                                      tempSelectedFlights.remove(destination);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'გაუქმება',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              this.setState(() {
                                page.selectedTransferOptions =
                                    tempSelectedFlights;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'არჩევა',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSingleSelectDropdown(BuildContext context) async {
    if (_isLoadingDrivers) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Colors.blue[700],
              ),
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'აირჩიეთ მძღოლი',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Drivers List
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _drivers.map((driver) {
                        final isSelected =
                            pages[currentPageIndex].selectedSingleOption ==
                                driver.busNumber;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              pages[currentPageIndex].selectedSingleOption =
                                  driver.busNumber;
                              pages[currentPageIndex].selectedDriverName =
                                  driver.fullName;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Bus Icon and Number
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.directions_bus,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Driver Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driver.busNumber,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        driver.fullName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selection Indicator
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _validateData() {
    PageState page = pages[currentPageIndex];
    String errorMessage = '';

    if (page.passengerController.text.isEmpty ||
        int.parse(page.passengerController.text) == 0) {
      errorMessage += 'მგზავრების რაოდენობა სავალდებულოა\n';
    }

    if (page.selectedTransferOptions.isEmpty) {
      errorMessage += 'გთხოვთ აირჩიოთ რეისი\n';
    }

    if (page.selectedSingleOption.isEmpty) {
      errorMessage += 'გთხოვთ აირჩიოთ ავტობუსი\n';
    }

    if (page.showFreePessangers) {
      if (page.freePassengersController.text.isEmpty ||
          int.parse(page.freePassengersController.text) == 0) {
        errorMessage += 'უფასო მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
      }
    }

    if (page.showOnTheWay) {
      if (page.onTheWayController.text.isEmpty ||
          int.parse(page.onTheWayController.text) == 0) {
        errorMessage += 'გზაში მყოფი მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
      }
    }

    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('შეცდომა'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    }

    return true;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[700],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'გვერდის წაშლა',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'დარწმუნებული ხარ რომ გსურს წაშლა?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'გაუქმება',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (pages.length > 1) {
                          setState(() {
                            pages.removeAt(currentPageIndex);
                            if (currentPageIndex >= pages.length) {
                              currentPageIndex = pages.length - 1;
                            }
                          });
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("ბოლო გვერდს ვერ წაშლი!"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_outline, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'წაშლა',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showResetConfirmation() async {
    bool shouldReset = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.orange[700],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'გასუფთავება',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'დარწმუნებული ხარ რომ გსურს გვერდის გასუფთავება?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        shouldReset = false;
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'გაუქმება',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        shouldReset = true;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'დიახ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return shouldReset;
  }

  void _resetPage(int pageIndex) {
    setState(() {
      PageState currentPage = pages[pageIndex];
      currentPage.selectedDate = DateTime.now();
      currentPage.selectedTime = TimeOfDay.now();

      currentPage.resetControllers();

      currentPage.passengerController.clear();
      currentPage.onTheWayController.clear();
      currentPage.freePassengersController.clear();
      currentPage.passengerCount = 0;
      currentPage.onlinePassengerCount = 0;
      currentPage.cashPassengerCount = 0;
      currentPage.cardPassengerCount = 0;
      currentPage.wizzPassengerCount = 0;
      currentPage.showCashChildCounter = false;
      currentPage.showCardChildCounter = false;
      currentPage.cashChildPassengerCount = 0;
      currentPage.cardChildPassengerCount = 0;
      currentPage.showOnTheWay = false;
      currentPage.onTheWayCashCount = 0;
      currentPage.showFreePessangers = false;
      currentPage.freePassengersCount = 0;
      currentPage.selectedTransferOptions = [];
      currentPage.selectedSingleOption = '';
      currentPage.selectedDriverName = '';
    });
  }

  Widget _buildTopBar() {
    double totalCashAmount = _calculateTotalCashAmount();

    return Builder(
        builder: (BuildContext context) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    color: Colors.blue[700],
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showDeleteConfirmation,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red[700]),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.file_copy_outlined,
                                size: 18, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Text(
                              '${currentPageIndex + 1}/${pages.length}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money,
                                size: 18, color: Colors.green[700]),
                            const SizedBox(width: 1),
                            Text(
                              '${totalCashAmount.toStringAsFixed(2)} ₾',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_all),
                    color: Colors.purple[700],
                    onPressed: () => _showAllPagesDialog(context),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      color: Colors.green[700],
                      onPressed: _addNewPage,
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildDateTimeSection() {
    PageState currentPage = pages[currentPageIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentPage.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() => currentPage.selectedDate = pickedDate);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MM/dd/yyyy').format(currentPage.selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: currentPage.selectedTime,
                );
                if (pickedTime != null) {
                  setState(() => currentPage.selectedTime = pickedTime);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      '${currentPage.selectedTime.hour.toString().padLeft(2, '0')}:${currentPage.selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSection() {
    PageState currentPage = pages[currentPageIndex];

    return Column(
      children: [
        // Flight Selection
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showFlightSelectionDialog(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.flight_takeoff,
                        size: 24, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentPage.selectedTransferOptions.isEmpty
                            ? 'რეისი'
                            : currentPage.selectedTransferOptions.join(', '),
                        style: TextStyle(
                          fontSize: 16,
                          color: currentPage.selectedTransferOptions.isEmpty
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bus Selection
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showSingleSelectDropdown(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus,
                        size: 24, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentPage.selectedSingleOption.isEmpty
                            ? 'ავტობუსი'
                            : '${currentPage.selectedDriverName} ${currentPage.selectedSingleOption}',
                        style: TextStyle(
                          fontSize: 16,
                          color: currentPage.selectedSingleOption.isEmpty
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCounters() {
    PageState currentPage = pages[currentPageIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Passengers
          _buildCounterField(
            icon: Icons.people,
            label: 'მგზავრები',
            controller: currentPage.passengerController,
            iconColor: Colors.orangeAccent,
          ),
          const Divider(height: 1),

          // Online Passengers
          _buildStaticCounter(
            icon: Icons.computer,
            label: 'ონლაინი',
            value: currentPage.onlinePassengerCount.toString(),
            iconColor: Colors.teal,
          ),
          const Divider(height: 1),

          // Cash Passengers
          _buildIncrementCounter(
            icon: Icons.money_rounded,
            label: 'ქეში',
            value: currentPage.cashPassengerCount,
            iconColor: Colors.green,
            onIncrement: () => _updateCount('cash', true),
            onDecrement: () => _updateCount('cash', false),
          ),

          // Cash Child Checkbox
          _buildChildCounterWithCheckbox(
            icon: Icons.child_care,
            label: 'ბავშვი',
            checkboxValue: currentPage.showCashChildCounter,
            onCheckboxChanged: (value) {
              setState(() {
                currentPage.showCashChildCounter = value ?? false;
                if (!currentPage.showCashChildCounter) {
                  currentPage.cashPassengerCount -=
                      currentPage.cashChildPassengerCount;
                  currentPage.cashChildPassengerCount = 0;
                  _updateOnlinePassengers(currentPageIndex);
                }
              });
            },
            value: currentPage.cashChildPassengerCount,
            onIncrement: () => _updateChildCount('cash', true),
            onDecrement: () => _updateChildCount('cash', false),
            showCounter: currentPage.showCashChildCounter,
            iconColor: Colors.blue,
          ),
          const Divider(height: 1),

          // Card Passengers
          _buildIncrementCounter(
            icon: Icons.credit_card,
            label: 'ბარათი',
            value: currentPage.cardPassengerCount,
            iconColor: Colors.red,
            onIncrement: () => _updateCount('card', true),
            onDecrement: () => _updateCount('card', false),
          ),

          // Card Child Checkbox
          _buildChildCounterWithCheckbox(
            icon: Icons.child_care,
            label: 'ბავშვი',
            checkboxValue: currentPage.showCardChildCounter,
            onCheckboxChanged: (value) {
              setState(() {
                currentPage.showCardChildCounter = value ?? false;
                if (!currentPage.showCardChildCounter) {
                  currentPage.cardPassengerCount -=
                      currentPage.cardChildPassengerCount;
                  currentPage.cardChildPassengerCount = 0;
                  _updateOnlinePassengers(currentPageIndex);
                }
              });
            },
            value: currentPage.cardChildPassengerCount,
            onIncrement: () => _updateChildCount('card', true),
            onDecrement: () => _updateChildCount('card', false),
            showCounter: currentPage.showCardChildCounter,
            iconColor: Colors.blue,
          ),
          const Divider(height: 1),

          // WizzAir Passengers
          _buildIncrementCounter(
            icon: Icons.flight,
            label: 'Wizz Air',
            value: currentPage.wizzPassengerCount,
            iconColor: Colors.purple,
            onIncrement: () => _updateCount('wizz', true),
            onDecrement: () => _updateCount('wizz', false),
          ),
          const Divider(height: 1),

          // Free Passengers Option
          _buildCheckboxWithCounter(
            icon: Icons.money_off,
            label: 'უფასო',
            checkboxValue: currentPage.showFreePessangers,
            onCheckboxChanged: (value) {
              setState(() {
                currentPage.showFreePessangers = value ?? false;
                if (!currentPage.showFreePessangers) {
                  // Get current free passengers count before clearing
                  final previousFreeCount =
                      int.tryParse(currentPage.freePassengersController.text) ??
                          0;

                  // Clear the counter
                  currentPage.freePassengersCount = 0;
                  currentPage.freePassengersController.clear();

                  currentPage.onlinePassengerCount += previousFreeCount;
                  // Update online passengers count by adding back the previous free count
                  _updateOnlinePassengers(currentPageIndex);
                }
              });
            },
            controller: currentPage.freePassengersController,
            showCounter: currentPage.showFreePessangers,
            iconColor: const Color.fromARGB(255, 0, 116, 60),
            onCounterChanged: (String value) {
              // Update the online passengers whenever free passengers value changes
              setState(() {
                _updateOnlinePassengers(currentPageIndex);
              });
            },
          ),
          // On The Way Option
          _buildCheckboxWithCounter(
            icon: Icons.transfer_within_a_station,
            label: 'გზაში',
            checkboxValue: currentPage.showOnTheWay,
            onCheckboxChanged: (value) {
              setState(() {
                currentPage.showOnTheWay = value ?? false;
                if (!currentPage.showOnTheWay) {
                  currentPage.onTheWayCashCount = 0;
                  currentPage.onTheWayController.clear();
                }
              });
            },
            controller: currentPage.onTheWayController,
            showCounter: currentPage.showOnTheWay,
            iconColor: Colors.blue,
          ),

          // On The Way Cash Counter
          if (currentPage.showOnTheWay)
            _buildIncrementCounter(
              icon: Icons.money_rounded,
              label: 'ქეში',
              value: currentPage.onTheWayCashCount,
              iconColor: Colors.green,
              onIncrement: () => _updateOnTheWayCash(true),
              onDecrement: () => _updateOnTheWayCash(false),
              isChild: true,
            ),
        ],
      ),
    );
  }

  Widget _buildStaticCounter({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementCounter({
    required IconData icon,
    required String label,
    required int value,
    required Color iconColor,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    bool isChild = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isChild ? 32 : 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: value > 0 ? onDecrement : null,
                  color: Colors.grey[700],
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  alignment: Alignment.center,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isChild ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: value < 99 ? onIncrement : null,
                  color: Colors.grey[700],
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxWithCounter({
    required IconData icon,
    required String label,
    required bool checkboxValue,
    required ValueChanged<bool?> onCheckboxChanged,
    required TextEditingController controller,
    required bool showCounter,
    required Color iconColor,
    ValueChanged<String>? onCounterChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Checkbox(
            value: checkboxValue,
            onChanged: onCheckboxChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (showCounter)
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: onCounterChanged, // Add this line
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                _updateOnlinePassengers(currentPageIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    double currentPageCashAmount =
        pages[currentPageIndex].toPassengerData().totalCashAmount;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
            onPressed: () => _showRefreshConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 8),
              ],
            ),
          ),
            // Total Cash Amount Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 20, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${currentPageCashAmount.toStringAsFixed(2)} ₾',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Copy Button
            ElevatedButton(
              onPressed: () => _showCustomDialog(context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('კოპირება'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.blue[700],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'გვერდების განახლება',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'გსურთ გვერდების განახლება და ახლიდან გენერაცია?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'გაუქმება',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _refreshPages();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'დიახ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _refreshPages() async {
  try {
    setState(() => _isLoadingDrivers = true);

    // Clear existing pages
    for (var page in pages) {
      page.dispose();
    }
    pages.clear();
    currentPageIndex = 0;

    // Load night flights and create new pages
    final nightFlights = await _timeTableService.getNightFlights();
    if (!mounted) return;

    setState(() {
      _stateManager.nightFlights = nightFlights;

      // Create new pages from night flights
      for (var flight in nightFlights) {
        final newPage = PageState()
          ..selectedDate = flight.date
          ..selectedTime = TimeOfDay.fromDateTime(flight.departureTime)
          ..selectedTransferOptions = flight.destinations;

        pages.add(newPage);
        newPage.passengerController
            .addListener(() => _updateOnlinePassengers(pages.length - 1));
      }

      // Add default page if no flights
      if (pages.isEmpty) {
        pages.add(PageState());
        pages[0].passengerController
            .addListener(() => _updateOnlinePassengers(0));
      }

      _isLoadingDrivers = false;
    });

    // Save the new state
    await _saveState();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('გვერდები წარმატებით განახლდა'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('შეცდომა განახლებისას: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  Widget _buildChildCounterWithCheckbox({
    required IconData icon,
    required String label,
    required bool checkboxValue,
    required ValueChanged<bool?> onCheckboxChanged,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool showCounter,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Checkbox(
            value: checkboxValue,
            onChanged: onCheckboxChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (showCounter)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: value > 0 ? onDecrement : null,
                    color: Colors.grey[700],
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 40),
                    alignment: Alignment.center,
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: value < 99 ? onIncrement : null,
                    color: Colors.grey[700],
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const AppDrawer(),
      body: Builder(
        builder: (BuildContext context) => SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        bool shouldReset = await _showResetConfirmation();
                        if (shouldReset) {
                          _resetPage(currentPageIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('გვერდი განახლდა'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildDateTimeSection(),
                            _buildSelectionSection(),
                            _buildPassengerCounters(),
                            _buildBottomNavigation(),
                            // Add extra space to ensure scrollability
                            //SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
