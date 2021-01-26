import 'package:flutter/material.dart';
import 'package:isapp/formula/mth.dart';

import 'config_models.dart';

class LessonState extends ChangeNotifier {
  final int problemNum;

  int texNo;
  int lineNo;
  int correctNum;
  int life;
  List<LessonTex> lessonTexs;
  bool showsNext;
  bool wrongAnswerDisabled;
  bool succeeded;
  bool failed;

  @override
  String toString() {
    return 'LessonState{texNo: $texNo, lineNo: $lineNo, correctNum: $correctNum, life: $life, lessonTexs: $lessonTexs, showsNext: $showsNext, wrongAnswerDisabled: $wrongAnswerDisabled, succeeded: $succeeded, failed: $failed}';
  }

  LessonState({
    @required Serie serie,
    @required int lifeNum,
    @required this.problemNum,
  })  : texNo = 0,
        lineNo = 1,
        correctNum = 0,
        life = lifeNum,
        lessonTexs = serie.mth.makeLessonTexs(problemNum + lifeNum),
        showsNext = false,
        wrongAnswerDisabled = false,
        succeeded = false,
        failed = false;

  LessonTex get currentLessonTex => lessonTexs[texNo];
  TexLine get currentLine => lessonTexs[texNo].lines[lineNo];

  bool get showsChoices => !showsNext && !succeeded && !failed;

  bool correct() {
    lineNo++;
    if (lineNo == lessonTexs[texNo].lines.length) {
      correctNum++;
      if (correctNum < problemNum) {
        showsNext = true;
      } else {
        succeeded = true;
      }
    }
    wrongAnswerDisabled = false;
    notifyListeners();
    return succeeded;
  }

  void wrong() {
    life--;
    failed = life == 0;
    wrongAnswerDisabled = true;
    notifyListeners();
  }

  void goNext() {
    texNo++;
    lineNo = 1;
    showsNext = false;
    wrongAnswerDisabled = false;
    notifyListeners();
  }
}
