import 'dart:async';
import '../models/account.dart';

class MockApi {
  final List<Account> _accounts = [
    Account(
      id: 'acc_1',
      accountNumber: 'CM00100012345',
      accountName: 'Compte Principal',
      balance: 1250000,
      currency: 'XAF',
      type: 'checking',
    ),
    Account(
      id: 'acc_2',
      accountNumber: 'CM00100067890',
      accountName: 'Compte Épargne',
      balance: 3500000,
      currency: 'XAF',
      type: 'savings',
    ),
  ];

  Future<List<Account>> getAccounts() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _accounts;
  }

  Future<Account> getAccount(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _accounts.firstWhere((account) => account.id == id);
  }

  Future<bool> executeTransfer({
    required String fromAccountId,
    required String toAccountNumber,
    required double amount,
    required String currency,
    String? note,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random success/failure
    final isSuccess = true; // Change to false to test error case

    if (!isSuccess) {
      throw Exception('Échec du virement: Solde insuffisant');
    }

    return true;
  }
}
