import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/snack_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    Key? key,
    required this.user,
    required this.back,
    required this.save,
  }) : super(key: key);

  final User user;
  final Function() back;
  final Function(User user) save;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _passController = TextEditingController();

  Widget _getSwitch() {
    if (widget.user.userId == 1) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Cтатус: ${widget.user.getStatus()}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          CupertinoSwitch(
            value: widget.user.userStatus == 1,
            onChanged: (value) {
              setState(() {
                if (value) {
                  widget.user.userStatus = 1;
                } else {
                  widget.user.userStatus = 0;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void _saveUser(String token) async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните имя",
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

    var result = await NetHandler(context).editUser(
      token,
      widget.user.userId.toString(),
      _nameController.text,
      _mailController.text,
      _passController.text,
      widget.user.userStatus.toString(),
    );

    if (result != null) {
      widget.save(result);
    }
  }

  @override
  void initState() {
    _nameController.text = widget.user.userName;
    _mailController.text = widget.user.userEmail;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

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
                  _getSwitch(),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 110,
                    height: 35,
                    child: StandartButton(
                      label: "Сохранить",
                      onTap: () => _saveUser(provider.token),
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
            child: Container(
              color: Colors.grey[100],
              child: const Center(
                child: Text(
                  "Здесь можно разместить информацию по активности пользователя",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
