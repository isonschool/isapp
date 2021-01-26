import 'package:flutter/material.dart';
import 'package:isapp/formula/mth.dart';
import 'package:isapp/models/models.dart';

class ExamState extends ChangeNotifier {
  final Serie serie;
  final int lifeNum;
  final int problemNum;

  int texNo;
  int correctNum;
  int life;
  List<ExamTex> examTexs;
  bool showsNext;
  List<int> disabledAnswers;
  bool succeeded;
  bool failed;

  @override
  String toString() {
    return 'ExamState{serie: $serie, texNo: $texNo, correctNum: $correctNum, life: $life, examTexs: $examTexs}';
  }

  ExamState({
    @required this.serie,
    @required this.lifeNum,
    @required this.problemNum,
  })  : texNo = 0,
        correctNum = 0,
        life = lifeNum,
        examTexs = serie.mth.makeExamTexs(problemNum + lifeNum),
        showsNext = false,
        disabledAnswers = [],
        succeeded = false,
        failed = false;

  ExamTex get currentExamTex => examTexs[texNo];

  bool get showsChoices => !showsNext && !succeeded && !failed;

  bool correct() {
    correctNum++;
    succeeded = correctNum == problemNum;
    showsNext = !succeeded;
    notifyListeners();
    return succeeded;
  }

  void wrong(int selectedAnswer) {
    life--;
    failed = life == 0;
    disabledAnswers = [...disabledAnswers, selectedAnswer];
    notifyListeners();
  }

  void goNext() {
    texNo++;
    showsNext = false;
    disabledAnswers = [];
    notifyListeners();
  }
}
