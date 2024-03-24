import 'package:dart_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import '../../screens/Auth.screen.dart';

class PhoneAuth extends StatefulWidget{
  PhoneAuth({
    super.key,
    required this.onSubmit
  });
  void Function(Map<String, String> authData) onSubmit;

  @override
  State<StatefulWidget> createState() => _StatePhoneAuth();
}

class _StatePhoneAuth extends State<PhoneAuth>{
  String email = '';
  String password = '';
  String? emailErrorText;
  String? passwordErrorText;
  late final _S = S.of(context);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focusEmitter.watch((index){
      if(index==0) _focus.requestFocus();
    });
  }

  void onSubmit(){
    var next = true;
    setState(() {
      if(!(email.contains('@'))){
        next = false;
        emailErrorText = 'Почта введена неправильно';
      }
      if(password.length<=6){
        next = false;
        passwordErrorText = 'Длина пароля меньше 7';
      }
      if(next){
        emailErrorText = null;
        passwordErrorText = null;
        widget.onSubmit({"email":email, "password":password});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderTheme = OutlineInputBorder(
        borderSide: BorderSide(
            color: theme.primaryColor,
            width: 3
        ),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 0
    );

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                  _S.auth,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor
                  )
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                style: theme.textTheme.bodyMedium,
                onChanged: (text){
                  email = text;
                },
                focusNode: _focus,
                decoration: InputDecoration(
                    filled: true,
                    errorText: emailErrorText,
                    hintText: _S.email,
                    contentPadding:const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                    enabledBorder: borderTheme,
                    focusedBorder: borderTheme
                ),
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                style: theme.textTheme.bodyMedium,
                onChanged: (text){
                  password = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    errorText: passwordErrorText,
                    hintText: _S.password,
                    contentPadding:const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                    enabledBorder: borderTheme,
                    focusedBorder: borderTheme,
                ),
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7.5),
            child: ElevatedButton(
                onPressed: onSubmit,
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    backgroundColor: MaterialStatePropertyAll(theme.primaryColor),
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 5, horizontal: 30)
                    ),
                    shape: MaterialStatePropertyAll<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                ),
                child: Text(
                  _S.log_btn,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.white
                  ),
                )
            )
          )
        ]
    );
  }
}