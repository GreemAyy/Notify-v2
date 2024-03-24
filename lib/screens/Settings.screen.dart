import 'package:notify/methods/workWithUser.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                    onPressed: () => logout(context),
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