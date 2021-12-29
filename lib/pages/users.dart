import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/user.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/extensions.dart';
import 'package:roman/services/network.dart';
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/snack_bar.dart';
import 'package:roman/widgets/table.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _pageController = PageController();

  var _page = 0;
  List<User> _users = [];
  User? _selectedUser;

  void _updateList(String token) async {
    var result = await NetHandler(context).getUsers(token);
    setState(() {
      _users = result;
    });
  }

  void _nextPage(User user) {
    setState(() {
      _selectedUser = user;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  void _back() {
    setState(() {
      _selectedUser = null;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  Widget _userPage() {
    if (_selectedUser == null) return const SizedBox();
    return UserPage(
      back: _back,
      user: _selectedUser!,
      save: (user) {
        var index = 0;
        for (User item in _users) {
          if (item.userId == user.userId) {
            setState(() {
              _users[index] = user;
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

    if (_users.isEmpty) {
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
                      flex: 4,
                      child: Container(
                        width: 10,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: AddButton(
                          label: "Добавить пользователя",
                          height: 280,
                          child: AddUser(
                            success: (user) {
                              setState(() {
                                _users.add(user);
                                _page = _users.getLastPage();
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
                      child: Text("Номер", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Имя", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("E-Mail", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("Статус", style: tableHeadStyle),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("Роль", style: tableHeadStyle),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _users.getListPage(_page).length,
                  itemBuilder: (context, index) {
                    return UserCell(
                      index: index,
                      user: _users.getListPage(_page)[index],
                      onTap: () => _nextPage(_users.getListPage(_page)[index]),
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
                  if (_page < _users.getLastPage()) {
                    setState(() {
                      _page++;
                    });
                  }
                },
                lastPage: () {
                  setState(() {
                    _page = _users.getLastPage();
                  });
                },
              ),
            ],
          ),
        ),
        _userPage(),
      ],
    );
  }
}

class UserCell extends StatelessWidget {
  const UserCell({
    Key? key,
    required this.index,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final User user;
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
                child: Text(user.userId.toString()),
              ),
              Expanded(
                flex: 2,
                child: Text(user.userName),
              ),
              Expanded(
                flex: 2,
                child: Text(user.userEmail),
              ),
              Expanded(
                flex: 1,
                child: Text(user.getStatus()),
              ),
              Expanded(
                flex: 1,
                child: Text(user.getRole()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddUser extends StatelessWidget {
  AddUser({
    Key? key,
    required this.success,
  }) : super(key: key);

  final Function(User user) success;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _addUser(BuildContext context, String token) async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните имя",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_emailController.text.isEmpty) {
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

    var result = await NetHandler(context).addUser(
      token,
      _nameController.text,
      _emailController.text,
      _passController.text,
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
            icon: LineIcons.globe,
            controller: _emailController,
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
          SizedBox(
            width: 110,
            height: 35,
            child: StandartButton(
              label: "Сохранить",
              onTap: () => _addUser(context, provider.token),
            ),
          ),
        ],
      ),
    );
  }
}
