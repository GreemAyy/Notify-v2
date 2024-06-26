import 'package:notify/methods/work_with_user.dart';
import 'package:flutter/material.dart';
import 'package:notify/store/collector_flutter.dart';
import 'package:notify/widgets/settings/show_change_language_modal.dart';
import '../app_settings/const.dart';
import '../generated/l10n.dart';
import '../store/store.dart';

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _StateSettingsScreen();
}

class _StateSettingsScreen extends State<SettingsScreen>{
  late final _S = S.of(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                _S.settings,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.primaryColor,
                  fontSize: theme.textTheme.bodyLarge!.fontSize!+10
                )
              )
            ),
            const SliverToBoxAdapter(child: ThemePicker()),
            const SliverToBoxAdapter(child: LanguagePicker()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                    onPressed: (){
                      clearUser();
                      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)
                    ),
                    child: Text(
                        _S.logout,
                        style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                        )
                    )
                )
              )
            )
          ]
        )
      )
    );
  }
}

final _rxTheme = Reactive.withStore(StoreConnect(key: 'theme_mode', store: store), ThemeMode.system);

class ThemePicker extends StatelessWidget{
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder(
        reactive: _rxTheme,
        builder: (context, _){
          final theme = Theme.of(context);
          final _S = S.of(context);
          final themes = {
            _S.system_theme: ThemeMode.system,
            _S.light_theme: ThemeMode.light,
            _S.dark_theme: ThemeMode.dark
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    _S.theme,
                    style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.primaryColor
                    )
                )
              ),
              ...themes.entries.map((e){
                return InkWell(
                  onTap: () => _rxTheme.value = e.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600
                          )
                        ),
                        if(e.value.name==_rxTheme.value.name)
                          Icon(
                            Icons.done,
                            color: theme.primaryColor
                          )
                      ]
                    )
                  )
                );
              }).toList()
            ]
          );
        }
    );
  }
}

final _rxLocale = Reactive.withStore(StoreConnect(key: 'locale', store: store), const Locale('en'));

class LanguagePicker extends StatelessWidget{
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder(
     reactive: _rxLocale,
     builder: (context, _){
       final theme = Theme.of(context);
       final _S = S.of(context);

       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Padding(
             padding: const EdgeInsets.only(left: 10),
             child: Text(
               _S.language,
               style: theme.textTheme.bodyLarge!.copyWith(
                 color: theme.primaryColor
               )
             )
           ),
           InkWell(
             onTap: () => showChangeLanguageModal(context),
             child: Container(
               padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
               width: MediaQuery.of(context).size.width,
               child: Text(
                 Constants.LANGUAGES[_rxLocale.value.languageCode]!,
                 style: theme.textTheme.bodyMedium!.copyWith(
                   fontWeight: FontWeight.w600
                 )
               )
             )
           )
         ]
       );
     }
    );
  }}