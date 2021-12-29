import 'package:flutter/material.dart';
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
import 'package:roman/widgets/table.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({Key? key}) : super(key: key);

  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _pageController = PageController();
  var _page = 0;

  List<Record> _records = [];
  Record? _selectedRecord;

  void _updateList(String token) async {
    var result = await NetHandler(context).getRecords(token);
    setState(() {
      _records = result;
    });
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

  Widget _recordPage() {
    if (_selectedRecord == null) return const SizedBox();
    return RecordPage(
      record: _selectedRecord!,
      back: _back,
      save: (record) {},
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
                          label: "Добавить заявку",
                          width: 500,
                          height: 520,
                          child: AddRecordWindow(succes: (record) {
                            setState(() {
                              _records.add(record);
                            });
                          }),
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
                      child: Text("Номер", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Дата", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Статус", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text("Компания", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text("Водитель", style: tableHeadStyle),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _records.getListPage(_page).length,
                  itemBuilder: (context, index) {
                    return RecordCell(
                      index: index,
                      record: _records.getListPage(_page)[index],
                      onTap: () {
                        _nextPage(_records.getListPage(_page)[index]);
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
                  if (_page < _records.getLastPage()) {
                    setState(() {
                      _page++;
                    });
                  }
                },
                lastPage: () {
                  setState(() {
                    _page = _records.getLastPage();
                  });
                },
              ),
            ],
          ),
        ),
        _recordPage(),
      ],
    );
  }
}

class RecordCell extends StatelessWidget {
  const RecordCell({
    Key? key,
    required this.index,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Record record;
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
                child: Text(record.recordId.toString()),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ConvertDate(context).fromUnix(
                    record.recordDate,
                    "dd.MM.yyyy",
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(record.getStatus()),
              ),
              Expanded(
                flex: 3,
                child: Text(record.company.companyName),
              ),
              Expanded(
                flex: 3,
                child: Text(record.driver?.driverName ?? ""),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
