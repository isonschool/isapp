import 'package:flutter/material.dart';
import 'package:isapp/formula/mth.dart';

import 'config_models.dart';

class DiplomaState extends ChangeNotifier {
  final int problemNum;

  int texNo;
  int correctNum;
  int life;
  List<DiplomaTex> diplomaTexs;
  List<int> disabledAnswers;
  bool succeeded;
  bool failed;
  bool isNewStudent;

  @override
  String toString() {
    return 'DiplomaState{problemNum: $problemNum, texNo: $texNo, correctNum: $correctNum, life: $life, diplomaTexs: $diplomaTexs, disabledAnswers: $disabledAnswers, succeeded: $succeeded, failed: $failed}';
  }

  DiplomaState({
    @required Serie serie,
    @required int lifeNum,
    @required this.problemNum,
    @required this.isNewStudent,
  })  : texNo = 0,
        correctNum = 0,
        life = lifeNum,
        diplomaTexs = serie.mth.makeDiplomaTexs(problemNum + lifeNum),
        disabledAnswers = [],
        succeeded = false,
        failed = false;

  DiplomaTex get currentDiplomaTex => diplomaTexs[texNo];

  bool get showsChoices => !succeeded && !failed;

  bool correct() {
    correctNum++;
    succeeded = correctNum == problemNum;
    if (!succeeded) texNo++;
    disabledAnswers = [];
    notifyListeners();
    return succeeded;
  }

  void wrong(int selectedAnswer) {
    life--;
    failed = life == 0;
    disabledAnswers = [...disabledAnswers, selectedAnswer];
    notifyListeners();
  }
}
