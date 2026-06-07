/// Leave Model
class LeaveModel {
  final String id;
  final String userId;
  final String leaveType; // SICK, CASUAL, ANNUAL, EMERGENCY
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // PENDING, APPROVED, REJECTED
  final DateTime appliedOn;
  final String? approvedBy;
  final String? rejectionReason;

  const LeaveModel({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.approvedBy,
    this.rejectionReason,
  });

  int get numberOfDays {
    return toDate.difference(fromDate).inDays + 1;
  }

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      leaveType: json['leaveType'] as String,
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      reason: json['reason'] as String,
      status: json['status'] as String,
      appliedOn: DateTime.parse(json['appliedOn'] as String),
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'leaveType': leaveType,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'appliedOn': appliedOn.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
    };
  }
}
