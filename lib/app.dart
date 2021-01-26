import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/category_screen.dart';
import 'package:isapp/screens/category_selector_screen.dart';
import 'package:isapp/screens/diploma_screen.dart';
import 'package:isapp/screens/exam_screen.dart';
import 'package:isapp/screens/lesson_screen.dart';
import 'package:isapp/screens/notification_screen.dart';
import 'package:isapp/screens/recent_screen.dart';
import 'package:isapp/screens/settings_screen.dart';
import 'package:isapp/screens/students_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve(
      {List<RouteTransitionRecord> newPageRouteHistory,
      Map<RouteTransitionRecord, RouteTransitionRecord>
          locationToExitingPageRoute,
      Map<RouteTransitionRecord, List<RouteTransitionRecord>>
          pageRouteToPagelessRoutes}) {
    final results = <RouteTransitionRecord>[];
    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }

    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }

      results.add(exitingPageRoute);
    }
    return results;
  }
}

class IsonSchoolRouterDelegate extends RouterDelegate<IsonSchoolRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<IsonSchoolRoutePath>
    implements RoutesHandler {
  final GlobalKey<NavigatorState> navigatorKey;

  IsonSchoolRoutes _route;
  String _skey;

  IsonSchoolRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  IsonSchoolRoutePath get currentConfiguration {
    if (_route == IsonSchoolRoutes.students) {
      return IsonSchoolRoutePath.students();
    } else if (_route == IsonSchoolRoutes.recent) {
      return IsonSchoolRoutePath.recent();
    } else if (_route == IsonSchoolRoutes.lesson) {
      return IsonSchoolRoutePath.lesson(_skey);
    } else if (_route == IsonSchoolRoutes.exam) {
      return IsonSchoolRoutePath.exam(_skey);
    } else if (_route == IsonSchoolRoutes.diploma) {
      return IsonSchoolRoutePath.diploma(_skey);
    } else if (_route == IsonSchoolRoutes.settings) {
      return IsonSchoolRoutePath.settings();
    } else if (_route == IsonSchoolRoutes.categorySelector) {
      return IsonSchoolRoutePath.categorySelector();
    }
    return IsonSchoolRoutePath.category();
  }

  @override
  Widget build(BuildContext context) {
    final ckey = context.select<Teacher, String>((t) => t.ckey);
    final notices = context.select<Config, List<Notice>>((t) => t.notices);
    final readNotices = context.select<Teacher, bool>((t) =>
        t.readNotices ||
        notices.every((n) =>
            n.date != null &&
            n.date.isBefore(
                DateTime.fromMillisecondsSinceEpoch(t.lastNotified))));
    return Navigator(
      key: navigatorKey,
      transitionDelegate: NoAnimationTransitionDelegate(),
      pages: [
        if (ckey != null)
          CategoryPage(
            category: context
                .select<Config, Category>((c) => c.getCategoryByCkey(ckey)),
            routesHandler: this,
          ),
        if (ckey == null || _route == IsonSchoolRoutes.categorySelector)
          CategorySelectorPage(
            routesHandler: this,
          ),
        if (_route == IsonSchoolRoutes.students)
          StudentsPage(routesHandler: this),
        if (_route == IsonSchoolRoutes.settings)
          SettingsPage(routesHandler: this),
        if (_route == IsonSchoolRoutes.recent) RecentPage(routesHandler: this),
        if (_route == IsonSchoolRoutes.lesson)
          LessonPage(
            serie:
                context.select<Config, Serie>((c) => c.getSerieBySkey(_skey)),
            routesHandler: this,
          ),
        if (_route == IsonSchoolRoutes.exam)
          ExamPage(
            serie:
                context.select<Config, Serie>((c) => c.getSerieBySkey(_skey)),
            routesHandler: this,
          ),
        if (_route == IsonSchoolRoutes.diploma)
          DiplomaPage(
            serie:
                context.select<Config, Serie>((c) => c.getSerieBySkey(_skey)),
            routesHandler: this,
          ),
        if (!readNotices || _route == IsonSchoolRoutes.notifications)
          NotificationPage(
            notices: notices,
            routesHandler: this,
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        _route = IsonSchoolRoutes.category;
        _skey = null;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(IsonSchoolRoutePath path) async {
    if (path == null) return;
    _route = path.route;
    _skey = path.skey;
  }

  void categoryTapped() {
    _route = IsonSchoolRoutes.category;
    _skey = null;
    notifyListeners();
  }

  void recentTapped() {
    _route = IsonSchoolRoutes.recent;
    _skey = null;
    notifyListeners();
  }

  void diplomasTapped() {
    _route = IsonSchoolRoutes.diplomas;
    _skey = null;
    notifyListeners();
  }

  void studentsTapped() {
    _route = IsonSchoolRoutes.students;
    _skey = null;
    notifyListeners();
  }

  void settingsTapped() {
    _route = IsonSchoolRoutes.settings;
    _skey = null;
    notifyListeners();
  }

  void categorySelectorTapped() {
    _route = IsonSchoolRoutes.categorySelector;
    _skey = null;
    notifyListeners();
  }

  void notificationsTapped() {
    _route = IsonSchoolRoutes.notifications;
    _skey = null;
    notifyListeners();
  }

  void lessonTapped(String skey) {
    _route = IsonSchoolRoutes.lesson;
    _skey = skey;
    notifyListeners();
  }

  void examTapped(String skey) {
    _route = IsonSchoolRoutes.exam;
    _skey = skey;
    notifyListeners();
  }

  void diplomaTapped(String skey) {
    _route = IsonSchoolRoutes.diploma;
    _skey = skey;
    notifyListeners();
  }
}

class _IsonSchoolAppState extends State<IsonSchoolApp> {
  IsonSchoolRouterDelegate _routerDelegate = IsonSchoolRouterDelegate();
  IsonSchoolRouteInformationParser _routeInformationParser =
      IsonSchoolRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(
          create: (_) async => await Config.fromRemoteConfig(widget.prefs),
          initialData: Config.loadConfig(widget.prefs),
        ),
        ChangeNotifierProvider(
            create: (_) => Teacher.fromSharedPreferences(widget.prefs)),
      ],
      child: MaterialApp.router(
        title: 'IsonSchool Math',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
        theme: IsonSchoolTheme.theme,
        localizationsDelegates: [
          Localized.delegate,
          ...AppLocalizations.localizationsDelegates
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

class IsonSchoolApp extends StatefulWidget {
  final SharedPreferences prefs;
  IsonSchoolApp(this.prefs);

  @override
  State<StatefulWidget> createState() => _IsonSchoolAppState();
}
