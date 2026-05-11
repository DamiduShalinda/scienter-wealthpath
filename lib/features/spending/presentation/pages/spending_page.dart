import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/spending/domain/entities/create_spending_input.dart';
import 'package:wealthpath/features/spending/presentation/cubit/spending_cubit.dart';
import 'package:wealthpath/features/spending/presentation/cubit/spending_state.dart';
import 'package:wealthpath/features/spending/presentation/widgets/spending_header_widget.dart';
import 'package:wealthpath/features/spending/presentation/widgets/spending_item_widget.dart';

class SpendingPage extends StatefulWidget {
  const SpendingPage({super.key});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<SpendingCubit>().loadSpending();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spending'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => _showAddSpendingSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<SpendingCubit, SpendingState>(
        listener: (context, state) {
          if (state is SpendingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SpendingInitial || state is SpendingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SpendingLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('No spending records yet.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showAddSpendingSheet(context),
                      child: const Text('Add Record'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<SpendingCubit>().loadSpending(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  SpendingHeaderWidget(
                    total: state.total,
                    count: state.items.length,
                  ),
                  const SizedBox(height: 12),
                  ...state.items.map((item) => SpendingItemWidget(item: item)),
                  if (state.hasMore) ...<Widget>[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Failed to load spending records.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<SpendingCubit>().loadSpending(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSpendingSheet(BuildContext context) async {
    final cubit = context.read<SpendingCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider<SpendingCubit>.value(
        value: cubit,
        child: const _AddSpendingSheet(),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final threshold = position.maxScrollExtent - 200;
    if (position.pixels >= threshold) {
      context.read<SpendingCubit>().loadMoreSpending();
    }
  }
}

class _AddSpendingSheet extends StatefulWidget {
  const _AddSpendingSheet();

  @override
  State<_AddSpendingSheet> createState() => _AddSpendingSheetState();
}

class _AddSpendingSheetState extends State<_AddSpendingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Groceries';
  String _currency = 'USD';

  static const _categories = <String>[
    'Groceries',
    'Dining',
    'Transport',
    'Utilities',
    'Shopping',
    'Healthcare',
    'Streaming',
    'Education',
    'Travel',
    'Fitness',
  ];

  InputDecoration _fieldDecoration(String label) {
    const borderColor = Color(0xFFD6D9DE);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Add Spending', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _merchantController,
              decoration: _fieldDecoration('Merchant'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Merchant is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: _fieldDecoration('Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _fieldDecoration('Category'),
              items: _categories
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: _fieldDecoration('Currency'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'LKR', child: Text('LKR')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _currency = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Record'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final input = CreateSpendingInput(
      merchant: _merchantController.text.trim(),
      amount: amount,
      category: _category,
      currency: _currency,
    );

    context.read<SpendingCubit>().addSpendingOptimistic(input);
    Navigator.of(context).pop();
  }
}
