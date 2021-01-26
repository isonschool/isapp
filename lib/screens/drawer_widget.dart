import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/common/common.dart';
import 'package:isapp/models/models.dart';
import 'package:mdi/mdi.dart';

class DrawerWidget extends StatelessWidget {
  final RoutesHandler routesHandler;

  DrawerWidget({
    @required this.routesHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              'IsonSchool Math',
              style: Theme.of(context).primaryTextTheme.headline4,
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(AppLocalizations.of(context).home),
            onTap: () => routesHandler.categoryTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text(AppLocalizations.of(context).recent),
            onTap: () => routesHandler.recentTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(AppLocalizations.of(context).students),
            onTap: () => routesHandler.studentsTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context).notification),
            onTap: () => routesHandler.notificationsTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(AppLocalizations.of(context).age),
            onTap: () => routesHandler.categorySelectorTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings),
            onTap: () => routesHandler.settingsTapped(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Mdi.youtube),
            title: Text('YouTube'),
            onTap: () async => IsonSchoolUrl.launchYoutubeChannel(),
          ),
        ],
      ),
    );
  }
}
