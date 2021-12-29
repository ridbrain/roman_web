import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/driver.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/extensions.dart';
import 'package:roman/services/formater.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/snack_bar.dart';
import 'package:roman/widgets/table.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({Key? key}) : super(key: key);

  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final _pageController = PageController();
  var _page = 0;

  List<Driver> _drivers = [];
  Driver? _selectedDriver;

  void _updateList(String token) async {
    var result = await NetHandler(context).getDrivers(token);
    setState(() {
      _drivers = result;
    });
  }

  void _nextPage(Driver driver) {
    setState(() {
      _selectedDriver = driver;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  void _back() {
    setState(() {
      _selectedDriver = null;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  Widget _driverPage() {
    if (_selectedDriver == null) return const SizedBox();
    return DriverPage(
      back: _back,
      driver: _selectedDriver!,
      save: (driver) {
        var index = 0;
        for (Driver item in _drivers) {
          if (item.driverId == driver.driverId) {
            setState(() {
              _drivers[index] = driver;
            });
            break;
          }
          index++;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_drivers.isEmpty) {
      _updateList(provider.token);
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: 10,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: AddButton(
                          label: "Добавить водителя",
                          height: 400,
                          child: AddDriver(
                            success: (driver) {
                              setState(() {
                                _drivers.add(driver);
                                _page = _drivers.getLastPage();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 45,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: radius,
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text("Имя", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("Телефон", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("E-Mail", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("Статус", style: tableHeadStyle),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _drivers.getListPage(_page).length,
                  itemBuilder: (context, index) {
                    return DriverCell(
                      index: index,
                      driver: _drivers.getListPage(_page)[index],
                      onTap: () {
                        _nextPage(_drivers.getListPage(_page)[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              BottomTable(
                page: _page + 1,
                firstPage: () => setState(() {
                  _page = 0;
                }),
                prePage: () {
                  if (_page > 0) {
                    setState(() {
                      _page--;
                    });
                  }
                },
                nextPage: () {
                  if (_page < _drivers.getLastPage()) {
                    setState(() {
                      _page++;
                    });
                  }
                },
                lastPage: () {
                  setState(() {
                    _page = _drivers.getLastPage();
                  });
                },
              ),
            ],
          ),
        ),
        _driverPage()
      ],
    );
  }
}

class DriverCell extends StatelessWidget {
  const DriverCell({
    Key? key,
    required this.index,
    required this.driver,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Driver driver;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: radius,
      color: index.isEven ? Colors.white : Colors.grey[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 45,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(driver.driverName),
              ),
              Expanded(
                flex: 1,
                child: Text(driver.driverPhone),
              ),
              Expanded(
                flex: 1,
                child: Text(driver.driverEmail),
              ),
              Expanded(
                flex: 1,
                child: Text(driver.getStatus()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDriver extends StatelessWidget {
  AddDriver({
    Key? key,
    required this.success,
  }) : super(key: key);

  final Function(Driver driver) success;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mailController = TextEditingController();
  final _passController = TextEditingController();
  final _countController = TextEditingController();

  void _addDriver(BuildContext context, String token) async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните имя",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_phoneController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните телефон",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_mailController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните E-Mail",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_passController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните пароль",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_countController.text.length != 1) {
      StandartSnackBar.show(
        context,
        "Заполните колл-во одновременных заявок",
        SnackBarStatus.warning(),
      );
      return;
    }

    var count = 0;

    try {
      count = int.parse(_countController.text);
    } catch (e) {
      StandartSnackBar.show(
        context,
        "Колл-во одновременных заявок должно быть указано цифрой",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await NetHandler(context).addDriver(
      token,
      _nameController.text,
      _phoneController.text,
      _mailController.text,
      _passController.text,
      count.toString(),
    );

    if (result != null) {
      success(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          TextFieldWidget(
            icon: LineIcons.addressCard,
            controller: _nameController,
            hint: "Имя",
          ),
          const SizedBox(
            height: 15,
          ),
          TextFieldWidget(
            icon: LineIcons.phone,
            controller: _phoneController,
            formatter: [
              MaskTextInputFormatter("+_ (___) ___-__-__"),
              LengthLimitingTextInputFormatter(18),
            ],
            hint: "Телефон",
            onTap: () {
              if (_phoneController.text.length < 4) {
                _phoneController.text = "+7 (";
              }
            },
          ),
          const SizedBox(
            height: 15,
          ),
          TextFieldWidget(
            icon: LineIcons.globe,
            controller: _mailController,
            hint: "E-Mail",
          ),
          const SizedBox(
            height: 15,
          ),
          TextFieldWidget(
            icon: LineIcons.key,
            controller: _passController,
            hint: "Пароль",
          ),
          const SizedBox(
            height: 15,
          ),
          TextFieldWidget(
            icon: LineIcons.list,
            controller: _countController,
            hint: "Колл-во одновременных заявок",
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 110,
            height: 35,
            child: StandartButton(
              label: "Сохранить",
              onTap: () => _addDriver(context, provider.token),
            ),
          ),
        ],
      ),
    );
  }
}
