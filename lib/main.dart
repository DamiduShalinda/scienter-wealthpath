import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthpath/core/di/injection.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:wealthpath/features/budgets/presentation/pages/budget_overview_page.dart';
import 'package:wealthpath/features/spending/presentation/cubit/spending_cubit.dart';
import 'package:wealthpath/features/spending/presentation/pages/spending_page.dart';

void main() {
  configureDependencies();
  runApp(const WealthPathApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/spending',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => _MainScaffold(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/spending',
          builder: (context, state) => BlocProvider<SpendingCubit>(
            create: (_) => sl<SpendingCubit>(),
            child: const SpendingPage(),
          ),
        ),
        GoRoute(
          path: '/budgets',
          builder: (context, state) => BlocProvider<BudgetCubit>(
            create: (_) => sl<BudgetCubit>(),
            child: const BudgetOverviewPage(),
          ),
        ),
      ],
    ),
  ],
);

class _MainScaffold extends StatelessWidget {
  const _MainScaffold({required this.child});

  final Widget child;

  int _currentIndex(String location) {
    if (location.startsWith('/budgets')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          if (index == 0) {
            context.go('/spending');
          } else {
            context.go('/budgets');
          }
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Spending',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
        ],
      ),
    );
  }
}

class WealthPathApp extends StatelessWidget {
  const WealthPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WealthPath',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
