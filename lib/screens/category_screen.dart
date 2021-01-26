import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isapp/models/models.dart';
import 'package:isapp/screens/drawer_widget.dart';
import 'package:isapp/screens/serie_card.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';

class CategoryPage extends Page {
  final Category category;
  final RoutesHandler routesHandler;

  CategoryPage({this.category, this.routesHandler})
      : super(key: ValueKey(category), arguments: category);

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return CategoryScreen(category: category, routesHandler: routesHandler);
      },
    );
  }
}

class CategoryScreen extends StatefulWidget {
  final Category category;
  final RoutesHandler routesHandler;

  CategoryScreen({this.category, this.routesHandler});

  @override
  State<StatefulWidget> createState() {
    return CategoryScreenState();
  }
}

class CategoryScreenState extends State<CategoryScreen> {
  bool showsGraduated;

  @override
  void initState() {
    showsGraduated = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> graduatedSkeys = context.select<Teacher, List<String>>(
        (t) => t.efforts
            .where((e) => e.graduated > 0)
            .map((e) => e.skey)
            .toList());
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context).age} ${widget.category.cname}'),
        actions: [
          IconButton(
            icon: !showsGraduated ? Icon(Mdi.checkbook) : Icon(Mdi.certificate),
            onPressed: () {
              setState(() {
                showsGraduated = !showsGraduated;
              });
            },
          ),
        ],
      ),
      drawer: DrawerWidget(routesHandler: widget.routesHandler),
      body: ListView(
        children: [
          for (var s in widget.category.series
              .where((s) => showsGraduated == graduatedSkeys.contains(s.skey)))
            SerieCard(
              serie: s,
              routesHandler: widget.routesHandler,
            ),
        ],
      ),
    );
  }
}
