enum EspeceAnimal {
  bovin,
  ovin,
  caprin,
  volaille,
  porcin,
  equin,
  autre;

  String get label {
    switch (this) {
      case EspeceAnimal.bovin:
        return 'Bovin';
      case EspeceAnimal.ovin:
        return 'Ovin';
      case EspeceAnimal.caprin:
        return 'Caprin';
      case EspeceAnimal.volaille:
        return 'Volaille';
      case EspeceAnimal.porcin:
        return 'Porcin';
      case EspeceAnimal.equin:
        return 'Équin';
      case EspeceAnimal.autre:
        return 'Autre';
    }
  }

  static EspeceAnimal fromString(String value) {
    return EspeceAnimal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EspeceAnimal.autre,
    );
  }
}

enum SexeAnimal {
  male,
  femelle;

  String get label => this == SexeAnimal.male ? 'Mâle' : 'Femelle';

  static SexeAnimal fromString(String value) {
    return SexeAnimal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SexeAnimal.femelle,
    );
  }
}

enum StatutAnimal {
  actif,
  vendu,
  mort,
  reforme;

  String get label {
    switch (this) {
      case StatutAnimal.actif:
        return 'Actif';
      case StatutAnimal.vendu:
        return 'Vendu';
      case StatutAnimal.mort:
        return 'Mort';
      case StatutAnimal.reforme:
        return 'Réformé';
    }
  }

  static StatutAnimal fromString(String value) {
    return StatutAnimal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StatutAnimal.actif,
    );
  }
}

class Animal {
  final String id;
  final String identifiant; // numéro de boucle / tag
  final String nom;
  final EspeceAnimal espece;
  final String? race;
  final SexeAnimal sexe;
  final DateTime? dateNaissance;
  final double? poidsKg;
  final StatutAnimal statut;
  final String? photoPath;
  final String? notes;
  final DateTime creeLe;
  final DateTime majLe;

  Animal({
    required this.id,
    required this.identifiant,
    required this.nom,
    required this.espece,
    this.race,
    required this.sexe,
    this.dateNaissance,
    this.poidsKg,
    this.statut = StatutAnimal.actif,
    this.photoPath,
    this.notes,
    required this.creeLe,
    required this.majLe,
  });

  int? get ageEnMois {
    if (dateNaissance == null) return null;
    final now = DateTime.now();
    return (now.year - dateNaissance!.year) * 12 +
        (now.month - dateNaissance!.month);
  }

  Animal copyWith({
    String? identifiant,
    String? nom,
    EspeceAnimal? espece,
    String? race,
    SexeAnimal? sexe,
    DateTime? dateNaissance,
    double? poidsKg,
    StatutAnimal? statut,
    String? photoPath,
    String? notes,
    DateTime? majLe,
  }) {
    return Animal(
      id: id,
      identifiant: identifiant ?? this.identifiant,
      nom: nom ?? this.nom,
      espece: espece ?? this.espece,
      race: race ?? this.race,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      poidsKg: poidsKg ?? this.poidsKg,
      statut: statut ?? this.statut,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      creeLe: creeLe,
      majLe: majLe ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'identifiant': identifiant,
        'nom': nom,
        'espece': espece.name,
        'race': race,
        'sexe': sexe.name,
        'date_naissance': dateNaissance?.toIso8601String(),
        'poids_kg': poidsKg,
        'statut': statut.name,
        'photo_path': photoPath,
        'notes': notes,
        'cree_le': creeLe.toIso8601String(),
        'maj_le': majLe.toIso8601String(),
      };

  factory Animal.fromMap(Map<String, dynamic> map) => Animal(
        id: map['id'] as String,
        identifiant: map['identifiant'] as String,
        nom: map['nom'] as String,
        espece: EspeceAnimal.fromString(map['espece'] as String),
        race: map['race'] as String?,
        sexe: SexeAnimal.fromString(map['sexe'] as String),
        dateNaissance: map['date_naissance'] != null
            ? DateTime.parse(map['date_naissance'] as String)
            : null,
        poidsKg: (map['poids_kg'] as num?)?.toDouble(),
        statut: StatutAnimal.fromString(map['statut'] as String),
        photoPath: map['photo_path'] as String?,
        notes: map['notes'] as String?,
        creeLe: DateTime.parse(map['cree_le'] as String),
        majLe: DateTime.parse(map['maj_le'] as String),
      );
}
