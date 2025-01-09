import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:passenger_managing_app/models/driver.dart';
import 'package:passenger_managing_app/models/flight.dart';
import 'package:passenger_managing_app/models/page_state.dart';
import 'package:passenger_managing_app/models/passenger_data.dart';
import 'package:passenger_managing_app/services/bus_service.dart';
import 'package:passenger_managing_app/services/driver_service.dart';
import 'package:passenger_managing_app/services/flight_service.dart';
import 'package:passenger_managing_app/services/messenger_service.dart';
import 'package:passenger_managing_app/utils/sorting_utils.dart';
import 'package:passenger_managing_app/widgets/app_drawer.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  _ModernHomeScreenState createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  List<PageState> pages = [];
  // List to store page states
  int currentPageIndex = 0;
  String copiedData = "";

  final BusService _busService = BusService();
  late final DriverService _driverService;
  final FlightService _flightService = FlightService();

  List<Driver> _drivers = [];
  List<Flight> _flights = [];
  // Replace _driverOptions with this
  bool _isLoadingDrivers = false;

  Future<void> _loadDriversAndFlights() async {
    setState(() => _isLoadingDrivers = true);

    try {
      final fetchedDrivers = await _driverService.getAllDrivers();

      fetchedDrivers
          .sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));
      setState(() {
        _drivers = fetchedDrivers;
        _isLoadingDrivers = false;
      });

      final fetchedFlights = await _flightService.getAllFlights();
      setState(() {
        _flights = fetchedFlights;
      });
    } catch (e) {
      setState(() => _isLoadingDrivers = false);
    }
  }

  List<String> _tempSelectedTransferOptions = [];

  @override
  void initState() {
    super.initState();
    _driverService = DriverService(_busService);
    _loadDriversAndFlights();
    pages.add(PageState());
    pages[0].passengerController.addListener(() => _updateOnlinePassengers(0));
  }

  void _addNewPage() {
    setState(() {
      pages.add(PageState());
      currentPageIndex = pages.length - 1;
      pages[currentPageIndex].passengerController.addListener(
            () => _updateOnlinePassengers(currentPageIndex),
          );
    });
  }

  void _navigateToPage(int index) {
    if (index >= 0 && index < pages.length) {
      setState(() {
        currentPageIndex = index;
      });
    }
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

    // Validate all pages before showing dialog
    for (var i = 0; i < pages.length; i++) {
      PageState page = pages[i];
      String errorMessage = '';

      if (page.passengerController.text.isEmpty ||
          int.parse(page.passengerController.text) == 0) {
        errorMessage += 'გვერდი ${i + 1}: მგზავრების რაოდენობა სავალდებულოა\n';
      }

      if (page.selectedTransferOptions.isEmpty) {
        errorMessage += 'გვერდი ${i + 1}: გთხოვთ აირჩიოთ რეისი\n';
      }

      if (page.selectedSingleOption.isEmpty) {
        errorMessage += 'გვერდი ${i + 1}: გთხოვთ აირჩიოთ ავტობუსი\n';
      }

      if (page.showFreePessangers) {
        if (page.freePassengersController.text.isEmpty ||
            int.parse(page.freePassengersController.text) == 0) {
          errorMessage +=
              'გვერდი ${i + 1}: უფასო მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
        }
      }

      if (page.showOnTheWay) {
        if (page.onTheWayController.text.isEmpty ||
            int.parse(page.onTheWayController.text) == 0) {
          errorMessage +=
              'გვერდი ${i + 1}: გზაში მყოფი მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
        }
      }

      if (errorMessage.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                          'შეცდომა',
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(errorMessage),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
        return;
      }
    }

    // If validation passes, collect data from all pages
    final String allPagesData = pages
        .asMap()
        .entries
        .map((entry) => entry.value.toPassengerData().toFormattedString())
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
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // This will push buttons to edges
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

  Future<void> _showConfirmDropdown(BuildContext context) async {
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

    PageState page = pages[currentPageIndex];
    _tempSelectedTransferOptions = List.from(page.selectedTransferOptions);

    final List<String> uniqueOptions =
        _flights.map((flight) => flight.name).toSet().toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
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
                            'აირჩიეთ რეისი',
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

                    // Flight List
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: uniqueOptions.map((String value) {
                            final isSelected =
                                _tempSelectedTransferOptions.contains(value);
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  if (isSelected) {
                                    _tempSelectedTransferOptions.remove(value);
                                  } else {
                                    _tempSelectedTransferOptions.add(value);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue[700]!
                                              : Colors.grey[400]!,
                                        ),
                                        color: isSelected
                                            ? Colors.blue[700]
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[800],
                                          fontWeight: isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
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

                    // Actions
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'გაუქმება',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  page.selectedTransferOptions =
                                      List.from(_tempSelectedTransferOptions);
                                });
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
                                'არჩევა',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
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

  Widget _buildTopBar() {
    return Builder(
        // Add this Builder widget
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              onTap: () => _showConfirmDropdown(context),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.green,
              onPressed: currentPageIndex > 0
                  ? () => _navigateToPage(currentPageIndex - 1)
                  : null,
            ),
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
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              color: Colors.green,
              onPressed: currentPageIndex < pages.length - 1
                  ? () => _navigateToPage(currentPageIndex + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const AppDrawer(),
      body: Builder(
        // Add this Builder widget
        builder: (BuildContext context) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTopBar(),
                _buildDateTimeSection(),
                _buildSelectionSection(),
                _buildPassengerCounters(),
                _buildBottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}