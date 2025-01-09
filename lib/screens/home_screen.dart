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
import 'package:passenger_managing_app/utils/sorting_utils.dart';
import 'package:passenger_managing_app/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store page states
  List<PageState> pages = [];
  int currentPageIndex = 0;
  String copiedData = "";

  final BusService _busService = BusService();
  late final DriverService _driverService;
  final FlightService _flightService = FlightService();

  List<Driver> _drivers = [];
  List<Flight> _flights = [];
  // Replace _driverOptions with this
  bool _isLoadingDrivers = false;
  bool _isLoadingFlights = false;

  Future<void> _loadDriversAndFlights() async {
    setState(() => _isLoadingDrivers = true);

    try {
      final fetchedDrivers = await _driverService.getAllDrivers();

      fetchedDrivers.sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));
      setState(() {
        _drivers = fetchedDrivers;
        _isLoadingDrivers = false;
      });

      final fetchedFlights = await _flightService.getAllFlights();
      setState(() {
        _flights = fetchedFlights;
        _isLoadingFlights = false;
      });

    } catch (e) {
      setState(() => _isLoadingDrivers = false);
    }
  }

  Future<void> _loadFlights() async {
    setState(() => _isLoadingFlights = true);

    try {
      final fetchedFlights = await _flightService.getAllFlights();
      setState(() {
        _flights = fetchedFlights;
        _isLoadingFlights = false;
      });
    } catch (e) {
      setState(() => _isLoadingFlights = false);
    }
  }

  // final List<String> _transferOptions = [
  //   'ვენა',
  //   'ბარსელონა',
  //   'კატოვიცე',
  //   'პრაღა',
  //   'აბუ-დაბი',
  //   'ვილნიუსი',
  //   'ბუდაპეშტი',
  //   'მილანი',
  //   'პოზნანი',
  //   'ბერლინი',
  //   'ვარშავა',
  // ];

  // final List<String> _driverOptions = [
  //   'GB-101-US',
  //   'GB-900-US',
  //   'GB-303-US',
  //   'GB-055-US',
  // ];
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
      page.onlinePassengerCount = page.passengerCount -
          (page.cashPassengerCount +
              page.cardPassengerCount +
              page.wizzPassengerCount);
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
        return AlertDialog(
          title: const Text('რეპორტი'),
          content: SingleChildScrollView(
            child: Text(formattedData),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
              child: const Text('დახურვა'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: formattedData));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('მონაცემები დაკოპირდა')),
                );
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
              child: const Text('კოპირება'),
            ),
          ],
        );
      },
    );
  }

