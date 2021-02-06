class Unit {
  String formalName;
  String unit;
  String unitId;

  Unit({
    this.formalName,
    this.unit,
    this.unitId

  });

  Map toMap(Unit unit) {
    var data = Map<String, dynamic>();
    data['formal_name'] = unit.formalName;
    data['unit'] = unit.unit;
    data['unit_id'] = unit.unitId;
    return data;
  }

  // Named constructor
  Unit.fromMap(Map<String, dynamic> mapData) {
    this.formalName = mapData['formal_name'];
    this.unit = mapData['unit'];
    this.unitId = mapData['unit_id'];
  }
}
