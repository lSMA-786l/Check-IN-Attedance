import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/notification_model.dart';
import '../models/leave_model.dart';
import '../models/announcement_model.dart';

/// Mock Data for AttendNova Employee Role
class MockData {
  // Current logged-in user (Employee)
  static final UserModel currentUser = UserModel(
    id: 'EMP001',
    role: 'EMPLOYEE',
    name: 'Sarah Field',
    managerId: 'MGR001',
    email: 'sarah.field@attendnova.com',
    phone: '+919876543210',
    designation: 'Field Executive',
    department: 'Operations',
  );

  // Manager
  static final UserModel manager = UserModel(
    id: 'MGR001',
    role: 'MANAGER',
    name: 'John Manager',
    email: 'john.manager@attendnova.com',
    phone: '+919876543211',
    designation: 'Senior Field Lead',
    department: 'Operations',
  );

  // Attendance Records (Last 30 days)
  static final List<AttendanceModel> attendanceRecords = _generateAttendanceRecords();

  static List<AttendanceModel> _generateAttendanceRecords() {
    final List<AttendanceModel> records = [];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dayOfWeek = date.weekday;

      // Skip Sundays (7)
      if (dayOfWeek == 7) {
        records.add(AttendanceModel(
          id: 'ATT_${30 - i}',
          userId: currentUser.id,
          date: DateTime(date.year, date.month, date.day),
          status: 'WEEK_OFF',
        ));
        continue;
      }

      // Generate varied attendance patterns
      String status;
      DateTime? checkIn;
      DateTime? checkOut;
      double? hoursWorked;

      if (i == 2 || i == 15) {
        // Absent days
        status = 'ABSENT';
      } else if (i == 5 || i == 20) {
        // Leave days
        status = 'LEAVE';
      } else if (i == 10) {
        // Half day
        status = 'HALF_DAY';
        checkIn = DateTime(date.year, date.month, date.day, 9, 0);
        checkOut = DateTime(date.year, date.month, date.day, 13, 0);
        hoursWorked = 4.0;
      } else {
        // Present days with varied hours
        status = 'PRESENT';
        final checkInHour = 8 + (i % 2); // 8 or 9 AM
        final checkInMinute = (i * 7) % 60;
        final workHours = 8 + (i % 3) * 0.5; // 8, 8.5, or 9 hours

        checkIn = DateTime(date.year, date.month, date.day, checkInHour, checkInMinute);
        checkOut = checkIn.add(Duration(hours: workHours.toInt(), minutes: ((workHours % 1) * 60).toInt()));
        hoursWorked = workHours;
      }

      records.add(AttendanceModel(
        id: 'ATT_${30 - i}',
        userId: currentUser.id,
        date: DateTime(date.year, date.month, date.day),
        status: status,
        checkIn: checkIn,
        checkOut: checkOut,
        location: checkIn != null ? '123 Tech Park, Pune' : null,
        hoursWorked: hoursWorked,
      ));
    }

