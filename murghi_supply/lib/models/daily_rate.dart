class DailyRate {
  final int? id;
  final String date; // stored as yyyy-MM-dd
  final double rate;
  final String description;

  DailyRate({
    this.id,
    required this.date,
    required this.rate,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'rate': rate,
      'description': description,
    };
  }

  factory DailyRate.fromMap(Map<String, dynamic> map) {
    return DailyRate(
      id: map['id'] as int?,
      date: map['date'] as String,
      rate: (map['rate'] as num).toDouble(),
      description: map['description'] as String? ?? '',
    );
  }

  DailyRate copyWith({
    int? id,
    String? date,
    double? rate,
    String? description,
  }) {
    return DailyRate(
      id: id ?? this.id,
      date: date ?? this.date,
      rate: rate ?? this.rate,
      description: description ?? this.description,
    );
  }
}
