import 'package:flutter/material.dart';
import 'package:notify/app_settings/const.dart';
import 'package:notify/store/store.dart';

void showChangeLanguageModal(BuildContext context){
  showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => _LocaleList()
  );
}

class _LocaleList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StateLocaleList();
}

class _StateLocaleList extends State<_LocaleList>{
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), (){
      if(_controller.hasClients){
        _controller.animateTo(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          (50*(langs.keys.toList().indexOf(
              store.get<Locale>('locale')?.languageCode??'en'
          ))).toDouble()
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = store.get<Locale>('locale')!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
        width: screenSize.width,
        height: screenSize.height*.3,
        child: ListView(
          controller: _controller,
          children: langs.entries.map((e){
            return InkWell(
              onTap: () => store.set('locale', Locale(e.key)),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: screenSize.width,
                  height: 50,
                  color: e.key==locale.languageCode?theme.primaryColor:Colors.transparent,
                  child: Text(
                    e.value,
                    style: theme.textTheme.bodyLarge!.copyWith(
                        color: e.key!=locale.languageCode?theme.primaryColor:Colors.white
                    ),
                  )
              ),
            );
          }).toList()
        )
    );
  }
}