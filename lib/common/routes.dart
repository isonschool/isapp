import 'package:flutter/material.dart';

enum IsonSchoolRoutes {
  category,
  recent,
  diplomas,
  lesson,
  exam,
  diploma,
  students,
  settings,
  categorySelector,
  notifications,
}

class IsonSchoolRoutePath {
  final IsonSchoolRoutes route;
  final String skey;

  IsonSchoolRoutePath.category()
      : route = IsonSchoolRoutes.category,
        skey = null;
  IsonSchoolRoutePath.recent()
      : route = IsonSchoolRoutes.recent,
        skey = null;
  IsonSchoolRoutePath.diplomas()
      : route = IsonSchoolRoutes.diplomas,
        skey = null;
  IsonSchoolRoutePath.lesson(this.skey) : route = IsonSchoolRoutes.lesson;
  IsonSchoolRoutePath.exam(this.skey) : route = IsonSchoolRoutes.exam;
  IsonSchoolRoutePath.diploma(this.skey) : route = IsonSchoolRoutes.diploma;
  IsonSchoolRoutePath.students()
      : route = IsonSchoolRoutes.students,
        skey = null;
  IsonSchoolRoutePath.settings()
      : route = IsonSchoolRoutes.settings,
        skey = null;
  IsonSchoolRoutePath.categorySelector()
      : route = IsonSchoolRoutes.categorySelector,
        skey = null;
  IsonSchoolRoutePath.notifications()
      : route = IsonSchoolRoutes.notifications,
        skey = null;

  bool get isCategory => route == IsonSchoolRoutes.category;
  bool get isRecent => route == IsonSchoolRoutes.recent;
  bool get isDiplomas => route == IsonSchoolRoutes.diplomas;
  bool get isLesson => route == IsonSchoolRoutes.lesson;
  bool get isExam => route == IsonSchoolRoutes.exam;
  bool get isDiploma => route == IsonSchoolRoutes.diploma;
  bool get isStudents => route == IsonSchoolRoutes.students;
  bool get isSettings => route == IsonSchoolRoutes.settings;
  bool get isCategorySelector => route == IsonSchoolRoutes.categorySelector;
  bool get isNotifications => route == IsonSchoolRoutes.notifications;
}

class IsonSchoolRouteInformationParser
    extends RouteInformationParser<IsonSchoolRoutePath> {
  @override
  Future<IsonSchoolRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.path == '/') {
      return IsonSchoolRoutePath.category();
    }
    var base = uri.pathSegments[0];
    if (base == 'students') {
      return IsonSchoolRoutePath.students();
    } else if (base == 'settings') {
      return IsonSchoolRoutePath.settings();
    } else if (base == 'diplomas') {
      return IsonSchoolRoutePath.diplomas();
    } else if (base == 'recent') {
      return IsonSchoolRoutePath.recent();
    } else if (base == 'notifications') {
      return IsonSchoolRoutePath.notifications();
    } else if (base == 'lesson') {
      var skey = uri.pathSegments[1];
      return IsonSchoolRoutePath.lesson(skey);
    } else if (base == 'exam') {
      var skey = uri.pathSegments[1];
      return IsonSchoolRoutePath.exam(skey);
    } else if (base == 'diploma') {
      var skey = uri.pathSegments[1];
      return IsonSchoolRoutePath.diploma(skey);
    }
    return null;
  }

  @override
  RouteInformation restoreRouteInformation(IsonSchoolRoutePath path) {
    if (path.isCategory) {
      return RouteInformation(location: '/');
    } else if (path.isLesson || path.isExam || path.isDiploma) {
      return RouteInformation(location: '/${path.route}/${path.skey}');
    }
    return RouteInformation(location: '/${path.route}');
  }
}
