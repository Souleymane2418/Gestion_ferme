import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper singleton pour la base SQLite locale (offline-first).
class DatabaseHelper {
  static const _dbName = 'gestion_ferme.db';
  static const _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animaux (
        id              TEXT PRIMARY KEY,
        identifiant     TEXT NOT NULL,
        nom             TEXT NOT NULL,
        espece          TEXT NOT NULL,
        race            TEXT,
        sexe            TEXT NOT NULL,
        date_naissance  TEXT,
        poids_kg        REAL,
        statut          TEXT NOT NULL DEFAULT 'actif',
        photo_path      TEXT,
        notes           TEXT,
        cree_le         TEXT NOT NULL,
        maj_le          TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_animaux_espece ON animaux(espece)');
    await db.execute(
        'CREATE INDEX idx_animaux_statut ON animaux(statut)');

    await db.execute('''
      CREATE TABLE sante (
        id              TEXT PRIMARY KEY,
        animal_id       TEXT NOT NULL,
        type            TEXT NOT NULL,
        libelle         TEXT NOT NULL,
        date            TEXT NOT NULL,
        prochain_rappel TEXT,
        veterinaire     TEXT,
        cout            REAL,
        notes           TEXT,
        cree_le         TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animaux(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sante_animal ON sante(animal_id)');
    await db.execute(
        'CREATE INDEX idx_sante_rappel ON sante(prochain_rappel)');

    await db.execute('''
      CREATE TABLE reproduction (
        id              TEXT PRIMARY KEY,
        femelle_id      TEXT NOT NULL,
        male_id         TEXT,
        type            TEXT NOT NULL,
        date            TEXT NOT NULL,
        date_attendue   TEXT,
        nb_petits       INTEGER,
        notes           TEXT,
        cree_le         TEXT NOT NULL,
        FOREIGN KEY (femelle_id) REFERENCES animaux(id) ON DELETE CASCADE,
        FOREIGN KEY (male_id) REFERENCES animaux(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_reproduction_femelle ON reproduction(femelle_id)');

    await db.execute('''
      CREATE TABLE production (
        id              TEXT PRIMARY KEY,
        animal_id       TEXT,
        type            TEXT NOT NULL,
        quantite        REAL NOT NULL,
        date            TEXT NOT NULL,
        notes           TEXT,
        cree_le         TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animaux(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_production_date ON production(date)');
    await db.execute(
        'CREATE INDEX idx_production_type ON production(type)');

    await db.execute('''
      CREATE TABLE transactions (
        id              TEXT PRIMARY KEY,
        type            TEXT NOT NULL,
        categorie       TEXT NOT NULL,
        montant         REAL NOT NULL,
        date            TEXT NOT NULL,
        animal_id       TEXT,
        description     TEXT,
        cree_le         TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animaux(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute(
        'CREATE INDEX idx_transactions_type ON transactions(type)');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
