import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  int _passengerCount = 0;
  int _onlinePassengerCount = 0;
  int _cashPassengerCount = 0;
  int _cardPassengerCount = 0;
  int _wizzPassengerCount = 0;
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Custom Dialog'),
          content: const Text('This is an example of a dialog in Flutter.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDropdown(BuildContext context) {
    _tempSelectedTransferOptions = List.from(_selectedTransferOptions);

    // Convert to Set and back to List to remove duplicates
    final List<String> uniqueOptions = _transferOptions.toSet().toList();

    showDialog(
      context: context,
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
                                  const Icon(Icons.calendar_today, size: 28,color: Colors.blue,),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      DateFormat('MM/dd/yyyy')
                                          .format(_selectedDate),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.blue
                                      ),
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
                                      onPressed: _cashPassengerCount > 0
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
                                      onPressed: _cardPassengerCount > 0
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
                  ElevatedButton(
                    onPressed: () => _showCustomDialog(context),
                    child: const Text('Show Dialog'),
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
    _focusNode.dispose();
    super.dispose();
  }
}
