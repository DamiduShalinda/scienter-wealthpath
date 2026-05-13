import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_state.dart';
import 'package:wealthpath/features/budgets/presentation/widgets/offline_banner.dart';

class BudgetOverviewPage extends StatefulWidget {
  const BudgetOverviewPage({super.key});

  @override
  State<BudgetOverviewPage> createState() => _BudgetOverviewPageState();
}

class _BudgetOverviewPageState extends State<BudgetOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Overview')),
      body: BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetInitial || state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetLoaded) {
            return Column(
              children: <Widget>[
                if (state.isOffline) const OfflineBanner(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredBudgets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final budget = state.filteredBudgets[index];
                      return ListTile(
                        title: Text(budget.category),
                        subtitle: Text(
                          '${budget.spent.toStringAsFixed(2)} / ${budget.limit.toStringAsFixed(2)} ${budget.currency}',
                        ),
                        trailing: Text('${budget.spendPercentage.toStringAsFixed(0)}%'),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<BudgetCubit>().loadBudgets(),
              child: const Text('Retry'),
            ),
          );
        },
      ),
    );
  }
}
