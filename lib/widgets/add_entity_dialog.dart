import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passenger_managing_app/models/driver.dart';
import 'package:passenger_managing_app/services/driver_service.dart';
import 'package:passenger_managing_app/services/bus_service.dart';

class AddEntityDialog extends StatefulWidget {
  const AddEntityDialog({
    Key? key,
    required this.existingBuses,
    required this.driverService,
    required this.busService,
    required this.onSuccess,
  }) : super(key: key);

  final List<String> existingBuses;
  final DriverService driverService;
  final BusService busService;
  final VoidCallback onSuccess;

  @override
  _AddEntityDialogState createState() => _AddEntityDialogState();
}

class _AddEntityDialogState extends State<AddEntityDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isAddingDriver = true;
  bool _isLoading = false;

  // Controllers for driver fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controller for bus number
  final _busNumberController = TextEditingController();
  String? _selectedBus;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _busNumberController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isAddingDriver = !isAddingDriver;
      _formKey.currentState?.reset();
      _clearFields();
    });
  }

  void _clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _busNumberController.clear();
    _selectedBus = null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
      return 'Enter a valid 9-digit phone number';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (isAddingDriver) {
        // Adding a driver
        final driver = Driver(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
          busNumber: _selectedBus ?? '',
        );
        await widget.driverService.addDriver(driver);
      } else {
        // Adding a bus
        final busNumber = _busNumberController.text;
        await widget.busService.addBus(busNumber);
      }

      widget.onSuccess();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAddingDriver
                ? 'მძღოლი წარმატებით დაემატა'
                : 'ავტობუსი წარმატებით დაემატა'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          isAddingDriver
                              ? 'მძღოლის დამატება'
                              : 'ავტობუსის დამატება',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isAddingDriver
                              ? Icons.directions_bus
                              : Icons.person_add),
                          onPressed: _toggleMode,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isAddingDriver) ...[
                  // Driver Form Fields
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'სახელი',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'სახელის ველი სავალდებულოა'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'გვარი',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'გვარის ველი სავალდებულოა'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'ტელეფონის ნომერი',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      hintText: '5XX XXX XXX',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedBus,
                    decoration: const InputDecoration(
                      labelText: 'ავტობუსი',
                      prefixIcon: Icon(Icons.directions_bus_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.existingBuses
                        .map((bus) => DropdownMenuItem(
                              value: bus,
                              child: Text(bus),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBus = value),
                    validator: (value) =>
                        value == null ? 'გთხოვთ,აირჩიოთ ავტობუსი' : null,
                  ),
                ] else ...[
                  // Bus Form Field
                  TextFormField(
                    controller: _busNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ავტობუსის ნომერი',
                      prefixIcon: Icon(Icons.directions_bus_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'შეიყვანეთ ავტობუსის ნომერი (მაგ: 101)',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'ნომერის ველი სავალდებულოა'
                        : null,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('დამატება'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
