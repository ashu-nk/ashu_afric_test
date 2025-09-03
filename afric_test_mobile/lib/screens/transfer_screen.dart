import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/mock_api.dart';

class TransferScreen extends StatefulWidget {
  final String fromAccountId;

  const TransferScreen({Key? key, required this.fromAccountId})
    : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final MockApi _api = MockApi();
  final _formKey = GlobalKey<FormState>();
  final _beneficiaryController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late Future<Account> _fromAccountFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fromAccountFuture = _api.getAccount(widget.fromAccountId);
  }

  String _formatXAF(double amount) {
    return NumberFormat.currency(
      locale: 'fr_CM',
      symbol: 'FCFA',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final fromAccount = await _fromAccountFuture;

      if (amount > fromAccount.balance) {
        setState(() {
          _errorMessage = 'Le montant dépasse le solde du compte';
          _isLoading = false;
        });
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success confirmation
      _showConfirmationDialog(fromAccount, amount, () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur lors du virement: $error';
        _isLoading = false;
      });
    }
  }

  _showConfirmationDialog(
    Account fromAccount,
    double amount,
    void Function()? onPressed,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le Virement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De: ${fromAccount.accountName}'),
            Text('Vers: ${_beneficiaryController.text}'),
            Text('Montant: ${_formatXAF(amount)}'),
            if (_noteController.text.isNotEmpty)
              Text('Note: ${_noteController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            //() => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _executeTransfer();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeTransfer() async {
    setState(() => _isLoading = true);

    try {
      // Simulate transfer execution
      await Future.delayed(const Duration(seconds: 3));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Virement effectué avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Return to previous screen
    } catch (error) {
      setState(() {
        _errorMessage = 'Échec du virement: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Virement'),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<Account>(
        future: _fromAccountFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final fromAccount = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Source Account Info
                  _buildAccountInfo(fromAccount),
                  const SizedBox(height: 24),

                  // Beneficiary Field
                  TextFormField(
                    controller: _beneficiaryController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],

                    decoration: const InputDecoration(
                      labelText: 'Numéro bénéficiaire*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir le numéro du bénéficiaire';
                      }
                      if (!RegExp(r'^\d{10,20}$').hasMatch(value)) {
                        return 'Le numéro doit contenir 10 à 20 chiffres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],

                    decoration: InputDecoration(
                      labelText: 'Montant (FCFA)*',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: 'Solde: ${_formatXAF(fromAccount.balance)}',
                      suffixStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir le montant';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Le montant doit être supérieur à 0';
                      }
                      if (amount > fromAccount.balance) {
                        return 'Le montant dépasse le solde disponible';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Note Field
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optionnel)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Effectuer le virement',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountInfo(Account account) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compte source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('${account.accountName} (${account.accountNumber})'),
            const SizedBox(height: 4),
            Text(
              _formatXAF(account.balance),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
