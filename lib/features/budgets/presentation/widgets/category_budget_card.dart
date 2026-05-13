import 'package:flutter/material.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';

class CategoryBudgetCard extends StatelessWidget {
  const CategoryBudgetCard({
    required this.budget,
    required this.onEdit,
    super.key,
  });

  final BudgetEntity budget;
  final VoidCallback onEdit;

  Color _progressColor(double percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 75) return Colors.amber.shade700;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = budget.spendPercentage;
    final progress = budget.spendRatio;
    final color = _progressColor(percentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    budget.category,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            Text(
              'Spent ${budget.currency} ${budget.spent.toStringAsFixed(2)} of ${budget.currency} ${budget.limit.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Text('${percentage.toStringAsFixed(0)}%'),
                if (percentage >= 90) ...<Widget>[
                  const SizedBox(width: 6),
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
