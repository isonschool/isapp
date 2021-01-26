import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/default_teacher_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config_models.dart';

class Teacher extends ChangeNotifier {
  final SharedPreferences prefs;

  Teacher.fromSharedPreferences(SharedPreferences p)
      : this.fromJson(
            p, jsonDecode(p.getString('teacher') ?? defaultTeacherJson));

  Future<void> save() async {
    print('teacher json: ${this.toJson()}');
    var jsonStr = jsonEncode(this, toEncodable: (dynamic o) => o.toJson());
    print('save: $jsonStr');
    await prefs.setString('teacher', jsonStr);
  }

  Teacher.fromJson(SharedPreferences p, Map<String, dynamic> json)
      : prefs = p,
        tid = json['tid'] ?? Uuid().generateV4(),
        _ckey = json['ckey'],
        students = (json['students'] as List<dynamic>)
                ?.map((m) => Student.fromJson(m))
                ?.toList() ??
            [],
        efforts = (json['efforts'] as List<dynamic>)
                ?.map((e) => Effort.fromJson(e))
                ?.toList() ??
            [],
        experience = json['experience'] ?? 0,
        lastNotified = json['lastNotified'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'tid': tid,
      'ckey': _ckey,
      'students': students,
      'efforts': efforts,
      'experience': experience,
      'lastNotified': lastNotified,
    };
  }

  String tid;
  String _ckey;
  List<Student> students;
  List<Effort> efforts;
  int experience;
  int lastNotified;

  bool readNotices = false;

  Teacher({
    this.prefs,
    this.tid,
    this.students,
    this.efforts,
    this.experience,
    this.lastNotified,
    String ckey,
  }) : _ckey = ckey;

  get ckey => _ckey;

  Future<void> setCkey(String value) async {
    _ckey = value;
    await save();
    notifyListeners();
  }

  Future<void> updateLastNotified() async {
    lastNotified = DateTime.now().millisecondsSinceEpoch;
    readNotices = true;
    await save();
    notifyListeners();
  }

  Student getStudentByPkey(String pkey) {
    return students.singleWhere((s) => s.pkey == pkey, orElse: () => null);
  }

  List<Student> selectStudents(int n, String skey, Challenge challenge) {
    List<Student> ret = [];
    const a = 7027;
    const b = 4337;
    const c = 9586277;
    int x = (skey.hashCode ^ challenge.hashCode > 0
            ? skey.hashCode ^ challenge.hashCode
            : -(skey.hashCode ^ challenge.hashCode)) %
        c;
    for (var i = 0; i < 10 * n; i++) {
      x = (a * x + b) % c;
      var r = students[x % students.length];
      if (!ret.contains(r)) ret.add(r);
      if (ret.length == n) return ret;
    }
    throw Exception('Cannot selectStudents. $n, $skey, $challenge');
  }

  Future<void> diplomaSuccess(Serie serie) async {
    experience++;
    var effort = Effort(skey: serie.skey);
    if (efforts.any((e) => e.skey == serie.skey))
      effort = efforts.singleWhere((e) => e.skey == serie.skey);
    effort.graduated++;
    effort.update();
    efforts.remove(effort);
    efforts.insert(0, effort);

    var student =
        students.singleWhere((s) => s.pkey == serie.pkey, orElse: () => null);
    if (student == null) {
      student = Student(pkey: serie.pkey);
      students.add(student);
    }
    student.experience += 10;
    var studentEffort = student.efforts
        .singleWhere((e) => e.skey == serie.skey, orElse: () => null);
    if (studentEffort == null) {
      studentEffort = Effort(skey: serie.skey);
    }
    studentEffort.graduated++;
    studentEffort.update();
    student.efforts.remove(studentEffort);
    student.efforts.insert(0, studentEffort);
    await save();
    notifyListeners();
  }

  Future<void> examSuccess(List<Student> students, Serie serie) async {
    experience++;
    var effort = Effort(skey: serie.skey);
    if (efforts.any((e) => e.skey == serie.skey))
      effort = efforts.singleWhere((e) => e.skey == serie.skey);
    effort.passed++;
    effort.update();
    efforts.remove(effort);
    efforts.insert(0, effort);

    for (var student in students) {
      student.experience++;
      var effort = Effort(skey: serie.skey);
      if (student.efforts.any((e) => e.skey == serie.skey))
        effort = student.efforts.singleWhere((e) => e.skey == serie.skey);
      effort.passed++;
      effort.update();
      student.efforts.remove(effort);
      student.efforts.insert(0, effort);
    }
    await save();
    notifyListeners();
  }

  Future<void> lessonSuccess(List<Student> students, Serie serie) async {
    experience++;
    var effort = Effort(skey: serie.skey);
    if (efforts.any((e) => e.skey == serie.skey))
      effort = efforts.singleWhere((e) => e.skey == serie.skey);
    effort.studied++;
    effort.update();
    efforts.remove(effort);
    efforts.insert(0, effort);

    for (var student in students) {
      student.experience++;
      var effort = Effort(skey: serie.skey);
      if (student.efforts.any((e) => e.skey == serie.skey))
        effort = student.efforts.singleWhere((e) => e.skey == serie.skey);
      effort.studied++;
      effort.update();
      student.efforts.remove(effort);
      student.efforts.insert(0, effort);
    }
    await save();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    Teacher teacher = Teacher.fromJson(prefs, jsonDecode(defaultTeacherJson));
    this.students = teacher.students;
    this.efforts = teacher.efforts;
    this.experience = teacher.experience;
    await save();
    notifyListeners();
  }
}

class Effort {
  final String skey;
  int studied;
  int passed;
  int graduated;
  int updated;

  Effort({
    @required this.skey,
    this.studied = 0,
    this.passed = 0,
    this.graduated = 0,
    this.updated,
  }) {
    if (updated == null) updated = DateTime.now().millisecondsSinceEpoch;
  }

  Effort.fromJson(Map<String, dynamic> json)
      : skey = json['skey'],
        studied = json['studied'] ?? 0,
        passed = json['passed'] ?? 0,
        graduated = json['graduated'] ?? 0,
        updated = json['updated'] ?? 0;

  @override
  String toString() {
    return 'Effort{skey: $skey, studied: $studied, passed: $passed, graduated: $graduated, updated: $updated}';
  }

  void update() {
    updated = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() {
    return {
      'skey': skey,
      'studied': studied,
      'passed': passed,
      'graduated': graduated,
      'updated': updated,
    };
  }
}

class Student {
  String pkey;
  bool favorite;
  int experience;
  List<Effort> efforts;

  Student({
    this.pkey,
    this.favorite = false,
    this.experience = 0,
    this.efforts,
  }) {
    if (efforts == null) efforts = [];
  }

  Student.fromJson(Map<String, dynamic> json)
      : pkey = json['pkey'],
        experience = json['experience'] ?? 0,
        favorite = json['favorite'] ?? false,
        efforts = (json['efforts'] is List<dynamic>)
            ? (json['efforts'] as List<dynamic>)
                    ?.map((e) => Effort.fromJson(e))
                    ?.toList() ??
                []
            : [];

  @override
  String toString() {
    return 'Student{pkey: $pkey, favorite $favorite, experience: $experience, efforts: $efforts}';
  }

  Map<String, dynamic> toJson() {
    return {
      'pkey': pkey,
      'favorite': favorite,
      'experience': experience,
      'efforts': efforts,
    };
  }
}
