import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/date.dart';
import 'package:roman/services/extensions.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/google_map.dart';
import 'package:roman/widgets/select_driver.dart';
import 'package:google_maps/google_maps.dart' as google;

class RecordPage extends StatefulWidget {
  const RecordPage({
    Key? key,
    required this.record,
    required this.back,
    required this.save,
  }) : super(key: key);

  final Record record;
  final Function() back;
  final Function(Record record) save;

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late Record record;

  final List<google.LatLng> _locations = [];

  final _mapId = DateTime.now().toIso8601String();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _driverController = TextEditingController();
  final _noteController = TextEditingController();

  String _getDriverLabel() {
    if (record.driver == null) {
      return "Назначить";
    }
    return "Изменить";
  }

  Widget _getNoteButton(String token) {
    if (record.recordStatus == StatusRecord.six ||
        record.recordStatus == StatusRecord.five) {
      return const SizedBox.shrink();
    }
    return Container(
      width: 130,
      height: 35,
      margin: const EdgeInsets.only(left: 15),
      child: StandartButton(
        label: "Сохранить",
        onTap: () => _editRecordNote(token),
      ),
    );
  }

  Widget _getDriverButton(String token) {
    if (record.recordStatus == StatusRecord.six ||
        record.recordStatus == StatusRecord.five) {
      return const SizedBox.shrink();
    }
    return Container(
      width: 130,
      margin: const EdgeInsets.only(left: 15),
      child: AddButton(
        popoverDirection: PopoverDirection.bottom,
        child: SelectDriver(
          onSelcet: (driver) => _setDriver(
            token,
            driver,
          ),
        ),
        label: _getDriverLabel(),
      ),
    );
  }

  Widget _getCancelButton(String token) {
    if (record.recordStatus == StatusRecord.six ||
        record.recordStatus == StatusRecord.five) {
      return const SizedBox.shrink();
    }
    return Container(
      width: 130,
      height: 35,
      margin: const EdgeInsets.only(left: 15),
      child: StandartButton(
        label: "Отменить",
        onTap: () => _dialogCancelRecord(token),
      ),
    );
  }

  void _dialogCancelRecord(String token) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Отменить заявку?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelRecord(token);
              },
              child: const Text("Да"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Нет"),
            ),
          ],
        );
      },
    );
  }

  void _cancelRecord(String token) async {
    var status = RecordStatus(
      status: StatusRecord.six,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = record.recordHistory;
    history.add(status);

    var result = await NetHandler(context).cancelRecord(
      token,
      record.recordId.toString(),
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        record.recordHistory = history;
        record.recordStatus = StatusRecord.six;
      });
      widget.save(record);
    }
  }

  void _updateLocations(String token, String driverId) async {
    var result = await NetHandler(context).getDriverLocations(
      token,
      driverId,
    );

    setState(() {
      for (Location item in result) {
        _locations.add(google.LatLng(item.latitude, item.longitude));
      }
    });
  }

  void _editRecordNote(String token) async {
    var note = _noteController.text;
    var result = await NetHandler(context).editRecordNote(
      token,
      record.recordId.toString(),
      note,
    );

    if (result) {
      setState(() {
        record.recordNote = note;
      });
    }
  }

  void _setDriver(String token, Driver driver) async {
    var status = RecordStatus(
      status: StatusRecord.two,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = record.recordHistory;
    history.add(status);

    var result = await NetHandler(context).setDriver(
      token,
      record.recordId.toString(),
      jsonEncode(driver),
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        record.driver = driver;
        record.recordHistory = history;
        record.recordStatus = StatusRecord.two;
      });
      widget.save(record);
    }
  }

  @override
  void initState() {
    record = widget.record;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    _companyController.text = record.company.companyName;
    _addressController.text = record.company.companyLocation.address;
    _driverController.text = record.driver?.driverName ?? "Не назначен";
    _noteController.text = record.recordNote;

    if (record.driver != null) {
      _updateLocations(provider.token, record.driver!.driverId.toString());
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(
                    height: 15,
                  ),
                  TextFieldWidget(
                    icon: LineIcons.addressCard,
                    readOnly: true,
                    controller: _companyController,
                    hint: "Компания",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFieldWidget(
                    icon: LineIcons.mapPin,
                    readOnly: true,
                    controller: _addressController,
                    hint: "Адрес",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          icon: LineIcons.car,
                          readOnly: true,
                          controller: _driverController,
                          hint: "Водитель",
                        ),
                      ),
                      _getDriverButton(provider.token),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          icon: LineIcons.stickyNote,
                          controller: _noteController,
                          hint: "Заметка",
                        ),
                      ),
                      _getNoteButton(provider.token),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: widget.record.recordHistory.length * 55,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: radius,
                          ),
                          child: ListView.builder(
                            itemCount: widget.record.recordHistory.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              var status = widget.record.recordHistory[index];
                              return SizedBox(
                                height: 55,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: status.getColor(),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(status.getLabel()),
                                        Text(
                                          ConvertDate(context).fromUnix(
                                            status.date,
                                            "dd.MM.yyyy HH:mm",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      _getCancelButton(provider.token),
                    ],
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
