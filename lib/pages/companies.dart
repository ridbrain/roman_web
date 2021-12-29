import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/company.dart';
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

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({Key? key}) : super(key: key);

  @override
  _CompaniesPageState createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final _pageController = PageController();

  var _companies = [];
  var _page = 0;

  Company? _selectedCompany;

  void _updateList(String token) async {
    var result = await NetHandler(context).getCompanies(token);
    setState(() {
      _companies = result;
    });
  }

  void _nextPage(Company company) {
    setState(() {
      _selectedCompany = company;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  void _back() {
    setState(() {
      _selectedCompany = null;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  Widget _companyPage() {
    if (_selectedCompany == null) return const SizedBox();
    return CompanyPage(
      back: _back,
      company: _selectedCompany!,
      save: (company) {
        var index = 0;
        for (Company item in _companies) {
          if (item.companyId == company.companyId) {
            setState(() {
              _companies[index] = company;
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

    if (_companies.isEmpty) {
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
                          label: "Добавить компанию",
                          width: 600,
                          height: 585,
                          child: AddCompany(
                            success: (company) {
                              setState(() {
                                _companies.add(company);
                                _page = _companies.getLastPage();
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
                      flex: 3,
                      child: Text("Название", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text("Адрес", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Телефон", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("E-Mail", style: tableHeadStyle),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _companies.getListPage(_page).length,
                  itemBuilder: (context, index) {
                    return CompanyCell(
                      index: index,
                      company: _companies.getListPage(_page)[index],
                      onTap: () {
                        _nextPage(_companies.getListPage(_page)[index]);
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
                  if (_page < _companies.getLastPage()) {
                    setState(() {
                      _page++;
                    });
                  }
                },
                lastPage: () {
                  setState(() {
                    _page = _companies.getLastPage();
                  });
                },
              ),
            ],
          ),
        ),
        _companyPage(),
      ],
    );
  }
}

class CompanyCell extends StatelessWidget {
  const CompanyCell({
    Key? key,
    required this.index,
    required this.company,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Company company;
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
                flex: 3,
                child: Text(company.companyName),
              ),
              Expanded(
                flex: 4,
                child: Text(company.companyLocation.address),
              ),
              Expanded(
                flex: 2,
                child: Text(company.companyPhone),
              ),
              Expanded(
                flex: 2,
                child: Text(company.companyWeb),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCompany extends StatefulWidget {
  const AddCompany({
    Key? key,
    required this.success,
  }) : super(key: key);

  final Function(Company company) success;

  @override
  _AddCompanyState createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  List<Result> _predictions = [];
  CompanyLocation? _companyLocation;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addresController = TextEditingController();
  final _noteController = TextEditingController();
  final _webController = TextEditingController();

  void _autoCompleteSearch(String token, String value) async {
    var result = await NetHandler(context).getPlaces(token, value);
    if (mounted) {
      setState(() {
        _predictions = result;
      });
    }
  }

  void _getDelails(Result place) async {
    setState(() {
      _companyLocation = CompanyLocation(
        address: place.formattedAddress,
        latitude: place.geometry.location.lat,
        longitude: place.geometry.location.lng,
      );
      _predictions = [];
    });
  }

  void _saveCompany(BuildContext context, String token) async {
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

    var result = await NetHandler(context).addCompany(
      token,
      _nameController.text,
      _phoneController.text,
      jsonEncode(_companyLocation),
      _noteController.text,
      _webController.text,
    );

    if (result != null) {
      widget.success(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_companyLocation != null) {
      _addresController.text = _companyLocation!.address;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                _autoCompleteSearch(provider.token, value);
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
                          title: Text(_predictions[index].formattedAddress),
                          onTap: () => _getDelails(_predictions[index]),
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
              onTap: () => _saveCompany(context, provider.token),
            ),
          ),
        ],
      ),
    );
  }
}
