import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/core/di/injection.dart';
import 'package:wealthpath/features/spending/presentation/cubit/spending_cubit.dart';
import 'package:wealthpath/features/spending/presentation/pages/spending_page.dart';

void main() {
  configureDependencies();
  runApp(const WealthPathApp());
}

class WealthPathApp extends StatelessWidget {
  const WealthPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WealthPath',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: BlocProvider<SpendingCubit>(
        create: (_) => sl<SpendingCubit>(),
        child: const SpendingPage(),
      ),
    );
  }
}