//   void telegram(BuildContext context) {
//   GestureDetector(
//     child: Text('Send message'),
//     onTap: () async {
//       try {
//         await openTelegram(
//           phone: '+995 (598) 111-770',
//           text: 'Initial text',
//         );
//       } on Exception catch (e) {
//         showDialog(
//           context: context,
//           builder: (context) => CupertinoAlertDialog(
//             title: const Text("Attention"),
//             content: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 'We did not find the «Telegram» application on your phone, please install it and try again',
//                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                       height: 1.1,
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                     ),
//               ),
//             ),
//             actions: [
//               CupertinoDialogAction(
//                 child: const Text('Close'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//         );
//       }
//     },
//   );
// }

  void _showAllPagesDialog(BuildContext context) {
    if (pages.isEmpty) return;

    // Collect formatted data from all pages
    final String allPagesData = pages
        .asMap()
        .entries
        .map((entry) => entry.value.toPassengerData().toFormattedString())
        .join('\n\n');

    // Show dialog with all pages data
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('რეპორტი'),
          content: SingleChildScrollView(
            child: Text(allPagesData),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
              child: const Text('დახურვა'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: allPagesData));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('მონაცემები დაკოპირდა')),
                );
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
              child: const Text('კოპირება'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDropdown(BuildContext context) async {
    if (_isLoadingDrivers) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: CircularProgressIndicator(),
        ),
      );
      return;
    }

    PageState page = pages[currentPageIndex];
    _tempSelectedTransferOptions = List.from(page.selectedTransferOptions);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    final List<String> uniqueOptions =
        _flights.map((flight) => flight.name).toSet().toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Select Options'),
              content: SizedBox(
                height: uniqueOptions.length > 10 ? 300 : null,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: uniqueOptions.map((String value) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Checkbox(
                            value: _tempSelectedTransferOptions.contains(value),
                            onChanged: (bool? checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  _tempSelectedTransferOptions.add(value);
                                } else {
                                  _tempSelectedTransferOptions.remove(value);
                                }
                              });
                            },
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                    });
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      page.selectedTransferOptions =
                          List.from(_tempSelectedTransferOptions);
                    });
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                    });
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSingleSelectDropdown(BuildContext context) async {
    if (_isLoadingDrivers) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => const AlertDialog(
          content: CircularProgressIndicator(),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _drivers.map((driver) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        pages[currentPageIndex].selectedSingleOption =
                            driver.busNumber.toString();
                        pages[currentPageIndex].selectedDriverName =
                            driver.fullName;
                      });
                      Navigator.of(context).pop();
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            driver.busNumber.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            driver.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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

  void _removePage(BuildContext context) {
    if (pages.length > 1) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("გვერდის წაშლა"),
            content: const Text("დარწმუნებული ხარ რომ გსურს წაშლა?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                  });
                },
                child: const Text("გაუქმება"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    pages.removeAt(currentPageIndex);

                    // Adjust the current page index to remain valid
                    if (currentPageIndex >= pages.length) {
                      currentPageIndex = pages.length - 1;
                    }
                  });

                  Navigator.of(dialogContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                  });
                },
                child: const Text("წაშლა"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ბოლო გვერდს ვერ წაშლი!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    PageState currentPage = pages[currentPageIndex];

    return Scaffold(
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context)
                .padding
                .top, // Dynamic padding for the top
          ),
          child: Column(
            children: [
              // Navigation Bar
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    // Left Edge: First Two Items
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 30,
                          color: Colors.red,
                          icon: const Icon(Icons.delete_rounded),
                          onPressed: () => _removePage(context),
                        ),
                        Text(
                          '${currentPageIndex + 1}/${pages.length}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const Spacer(), // Push items apart
                    // Right Edge: Last Two Items
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          color: Colors.purple,
                          icon: const Icon(Icons.copy),
                          onPressed: () => _showAllPagesDialog(context),
                        ),
                        IconButton(
                          iconSize: 30,
                          color: Colors.green,
                          icon: const Icon(Icons.post_add_rounded),
                          onPressed: _addNewPage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // First Row for Date and Time Picker
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    // Date Picker
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(
                                () => currentPage.selectedDate = pickedDate);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 28,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  DateFormat('MM/dd/yyyy')
                                      .format(currentPage.selectedDate),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Time Picker
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: currentPage.selectedTime,
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors
                                          .blue, // Header background color
                                      onPrimary:
                                          Colors.white, // Header text color
                                      onSurface:
                                          Colors.black, // Body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.blue, // Button text color
                                      ),
                                    ),
                                    dialogBackgroundColor:
                                        Colors.white, // Dialog background color
                                  ),
                                  child: child!,
                                ),
                              );
                            },
                          );

                          if (pickedTime != null) {
                            setState(() {
                              currentPage.selectedTime =
                                  pickedTime; // Save the selected time
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  size: 30, color: Colors.blue),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${currentPage.selectedTime.hour.toString().padLeft(2, '0')}:${currentPage.selectedTime.minute.toString().padLeft(2, '0')}', // Display selected time in 24-hour format
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // Multi-select Dropdown Row
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async => await _showConfirmDropdown(context),
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(),
                          child: Row(
                            children: [
                              Icon(Icons.location_city_rounded,
                                  size: 28, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentPage.selectedTransferOptions.isEmpty
                                      ? 'რეისი'
                                      : currentPage.selectedTransferOptions
                                          .join(', '),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async =>
                            await _showSingleSelectDropdown(context),
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(),
                          child: Row(
                            children: [
                              Icon(Icons.directions_bus,
                                  size: 28, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentPage.selectedSingleOption.isEmpty
                                      ? 'ავტობუსი'
                                      : '${currentPage.selectedDriverName} ${currentPage.selectedSingleOption}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.blueGrey, // Line color
                thickness: 3, // Line thickness
                height: 20, // Space around the line
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                Icon(
                                  Icons.people,
                                  size: 28,
                                  color: Colors.orangeAccent,
                                ),
                                Text(
                                  'მგზავრები:',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: TextFormField(
                                    controller: currentPage.passengerController,
                                    focusNode: currentPage.focusNode,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        currentPage.passengerCount =
                                            int.tryParse(value) ??
                                                currentPage.passengerCount;
                                        _updateOnlinePassengers(
                                            currentPageIndex);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: const [
                        Icon(
                          Icons.computer,
                          size: 28,
                          color: Colors.teal,
                        ),
                        Text(
                          'ონლაინი:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      '${currentPage.onlinePassengerCount}',
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                Icon(
                                  Icons.money_rounded,
                                  size: 28,
                                  color: Colors.green,
                                ),
                                Text(
                                  'ქეში:',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.cashPassengerCount > 0
                                      ? () => _updateCount('cash', false)
                                      : null,
                                ),
                                Text(
                                  '${currentPage.cashPassengerCount}',
                                  style: const TextStyle(fontSize: 25),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.cashPassengerCount < 99
                                      ? () => _updateCount('cash', true)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.child_care, // Use any icon you prefer
                                  size: 24,
                                  color: Colors.blue, // Customize the color
                                ),
                                Checkbox(
                                  value: currentPage.showCashChildCounter,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      currentPage.showCashChildCounter =
                                          value ?? false;
                                      if (!currentPage.showCashChildCounter) {
                                        // Decrease parent counter by child count
                                        currentPage.cashPassengerCount -=
                                            currentPage.cashChildPassengerCount;
                                        currentPage.cashChildPassengerCount = 0;
                                        _updateOnlinePassengers(
                                            currentPageIndex);
                                      }
                                    });
                                  },
                                ),
                                const Text(
                                  'ბავშვი',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            if (currentPage.showCashChildCounter)
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    iconSize: 25,
                                    onPressed:
                                        currentPage.cashChildPassengerCount > 0
                                            ? () =>
                                                _updateChildCount('cash', false)
                                            : null,
                                  ),
                                  Text(
                                    '${currentPage.cashChildPassengerCount}',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: 25,
                                    onPressed:
                                        currentPage.cashChildPassengerCount < 99
                                            ? () =>
                                                _updateChildCount('cash', true)
                                            : null,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                Icon(
                                  Icons.credit_card,
                                  size: 28,
                                  color: Colors.red,
                                ),
                                Text(
                                  'ბარათი:',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.cardPassengerCount >
                                          currentPage.cardChildPassengerCount
                                      ? () => _updateCount('card', false)
                                      : null,
                                ),
                                Text(
                                  '${currentPage.cardPassengerCount}',
                                  style: const TextStyle(fontSize: 25),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.cardPassengerCount < 99
                                      ? () => _updateCount('card', true)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.child_care, // Use any icon you prefer
                                  size: 24,
                                  color: Colors.blue, // Customize the color
                                ),
                                Checkbox(
                                  value: currentPage.showCardChildCounter,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      currentPage.showCardChildCounter =
                                          value ?? false;
                                      if (!currentPage.showCardChildCounter) {
                                        // Decrease parent counter by child count
                                        currentPage.cardPassengerCount -=
                                            currentPage.cardChildPassengerCount;
                                        currentPage.cardChildPassengerCount = 0;
                                        _updateOnlinePassengers(
                                            currentPageIndex);
                                      }
                                    });
                                  },
                                ),
                                const Text(
                                  'ბავშვი',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            if (currentPage.showCardChildCounter)
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    iconSize: 25,
                                    onPressed:
                                        currentPage.cardChildPassengerCount > 0
                                            ? () =>
                                                _updateChildCount('card', false)
                                            : null,
                                  ),
                                  Text(
                                    '${currentPage.cardChildPassengerCount}',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: 25,
                                    onPressed:
                                        currentPage.cardChildPassengerCount < 99
                                            ? () =>
                                                _updateChildCount('card', true)
                                            : null,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                Icon(
                                  Icons.flight,
                                  size: 28,
                                  color: Colors.purple,
                                ),
                                Text(
                                  'Wizz Air:',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.wizzPassengerCount > 0
                                      ? () => _updateCount('wizz', false)
                                      : null,
                                ),
                                Text(
                                  '${currentPage.wizzPassengerCount}',
                                  style: const TextStyle(fontSize: 25),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 30,
                                  onPressed: currentPage.wizzPassengerCount < 99
                                      ? () => _updateCount('wizz', true)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.blueGrey,
                thickness: 3,
                height: 10,
              ),
              // In the build method, replace the separate checkbox and text field rows with:
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Checkbox
                            Icon(
                              Icons.money_off,
                              size: 22,
                              color: const Color.fromARGB(255, 0, 116, 60),
                            ),
                            Checkbox(
                              value: currentPage.showFreePessangers,
                              onChanged: (bool? value) {
                                setState(() {
                                  currentPage.showFreePessangers =
                                      value ?? false;
                                  if (!currentPage.showFreePessangers) {
                                    currentPage.freePassengersCount = 0;
                                    currentPage.freePassengersController
                                        .clear();
                                  }
                                });
                              },
                            ),
                            const Text(
                              'უფასო',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 39),
                            Spacer(),
                            // TextField (only shown when checkbox is checked)
                            if (currentPage.showFreePessangers)
                              Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 90,
                                      height: 30,
                                      child: TextField(
                                        controller: currentPage
                                            .freePassengersController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 9),
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        focusNode:
                                            currentPage.freePassengersFocus,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Checkbox
                            Icon(
                              Icons.transfer_within_a_station,
                              size: 22,
                              color: Colors.blue,
                            ),
                            Checkbox(
                              value: currentPage.showOnTheWay,
                              onChanged: (bool? value) {
                                setState(() {
                                  currentPage.showOnTheWay = value ?? false;
                                  if (!currentPage.showOnTheWay) {
                                    currentPage.onTheWayCashCount = 0;
                                    currentPage.onTheWayController.clear();
                                  }
                                });
                              },
                            ),
                            const Text(
                              'გზაში',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 37),
                            Spacer(),
                            // TextField (only shown when checkbox is checked)
                            if (currentPage.showOnTheWay)
                              Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(width: 21),
                                    SizedBox(
                                      width: 90,
                                      height: 30,
                                      child: TextField(
                                        controller:
                                            currentPage.onTheWayController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 9),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (currentPage.showOnTheWay)
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Wrap(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Icons.money_rounded,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    'ქეში:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    iconSize: 28,
                                    onPressed: currentPage.onTheWayCashCount > 0
                                        ? () => _updateOnTheWayCash(false)
                                        : null,
                                  ),
                                  Text(
                                    '${currentPage.onTheWayCashCount}',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: 28,
                                    onPressed:
                                        currentPage.onTheWayCashCount < 99
                                            ? () => _updateOnTheWayCash(true)
                                            : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Arrow
                    IconButton(
                      iconSize: 40,
                      color: Colors.green,
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: currentPageIndex > 0
                          ? () => _navigateToPage(currentPageIndex - 1)
                          : null,
                    ),
                    ElevatedButton(
                      onPressed: () => _showCustomDialog(context),
                      child: const Text('კოპირება'),
                    ),
                    IconButton(
                      iconSize: 40,
                      color: Colors.green,
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: currentPageIndex < pages.length - 1
                          ? () => _navigateToPage(currentPageIndex + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
