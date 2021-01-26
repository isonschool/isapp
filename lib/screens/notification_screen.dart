import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isapp/common/localization.dart';
import 'package:isapp/models/models.dart';
import 'package:provider/provider.dart';

class NotificationPage extends Page {
  final List<Notice> notices;
  final RoutesHandler routesHandler;

  NotificationPage({this.notices, this.routesHandler})
      : super(key: ValueKey('NotificationPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return NotificationScreen(
            notices: notices, routesHandler: routesHandler);
      },
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final List<Notice> notices;
  final RoutesHandler routesHandler;

  NotificationScreen({this.notices, this.routesHandler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${AppLocalizations.of(context).notification}'),
      ),
      body: ListView(
        children: [
          for (var notice in notices)
            Card(
              child: ListTile(
                leading: notice.noticeType == NoticeType.important
                    ? Icon(Icons.notifications)
                    : notice.noticeType == NoticeType.version
                        ? Icon(Icons.notification_important)
                        : Icon(Icons.message),
                title: Text(notice.noticeType == NoticeType.version
                    ? AppLocalizations.of(context).downloadLatestVersion
                    : Localized.of(context).noticeMessage(notice)),
                subtitle: notice.date == null
                    ? null
                    : Text(DateFormat.yMd().format(notice.date)),
              ),
            )
        ],
      ),
      persistentFooterButtons: [
        RaisedButton.icon(
            color: Theme.of(context).secondaryHeaderColor,
            icon: Icon(Icons.clear),
            label: Text(AppLocalizations.of(context).close),
            onPressed: () {
              context.read<Teacher>().updateLastNotified();
              routesHandler.categoryTapped();
            }),
      ],
    );
  }
}
