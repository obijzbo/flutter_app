import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_pipe_flutter/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Media Pipe Flutter",
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            elevation: 1.0,
            color: Colors.indigoAccent
          )
        ),
        home: HomePage(),
      ),
    );
  }
}

