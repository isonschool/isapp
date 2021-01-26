import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/models/models.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';

import 'ison_tex.dart';

class SerieCard extends StatelessWidget {
  final Serie serie;
  final RoutesHandler routesHandler;

  SerieCard({
    @required this.serie,
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    final effort = context.select<Teacher, Effort>((t) => t.efforts.singleWhere(
        (e) => e.skey == serie.skey,
        orElse: () => Effort(skey: serie.skey)));
    double width = MediaQuery.of(context).size.width;
    return Card(
      child: Column(
        children: [
          ListTile(
            title: IsonTex(serie.sampleTex, width),
            subtitle: Text(Localized.of(context).serieName(serie)),
          ),
          ButtonBar(
            children: [
              FlatButton.icon(
                icon: effort.studied > 0 ? Icon(Mdi.bookCheck) : Icon(Mdi.book),
                label: Text(AppLocalizations.of(context).lesson),
                onPressed: () => routesHandler.lessonTapped(serie.skey),
              ),
              FlatButton.icon(
                icon: effort.passed > 0
                    ? Icon(Mdi.textBoxCheck)
                    : Icon(Mdi.textBox),
                label: Text(AppLocalizations.of(context).exam),
                onPressed: () => routesHandler.examTapped(serie.skey),
              ),
              if (effort.passed > 0 && effort.studied > 0)
                FlatButton.icon(
                  icon: effort.graduated > 0
                      ? Icon(Mdi.certificate)
                      : Icon(Mdi.checkbook),
                  label: Text(AppLocalizations.of(context).diploma),
                  onPressed: () => routesHandler.diplomaTapped(serie.skey),
                ),
              //FlatButton.icon(
              //  icon: Icon(Mdi.calculator),
              //  label: Text('calSize'),
              //  onPressed: () => routesHandler.calSizeTapped(serie.skey),
              //),
            ],
          ),
        ],
      ),
    );
  }
}
