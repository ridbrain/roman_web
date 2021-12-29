import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/formater.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:google_maps/google_maps.dart' as google;
import 'package:roman/widgets/google_map.dart';
import 'package:roman/widgets/snack_bar.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({
    Key? key,
    required this.driver,
    required this.back,
    required this.save,
  }) : super(key: key);

  final Driver driver;
  final Function() back;
  final Function(Driver driver) save;

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final List<google.LatLng> _locations = [];

  final _mapId = DateTime.now().toIso8601String();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mailController = TextEditingController();
  final _passController = TextEditingController();
  final _countController = TextEditingController();

  void _updateLocations(String token) async {
    var result = await NetHandler(context).getDriverLocations(
      token,
      widget.driver.driverId.toString(),
    );

    setState(() {
      for (Location item in result) {
        _locations.add(google.LatLng(item.latitude, item.longitude));
      }
    });
  }

  void _saveDriver(String token) async {
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

    var result = await NetHandler(context).editDriver(
      token,
      widget.driver.driverId.toString(),
      _nameController.text,
      _phoneController.text,
      _mailController.text,
      _passController.text,
      widget.driver.driverStatus.toString(),
      count.toString(),
    );

    if (result != null) {
      widget.save(result);
    }
  }

  @override
  void initState() {
    _nameController.text = widget.driver.driverName;
    _phoneController.text = widget.driver.driverPhone;
    _mailController.text = widget.driver.driverEmail;
    _countController.text = widget.driver.driverRecordCount.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_locations.isEmpty) {
      _updateLocations(provider.token);
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 30,
                        child: Material(
                          borderRadius: radius,
                          color: Colors.grey[200],
                          child: InkWell(
                            borderRadius: radius,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                              ),
                            ),
                            onTap: widget.back,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
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
                    hint: "Новый пароль",
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
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Cтатус: ${widget.driver.getStatus()}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        CupertinoSwitch(
                          value: widget.driver.driverStatus == 1,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                widget.driver.driverStatus = 1;
                              } else {
                                widget.driver.driverStatus = 0;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 110,
                    height: 35,
                    child: StandartButton(
                      label: "Сохранить",
                      onTap: () => _saveDriver(provider.token),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            flex: 1,
            child: _locations.isEmpty
                ? Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Text(
                        "Здесь будут отображены последние координаты водителя",
                      ),
                    ),
                  )
                : GoogleMap(
                    id: _mapId,
                    locations: _locations,
                  ),
          ),
        ],
      ),
    );
  }
}
