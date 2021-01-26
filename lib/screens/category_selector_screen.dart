import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/localization.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/drawer_widget.dart';
import 'package:provider/provider.dart';

class CategorySelectorPage extends MaterialPage {
  CategorySelectorPage({
    @required RoutesHandler routesHandler,
  }) : super(
          key: ValueKey('CategorySelectorPage'),
          child: CategorySelectorScreen(
            routesHandler: routesHandler,
          ),
        );
}

class CategorySelectorScreen extends StatelessWidget {
  final RoutesHandler routesHandler;

  CategorySelectorScreen({
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).age),
      ),
      drawer: DrawerWidget(
        routesHandler: routesHandler,
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(AppLocalizations.of(context).selectYourAge),
            ),
          ),
          for (var c
              in context.select<Config, List<Category>>((c) => c.categories))
            Card(
              child: ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(
                    Localized.of(context).categoryName(c),
                  ),
                  onTap: () async {
                    await context.read<Teacher>().setCkey(c.ckey);
                    routesHandler.categoryTapped();
                  }),
            ),
        ],
      ),
    );
  }
}
