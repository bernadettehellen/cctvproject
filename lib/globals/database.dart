import 'package:sqflite/sqflite.dart';

import 'history.dart';

final DatabaseNotif dbn = DatabaseNotif();

class DatabaseNotif {
  late final Future<Database> database;

  Future<void> insertNotification(Log notif) async {
    final db = await database;
    db.insert('notification', notif.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Log>> history() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notification');
    return List.generate(maps.length, (index) {
      return Log(id: maps[index]['id'], title: maps[index]['title'], message: maps[index]['message'], type: maps[index]['type'], date: maps[index]['date']);
    });
  }
}