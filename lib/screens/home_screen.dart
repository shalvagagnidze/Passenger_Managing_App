import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:passenger_managing_app/models/PassengerData';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now(); // Store selected time
  final TextEditingController _passengerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _freePassengersFocus = FocusNode();

  int _passengerCount = 0;
  int _onlinePassengerCount = 0;
  int _cashPassengerCount = 0;
  int _cardPassengerCount = 0;
  int _wizzPassengerCount = 0;

  bool _showCashChildCounter = false;
  bool _showCardChildCounter = false;
  int _cashChildPassengerCount = 0;
  int _cardChildPassengerCount = 0;

  bool _showOnTheWay = false;
  int _onTheWayCashCount = 0;
  final TextEditingController _onTheWayController = TextEditingController();

  bool _showFreePessangers = false;
  int freePassengersCount = 0;
  final TextEditingController _freePassengersController =
      TextEditingController();
  // Multi-select dropdown state
  List<String> _selectedTransferOptions = [];
  String _selectedSingleOption = '';
  final List<String> _transferOptions = [
    'ვენა',
    'ბარსელონა',
    'კატოვიცე',
    'პრაღა',
    'აბუ-დაბი',
    'ვილნიუსი',
    'ბუდაპეშტი',
    'მილანი',
    'პოზნანი',
    'ბერლინი',
    'ვარშავა',
  ];

  final List<String> _driverOptions = [
    'GB-101-US',
    'GB-900-US',
    'GB-303-US',
    'GB-055-US',
  ];

  List<String> _tempSelectedTransferOptions = [];

  @override
  void initState() {
    super.initState();
    _passengerController.addListener(_updateOnlinePassengers);
  }

  void _updateCount(String type, bool increment) {
    setState(() {
      switch (type) {
        case 'cash':
          if (increment && _cashPassengerCount < 99) {
            _cashPassengerCount++;
          } else if (!increment && _cashPassengerCount > 0) {
            _cashPassengerCount--;
          }
          break;
        case 'card':
          if (increment && _cardPassengerCount < 99) {
            _cardPassengerCount++;
          } else if (!increment && _cardPassengerCount > 0) {
            _cardPassengerCount--;
          }
          break;
        case 'wizz':
          if (increment && _wizzPassengerCount < 99) {
            _wizzPassengerCount++;
          } else if (!increment && _wizzPassengerCount > 0) {
            _wizzPassengerCount--;
          }
          break;
      }
      _updateOnlinePassengers();
    });
  }

  void _updateOnlinePassengers() {
    setState(() {
      _passengerCount = int.tryParse(_passengerController.text) ?? 0;
      _onlinePassengerCount = _passengerCount -
          (_cashPassengerCount + _cardPassengerCount + _wizzPassengerCount);
      if (_onlinePassengerCount < 0) _onlinePassengerCount = 0;
    });
  }

  void _showCustomDialog(BuildContext context) {
    if (!_validateData()) {
      return;
    }

    double standartRate = 25.0;
    double childRate = 15.0;

    double totalCashAmount =
        (_cashPassengerCount - _cashChildPassengerCount) * standartRate +
            _cashChildPassengerCount * childRate;

    double totalCardAmount =
        (_cardPassengerCount - _cardChildPassengerCount) * standartRate +
            _cardChildPassengerCount * childRate;

    final data = PassengerData(
      date: _selectedDate,
      hours: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      route: _selectedTransferOptions,
      bus: _selectedSingleOption,
      totalPassengers: int.tryParse(_passengerController.text) ?? 0,
      onlinePassengers: _onlinePassengerCount,
      cashPassengers: _cashPassengerCount,
      cashChild: _cashChildPassengerCount,
      cardPassengers: _cardPassengerCount,
      cardChild: _cardChildPassengerCount,
      wizzAirPassengers: _wizzPassengerCount,
      freePassengers: int.tryParse(_freePassengersController.text) ?? 0,
      onTheWayPassengers: int.tryParse(_onTheWayController.text) ?? 0,
      onTheWayCash: _onTheWayCashCount,
      totalCashAmount: totalCashAmount,
      totalCardAmount: totalCardAmount,
    );

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     // Parse the JSON string to get the filtered data
    //     Map<String, dynamic> displayData = jsonDecode(data.toJson());
    //     return AlertDialog(
    //       title: const Text('Passenger Data'),
    //       content: SingleChildScrollView(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: displayData.entries.map((entry) {
    //             // Format amounts with 2 decimal places
    //             var value = entry.value;
    //             if (value is double) {
    //               value = '${value.toStringAsFixed(2)} GEL';
    //             }
    //             return Text('${entry.key}: $value');
    //           }).toList(),
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             FocusScope.of(context).unfocus();
    //           },
    //           child: const Text('Close'),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Clipboard.setData(ClipboardData(text: data.toJson()));
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               const SnackBar(content: Text('Data copied to clipboard')),
    //             );
    //             Navigator.of(context).pop();
    //             FocusScope.of(context).unfocus();
    //           },
    //           child: const Text('Copy to Clipboard'),
    //         ),
    //       ],
    //     );
    //   },
    // );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String formattedData = data.toFormattedString();
        return AlertDialog(
          title: const Text('რაოდენობები'),
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

  void _updateChildCount(String type, bool increment) {
    setState(() {
      switch (type) {
        case 'cash':
          if (increment) {
            if (_cashChildPassengerCount < 99) {
              _cashChildPassengerCount++;
              _cashPassengerCount++; // Increase parent counter
            }
          } else {
            if (_cashChildPassengerCount > 0) {
              _cashChildPassengerCount--;
              _cashPassengerCount--; // Decrease parent counter
            }
          }
          break;
        case 'card':
          if (increment) {
            if (_cardChildPassengerCount < 99) {
              _cardChildPassengerCount++;
              _cardPassengerCount++; // Increase parent counter
            }
          } else {
            if (_cardChildPassengerCount > 0) {
              _cardChildPassengerCount--;
              _cardPassengerCount--; // Decrease parent counter
            }
          }
          break;
      }
      _updateOnlinePassengers();
    });
  }

  void _updateOnTheWayCash(bool increment) {
    setState(() {
      if (increment && _onTheWayCashCount < 99) {
        _onTheWayCashCount++;
      } else if (!increment && _onTheWayCashCount > 0) {
        _onTheWayCashCount--;
      }
    });
  }

  void _showConfirmDropdown(BuildContext context) {
    _tempSelectedTransferOptions = List.from(_selectedTransferOptions);
    FocusScope.of(context).unfocus();
    // Convert to Set and back to List to remove duplicates
    final List<String> uniqueOptions = _transferOptions.toSet().toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Select Options'),
              content: Container(
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
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTransferOptions =
                          List.from(_tempSelectedTransferOptions);
                    });
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
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

  void _showSingleSelectDropdown(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _driverOptions.map((String value) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSingleOption = value;
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
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
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
    String errorMessage = '';

    // Check total passengers
    if (_passengerController.text.isEmpty ||
        int.parse(_passengerController.text) == 0) {
      errorMessage += 'მგზავრების რაოდენობა სავალდებულოა\n';
    }

    // Check route selection
    if (_selectedTransferOptions.isEmpty) {
      errorMessage += 'გთხოვთ აირჩიოთ რეისი\n';
    }

    // Check bus selection
    if (_selectedSingleOption.isEmpty) {
      errorMessage += 'გთხოვთ აირჩიოთ ავტობუსი\n';
    }

    // Check free passengers if checked
    if (_showFreePessangers) {
      if (_freePassengersController.text.isEmpty ||
          int.parse(_freePassengersController.text) == 0) {
        errorMessage += 'უფასო მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
      }
    }

    // Check on the way passengers if checked
    if (_showOnTheWay) {
      if (_onTheWayController.text.isEmpty ||
          int.parse(_onTheWayController.text) == 0) {
        errorMessage += 'გზაში მყოფი მგზავრების რაოდენობა არ შეიძლება იყოს 0\n';
      }
    }

    // If there are any errors, show them in a dialog
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context)
                    .padding
                    .top, // Dynamic padding for the top
              ),
              child: Column(
                children: [
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
                                setState(() => _selectedDate = pickedDate);
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                          .format(_selectedDate),
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
                                initialTime: _selectedTime,
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
                                            foregroundColor: Colors
                                                .blue, // Button text color
                                          ),
                                        ),
                                        dialogBackgroundColor: Colors
                                            .white, // Dialog background color
                                      ),
                                      child: child!,
                                    ),
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  _selectedTime =
                                      pickedTime; // Save the selected time
                                });
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 30, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}', // Display selected time in 24-hour format
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
                            onTap: () => _showConfirmDropdown(context),
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(),
                              child: Row(
                                children: [
                                  Icon(Icons.location_city_rounded,
                                      size: 28, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedTransferOptions.isEmpty
                                          ? 'რეისი'
                                          : _selectedTransferOptions.join(', '),
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
                            onTap: () => _showSingleSelectDropdown(context),
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(),
                              child: Row(
                                children: [
                                  Icon(Icons.directions_bus,
                                      size: 28, color: Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedSingleOption.isEmpty
                                          ? 'ავტობუსი'
                                          : _selectedSingleOption,
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
                                      child: TextField(
                                        controller: _passengerController,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 8),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _passengerCount =
                                                int.tryParse(value) ??
                                                    _passengerCount;
                                            _updateOnlinePassengers();
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
                          '$_onlinePassengerCount',
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
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      iconSize: 30,
                                      onPressed: _cashPassengerCount >
                                              _cashChildPassengerCount
                                          ? () => _updateCount('cash', false)
                                          : null,
                                    ),
                                    Text(
                                      '$_cashPassengerCount',
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      iconSize: 30,
                                      onPressed: _cashPassengerCount < 99
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
                                      Icons
                                          .child_care, // Use any icon you prefer
                                      size: 24,
                                      color: Colors.blue, // Customize the color
                                    ),
                                    Checkbox(
                                      value: _showCashChildCounter,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _showCashChildCounter =
                                              value ?? false;
                                          if (!_showCashChildCounter) {
                                            // Decrease parent counter by child count
                                            _cashPassengerCount -=
                                                _cashChildPassengerCount;
                                            _cashChildPassengerCount = 0;
                                            _updateOnlinePassengers();
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
                                if (_showCashChildCounter)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        iconSize: 25,
                                        onPressed: _cashChildPassengerCount > 0
                                            ? () =>
                                                _updateChildCount('cash', false)
                                            : null,
                                      ),
                                      Text(
                                        '$_cashChildPassengerCount',
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        iconSize: 25,
                                        onPressed: _cashChildPassengerCount < 99
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
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      iconSize: 30,
                                      onPressed: _cardPassengerCount >
                                              _cardChildPassengerCount
                                          ? () => _updateCount('card', false)
                                          : null,
                                    ),
                                    Text(
                                      '$_cardPassengerCount',
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      iconSize: 30,
                                      onPressed: _cardPassengerCount < 99
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
                                      Icons
                                          .child_care, // Use any icon you prefer
                                      size: 24,
                                      color: Colors.blue, // Customize the color
                                    ),
                                    Checkbox(
                                      value: _showCardChildCounter,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _showCardChildCounter =
                                              value ?? false;
                                          if (!_showCardChildCounter) {
                                            // Decrease parent counter by child count
                                            _cardPassengerCount -=
                                                _cardChildPassengerCount;
                                            _cardChildPassengerCount = 0;
                                            _updateOnlinePassengers();
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
                                if (_showCardChildCounter)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        iconSize: 25,
                                        onPressed: _cardChildPassengerCount > 0
                                            ? () =>
                                                _updateChildCount('card', false)
                                            : null,
                                      ),
                                      Text(
                                        '$_cardChildPassengerCount',
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        iconSize: 25,
                                        onPressed: _cardChildPassengerCount < 99
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
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      iconSize: 30,
                                      onPressed: _wizzPassengerCount > 0
                                          ? () => _updateCount('wizz', false)
                                          : null,
                                    ),
                                    Text(
                                      '$_wizzPassengerCount',
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      iconSize: 30,
                                      onPressed: _wizzPassengerCount < 99
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
                                  value: _showFreePessangers,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _showFreePessangers = value ?? false;
                                      if (!_showFreePessangers) {
                                        freePassengersCount = 0;
                                        _freePassengersController.clear();
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
                                if (_showFreePessangers)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 90,
                                          height: 30,
                                          child: TextField(
                                            controller:
                                                _freePassengersController,
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 9),
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            focusNode: _freePassengersFocus,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
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
                                  value: _showOnTheWay,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _showOnTheWay = value ?? false;
                                      if (!_showOnTheWay) {
                                        _onTheWayCashCount = 0;
                                        _onTheWayController.clear();
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
                                if (_showOnTheWay)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 21),
                                        SizedBox(
                                          width: 90,
                                          height: 30,
                                          child: TextField(
                                            controller: _onTheWayController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 9),
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
                  if (_showOnTheWay)
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        iconSize: 28,
                                        onPressed: _onTheWayCashCount > 0
                                            ? () => _updateOnTheWayCash(false)
                                            : null,
                                      ),
                                      Text(
                                        '$_onTheWayCashCount',
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        iconSize: 28,
                                        onPressed: _onTheWayCashCount < 99
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
                  ElevatedButton(
                    onPressed: () => _showCustomDialog(context),
                    child: const Text('კოპირება'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _passengerController.removeListener(_updateOnlinePassengers);
    _passengerController.dispose();
    _onTheWayController.dispose();
    _freePassengersController.dispose();
    _focusNode.dispose();
    _freePassengersFocus.dispose();
    super.dispose();
  }
}
