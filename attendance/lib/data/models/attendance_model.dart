/// Attendance Model
class AttendanceModel {
  final String id;
  final String userId;
  final DateTime date;
  final String status; // PRESENT, ABSENT, HALF_DAY, LEAVE, WEEK_OFF
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? location;
  final double? hoursWorked;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.location,
    this.hoursWorked,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      checkIn: json['checkIn'] != null 
          ? DateTime.parse(json['checkIn'] as String) 
          : null,
      checkOut: json['checkOut'] != null 
          ? DateTime.parse(json['checkOut'] as String) 
          : null,
      location: json['location'] as String?,
      hoursWorked: json['hoursWorked'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'status': status,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'location': location,
      'hoursWorked': hoursWorked,
    };
  }
}
