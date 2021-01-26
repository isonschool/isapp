import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/common/icon_no.dart';
import 'package:isapp/formula/mth.dart';
import 'package:isapp/models/exam_state.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/pupil_widget.dart';
import 'package:isapp/services/sound_service.dart';
import 'package:provider/provider.dart';

import 'ison_tex.dart';

class ExamPage extends Page {
  final Serie serie;
  final RoutesHandler routesHandler;

  ExamPage({
    @required this.serie,
    @required this.routesHandler,
  });

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        final students = context.select<Teacher, List<Student>>((t) =>
            t.selectStudents(examProblemNum, serie.skey, Challenge.exam));
        return ChangeNotifierProvider(
          create: (_) => ExamState(
            serie: serie,
            lifeNum: lifeNum,
            problemNum: examProblemNum,
          ),
          child: ExamScreen(
            serie: serie,
            students: students,
            routesHandler: routesHandler,
          ),
        );
      },
    );
  }
}

class ExamScreen extends StatelessWidget {
  final Serie serie;
  final List<Student> students;
  final RoutesHandler routesHandler;

  ExamScreen({
    @required this.serie,
    @required this.students,
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExamState>();
    if (state.succeeded)
      return ExamSuccessScreen(
        serie: serie,
        students: students,
        routesHandler: routesHandler,
      );
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text('${AppLocalizations.of(context).findAMistake}'),
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
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(bottom: 4.0),
              child: Card(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: PupilImageWidget(pkey: students[state.texNo].pkey),
                ),
              ),
            ),
            for (var i = 0; i < state.currentExamTex.tex.length; i++)
              Card(
                child: Column(
                  children: [
                    ListTile(
                      tileColor: i == 0 ||
                              !state.showsChoices ||
                              state.disabledAnswers.contains(i)
                          ? null
                          : Theme.of(context).secondaryHeaderColor,
                      leading: i == 0
                          ? Icon(
                              IconNo.iconData(state.texNo + 1),
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor,
                            )
                          : Icon(
                              Icons.clear,
                              color: Theme.of(context).primaryColorDark,
                            ),
                      title: IsonTex(
                          (i > 0
                                  ? (state.currentExamTex.relationTex + ' ')
                                  : '') +
                              state.currentExamTex.tex[i],
                          width),
                      subtitle: (!state.showsChoices &&
                              state.currentExamTex.tex[i] !=
                                  state.currentExamTex.correctTex[i])
                          ? IsonTex(
                              state.currentExamTex.relationTex +
                                  ' ' +
                                  state.currentExamTex.correctTex[i],
                              width)
                          : null,
                      onTap: i == 0 ||
                              !state.showsChoices ||
                              state.disabledAnswers.contains(i)
                          ? null
                          : () async => await _answer(
                                context,
                                state.currentExamTex,
                                i,
                              ),
                    ),
                  ],
                ),
              ),
            if (state.showsChoices)
              Card(
                child: ListTile(
                  tileColor: state.disabledAnswers.contains(-1)
                      ? null
                      : Theme.of(context).secondaryHeaderColor,
                  leading: Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  title: Text(AppLocalizations.of(context).correctAnswer),
                  onTap: state.disabledAnswers.contains(-1)
                      ? null
                      : () async =>
                          await _answer(context, state.currentExamTex, -1),
                ),
              ),
            if (state.showsNext)
              Card(
                elevation: 5.0,
                child: ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  leading: Icon(Icons.navigate_next),
                  title: Text(AppLocalizations.of(context).next),
                  onTap: () => context.read<ExamState>().goNext(),
                ),
              ),
            if (state.failed)
              Card(
                elevation: 5.0,
                child: ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(
                    AppLocalizations.of(context).examFailed,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
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
            onPressed: () => context.read<ExamState>().goNext(),
          ),
        if (state.showsChoices)
          for (var i = 1; i < state.currentExamTex.tex.length; i++)
            RaisedButton(
              color: Theme.of(context).secondaryHeaderColor,
              //icon: Icon(Icons.clear),
              child: Icon(IconNo.alphabetIconData(i)),
              onPressed: state.disabledAnswers.contains(i)
                  ? null
                  : () async => await _answer(
                        context,
                        state.currentExamTex,
                        i,
                      ),
            ),
        if (state.showsChoices)
          RaisedButton(
            color: Theme.of(context).secondaryHeaderColor,
            child: Icon(Icons.check_outlined),
            //label: Text(AppLocalizations.of(context).correct),
            onPressed: state.disabledAnswers.contains(-1)
                ? null
                : () async => await _answer(
                      context,
                      state.currentExamTex,
                      -1,
                    ),
          ),
      ],*/
    );
  }

  Future<void> _answer(
      BuildContext context, ExamTex examTex, int selectedAnswer) async {
    if (selectedAnswer == examTex.wrongNo) {
      if (context.read<ExamState>().correct()) {
        SoundService.playSuccess();
        await context.read<Teacher>().examSuccess(students, serie);
      } else {
        SoundService.playCorrect();
      }
    } else {
      SoundService.playWrong();
      context.read<ExamState>().wrong(selectedAnswer);
    }
  }
}

class ExamSuccessScreen extends StatelessWidget {
  final Serie serie;
  final List<Student> students;
  final RoutesHandler routesHandler;

  ExamSuccessScreen({
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
                  AppLocalizations.of(context).examPassed,
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
