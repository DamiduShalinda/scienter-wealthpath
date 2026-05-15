import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.wifi_off, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text('Offline - Showing cached data'),
          ),
        ],
      ),
    );
  }
}
