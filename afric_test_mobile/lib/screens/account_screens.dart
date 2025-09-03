import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/mock_api.dart';
import 'transfer_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final MockApi _api = MockApi();
  late Future<List<Account>> _accountsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _api.getAccounts();
  }

  String _formatXAF(double amount) {
    return NumberFormat.currency(
      locale: 'fr_CM',
      symbol: 'FCFA',
      decimalDigits: 0,
    ).format(amount);
  }

  void _navigateToTransfer(BuildContext context, String fromAccountId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferScreen(fromAccountId: fromAccountId),
      ),
    );
  }

  void _showQuickTransfer(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickTransferModal(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Comptes'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _accountsFuture = _api.getAccounts();
                    }),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final accounts = snapshot.data!;
          final totalBalance = accounts.fold<double>(
            0,
            (sum, account) => sum + account.balance,
          );

          return Column(
            children: [
              // Total Balance Card
              _buildTotalBalanceCard(totalBalance),

              // Accounts List
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _buildAccountCard(account, context);
                  },
                ),
              ),

              FloatingActionButton(
                onPressed: () {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    _showQuickTransfer(context, snapshot.data!.first);
                  }
                },
                backgroundColor: Colors.blue[800],
                child: const Icon(Icons.history, color: Colors.white),
                tooltip: 'Virement rapide',
              ),

              SizedBox(height: 200),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Solde Total',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatXAF(totalBalance),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(Account account, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAccountColor(account.type),
          child: Icon(_getAccountIcon(account.type), color: Colors.white),
        ),
        title: Text(
          account.accountName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account.accountNumber),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatXAF(account.balance),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              _getAccountTypeLabel(account.type),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () => _navigateToTransfer(context, account.id),
        onLongPress: () => _showQuickTransfer(context, account),
      ),
    );
  }

  Color _getAccountColor(String type) {
    switch (type) {
      case 'checking':
        return Colors.blue;
      case 'savings':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.credit_card;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'checking':
        return 'Compte Courant';
      case 'savings':
        return 'Compte Épargne';
      default:
        return type;
    }
  }
}

class QuickTransferModal extends StatelessWidget {
  final Account account;

  const QuickTransferModal({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Virement Rapide - ${account.accountName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Nouveau virement'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransferScreen(fromAccountId: account.id),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique des virements'),
            onTap: () {
              // Navigate to transfer history
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
