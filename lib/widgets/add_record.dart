import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/date.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/snack_bar.dart';

class AddRecordWindow extends StatefulWidget {
  const AddRecordWindow({
    Key? key,
    required this.succes,
  }) : super(key: key);

  final Function(Record record) succes;

  @override
  _AddRecordWindowState createState() => _AddRecordWindowState();
}

class _AddRecordWindowState extends State<AddRecordWindow> {
  List<Company> _companies = [];

  final _dateController = TextEditingController();
  final _companyController = TextEditingController();
  final _noteController = TextEditingController();

  var _selectedDate = DateTime.now().toLocal();
  Company? _selectedCompany;

  void _search(String token, String text) async {
    var result = await NetHandler(context).searchCompanies(token, text);

    if (result.isNotEmpty && mounted) {
      setState(() {
        _companies = result;
      });
    }
  }

  void _addRecord(String token) async {
    if (_selectedCompany == null) {
      StandartSnackBar.show(
        context,
        "Укажите компанию",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await NetHandler(context).addRecord(
      token,
      ConvertDate(context).fromDateTime(_selectedDate).toString(),
      jsonEncode(_selectedCompany),
      jsonEncode(
        [
          RecordStatus(
            status: StatusRecord.one,
            date: ConvertDate(context).fromDateTime(DateTime.now().toLocal()),
          ),
        ],
      ),
      _noteController.text,
    );

    if (result != null) {
      widget.succes(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    _dateController.text = ConvertDate(context).fromDate(
      _selectedDate,
      "dd.MM.yyyy",
    );

    if (_selectedCompany != null) {
      _companyController.text = _selectedCompany!.companyName;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFieldWidget(
            icon: LineIcons.calendar,
            readOnly: true,
            onTap: () => ConvertDate(context).showDatePicker(
              _selectedDate,
              (date) => setState(() {
                _selectedDate = date;
              }),
            ),
            hint: "Дата",
            controller: _dateController,
          ),
          const SizedBox(
            height: 15,
          ),
          TextFieldWidget(
            icon: LineIcons.addressCard,
            hint: "Компания",
            controller: _companyController,
            onChanged: (value) {
              _selectedCompany = null;
              if (value.isNotEmpty) {
                _search(provider.token, value);
              } else {
                if (_companies.isNotEmpty && mounted) {
                  setState(() {
                    _companies = [];
                  });
                }
              }
            },
          ),
          const SizedBox(
            height: 5,
          ),
          AnimatedSizeAndFade(
            child: SizedBox(
              height: _companies.isEmpty ? 0 : 200,
              child: ListView.builder(
                itemCount: _companies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_companies[index].companyName),
                    subtitle: Text(_companies[index].companyLocation.address),
                    onTap: () {
                      setState(() {
                        _selectedCompany = _companies[index];
                        _companies = [];
                      });
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            icon: LineIcons.stickyNote,
            controller: _noteController,
            hint: "Заметка",
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 110,
            height: 35,
            child: StandartButton(
              label: "Сохранить",
              onTap: () => _addRecord(provider.token),
            ),
          ),
        ],
      ),
    );
  }
}
