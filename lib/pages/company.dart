import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps/google_maps.dart' as google;
import 'package:google_place/google_place.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/formater.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/google_map.dart';
import 'package:roman/widgets/snack_bar.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({
    Key? key,
    required this.company,
    required this.back,
    required this.save,
  }) : super(key: key);

  final Company company;
  final Function() back;
  final Function(Company company) save;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _mapId = DateTime.now().toIso8601String();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addresController = TextEditingController();
  final _noteController = TextEditingController();
  final _webController = TextEditingController();

  final GooglePlace _googlePlace = GooglePlace(
    "AIzaSyALQnGInxCs7qV-ATtbEnI61oJTAUTGWh0",
  );
  List<AutocompletePrediction> _predictions = [];
  CompanyLocation? _companyLocation;

  void _autoCompleteSearch(String value) async {
    var result = await _googlePlace.autocomplete.get(value, language: "ru_RU");
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        _predictions = result.predictions ?? [];
      });
    }
  }

  void _getDelails(String place) async {
    var result = await _googlePlace.details.get(place, language: "ru_RU");
    var adr = result?.result;

    if (adr != null) {
      setState(() {
        _companyLocation = CompanyLocation(
          address: adr.formattedAddress!,
          latitude: adr.geometry!.location!.lat!,
          longitude: adr.geometry!.location!.lng!,
        );
        _predictions = [];
      });
    }
  }

  void _saveCompany(String token) async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните наименование",
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
    if (_companyLocation == null) {
      StandartSnackBar.show(
        context,
        "Выберите адрес",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await NetHandler(context).editCompany(
      token,
      widget.company.companyId.toString(),
      _nameController.text,
      _phoneController.text,
      jsonEncode(_companyLocation),
      _noteController.text,
      _webController.text,
    );

    if (result != null) {
      widget.save(result);
    }
  }

  @override
  void initState() {
    _companyLocation = widget.company.companyLocation;
    _nameController.text = widget.company.companyName;
    _phoneController.text = widget.company.companyPhone;
    _noteController.text = widget.company.companyNote;
    _webController.text = widget.company.companyWeb;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_companyLocation != null) {
      _addresController.text = _companyLocation!.address;
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
                    hint: "Наименование",
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
                    icon: LineIcons.mapPin,
                    hint: "Адрес",
                    controller: _addresController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _autoCompleteSearch(value);
                        _companyLocation = null;
                      } else {
                        if (_predictions.isNotEmpty && mounted) {
                          setState(() {
                            _predictions = [];
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  AnimatedSizeAndFade(
                    child: _predictions.isNotEmpty
                        ? SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: _predictions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  title: Text(
                                      _predictions[index].description ?? ""),
                                  onTap: () {
                                    _getDelails(_predictions[index].placeId!);
                                  },
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
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
                  TextFieldWidget(
                    icon: LineIcons.globe,
                    controller: _webController,
                    hint: "E-Mail",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 110,
                    height: 35,
                    child: StandartButton(
                      label: "Сохранить",
                      onTap: () => _saveCompany(provider.token),
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
            child: _companyLocation == null
                ? const SizedBox()
                : GoogleMap(
                    id: _mapId,
                    locations: [
                      google.LatLng(
                        _companyLocation!.latitude,
                        _companyLocation!.longitude,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
