import 'package:notify/http/users.http.dart';
import 'package:notify/methods/workWithUser.dart';
import 'package:notify/widgets/auth/CodeAuth.widget.dart';
import 'package:notify/widgets/auth/PhoneAuth.widget.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../store/store_flutter_lib.dart';

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateAuthScreen();
}

final focusEmitter = Reactive(0);

class _StateAuthScreen extends State<AuthScreen>{
  late final _S = S.of(context);
  int currentIndex = 0;
  String email = '';
  String password = '';
  bool isLoading = false;

  void phoneSubmit(Map<String, String> data) async {
    if(!isLoading){
      setState(() => isLoading = true);
      email = data['email'] ?? '';
      password = data['password'] ?? '';
      var auth = await UsersHttp.authUser(email,password);
      if(auth){
        setState(() => currentIndex = 1);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.withOpacity(0.7),
                content: Text(
                  _S.snack_bar,
                  style: const TextStyle(
                      color: Colors.white
                  )
                )
            )
        );
      }
      setState(() => isLoading = false);
      focusEmitter.value = 1;
    }
  }

  void codeSubmit(String code) async {
    if(!isLoading){
      setState(() => isLoading = true);
      var auth = await UsersHttp.logUser(email,password,code);
      var haveAccess = (auth['access'] as bool?) ?? false;
      if(haveAccess){
        var id = (auth['id'] as int?)??0;
        var hash = (auth['hash'] as String?)??'';
        setUser(id, hash);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_)=>false);
      }
      setState(() => isLoading = false);
      focusEmitter.value = 0;
    }
  }

  void backScreen(){

  }

  @override
  void dispose() {
    super.dispose();
    focusEmitter.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  width: screenSize.width,
                  height: screenSize.height,
                  child: PhoneAuth(onSubmit: phoneSubmit)
              ),
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  width: screenSize.width,
                  height: screenSize.height,
                  left: currentIndex>=1?0:screenSize.width,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: CodeAuth(
                        onSubmit: codeSubmit,
                        onBack: backScreen,
                    )
                  )
              ),
              AnimatedPositioned(
                  width: 200,
                  height: 200,
                  top:  isLoading ? 20 : -(screenSize.height),
                  left: (screenSize.width/2-100),
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.scaffoldBackgroundColor.withOpacity(.7)
                    ),
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                      strokeWidth: 10,
                    )
                  )
              )
            ]
          )
        )
      )
    );
  }
}