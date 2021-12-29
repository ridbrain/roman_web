import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:roman/pages/auth.dart';
import 'package:roman/pages/home.dart';
import 'package:roman/services/data_provider.dart';
import 'package:roman/services/network.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var userData = await DataProvider.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => userData,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Roman Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoadingAdmin(),
      ),
    );
  }
}

class LoadingAdmin extends StatelessWidget {
  const LoadingAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: FutureBuilder(
        future: NetHandler(context).checkToken(provider.token),
        builder: (context, AsyncSnapshot<bool> snap) {
          if (snap.hasData) {
            if (snap.data ?? false) {
              return const HomePage();
            }
            return const AuthPage();
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
    );
  }
}
