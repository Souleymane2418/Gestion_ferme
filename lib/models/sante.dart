enum TypeSante {
  vaccination,
  traitement,
  consultation,
  dewormage,
  autre;

  String get label {
    switch (this) {
      case TypeSante.vaccination:
        return 'Vaccination';
      case TypeSante.traitement:
        return 'Traitement';
      case TypeSante.consultation:
        return 'Consultation';
      case TypeSante.dewormage:
        return 'Vermifuge';
      case TypeSante.autre:
        return 'Autre';
    }
  }

  static TypeSante fromString(String value) {
    return TypeSante.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TypeSante.autre,
    );
  }
}

class Sante {
  final String id;
  final String animalId;
  final TypeSante type;
  final String libelle; // ex. "Vaccin Foot & Mouth", "Antibiotique Penicillin"
  final DateTime date;
  final DateTime? prochainRappel;
  final String? veterinaire;
  final double? cout;
  final String? notes;
  final DateTime creeLe;

  Sante({
    required this.id,
    required this.animalId,
    required this.type,
    required this.libelle,
    required this.date,
    this.prochainRappel,
    this.veterinaire,
    this.cout,
    this.notes,
    required this.creeLe,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'animal_id': animalId,
        'type': type.name,
        'libelle': libelle,
        'date': date.toIso8601String(),
        'prochain_rappel': prochainRappel?.toIso8601String(),
        'veterinaire': veterinaire,
        'cout': cout,
        'notes': notes,
        'cree_le': creeLe.toIso8601String(),
      };

  factory Sante.fromMap(Map<String, dynamic> map) => Sante(
        id: map['id'] as String,
        animalId: map['animal_id'] as String,
        type: TypeSante.fromString(map['type'] as String),
        libelle: map['libelle'] as String,
        date: DateTime.parse(map['date'] as String),
        prochainRappel: map['prochain_rappel'] != null
            ? DateTime.parse(map['prochain_rappel'] as String)
            : null,
        veterinaire: map['veterinaire'] as String?,
        cout: (map['cout'] as num?)?.toDouble(),
        notes: map['notes'] as String?,
        creeLe: DateTime.parse(map['cree_le'] as String),
      );
}
