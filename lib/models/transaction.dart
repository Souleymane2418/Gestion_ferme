enum TypeTransaction {
  revenu,
  depense;

  String get label => this == TypeTransaction.revenu ? 'Revenu' : 'Dépense';

  static TypeTransaction fromString(String value) {
    return TypeTransaction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TypeTransaction.depense,
    );
  }
}

enum CategorieTransaction {
  venteAnimal,
  venteProduit,
  achatAnimal,
  alimentation,
  veterinaire,
  materiel,
  salaire,
  autre;

  String get label {
    switch (this) {
      case CategorieTransaction.venteAnimal:
        return 'Vente animal';
      case CategorieTransaction.venteProduit:
        return 'Vente produit';
      case CategorieTransaction.achatAnimal:
        return 'Achat animal';
      case CategorieTransaction.alimentation:
        return 'Alimentation';
      case CategorieTransaction.veterinaire:
        return 'Vétérinaire';
      case CategorieTransaction.materiel:
        return 'Matériel';
      case CategorieTransaction.salaire:
        return 'Salaire';
      case CategorieTransaction.autre:
        return 'Autre';
    }
  }

  static CategorieTransaction fromString(String value) {
    return CategorieTransaction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategorieTransaction.autre,
    );
  }
}

class Transaction {
  final String id;
  final TypeTransaction type;
  final CategorieTransaction categorie;
  final double montant;
  final DateTime date;
  final String? animalId;
  final String? description;
  final DateTime creeLe;

  Transaction({
    required this.id,
    required this.type,
    required this.categorie,
    required this.montant,
    required this.date,
    this.animalId,
    this.description,
    required this.creeLe,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'categorie': categorie.name,
        'montant': montant,
        'date': date.toIso8601String(),
        'animal_id': animalId,
        'description': description,
        'cree_le': creeLe.toIso8601String(),
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        type: TypeTransaction.fromString(map['type'] as String),
        categorie: CategorieTransaction.fromString(map['categorie'] as String),
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        animalId: map['animal_id'] as String?,
        description: map['description'] as String?,
        creeLe: DateTime.parse(map['cree_le'] as String),
      );
}
