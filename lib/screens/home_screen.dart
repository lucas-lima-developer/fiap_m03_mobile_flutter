import 'package:fiap_m03_mobile_flutter/screens/home_screen_tabs/dashboard.dart';
import 'package:fiap_m03_mobile_flutter/screens/home_screen_tabs/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                  borderRadius: BorderRadius.circular(50)),
            ),
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout,
                      color: Colors.black54), // Ícone discreto
                  onPressed: () async {
                    await authProvider.logout();
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
              title: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                  Text(
                    "Bem vindo, ${authProvider.user?.email}",
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.home), Text('Dashboard')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.currency_exchange),
                        Text('Transações')
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
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
            )),
      ),
    );
  }
}
