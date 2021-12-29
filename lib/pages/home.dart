import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/calendart.dart';
import 'package:roman/pages/companies.dart';
import 'package:roman/pages/drivers.dart';
import 'package:roman/pages/records.dart';
import 'package:roman/pages/users.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/widgets/logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;

  final _pages = [
    const CalendarPage(),
    const RecordsPage(),
    const DriversPage(),
    const CompaniesPage(),
    const UsersPage(),
  ];

  TextStyle? _getStyle(int index) {
    if (index == _index) {
      return const TextStyle(
        fontWeight: FontWeight.bold,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 220,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const DrawerHeader(
                      child: RomanLogo(),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.chalkboard),
                      title: Text(
                        "Главная",
                        style: _getStyle(0),
                      ),
                      onTap: () => setState(() {
                        _index = 0;
                      }),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.stream),
                      title: Text(
                        "Заявки",
                        style: _getStyle(1),
                      ),
                      onTap: () => setState(() {
                        _index = 1;
                      }),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.car),
                      title: Text(
                        "Водители",
                        style: _getStyle(2),
                      ),
                      onTap: () => setState(() {
                        _index = 2;
                      }),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.addressCard),
                      title: Text(
                        "Компании",
                        style: _getStyle(3),
                      ),
                      onTap: () => setState(() {
                        _index = 3;
                      }),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.user),
                      title: Text(
                        "Пользователи",
                        style: _getStyle(4),
                      ),
                      onTap: () => setState(() {
                        _index = 4;
                      }),
                    ),
                    ListTile(
                      leading: const Icon(LineIcons.arrowCircleRight),
                      title: const Text("Выход"),
                      onTap: () => provider.setUserToken(""),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _pages[_index],
            ),
          ],
        ),
      ),
    );
  }
}
