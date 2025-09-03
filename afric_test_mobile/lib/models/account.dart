class Account {
  final String id;
  final String accountNumber;
  final String accountName;
  final double balance;
  final String currency;
  final String type;

  Account({
    required this.id,
    required this.accountNumber,
    required this.accountName,
    required this.balance,
    required this.currency,
    required this.type,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'],
      type: json['type'],
    );
  }
}
