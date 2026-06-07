import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';

/// Singleton service to manage attendance state globally
class AttendanceService extends ChangeNotifier {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  // Current session state
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  String? _checkInLocation;
  
  // Attendance history
  final List<AttendanceModel> _attendanceHistory = [];

  // Getters
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  String? get checkInLocation => _checkInLocation;
  List<AttendanceModel> get attendanceHistory => List.unmodifiable(_attendanceHistory);

  // Check in
  Future<void> checkIn(String location) async {
    _isCheckedIn = true;
    _checkInTime = DateTime.now();
    _checkInLocation = location;
    notifyListeners();
  }

  // Check out and save to history
  Future<void> checkOut() async {
    if (!_isCheckedIn || _checkInTime == null) return;

    final checkOutTime = DateTime.now();
    final duration = checkOutTime.difference(_checkInTime!);
    final hoursWorked = duration.inMinutes / 60.0;

    // Create attendance record
    final record = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'EMP001',
      date: _checkInTime!,
      status: 'PRESENT',
      checkIn: _checkInTime,
      checkOut: checkOutTime,
      hoursWorked: hoursWorked,
      location: _checkInLocation,
    );

    // Add to history (at the beginning for latest first)
    _attendanceHistory.insert(0, record);

    // Reset state
    _isCheckedIn = false;
    _checkInTime = null;
    _checkInLocation = null;
    
    notifyListeners();
  }

  // Get duration since check-in
  Duration? getDuration() {
    if (_checkInTime == null) return null;
    return DateTime.now().difference(_checkInTime!);
  }

  // Reset (for testing/development)
  void reset() {
    _isCheckedIn = false;
    _checkInTime = null;
    _checkInLocation = null;
    notifyListeners();
  }
}
