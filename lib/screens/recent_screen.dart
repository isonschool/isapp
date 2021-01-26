import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/drawer_widget.dart';
import 'package:isapp/screens/serie_card.dart';
import 'package:provider/provider.dart';

class RecentPage extends Page {
  final RoutesHandler routesHandler;

  RecentPage({this.routesHandler}) : super(key: ValueKey('RecentPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return RecentScreen(routesHandler: routesHandler);
      },
    );
  }
}

class RecentScreen extends StatelessWidget {
  final RoutesHandler routesHandler;

  RecentScreen({this.routesHandler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).recent),
      ),
      drawer: DrawerWidget(routesHandler: routesHandler),
      body: ListView(
        children: [
          for (var s in context.select<Teacher, List<Effort>>((t) => t.efforts))
            SerieCard(
              serie: context
                  .select<Config, Serie>((c) => c.getSerieBySkey(s.skey)),
              routesHandler: routesHandler,
            ),
        ],
      ),
    );
  }
}
