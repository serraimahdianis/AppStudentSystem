// ─── Student Model ───────────────────────────────────────────────
class Student {
  final String id;
  final String fullName;
  final String email;
  final String studentId;
  final String rfidCode;
  final String qrCode;
  final String? faceImage;
  final String group;
  final String year;
  final String speciality;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.rfidCode,
    required this.qrCode,
    this.faceImage,
    required this.group,
    required this.year,
    required this.speciality,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      rfidCode: json['rfidCode']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      faceImage: json['faceImage']?.toString(),
      group: json['group']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      speciality: json['speciality']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'email': email,
    'studentId': studentId,
    'rfidCode': rfidCode,
    'qrCode': qrCode,
    'faceImage': faceImage,
    'group': group,
    'year': year,
    'speciality': speciality,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ─── Module Model ────────────────────────────────────────────────
class Module {
  final String id;
  final String name;
  final String teacherId;
  final String? teacherName;
  final String year;
  final DateTime createdAt;

  Module({
    required this.id,
    required this.name,
    required this.teacherId,
    this.teacherName,
    required this.year,
    required this.createdAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      teacherId: json['teacherId'] is Map ? json['teacherId']['_id']?.toString() ?? '' : json['teacherId']?.toString() ?? '',
      teacherName: json['teacherId'] is Map ? json['teacherId']['fullName']?.toString() : null,
      year: json['year']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

// ─── Schedule Model ──────────────────────────────────────────────
class Schedule {
  final String id;
  final String teacherId;
  final String? teacherName;
  final String moduleId;
  final String? moduleName;
  final String type; // cours | td | tp
  final String year; // L1 | L2 | L3 | M1 | M2
  final String? group;
  final String? speciality;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;

  Schedule({
    required this.id,
    required this.teacherId,
    this.teacherName,
    required this.moduleId,
    this.moduleName,
    required this.type,
    required this.year,
    this.group,
    this.speciality,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id']?.toString() ?? '',
      teacherId: (json['teacherId'] is Map ? json['teacherId']['_id']?.toString() : json['teacherId']?.toString()) ?? '',
      teacherName: json['teacherId'] is Map ? json['teacherId']['fullName']?.toString() : null,
      moduleId: (json['moduleId'] is Map ? json['moduleId']['_id']?.toString() : json['moduleId']?.toString()) ?? '',
      moduleName: json['moduleId'] is Map ? json['moduleId']['name']?.toString() : null,
      type: json['type']?.toString() ?? 'cours',
      year: json['year']?.toString() ?? '',
      group: json['group']?.toString(),
      speciality: json['speciality']?.toString(),
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
    );
  }

  String get typeLabel => type.toUpperCase();
}

// ─── Session Model ────────────────────────────────────────────────
class Session {
  final String id;
  final String? scheduleId;
  final String teacherId;
  final String? teacherName;
  final String moduleId;
  final String? moduleName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String type; // cours | td | tp
  final String group;
  final String? speciality;
  final String year; // Added for filtering
  final String status; // planned | active | closed
  final bool isReplacement;
  final String? reasonForReplacement;
  final String? room;

  Session({
    required this.id,
    this.scheduleId,
    required this.teacherId,
    this.teacherName,
    required this.moduleId,
    this.moduleName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.group,
    this.speciality,
    required this.year,
    required this.status,
    required this.isReplacement,
    this.reasonForReplacement,
    this.room,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id']?.toString() ?? '',
      scheduleId: (json['scheduleId'] is Map ? json['scheduleId']['_id']?.toString() : json['scheduleId']?.toString()),
      teacherId: (json['teacherId'] is Map ? json['teacherId']['_id']?.toString() : json['teacherId']?.toString()) ?? '',
      teacherName: json['teacherId'] is Map ? json['teacherId']['fullName']?.toString() : null,
      moduleId: (json['moduleId'] is Map ? json['moduleId']['_id']?.toString() : json['moduleId']?.toString()) ?? '',
      moduleName: json['moduleId'] is Map ? json['moduleId']['name']?.toString() : null,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      type: json['type']?.toString() ?? 'cours',
      group: json['group']?.toString() ?? '',
      speciality: json['speciality']?.toString(),
      year: () {
        if (json['year'] != null && json['year'].toString().isNotEmpty) return json['year'].toString();
        if (json['moduleId'] is Map) return json['moduleId']['year']?.toString() ?? '';
        return '';
      }(),
      status: json['status']?.toString() ?? 'planned',
      isReplacement: json['isReplacement'] is bool ? json['isReplacement'] : false,
      reasonForReplacement: json['reasonForReplacement'] is Map ? null : json['reasonForReplacement']?.toString(),
      room: () {
        if (json['room'] != null && json['room'].toString().isNotEmpty) return json['room'].toString();
        if (json['scheduleId'] is Map) return json['scheduleId']['room']?.toString();
        return null;
      }(),
    );
  }

  bool get isActive => status == 'active';
  bool get isUpcoming => status == 'planned';
  bool get isClosed => status == 'closed';
  
  String get typeLabel => type.toUpperCase();
  
  String get formattedDate {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String dayName = days[date.weekday - 1];
    return '$dayName, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── Attendance Model ─────────────────────────────────────────────
class Attendance {
  final String id;
  final String sessionId;
  final Session? session;
  final String studentId;
  final String status; // present | late | absent
  final DateTime scanTime;

  Attendance({
    required this.id,
    required this.sessionId,
    this.session,
    required this.studentId,
    required this.status,
    required this.scanTime,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id']?.toString() ?? '',
      sessionId: json['sessionId'] is Map ? json['sessionId']['_id']?.toString() ?? '' : json['sessionId']?.toString() ?? '',
      session: json['sessionId'] is Map ? Session.fromJson(json['sessionId']) : null,
      studentId: json['studentId'] is Map ? json['studentId']['_id']?.toString() ?? '' : json['studentId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'absent',
      scanTime: DateTime.tryParse(json['scanTime']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';
}

// ─── Module Attendance Stats ───────────────────────────────────────
class ModuleAttendanceStats {
  final Module module;
  final int totalSessions;
  final int present;
  final int absent;
  final int late;
  final bool isExcluded;
  final double attendanceRate;

  ModuleAttendanceStats({
    required this.module,
    required this.totalSessions,
    required this.present,
    required this.absent,
    required this.late,
    required this.isExcluded,
    required this.attendanceRate,
  });

  factory ModuleAttendanceStats.fromJson(Map<String, dynamic> json) {
    return ModuleAttendanceStats(
      module: Module(
        id: json['moduleId']?.toString() ?? '',
        name: json['moduleName']?.toString() ?? 'Unknown Module',
        teacherId: '',
        year: '',
        createdAt: DateTime.now(),
      ),
      totalSessions: _toInt(json['total'] ?? json['totalSessions']),
      present: _toInt(json['present']),
      absent: _toInt(json['absent']),
      late: _toInt(json['late']),
      isExcluded: json['isExcluded'] ?? false,
      attendanceRate: _toDouble(json['attendanceRate']),
    );
  }
}

// ─── Dashboard Data ────────────────────────────────────────────────
class DashboardData {
  final double attendanceRate;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalSessions;
  final Session? nextSession;
  final List<ModuleAttendanceStats> moduleStats;
  final List<Map<String, dynamic>> weeklyData;

  DashboardData({
    required this.attendanceRate,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
    required this.totalSessions,
    this.nextSession,
    required this.moduleStats,
    required this.weeklyData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      attendanceRate: _toDouble(json['attendanceRate']),
      totalPresent: _toInt(json['totalPresent']),
      totalAbsent: _toInt(json['totalAbsent']),
      totalLate: _toInt(json['totalLate']),
      totalSessions: _toInt(json['totalSessions']),
      nextSession: json['nextSession'] != null ? Session.fromJson(json['nextSession']) : null,
      moduleStats: (json['moduleStats'] as List? ?? [])
          .map((e) => ModuleAttendanceStats.fromJson(e))
          .toList(),
      weeklyData: List<Map<String, dynamic>>.from(json['weeklyData'] ?? []),
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

// ─── Notification Model ────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
