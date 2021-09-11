import 'package:dino_run_clone/widgets/menu.dart';
import 'package:dino_run_clone/widgets/settings.dart';
import 'package:flutter/material.dart';

// This class represents the main menu of this game.
class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  /// This notifier is used to decide which menu should be displayed
  /// from [Menu] or [Settings].
  late ValueNotifier<CrossFadeState> _crossFadeStateNotifier;

  @override
  void initState() {
    super.initState();
    _crossFadeStateNotifier = ValueNotifier(CrossFadeState.showFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.black.withOpacity(0.4),
            child: Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 100.0, vertical: 50.0),
              child: ValueListenableBuilder(
                valueListenable: _crossFadeStateNotifier,
                builder: (BuildContext context, CrossFadeState value, Widget? child) {
                  return AnimatedCrossFade(
                    firstChild: Menu(
                      onSettingsPressed: showSettings,
                    ),
                    secondChild: Settings(
                      onBackPressed: showMenu,
                    ),
                    crossFadeState: value,
                    duration: Duration(milliseconds: 300),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// When called will change the current menu to [Menu].
  void showMenu() {
    _crossFadeStateNotifier.value = CrossFadeState.showFirst;
  }

  /// When called will change the current menu to [Settings].
  void showSettings() {
    _crossFadeStateNotifier.value = CrossFadeState.showSecond;
  }
}