import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/models/teacher.dart';
import 'package:isapp/screens/drawer_widget.dart';
import 'package:provider/provider.dart';

import 'pupil_widget.dart';

class StudentsPage extends MaterialPage {
  StudentsPage({RoutesHandler routesHandler})
      : super(
          key: ValueKey('StudentsPage'),
          child: StudentsScreen(routesHandler: routesHandler),
        );
}

class StudentsScreen extends StatelessWidget {
  final RoutesHandler routesHandler;

  StudentsScreen({this.routesHandler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      drawer: DrawerWidget(routesHandler: routesHandler),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).students),
      ),
      body: ListView(
        children: [
          for (var s
              in context.select<Teacher, List<Student>>((t) => t.students))
            PupilWidget(student: s),
        ],
      ),
    );
  }
}
