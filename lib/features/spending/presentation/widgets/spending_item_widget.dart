import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealthpath/features/spending/domain/entities/spending_entity.dart';

class SpendingItemWidget extends StatelessWidget {
  const SpendingItemWidget({
    required this.item,
    super.key,
  });

  final SpendingEntity item;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d').format(item.date.toLocal());
    final amountText = '\$${item.amount.toStringAsFixed(2)}';

    return Card(
      child: ListTile(
        title: Text(item.merchant),
        subtitle: Text('${item.category} • $dateText'),
        trailing: Text(
          amountText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
