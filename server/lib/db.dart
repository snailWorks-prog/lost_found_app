// SQLite setup. The database file is created automatically on first start.

import 'package:sqlite3/sqlite3.dart';

/// The single database connection, opened once at startup by [initDb].
late final Database db;

/// Opens (and creates, on first run) the database and its schema.
void initDb(String path) {
  db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      name          TEXT    NOT NULL,
      created_at    TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      title      TEXT    NOT NULL,
      content    TEXT    NOT NULL DEFAULT '',
      created_at TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS files (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      name       TEXT    NOT NULL,
      mime_type  TEXT    NOT NULL,
      size       INTEGER NOT NULL,
      path       TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS items (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id     INTEGER NOT NULL REFERENCES users (id),
      title       TEXT    NOT NULL,
      description TEXT    NOT NULL DEFAULT '',
      location    TEXT    NOT NULL DEFAULT '',
      date        TEXT    NOT NULL DEFAULT '',
      type        TEXT    NOT NULL DEFAULT 'found',
      category    TEXT    NOT NULL DEFAULT 'Разное',
      is_resolved INTEGER NOT NULL DEFAULT 0,
      image_url   TEXT,
      created_at  TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS claims (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id           INTEGER NOT NULL REFERENCES users (id),
      item_id           TEXT    NOT NULL,
      item_title        TEXT    NOT NULL,
      proof_description TEXT    NOT NULL,
      status            TEXT    NOT NULL DEFAULT 'pending',
      created_at        TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS messages (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      claim_id   TEXT    NOT NULL,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      text       TEXT    NOT NULL,
      time       TEXT    NOT NULL,
      is_me      INTEGER NOT NULL DEFAULT 1,
      created_at TEXT    NOT NULL
    );
  ''');
}

/// Seeds default campus items for a user if their items list is empty.
void seedUserItemsIfEmpty(int userId) {
  final countRow = db.select('SELECT COUNT(*) AS n FROM items WHERE user_id = ?', [userId]);
  if ((countRow.first['n'] as int) == 0) {
    final seedData = [
      ['Студенческий билет TI-236', 'Синяя пластиковая карта на имя Семиона Георгиева. Оставлена на третьем ряду.', 'Корпус 3, ауд. 3-215', '2 окт, 14:15', 'found', 'Документы', 0],
      ['Ключи от общежития с синим брелоком', 'Связка из трёх ключей и круглый чип от домофона общежития №2.', 'Спортивная площадка / сквер', '2 окт, 16:40', 'lost', 'Ключи', 0],
      ['Калькулятор Casio fx-991EX', 'Черно-белый научный калькулятор, сзади наклейка с формулой Эйлера.', 'Читальный зал библиотеки', '1 окт, 11:20', 'found', 'Электроника', 0],
      ['Беспроводные наушники в белом кейсе', 'Кейс поцарапан с правой стороны, внутри один левый наушник.', 'Столовая главного корпуса', '1 окт, 13:05', 'lost', 'Электроника', 0],
      ['Конспект по PAM и дискретной математике', 'Тетрадь 96 листов в зелёную клетку, на первой странице надпись TI-236.', 'Корпус 3, коворкинг 4 этаж', '30 сен, 17:30', 'found', 'Учёба', 0],
      ['Худи тёмно-синее с логотипом UTM', 'Размер L, забыто на вешалке в гардеробе после лекции по сетям.', 'Корпус 3, гардероб 1 этажа', '30 сен, 15:00', 'lost', 'Одежда', 0],
      ['Флешка Kingston 64GB', 'Металлический корпус, на шнурке. Внутри файлы лабораторных работ.', 'Лаборатория 3-412', '29 сен, 18:10', 'found', 'Электроника', 1],
      ['Пропуск в лабораторию микроэлектроники', 'Белая бесконтактная карта в прозрачном бейдже на красной ленте.', 'Холл корпуса 3 возле турникетов', '28 сен, 09:15', 'found', 'Документы', 0],
    ];

    for (final item in seedData) {
      db.execute(
        'INSERT INTO items (user_id, title, description, location, date, type, category, is_resolved, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [userId, item[0], item[1], item[2], item[3], item[4], item[5], item[6], nowIso()],
      );
    }
  }
}

/// Current UTC time in ISO-8601, the format used for all timestamps.
String nowIso() => DateTime.now().toUtc().toIso8601String();
