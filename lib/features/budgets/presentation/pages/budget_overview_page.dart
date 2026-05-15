import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_state.dart';
import 'package:wealthpath/features/budgets/presentation/widgets/budget_search_bar.dart';
import 'package:wealthpath/features/budgets/presentation/widgets/category_budget_card.dart';
import 'package:wealthpath/features/budgets/presentation/widgets/offline_banner.dart';

class BudgetOverviewPage extends StatefulWidget {
  const BudgetOverviewPage({super.key});

  @override
  State<BudgetOverviewPage> createState() => _BudgetOverviewPageState();
}

class _BudgetOverviewPageState extends State<BudgetOverviewPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().loadBudgets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Overview'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.read<BudgetCubit>().refreshBudgets(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is BudgetInitial || state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetLoaded) {
            if (_searchController.text != state.searchQuery) {
              _searchController.value = TextEditingValue(
                text: state.searchQuery,
                selection: TextSelection.collapsed(
                  offset: state.searchQuery.length,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<BudgetCubit>().refreshBudgets(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: <Widget>[
                  if (state.isOffline) const OfflineBanner(),
                  BudgetSearchBar(
                    controller: _searchController,
                    onChanged: (value) =>
                        context.read<BudgetCubit>().onSearchChanged(value),
                    onClear: () {
                      _searchController.clear();
                      context.read<BudgetCubit>().onSearchChanged('');
                      setState(() {});
                    },
                  ),
                  if (state.filteredBudgets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No matching categories found.'),
                      ),
                    )
                  else
                    ...state.filteredBudgets.map(
                      (budget) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: CategoryBudgetCard(
                          budget: budget,
                          onEdit: () => _showEditLimitDialog(context, budget),
                        ),
                      ),
                    ),
                  if (state.hasMore)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<BudgetCubit>().loadMoreBudgets(),
                        child: const Text('Load more'),
                      ),
                    ),
                ],
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<BudgetCubit>().refreshBudgets(),
              child: const Text('Retry'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditLimitDialog(
    BuildContext context,
    BudgetEntity budget,
  ) async {
    final controller = TextEditingController(
      text: budget.limit.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${budget.category} limit'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'New limit'),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0)
                  return 'Enter a valid amount';
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final newLimit = double.parse(controller.text.trim());
                context.read<BudgetCubit>().updateBudgetLimitOptimistic(
                  budget.id,
                  newLimit,
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
