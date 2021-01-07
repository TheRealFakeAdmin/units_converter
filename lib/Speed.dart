import 'UtilsConversion.dart';
import 'Unit.dart';

//Available SPEED units
enum SPEED {
  meters_per_second,
  kilometers_per_hour,
  miles_per_hour,
  knots,
  feets_per_second,
}

class Speed {
  //Map between units and its symbol
  final Map<SPEED, String> mapSymbols = {
    SPEED.meters_per_second: 'm/s',
    SPEED.kilometers_per_hour: 'km/h',
    SPEED.miles_per_hour: 'mi/h',
    SPEED.knots: 'kts',
    SPEED.feets_per_second: 'ft/s',
  };

  int significantFigures;
  bool removeTrailingZeros;
  List<Unit> unitList = [];
  Node _unit_conversion;

  ///Class for speed conversions, e.g. if you want to convert 1 square meters in acres:
  ///```dart
  ///var speed = Speed(removeTrailingZeros: false);
  ///speed.Convert(Unit(SPEED.square_meters, value: 1));
  ///print(SPEED.acres);
  /// ```
  Speed({int significantFigures = 10, bool removeTrailingZeros = true}) {
    this.significantFigures = significantFigures;
    this.removeTrailingZeros = removeTrailingZeros;
    SPEED.values.forEach((element) => unitList.add(Unit(element, symbol: mapSymbols[element])));
    _unit_conversion = Node(name: SPEED.meters_per_second, leafNodes: [
      Node(coefficientProduct: 1 / 3.6, name: SPEED.kilometers_per_hour, leafNodes: [
        Node(
          coefficientProduct: 1.609344,
          name: SPEED.miles_per_hour,
        ),
        Node(
          coefficientProduct: 1.852,
          name: SPEED.knots,
        ),
      ]),
      Node(
        coefficientProduct: 0.3048,
        name: SPEED.feets_per_second,
      ),
    ]);
  }

  ///Converts a unit with a specific name (e.g. SPEED.miles_per_hour) and value to all other units
  void Convert(SPEED name, double value) {
    _unit_conversion.clearAllValues();
    _unit_conversion.clearSelectedNode();
    var currentUnit = _unit_conversion.getByName(name);
    currentUnit.value = value;
    currentUnit.selectedNode = true;
    currentUnit.convertedNode = true;
    _unit_conversion.convert();
    for (var i = 0; i < SPEED.values.length; i++) {
      unitList[i].value = _unit_conversion.getByName(SPEED.values.elementAt(i)).value;
      unitList[i].stringValue = mantissaCorrection(unitList[i].value, significantFigures, removeTrailingZeros);
    }
  }

  Unit get meters_per_second => _getUnit(SPEED.meters_per_second);
  Unit get kilometers_per_hour => _getUnit(SPEED.kilometers_per_hour);
  Unit get miles_per_hour => _getUnit(SPEED.miles_per_hour);
  Unit get knots => _getUnit(SPEED.knots);
  Unit get feets_per_second => _getUnit(SPEED.feets_per_second);

  ///Returns all the speed units converted with prefixes
  List<Unit> getAll() {
    return unitList;
  }

  ///Returns the Unit with the corresponding name
  Unit _getUnit(var name) {
    return unitList.where((element) => element.name == name).first;
  }
}