    return records;
  }

  // Statistics
  static Map<String, dynamic> get statistics {
    final presentDays = attendanceRecords.where((r) => r.status == 'PRESENT' || r.status == 'HALF_DAY').length;
    final totalHours = attendanceRecords
        .where((r) => r.hoursWorked != null)
        .fold<double>(0, (sum, r) => sum + (r.hoursWorked ?? 0));
    final workingDays = attendanceRecords.where((r) => r.status != 'WEEK_OFF').length;
    final attendancePercentage = workingDays > 0 ? (presentDays / workingDays * 100).round() : 0;
    final leavesTaken = attendanceRecords.where((r) => r.status == 'LEAVE').length;

    return {
      'presentDays': presentDays,
      'totalHours': totalHours.round(),
      'attendancePercentage': attendancePercentage,
      'leavesTaken': leavesTaken,
    };
  }

  // Notifications
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'NOTIF_001',
      userId: currentUser.id,
      title: 'Leave Approved',
      body: 'Your sick leave for Dec 15 has been approved by John Manager.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NOTIF_002',
      userId: currentUser.id,
      title: 'Regularization Request Rejected',
      body: 'Your regularization request for Nov 28 has been rejected. Please contact your manager.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NOTIF_003',
      userId: currentUser.id,
      title: 'Ticket Updated',
      body: 'Your support ticket #1234 has been updated. Status: In Progress.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ),
    NotificationModel(
      id: 'NOTIF_004',
      userId: currentUser.id,
      title: 'New Announcement',
      body: 'Team meeting scheduled for tomorrow at 10:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      isRead: true,
    ),
    NotificationModel(
      id: 'NOTIF_005',
      userId: currentUser.id,
      title: 'Attendance Reminder',
      body: 'Don\'t forget to mark your attendance today!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  // Leave Records
  static final List<LeaveModel> leaveRecords = [
    LeaveModel(
      id: 'LEAVE_001',
      userId: currentUser.id,
      leaveType: 'SICK',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 10)),
      reason: 'Medical appointment',
      status: 'APPROVED',
      appliedOn: DateTime.now().subtract(const Duration(days: 5)),
      approvedBy: manager.id,
    ),
    LeaveModel(
      id: 'LEAVE_002',
      userId: currentUser.id,
      leaveType: 'CASUAL',
      fromDate: DateTime.now().add(const Duration(days: 20)),
      toDate: DateTime.now().add(const Duration(days: 22)),
      reason: 'Personal work',
      status: 'PENDING',
      appliedOn: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LeaveModel(
      id: 'LEAVE_003',
      userId: currentUser.id,
      leaveType: 'ANNUAL',
      fromDate: DateTime.now().subtract(const Duration(days: 45)),
      toDate: DateTime.now().subtract(const Duration(days: 40)),
      reason: 'Family vacation',
      status: 'APPROVED',
      appliedOn: DateTime.now().subtract(const Duration(days: 60)),
      approvedBy: manager.id,
    ),
    LeaveModel(
      id: 'LEAVE_004',
      userId: currentUser.id,
      leaveType: 'SICK',
      fromDate: DateTime.now().subtract(const Duration(days: 15)),
      toDate: DateTime.now().subtract(const Duration(days: 15)),
      reason: 'Fever',
      status: 'APPROVED',
      appliedOn: DateTime.now().subtract(const Duration(days: 16)),
      approvedBy: manager.id,
    ),
    LeaveModel(
      id: 'LEAVE_005',
      userId: currentUser.id,
      leaveType: 'EMERGENCY',
      fromDate: DateTime.now().subtract(const Duration(days: 5)),
      toDate: DateTime.now().subtract(const Duration(days: 5)),
      reason: 'Family emergency',
      status: 'REJECTED',
      appliedOn: DateTime.now().subtract(const Duration(days: 6)),
      rejectionReason: 'Insufficient documentation provided',
    ),
    LeaveModel(
      id: 'LEAVE_006',
      userId: currentUser.id,
      leaveType: 'CASUAL',
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now().subtract(const Duration(days: 29)),
      reason: 'Wedding attendance',
      status: 'APPROVED',
      appliedOn: DateTime.now().subtract(const Duration(days: 40)),
      approvedBy: manager.id,
    ),
  ];

  // Leave Balances
  static final Map<String, Map<String, int>> leaveBalances = {
    'SICK': {'used': 2, 'total': 10},
    'CASUAL': {'used': 3, 'total': 12},
    'ANNUAL': {'used': 5, 'total': 20},
  };

  // Manager Announcements
  static final List<AnnouncementModel> announcements = [
    AnnouncementModel(
      id: 'ANN_001',
      managerId: manager.id,
      title: 'Team Meeting Tomorrow',
      message: 'Reminder: We have our monthly team sync tomorrow at 10:00 AM. Please be on time.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isPinned: true,
    ),
    AnnouncementModel(
      id: 'ANN_002',
      managerId: manager.id,
      title: 'New Attendance Policy',
      message: 'Please note the updated attendance policy. Grace period is now 15 minutes instead of 30 minutes.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isPinned: true,
    ),
    AnnouncementModel(
      id: 'ANN_003',
      managerId: manager.id,
      title: 'Holiday Notification',
      message: 'Office will be closed on December 25th for Christmas. Happy holidays!',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isPinned: false,
    ),
    AnnouncementModel(
      id: 'ANN_004',
      managerId: manager.id,
      title: 'Performance Reviews',
      message: 'Q4 performance reviews will be conducted next week. Please prepare your self-assessment.',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isPinned: true,
    ),
  ];

  // Check-in status for today
  static bool get isCheckedInToday {
    final today = DateTime.now();
    final todayRecord = attendanceRecords.firstWhere(
      (r) => r.date.year == today.year && 
             r.date.month == today.month && 
             r.date.day == today.day,
      orElse: () => AttendanceModel(
        id: '',
        userId: '',
        date: today,
        status: 'ABSENT',
      ),
    );
    return todayRecord.checkIn != null;
  }
}
