import 'package:flutter/material.dart';
import 'package:notify/app_settings/const.dart';
import 'package:notify/store/store.dart';

void showChangeLanguageModal(BuildContext context){
  showModalBottomSheet(
      context: context,
      builder: (context){
        final locale = store.get<Locale>('locale')!;
        final theme = Theme.of(context);
        final screenSize = MediaQuery.of(context).size;

        return SingleChildScrollView(
          child: Container(
            width: screenSize.width,
            height: screenSize.height*.3,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: langs.entries.map((e){
                return InkWell(
                  onTap: () => store.set('locale', Locale(e.key)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: screenSize.width,
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
            ),
          )
        );
      }
  );
}