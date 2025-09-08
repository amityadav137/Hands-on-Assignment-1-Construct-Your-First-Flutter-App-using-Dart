// Measures Converter
// Author: <Your Name>
// Notes:
// - Clean, readable, and unit-test friendly conversion logic.
// - Follows Effective Dart naming & formatting.
// - UI mirrors the provided mock: value input, from/to dropdowns, Convert button, result text.
//
// Categories: Length, Weight, Temperature
// Length base: meter; Weight base: kilogram; Temperature handled via dedicated functions.

import 'package:flutter/material.dart';

void main() => runApp(const ConverterApp());

class ConverterApp extends StatelessWidget {
  const ConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConverterScreen(),
    );
  }
}

/// A value object representing a unit in a category.
class Unit {
  final String name;   // e.g., "meters"
  final String symbol; // e.g., "m"
  const Unit(this.name, this.symbol);

  @override
  String toString() => name;
}

enum Category { length, weight, temperature }

const Map<Category, List<Unit>> kUnits = {
  Category.length: [
    Unit('meters', 'm'),
    Unit('kilometers', 'km'),
    Unit('miles', 'mi'),
    Unit('feet', 'ft'),
  ],
  Category.weight: [
    Unit('kilograms', 'kg'),
    Unit('grams', 'g'),
    Unit('pounds', 'lb'),
    Unit('ounces', 'oz'),
  ],
  Category.temperature: [
    Unit('Celsius', '°C'),
    Unit('Fahrenheit', '°F'),
    Unit('Kelvin', 'K'),
  ],
};

// Linear factors to the canonical base unit per category.
const Map<String, double> _lengthToMeter = {
  'meters': 1.0,
  'kilometers': 1000.0,
  'miles': 1609.344,
  'feet': 0.3048,
};

const Map<String, double> _weightToKilogram = {
  'kilograms': 1.0,
  'grams': 0.001,
  'pounds': 0.45359237,
  'ounces': 0.028349523125,
};

/// Converts [value] between [from] and [to] within a [category].
double convert(double value, Category category, String from, String to) {
  switch (category) {
    case Category.length:
      // Convert to meters then to target.
      final meters = value * _lengthToMeter[from]!;
      return meters / _lengthToMeter[to]!;
    case Category.weight:
      // Convert to kilograms then to target.
      final kg = value * _weightToKilogram[from]!;
      return kg / _weightToKilogram[to]!;
    case Category.temperature:
      // Temperature is non-linear.
      final celsius = _toCelsius(value, from);
      return _fromCelsius(celsius, to);
  }
}

double _toCelsius(double v, String from) {
  switch (from) {
    case 'Celsius':
      return v;
    case 'Fahrenheit':
      return (v - 32) * 5 / 9;
    case 'Kelvin':
      return v - 273.15;
    default:
      throw ArgumentError('Unsupported temperature unit: $from');
  }
}

double _fromCelsius(double c, String to) {
  switch (to) {
    case 'Celsius':
      return c;
    case 'Fahrenheit':
      return c * 9 / 5 + 32;
    case 'Kelvin':
      return c + 273.15;
    default:
      throw ArgumentError('Unsupported temperature unit: $to');
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _valueCtrl = TextEditingController(text: '100');
  Category _category = Category.length;
  late Unit _from = kUnits[_category]!.first;
  late Unit _to = kUnits[_category]![1];
  String _result = '';

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  void _onCategoryChanged(Category? newCat) {
    if (newCat == null) return;
    setState(() {
      _category = newCat;
      final units = kUnits[_category]!;
      _from = units.first;
      _to = units[1];
    });
    _recompute();
  }

  void _recompute() {
    final raw = _valueCtrl.text.trim();
    final value = double.tryParse(raw);
    if (value == null) {
      setState(() => _result = 'Enter a valid number.');
      return;
    }
    final out = convert(value, _category, _from.name, _to.name);
    setState(() {
      _result = '${value.toStringAsFixed(1)} ${_from.name} are '
                '${out.toStringAsFixed(3)} ${_to.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = kUnits[_category]!;
    return Scaffold(
      appBar: AppBar(title: const Text('Measures Converter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          const Center(child: Text('Value', style: TextStyle(fontSize: 18))),
          TextField(
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter a value to convert',
              border: UnderlineInputBorder(),
            ),
            onChanged: (_) => _recompute(),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('From', style: TextStyle(fontSize: 16))),
          DropdownButton<Unit>(
            isExpanded: true,
            value: _from,
            items: units.map((u) =>
              DropdownMenuItem(value: u, child: Text(u.name))).toList(),
            onChanged: (u) { setState(() => _from = u!); _recompute(); },
          ),
          const SizedBox(height: 8),
          const Center(child: Text('To', style: TextStyle(fontSize: 16))),
          DropdownButton<Unit>(
            isExpanded: true,
            value: _to,
            items: units.map((u) =>
              DropdownMenuItem(value: u, child: Text(u.name))).toList(),
            onChanged: (u) { setState(() => _to = u!); _recompute(); },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _recompute,
              child: const Text('Convert'),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text(_result, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
