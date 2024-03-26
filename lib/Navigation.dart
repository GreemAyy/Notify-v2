import 'package:notify/screens/Home.screen.dart';
import 'package:notify/screens/Settings.screen.dart';
import 'package:notify/store/store_flutter_lib.dart';
import 'package:flutter/material.dart';
import 'generated/l10n.dart';

final pickedIndex = Reactive(0);

class Navigation extends StatelessWidget{
  Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder(
        reactive: pickedIndex,
        builder: (context){
          final _S = S.of(context);

          return Scaffold(
              body: IndexedStack(
                  index: pickedIndex.value,
                  children: const [
                    HomeScreen(),
                    SettingsScreen()
                  ]
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: pickedIndex.value,
                unselectedFontSize: 14,
                selectedFontSize: 14,
                enableFeedback: true,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    activeIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
                    label: _S.home,
                  ),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.settings),
                      activeIcon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
                      label: _S.settings
                  )
                ],
                onTap: (index){
                  pickedIndex.value = index;
                },
              )
          );
        }
    );
  }
}