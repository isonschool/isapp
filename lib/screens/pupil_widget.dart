import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/models/models.dart';

class PupilWidget extends StatelessWidget {
  final Student student;

  PupilWidget({
    this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: PupilImageWidget(pkey: student.pkey),
        title: Text(
            '${AppLocalizations.of(context).experience}: ${student.experience}'),
      ),
    );
  }
}

class PupilImageWidget extends StatelessWidget {
  final String pkey;

  PupilImageWidget({this.pkey});

  @override
  Widget build(BuildContext context) {
    if (pkey == null) {
      return Image.asset('assets/pupils/null.png');
    }
    return Image.asset('assets/pupils/$pkey.png');
  }
}
