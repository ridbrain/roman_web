import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';

class SelectDriver extends StatefulWidget {
  const SelectDriver({
    Key? key,
    required this.onSelcet,
  }) : super(key: key);

  final Function(Driver driver) onSelcet;

  @override
  _SelectDriverState createState() => _SelectDriverState();
}

class _SelectDriverState extends State<SelectDriver> {
  final _driverController = TextEditingController();

  List<Driver> _drivers = [];
  Driver? _selectedDriver;

  void _search(String token, String text) async {
    var result = await NetHandler(context).searchDrivers(token, text);

    if (result.isNotEmpty && mounted) {
      setState(() {
        _drivers = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_selectedDriver != null) {
      _driverController.text = _selectedDriver!.driverName;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFieldWidget(
            icon: LineIcons.addressCard,
            hint: "Водитель",
            controller: _driverController,
            onChanged: (value) {
              _selectedDriver = null;
              if (value.isNotEmpty) {
                _search(provider.token, value);
              } else {
                if (_drivers.isNotEmpty && mounted) {
                  setState(() {
                    _drivers = [];
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
              height: 175,
              child: ListView.builder(
                itemCount: _drivers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_drivers[index].driverName),
                    subtitle: Text(_drivers[index].driverPhone),
                    onTap: () {
                      setState(() {
                        _selectedDriver = _drivers[index];
                        _drivers = [];
                      });
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 110,
            height: 35,
            child: StandartButton(
              label: "Сохранить",
              onTap: () {
                if (_selectedDriver != null) {
                  widget.onSelcet(_selectedDriver!);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
