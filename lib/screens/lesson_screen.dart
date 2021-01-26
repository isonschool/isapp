import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/common/icon_no.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/pupil_widget.dart';
import 'package:isapp/services/sound_service.dart';
import 'package:provider/provider.dart';

import 'ison_tex.dart';

class LessonPage extends Page {
  final Serie serie;
  final RoutesHandler routesHandler;

  LessonPage({
    @required this.serie,
    @required this.routesHandler,
  }) : super(
          key: ValueKey(serie),
          name: IsonSchoolRoutes.lesson.toString(),
          arguments: serie,
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        final students = context.select<Teacher, List<Student>>((t) =>
            t.selectStudents(
                2 * lessonProblemNum, serie.skey, Challenge.lesson));
        return ChangeNotifierProvider(
          create: (_) => LessonState(
            serie: serie,
            lifeNum: lifeNum,
            problemNum: lessonProblemNum,
          ),
          child: LessonScreen(
            serie: serie,
            students: students,
            routesHandler: routesHandler,
          ),
        );
      },
    );
  }
}

class LessonScreen extends StatelessWidget {
  final Serie serie;
  final List<Student> students;
  final RoutesHandler routesHandler;

  LessonScreen({
    @required this.serie,
    @required this.students,
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    final LessonState state = context.watch<LessonState>();
    print(state);
    if (state.succeeded) {
      return LessonSuccessScreen(
        serie: serie,
        students: students,
        routesHandler: routesHandler,
      );
    }
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text('${AppLocalizations.of(context).whichIsCorrect}'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < state.lineNo; i++)
              Card(
                child: ListTile(
                  leading: i == 0
                      ? Icon(
                          IconNo.iconData(state.texNo + 1),
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor,
                        )
                      : IsonTex(state.currentLessonTex.relationTex, width),
                  title: IsonTex(
                      state.currentLessonTex.lines[i].correctTex, width),
                ),
              ),
            Padding(padding: EdgeInsets.zero.copyWith(top: 10.0)),
            if (!state.showsNext)
              for (var i = 0; i < 2; i++)
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    tileColor: state.failed ||
                            (state.wrongAnswerDisabled &&
                                !state.currentLine.isCorrect(i))
                        ? null
                        : Theme.of(context).secondaryHeaderColor,
                    leading: PupilImageWidget(
                        pkey: students[(state.texNo * 2 + i) % students.length]
                            .pkey),
                    title: IsonTex(
                        '${state.currentLessonTex.relationTex} ${state.currentLine.choice(i)}',
                        width),
                    onTap: state.failed
                        ? null
                        : () async => await _answer(
                            context, state.currentLine.isCorrect(i)),
                    enabled: !(state.wrongAnswerDisabled &&
                        !state.currentLine.isCorrect(i)),
                  ),
                ),
            if (state.showsNext)
              Card(
                elevation: 5.0,
                child: ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  leading: Icon(Icons.navigate_next),
                  title: Text(AppLocalizations.of(context).next),
                  onTap: () => context.read<LessonState>().goNext(),
                ),
              ),
            if (state.failed)
              Card(
                elevation: 5.0,
                child: ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(
                    AppLocalizations.of(context).lessonFailed,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => routesHandler.categoryTapped(),
                ),
              )
          ],
        ),
      ),
      /*
      persistentFooterButtons: [
        if (state.failed)
          RaisedButton(
            color: Theme.of(context).secondaryHeaderColor,
            onPressed: () => routesHandler.categoryTapped(),
            child: Text(AppLocalizations.of(context).ok),
          ),
        if (state.showsNext)
          RaisedButton.icon(
            color: Theme.of(context).secondaryHeaderColor,
            icon: Icon(Icons.navigate_next),
            label: Text(AppLocalizations.of(context).next),
            onPressed: () => context.read<LessonState>().goNext(),
          ),
        if (state.showsChoices)
          for (var i = 0; i < 2; i++)
            RaisedButton(
              onPressed: state.wrongAnswerDisabled &&
                      !state.currentLine.isCorrect(i)
                  ? null
                  : () async =>
                      await _answer(context, state.currentLine.isCorrect(i)),
              color: Theme.of(context).secondaryHeaderColor,
              child: Padding(
                padding:
                    const EdgeInsets.all(0.0).copyWith(left: 25.0, right: 25.0),
                child: Container(
                  width: 55,
                  height: 55,
                  child: PupilImageWidget(
                      pkey: students[(state.texNo * 2 + i) % students.length]
                          .pkey),
                ),
              ),
            ),
      ],*/
    );
  }

  Future<void> _answer(BuildContext context, bool isCorrect) async {
    if (isCorrect) {
      if (context.read<LessonState>().correct()) {
        SoundService.playSuccess();
        await context.read<Teacher>().lessonSuccess(students, serie);
      } else {
        SoundService.playCorrect();
      }
    } else {
      SoundService.playWrong();
      context.read<LessonState>().wrong();
    }
  }
}

class LessonSuccessScreen extends StatelessWidget {
  final Serie serie;
  final List<Student> students;
  final RoutesHandler routesHandler;

  LessonSuccessScreen({
    @required this.serie,
    @required this.students,
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('${Localized.of(context).serieName(serie)}'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).lessonSuccess,
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      .copyWith(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            for (var student in students) PupilWidget(student: student),
          ],
        ),
      ),
      persistentFooterButtons: [
        RaisedButton(
          color: Theme.of(context).secondaryHeaderColor,
          child: Text(AppLocalizations.of(context).ok),
          onPressed: () => routesHandler.categoryTapped(),
        )
      ],
    );
  }
}
