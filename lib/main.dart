import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:nonogram/page/page_game.dart';
import 'package:nonogram/page/page_game_2.dart';
import 'package:nonogram/page/page_home.dart';
import 'package:nonogram/utils/game_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FullScreen.enterFullScreen(FullScreenMode.LEANBACK);
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      // home: const PageHome(),
      home: const PageGame2(
        tileCount: 5,
        maxFilledCount: 4,
      ),
      // home: const PageGame(tileCount: 5, maxFilledCount: 4),
    );
  }
}
