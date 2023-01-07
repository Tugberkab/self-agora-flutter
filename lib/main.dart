import 'package:flutter/material.dart';
import 'package:flutter_agora/src/pages/index.dart';
import 'package:flutter_agora/src/router/app_router.dart';
import 'package:flutter_agora/src/utils/project_padding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AppRouter _appRouter = AppRouter();
  final ProjectPadding _projectPadding = ProjectPadding();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _appRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.purple,
          titleTextStyle: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.purple,
                width: 1,
              )),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          hoverColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.purple,
            minimumSize: const Size(double.infinity, 40),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}
