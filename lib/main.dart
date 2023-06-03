import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(CurrencyConverterApp());

class Currency {
  final String code;
  final String name;
  final String flag;

  Currency(this.code, this.name, this.flag);
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          backgroundColor: Colors.grey[50],
          cardColor: Colors.white,
          errorColor: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
        ),
      ),
      home: CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  double _convertedAmount = 0.0;
  Currency? _selectedFromCurrency;
  Currency? _selectedToCurrency;
  final List<Currency> _currencies = [
    Currency('USD', 'United States Dollar', '🇺🇸'),
    Currency('EUR', 'Euro', '🇪🇺'),
    Currency('GBP', 'British Pound', '🇬🇧'),
    Currency('JPY', 'Japanese Yen', '🇯🇵'),
    Currency('CAD', 'Canadian Dollar', '🇨🇦'),
    Currency('AUD', 'Australian Dollar', '🇦🇺'),
    Currency('CHF', 'Swiss Franc', '🇨🇭'),
    Currency('CNY', 'Chinese Yuan', '🇨🇳'),
    Currency('INR', 'Indian Rupee', '🇮🇳'),
    Currency('BRL', 'Brazilian Real', '🇧🇷'),
    Currency('MXN', 'Mexican Peso', '🇲🇽'),
    Currency('RUB', 'Russian Ruble', '🇷🇺'),
    Currency('TRY', 'Turkish Lira', '🇹🇷'),
    Currency('ZAR', 'South African Rand', '🇿🇦'),
    Currency('SGD', 'Singapore Dollar', '🇸🇬'),
    Currency('NZD', 'New Zealand Dollar', '🇳🇿'),
    Currency('SEK', 'Swedish Krona', '🇸🇪'),
    Currency('PLN', 'Polish Złoty', '🇵🇱'),
    // Add more currencies as needed
  ];

  Future<Map<String, dynamic>> _fetchCurrencies() async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
    final data = jsonDecode(response.body);
    return data['rates'];
  }

  Future<double> _convertCurrency(
      String baseCurrency, String targetCurrency, double amount) async {
    final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'));
    final data = jsonDecode(response.body);
    final rate = data['rates'][targetCurrency];
    return rate * amount;
  }

  void _onAmountChanged(String value) {
    final amount = double.tryParse(value);
    if (amount != null &&
        _selectedFromCurrency != null &&
        _selectedToCurrency != null) {
      _convertCurrency(
              _selectedFromCurrency!.code, _selectedToCurrency!.code, amount)
          .then((convertedAmount) {
        setState(() {
          _convertedAmount = convertedAmount;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
    _amountController.addListener(() {
      _onAmountChanged(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<Currency>(
              value: _selectedFromCurrency,
              onChanged: (Currency? newValue) {
                setState(() {
                  _selectedFromCurrency = newValue;
                });
                _onAmountChanged(_amountController.text);
              },
              items: _currencies
                  .map<DropdownMenuItem<Currency>>((Currency currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Row(
                    children: [
                      Text(currency.flag),
                      SizedBox(width: 8.0),
                      Text('${currency.name} (${currency.code})'),
                    ],
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<Currency>(
              value: _selectedToCurrency,
              onChanged: (Currency? newValue) {
                setState(() {
                  _selectedToCurrency = newValue;
                });
                _onAmountChanged(_amountController.text);
              },
              items: _currencies
                  .map<DropdownMenuItem<Currency>>((Currency currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Row(
                    children: [
                      Text(currency.flag),
                      SizedBox(width: 8.0),
                      Text('${currency.name} (${currency.code})'),
                    ],
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 32.0),
            Text(
              'Converted Amount: ${_convertedAmount.toStringAsFixed(3)}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
