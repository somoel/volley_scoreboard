class MatchModel {
  final String id;
  final DateTime date;
  final String? location;

  MatchModel({
    required this.id,
    required this.date,
    this.location,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String?,
    );
  }
}
