enum TypeProduction {
  lait,
  oeufs,
  viande,
  laine,
  autre;

  String get label {
    switch (this) {
      case TypeProduction.lait:
        return 'Lait';
      case TypeProduction.oeufs:
        return 'Œufs';
      case TypeProduction.viande:
        return 'Viande';
      case TypeProduction.laine:
        return 'Laine';
      case TypeProduction.autre:
        return 'Autre';
    }
  }

  String get unite {
    switch (this) {
      case TypeProduction.lait:
        return 'L';
      case TypeProduction.oeufs:
        return 'unités';
      case TypeProduction.viande:
        return 'kg';
      case TypeProduction.laine:
        return 'kg';
      case TypeProduction.autre:
        return '';
    }
  }

  static TypeProduction fromString(String value) {
    return TypeProduction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TypeProduction.autre,
    );
  }
}

class Production {
  final String id;
  final String? animalId; // null = production collective (ex. troupeau de poules)
  final TypeProduction type;
  final double quantite;
  final DateTime date;
  final String? notes;
  final DateTime creeLe;

  Production({
    required this.id,
    this.animalId,
    required this.type,
    required this.quantite,
    required this.date,
    this.notes,
    required this.creeLe,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'animal_id': animalId,
        'type': type.name,
        'quantite': quantite,
        'date': date.toIso8601String(),
        'notes': notes,
        'cree_le': creeLe.toIso8601String(),
      };

  factory Production.fromMap(Map<String, dynamic> map) => Production(
        id: map['id'] as String,
        animalId: map['animal_id'] as String?,
        type: TypeProduction.fromString(map['type'] as String),
        quantite: (map['quantite'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String?,
        creeLe: DateTime.parse(map['cree_le'] as String),
      );
}
