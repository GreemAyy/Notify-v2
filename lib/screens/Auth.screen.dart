import 'package:notify/http/users.http.dart';
import 'package:notify/methods/workWithUser.dart';
import 'package:notify/widgets/auth/CodeAuth.widget.dart';
import 'package:notify/widgets/auth/PhoneAuth.widget.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../store/store.dart';
import '../store/collector_flutter.dart';
import '../widgets/auth/NameAuth.dart';

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateAuthScreen();
}

final rxFocusEmitter = Reactive(0);

class _StateAuthScreen extends State<AuthScreen>{
  late final _S = S.of(context);
  final pageController = PageController(initialPage: rxFocusEmitter.value);
  String email = '';
  String password = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    rxFocusEmitter.watch((index) async {
      if(pageController.hasClients) {
        await pageController.animateToPage(rxFocusEmitter.value, duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    });
  }

  void phoneSubmit(Map<String, String> data) async {
    if(!isLoading){
      setState(() => isLoading = true);
      email = data['email'] ?? '';
      password = data['password'] ?? '';
      var auth = await UsersHttp.authUser(email,password);
      if(auth){
        rxFocusEmitter.value = 1;
      } else {
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
        final userInfo = (await UsersHttp.getSingle(id))!;
        if(userInfo.name.length<2){
          rxFocusEmitter.value = 2;
        }else{
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_)=>false);
        }
      }
      setState(() => isLoading = false);
      try{
        rxFocusEmitter.value = 0;
      }catch(_){}
    }
  }

  void nameSubmit(String name) async {
    if(!isLoading){
      setState(() => isLoading = true);
      final id = store.get<int>('id')!;
      final updated = await UsersHttp.updateUser(id, name);
      if(updated){
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_)=>false);
      }
      setState(() => isLoading = false);
      try{
        rxFocusEmitter.value = 0;
      }catch(_){}
    }
  }

  void backScreen(){
    rxFocusEmitter.value = 0;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
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
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  PhoneAuth(onSubmit: phoneSubmit),
                  CodeAuth(
                    onSubmit: codeSubmit,
                    onBack: backScreen,
                  ),
                  NameAuth(
                    onSubmit: nameSubmit
                  )
                ]
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