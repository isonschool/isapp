import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/common/icon_no.dart';
import 'package:isapp/formula/mth.dart';
import 'package:isapp/models/diploma_state.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/pupil_widget.dart';
import 'package:isapp/services/sound_service.dart';
import 'package:provider/provider.dart';

import 'ison_tex.dart';

class DiplomaPage extends Page {
  final Serie serie;
  final RoutesHandler routesHandler;

  DiplomaPage({@required this.serie, @required this.routesHandler})
      : super(
          key: ValueKey(serie),
          name: IsonSchoolRoutes.diploma.toString(),
          arguments: serie,
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => DiplomaState(
            serie: serie,
            lifeNum: lifeNum,
            problemNum: diplomaProblemNum,
            isNewStudent:
                context.read<Teacher>().getStudentByPkey(serie.pkey) == null,
          ),
          child: DiplomaScreen(
            serie: serie,
            routesHandler: routesHandler,
          ),
        );
      },
    );
  }
}

class DiplomaScreen extends StatefulWidget {
  final Serie serie;
  final RoutesHandler routesHandler;

  DiplomaScreen({
    @required this.serie,
    @required this.routesHandler,
  });

  @override
  State<StatefulWidget> createState() {
    return _DiplomaScreenState();
  }
}

class _DiplomaScreenState extends State<DiplomaScreen> {
  int timeRemained;
  bool timeOver;
  Timer timer;

  @override
  void initState() {
    timeRemained = 100;
    timeOver = false;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeRemained--;
        if (timeRemained <= 0) {
          timer.cancel();
          timeElapsed();
        }
      });
    });
    super.initState();
  }

  timeElapsed() {
    setState(() {
      context.read<DiplomaState>().failed = true;
      timeOver = true;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DiplomaState state = context.watch<DiplomaState>();
    print(state);
    if (state.succeeded) {
      return DiplomaSuccessScreen(
        serie: widget.serie,
        routesHandler: widget.routesHandler,
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
            Card(
              child: ListTile(
                leading: Icon(Icons.timer),
                trailing: timeOver
                    ? Text(AppLocalizations.of(context).timeOver)
                    : Text('$timeRemained'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(
                  IconNo.iconData(state.texNo + 1),
                  color: Theme.of(context).textSelectionTheme.selectionColor,
                ),
                title: IsonTex(state.currentDiplomaTex.problemTex, width),
              ),
            ),
            Padding(padding: EdgeInsets.zero.copyWith(top: 10.0)),
            for (var i = 0; i < 4; i++)
              Card(
                elevation: 5.0,
                child: ListTile(
                  tileColor: state.failed || state.disabledAnswers.contains(i)
                      ? null
                      : Theme.of(context).secondaryHeaderColor,
                  leading: Icon(
                    IconNo.alphabetCircleIconData(i),
                    color: Theme.of(context).primaryColorDark,
                  ),
                  title: i < 3
                      ? IsonTex(
                          '${state.currentDiplomaTex.relationTex} ${state.currentDiplomaTex.answerTexs[i]}',
                          width)
                      : Text(AppLocalizations.of(context).noneOfTheAbove),
                  onTap: state.failed
                      ? null
                      : () async =>
                          await _answer(context, state.currentDiplomaTex, i),
                  enabled: !state.disabledAnswers.contains(i),
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
                        .headline1
                        .copyWith(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => widget.routesHandler.categoryTapped(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _answer(
      BuildContext context, DiplomaTex diplomaTex, int selectedAnswer) async {
    if (selectedAnswer == diplomaTex.correctAnswerNo) {
      if (context.read<DiplomaState>().correct()) {
        SoundService.playSuccessDiploma();
        await context.read<Teacher>().diplomaSuccess(widget.serie);
      } else {
        SoundService.playCorrect();
      }
    } else {
      SoundService.playWrong();
      context.read<DiplomaState>().wrong(selectedAnswer);
    }
  }
}

class DiplomaSuccessScreen extends StatelessWidget {
  final Serie serie;
  final RoutesHandler routesHandler;

  DiplomaSuccessScreen({
    @required this.serie,
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    final Student student =
        context.select<Teacher, Student>((t) => t.getStudentByPkey(serie.pkey));
    final isNewStudent =
        context.select<DiplomaState, bool>((s) => s.isNewStudent);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('${Localized.of(context).serieName(serie)}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text(
                AppLocalizations.of(context).diplomaSuccess,
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (!isNewStudent) PupilWidget(student: student),
          if (isNewStudent) NewStudentWidget(pkey: student.pkey),
        ],
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

class NewStudentWidget extends StatelessWidget {
  final String pkey;

  NewStudentWidget({@required this.pkey});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text(AppLocalizations.of(context).joinedNewStudent),
          ),
        ),
        Card(
          child: SizedBox(
            width: 128,
            height: 128,
            child: PupilImageWidget(pkey: pkey),
          ),
        ),
      ],
    );
  }
}
