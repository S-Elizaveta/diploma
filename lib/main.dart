import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'createpage/cubit_create_page.dart';
import 'eventpage/cubit_event_page.dart';
import 'homepage/cubit_home_page.dart';
import 'homepage/homepage.dart';
import 'db/shared_preferences_provider.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesProvider.initialize();
  runApp(
    MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<CubitHomePage>(
          create: (context) => CubitHomePage(),
        ),
        BlocProvider<CubitEventPage>(
          create: (context) => CubitEventPage(),
        ),
        BlocProvider<CubitCreatePage>(
          create: (context) => CubitCreatePage(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppTheme(
      builder: (context, _brightness) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Homework App',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: _brightness,
          ),
          home: HomePage(),
        );
      },
    );
  }
}
