import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/record.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/date.dart';
import 'package:roman/services/extensions.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/add_record.dart';
import 'package:roman/widgets/buttons.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _pageController = PageController();
  final _firstDay = ConvertDate.firstDayOfWeak();

  List<Record> _records = [];
  Record? _selectedRecord;

  void _updateList(String token) async {
    var result = await NetHandler(context).getRecords(token);
    setState(() {
      _records = result;
    });
  }

  void _updateRecord(Record record) {
    var index = 0;
    for (var item in _records) {
      if (item.recordId == record.recordId) {
        setState(() {
          _records[index] = record;
        });
        break;
      }
      index++;
    }
  }

  void _nextPage(Record record) {
    setState(() {
      _selectedRecord = record;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  void _back() {
    _selectedRecord = null;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  DateTime _getDay(int index) {
    return _firstDay.add(Duration(days: index));
  }

  List<Record> _getDayRecords(int index) {
    var start = _firstDay.add(Duration(days: index)).secondsSinceEpoch();
    var end = start + 86400;

    List<Record> records = [];

    for (Record item in _records) {
      if (item.recordDate > start && item.recordDate < end) {
        records.add(item);
      }
    }

    records.sort(
      (a, b) => a.recordStatus.index.compareTo(b.recordStatus.index),
    );

    return records;
  }

  Widget _devider() {
    return const SizedBox(
      width: 15,
    );
  }

  Widget _generalPage(String token) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SizedBox(
                        height: 35,
                        child: StandartButton(
                          label: "Обновить",
                          onTap: () => _updateList(token),
                        ),
                      ),
                    ),
                  ),
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
                        label: "Добавить заявку",
                        width: 500,
                        height: 500,
                        child: AddRecordWindow(
                          succes: (record) {
                            setState(() {
                              _records.add(record);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DayList(
                  date: _getDay(0),
                  records: _getDayRecords(0),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(1),
                  records: _getDayRecords(1),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(2),
                  records: _getDayRecords(2),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(3),
                  records: _getDayRecords(3),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(4),
                  records: _getDayRecords(4),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(5),
                  records: _getDayRecords(5),
                  selectRecord: _nextPage,
                ),
                _devider(),
                DayList(
                  date: _getDay(6),
                  records: _getDayRecords(6),
                  selectRecord: _nextPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordPage() {
    if (_selectedRecord == null) return const SizedBox();
    return RecordPage(
      record: _selectedRecord!,
      back: _back,
      save: _updateRecord,
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_records.isEmpty) {
      _updateList(provider.token);
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _generalPage(provider.token),
        _recordPage(),
      ],
    );
  }
}

class DayList extends StatelessWidget {
  const DayList({
    Key? key,
    required this.date,
    required this.records,
    required this.selectRecord,
  }) : super(key: key);

  final DateTime date;
  final List<Record> records;
  final Function(Record record) selectRecord;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          Container(
            height: 45,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: radius,
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ConvertDate(context).fromDate(date, "dd.MM").capitalLetter(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  ConvertDate(context).fromDate(date, "EEEE").capitalLetter(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: records.length,
            itemBuilder: (context, index) {
              return RecordCell(
                record: records[index],
                onTap: () => selectRecord(records[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RecordCell extends StatelessWidget {
  const RecordCell({
    Key? key,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  final Record record;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Material(
        borderRadius: radius,
        color: record.getColor(),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LineIcons.building,
                      size: 15,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Text(
                        record.company.companyName.replaceAll("\\", ""),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      LineIcons.car,
                      size: 15,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Text(
                        record.driverName(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Text(
                    record.getStatus(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    Key? key,
    required this.selected,
    required this.select,
  }) : super(key: key);

  final int selected;
  final Function(int color) select;

  Widget _getColor(Color color, int index) {
    return InkWell(
      onTap: () => select(index),
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected == index ? Colors.grey[800]! : Colors.white,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Цвет",
              style: TextStyle(fontSize: 16),
            ),
          ),
          _getColor(Colors.grey.shade100, 1),
          _getColor(Colors.red.shade100, 2),
          _getColor(Colors.green.shade100, 3),
          _getColor(Colors.blue.shade100, 4),
        ],
      ),
    );
  }
}
