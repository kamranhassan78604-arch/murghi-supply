class Account {
  final int? id;
  final String accountName;
  final String address;
  final String supplyVehicle;
  final double previousBalance;
  final double supplyDiscount; // percentage or flat amount, treated as amount here

  Account({
    this.id,
    required this.accountName,
    required this.address,
    required this.supplyVehicle,
    required this.previousBalance,
    required this.supplyDiscount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountName': accountName,
      'address': address,
      'supplyVehicle': supplyVehicle,
      'previousBalance': previousBalance,
      'supplyDiscount': supplyDiscount,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      accountName: map['accountName'] as String,
      address: map['address'] as String? ?? '',
      supplyVehicle: map['supplyVehicle'] as String? ?? '',
      previousBalance: (map['previousBalance'] as num?)?.toDouble() ?? 0.0,
      supplyDiscount: (map['supplyDiscount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Account copyWith({
    int? id,
    String? accountName,
    String? address,
    String? supplyVehicle,
    double? previousBalance,
    double? supplyDiscount,
  }) {
    return Account(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      address: address ?? this.address,
      supplyVehicle: supplyVehicle ?? this.supplyVehicle,
      previousBalance: previousBalance ?? this.previousBalance,
      supplyDiscount: supplyDiscount ?? this.supplyDiscount,
    );
  }
}
