import 'package:fiap_m03_mobile_flutter/screens/home_screen_tabs/dashboard.dart';
import 'package:fiap_m03_mobile_flutter/screens/home_screen_tabs/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions(context);
  }

  void _loadTransactions(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      transactionProvider.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.pushNamed(context, '/transaction');
            },
            label: const Text(
              'Nova transação',
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black54),
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Bem-vindo, ${authProvider.user?.email}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 8),
                      Text('Dashboard')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.currency_exchange),
                      SizedBox(width: 8),
                      Text('Transações')
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: transactionProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Dashboard(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TransactionListPage(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
