import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/version.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/models/teacher.dart';
import 'package:isapp/screens/drawer_widget.dart';
import 'package:provider/provider.dart';

class SettingsPage extends MaterialPage {
  SettingsPage({RoutesHandler routesHandler})
      : super(
          key: ValueKey('SettingsPage'),
          child: SettingsScreen(routesHandler: routesHandler),
        );
}

class SettingsScreen extends StatelessWidget {
  final RoutesHandler routesHandler;

  SettingsScreen({this.routesHandler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      drawer: DrawerWidget(routesHandler: routesHandler),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Builder(
        builder: (context) => ListView(
          children: [
            Card(
              child: ListTile(
                title: Text(AppLocalizations.of(context).clearAllData),
                onTap: () async {
                  await _showConfirmDialog(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text(AppLocalizations.of(context).moreInfo),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: isonSchoolMathAppName,
                  applicationVersion: isonSchoolMathVersion,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context_) async {
    return showDialog<void>(
      context: context_,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).clearAllData),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).areYouSure),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).clearAllData),
              onPressed: () async {
                await context.read<Teacher>().clearAllData();
                Scaffold.of(context_).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context).allDataCleared),
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
