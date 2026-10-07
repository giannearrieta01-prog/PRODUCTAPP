import 'package:flutter/material.dart';

void main() {
  runApp(const MassConverterApp());
}

class MassConverterApp extends StatelessWidget {
  const MassConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mass Converter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MassConverterScreen(),
    );
  }
}

class MassConverterScreen extends StatefulWidget {
  const MassConverterScreen({super.key});

  @override
  State<MassConverterScreen> createState() => _MassConverterScreenState();
}

class _MassConverterScreenState extends State<MassConverterScreen> {
  final TextEditingController _inputController = TextEditingController();

  String _fromUnit = 'Gram (g)';
  String _toUnit = 'Kilogram (kg)';
  double? _result;

  // Conversion rates relative to 1 Gram (g)
  final Map<String, double> _unitToGram = {
    'Milligram (mg)': 0.001,
    'Gram (g)': 1.0,
    'Kilogram (kg)': 1000.0,
    'Metric Ton (t)': 1000000.0,
    'Ounce (oz)': 28.349523125,
    'Pound (lb)': 453.59237,
    'Stone (st)': 6350.29318,
    'Carat (ct)': 0.2, // Enhancement
  };

  void _convert() {
    double? inputVal = double.tryParse(_inputController.text);
    if (inputVal == null) {
      setState(() {
        _result = null;
      });
      return;
    }

    // Convert input to base unit (grams), then convert grams to target unit
    double valueInGrams = inputVal * _unitToGram[_fromUnit]!;
    double convertedValue = valueInGrams / _unitToGram[_toUnit]!;

    setState(() {
      _result = convertedValue;
    });
  }

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> units = _unitToGram.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Mass Converter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromUnit,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _fromUnit = val;
                          _convert();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 28),
                  onPressed: _swapUnits,
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toUnit,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _toUnit = val;
                          _convert();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Result:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(
                      _result != null
                          ? '${_result!.toStringAsFixed(4)} ${_toUnit.split(' ').last}'
                          : 'Enter a number',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}}