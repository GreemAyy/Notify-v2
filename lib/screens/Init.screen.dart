import 'dart:async';
import 'package:notify/http/users.http.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../methods/workWithUser.dart';
import '../store/store.dart';

class InitScreen extends StatefulWidget{
  const InitScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateInitScreen();
}

class _StateInitScreen extends State<InitScreen>{
  double opacity = 0.5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    init();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
     if(_timer!=null) setState(() => opacity = opacity < 1 ? 1 : 0.75);
    });
  }

  void init() async {
    var prefs = await SharedPreferences.getInstance();
    var id = prefs.get('id') as int?;
    var hash = prefs.get('hash') as String?;
    var access = await UsersHttp.checkUserAccess(id??0, hash??'');
    if(!access) cleanUser();
    if(id==null||hash==null||!access){
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }else{
        store.mapMultiSet({
          "id":id,
          "hash":hash
        });
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: opacity,
                child: Text(
                    'Notify🛎️',
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 70,
                        fontWeight: FontWeight.w600
                    )
                )
            )
          ]
        )
      )
    );
  }
}

