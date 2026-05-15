import 'package:flutter/material.dart';

class SpendingHeaderWidget extends StatelessWidget {
  const SpendingHeaderWidget({
    required this.total,
    required this.count,
    super.key,
  });

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _Metric(
              label: 'Total Spent',
              value: '\$${total.toStringAsFixed(2)}',
            ),
            _Metric(
              label: 'Transactions',
              value: '$count',
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: textTheme.titleLarge),
      ],
    );
  }
}
