import 'dart:io';

import 'package:expense_tracker/model/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:intl/intl.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'expenses1.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_expenses(id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category INTEGER)');
    },
    version: 1,
  );
  print('getdb');

  return db;
}

class DataNotifier extends StateNotifier<List<Expense>> {
  DataNotifier() : super(const []);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Category toCategory(int x) {
    if (x == 1) {
      return Category.food;
    } else if (x == 2) {
      return Category.leisure;
    } else if (x == 3) {
      return Category.travel;
    } else if (x == 4) {
      return Category.work;
    } else {
      return Category.leisure;
    }
  }

  int toInt(Category cat) {
    if (cat == Category.food) {
      return 1;
    } else if (cat == Category.leisure) {
      return 2;
    } else if (cat == Category.travel) {
      return 3;
    } else if (cat == Category.work) {
      return 4;
    } else {
      return 2;
    }
  }

  Future<void> loadData() async {
    final db = await _getDatabase();
    final data = await db.query('user_expenses');
    print('loaddb1');
    final expenses = data
        .map((row) => Expense(
              id: row['id'] as String,
              title: row['title'] as String,
              amount: row['amount'] as double,
              date: dateFormat.parse(row['date'] as String),
              category: toCategory(row['category'] as int),
            ))
        .toList();
    print('loaddb2');

    state = expenses;
  }

  void addExp(Expense expense) async {
    // final appDir = await syspaths.getApplicationDocumentsDirectory();
    // final filename = path.basename(image.path);
    // final copiedImage = await image.copy('${appDir.path}/$filename');

    final newExp = expense;
    // Expense(title: title, amount: amount, date: date, category: category);

    // Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();

    db.insert('user_expenses', {
      'id': newExp.id,
      'title': newExp.title,
      'amount': newExp.amount,
      'date': dateFormat.format(newExp.date),
      'category': toInt(newExp.category),
    });
    print('addexp');

    state = [newExp, ...state];
  }

  void removeExp(Expense expense) async {
    final db = await _getDatabase();

    db.delete('user_expenses', where: '"id" = ?', whereArgs: [expense.id]);
    print('delexp');

    state.remove(expense);
    //loadData();
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, List<Expense>>(
  (ref) => DataNotifier(),
);
