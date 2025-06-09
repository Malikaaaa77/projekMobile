import 'package:flutter/material.dart';
import '../../presenters/conversion_presenter.dart';
import '../../utils/constants.dart';

class ConversionView extends StatefulWidget {
  const ConversionView({super.key});

  @override
  ConversionViewState createState() => ConversionViewState();
}

class ConversionViewState extends State<ConversionView> 
    with SingleTickerProviderStateMixin implements ConversionViewContract {
  
  late ConversionPresenter _presenter;
  late TabController _tabController;
  
  // Currency conversion - Fixed: make final
  final _currencyAmountController = TextEditingController();
  final String _fromCurrency = 'USD';  // Fixed: Added final
  final String _toCurrency = 'IDR';    // Fixed: Added final
  String _currencyResult = '';
  bool _isCurrencyLoading = false;
  
  // Time conversion
  String _fromTimezone = 'Asia/Jakarta';
  String _toTimezone = 'Europe/London';
  String _timeResult = '';
  bool _isTimeLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = ConversionPresenter(this);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.monetization_on), text: 'Currency'),
            Tab(icon: Icon(Icons.access_time), text: 'Time Zone'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrencyConverter(),
          _buildTimeConverter(),
        ],
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[700], size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Currency Converter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Amount Input
                  TextField(
                    controller: _currencyAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // From Currency
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromCurrency,
                          decoration: InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: Constants.currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: null, // Fixed: Currency is final, so disabled
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.green[700],
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toCurrency,
                          decoration: InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: Constants.currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: null, // Fixed: Currency is final, so disabled
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Convert Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isCurrencyLoading ? null : _convertCurrency,
                      icon: _isCurrencyLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.currency_exchange),
                      label: Text(
                        _isCurrencyLoading ? 'Converting...' : 'Convert',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Result
          if (_currencyResult.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Conversion Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        _currencyResult,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeConverter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue[700], size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Time Zone Converter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // From Timezone
                  DropdownButtonFormField<String>(
                    value: _fromTimezone,
                    decoration: InputDecoration(
                      labelText: 'From Time Zone',
                      prefixIcon: const Icon(Icons.public),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                      ),
                    ),
                    items: Constants.timezones.map((timezone) {
                      return DropdownMenuItem(
                        value: timezone,
                        child: Text(Constants.timezoneDisplayNames[timezone] ?? timezone),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromTimezone = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // To Timezone
                  DropdownButtonFormField<String>(
                    value: _toTimezone,
                    decoration: InputDecoration(
                      labelText: 'To Time Zone',
                      prefixIcon: const Icon(Icons.schedule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                      ),
                    ),
                    items: Constants.timezones.map((timezone) {
                      return DropdownMenuItem(
                        value: timezone,
                        child: Text(Constants.timezoneDisplayNames[timezone] ?? timezone),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toTimezone = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Convert Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isTimeLoading ? null : _convertTime,
                      icon: _isTimeLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.schedule),
                      label: Text(
                        _isTimeLoading ? 'Converting...' : 'Convert Time',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Result
          if (_timeResult.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Time Conversion Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        _timeResult,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _convertCurrency() {
    final amountText = _currencyAmountController.text.trim();
    if (amountText.isEmpty) {
      showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showError('Please enter a valid amount');
      return;
    }

    _presenter.convertCurrency(_fromCurrency, _toCurrency, amount);
  }

  void _convertTime() {
    _presenter.convertTime(_fromTimezone, _toTimezone);
  }

  @override
  void showCurrencyLoading() {
    setState(() {
      _isCurrencyLoading = true;
    });
  }

  @override
  void hideCurrencyLoading() {
    setState(() {
      _isCurrencyLoading = false;
    });
  }

  @override
  void showCurrencyResult(String result) {
    setState(() {
      _currencyResult = result;
    });
  }

  @override
  void showTimeLoading() {
    setState(() {
      _isTimeLoading = true;
    });
  }

  @override
  void hideTimeLoading() {
    setState(() {
      _isTimeLoading = false;
    });
  }

  @override
  void showTimeResult(String result) {
    setState(() {
      _timeResult = result;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _currencyAmountController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

abstract class ConversionViewContract {
  void showCurrencyLoading();
  void hideCurrencyLoading();
  void showCurrencyResult(String result);
  void showTimeLoading();
  void hideTimeLoading();
  void showTimeResult(String result);
  void showError(String message);
}