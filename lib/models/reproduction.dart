enum TypeReproduction {
  saillie,
  insemination,
  gestation,
  miseBas;

  String get label {
    switch (this) {
      case TypeReproduction.saillie:
        return 'Saillie';
      case TypeReproduction.insemination:
        return 'Insémination';
      case TypeReproduction.gestation:
        return 'Gestation';
      case TypeReproduction.miseBas:
        return 'Mise bas';
    }
  }

  static TypeReproduction fromString(String value) {
    return TypeReproduction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TypeReproduction.saillie,
    );
  }
}

class Reproduction {
  final String id;
  final String femelleId;
  final String? maleId;
  final TypeReproduction type;
  final DateTime date;
  final DateTime? dateAttendue; // mise bas attendue
  final int? nbPetits;
  final String? notes;
  final DateTime creeLe;

  Reproduction({
    required this.id,
    required this.femelleId,
    this.maleId,
    required this.type,
    required this.date,
    this.dateAttendue,
    this.nbPetits,
    this.notes,
    required this.creeLe,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'femelle_id': femelleId,
        'male_id': maleId,
        'type': type.name,
        'date': date.toIso8601String(),
        'date_attendue': dateAttendue?.toIso8601String(),
        'nb_petits': nbPetits,
        'notes': notes,
        'cree_le': creeLe.toIso8601String(),
      };

  factory Reproduction.fromMap(Map<String, dynamic> map) => Reproduction(
        id: map['id'] as String,
        femelleId: map['femelle_id'] as String,
        maleId: map['male_id'] as String?,
        type: TypeReproduction.fromString(map['type'] as String),
        date: DateTime.parse(map['date'] as String),
        dateAttendue: map['date_attendue'] != null
            ? DateTime.parse(map['date_attendue'] as String)
            : null,
        nbPetits: map['nb_petits'] as int?,
        notes: map['notes'] as String?,
        creeLe: DateTime.parse(map['cree_le'] as String),
      );
}
