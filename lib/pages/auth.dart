import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roman/services/constants.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/network.dart';
import 'package:roman/widgets/buttons.dart';
import 'package:roman/widgets/fields.dart';
import 'package:roman/widgets/logo.dart';
import 'package:roman/widgets/snack_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _loginController = TextEditingController();
  final _passController = TextEditingController();

  void _authUser(DataProvider provider) async {
    if (_loginController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните поле Login",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_passController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните поле Pass",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await NetHandler(context).userAuth(
      _loginController.text,
      _passController.text,
    );

    if (result != null) {
      provider.setUserToken(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            width: 400,
            height: 265,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: AutofillGroup(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const RomanLogo(),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.user,
                      controller: _loginController,
                      hint: "E-Mail",
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.key,
                      controller: _passController,
                      obscureText: true,
                      hint: "Пароль",
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 110,
                      child: StandartButton(
                        label: "Войти",
                        onTap: () => _authUser(provider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
