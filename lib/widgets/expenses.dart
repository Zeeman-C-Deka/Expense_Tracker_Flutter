import 'package:expense_tracker/data/data.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expense_list/expenses_list.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends ConsumerState<Expenses> {
  late Future<void> _expFuture;

  @override
  void initState() {
    super.initState();
    _expFuture = ref.read(dataProvider.notifier).loadData();
  }

  void _removeExpense(Expense expense) {
    //final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      ref.read(dataProvider.notifier).removeExp(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              ref.read(dataProvider.notifier).addExp(expense);
            });
          },
        ),
      ),
    );
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      ref.read(dataProvider.notifier).addExp(expense);
    });
  }

  @override
  Widget build(BuildContext context) {
    final registeredExpenses = ref.watch(dataProvider);

    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OzyLabz Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: _expFuture,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? (const Center(
                    child: CircularProgressIndicator(),
                  ))
                : (width < 600
                    ? (Column(
                        children: [
                          Chart(expenses: registeredExpenses),
                          Expanded(
                            child: mainContent,
                          ),
                        ],
                      ))
                    : (Row(
                        children: [
                          Expanded(
                            child: Chart(expenses: registeredExpenses),
                          ),
                          Expanded(
                            child: mainContent,
                          ),
                        ],
                      ))),
      ),
    );
  }
}
