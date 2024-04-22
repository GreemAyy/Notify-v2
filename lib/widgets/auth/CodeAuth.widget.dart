import 'package:flutter/cupertino.dart';
import 'package:notify/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../screens/Auth.screen.dart';

class CodeAuth extends StatefulWidget{
  CodeAuth({
    super.key,
    required this.onSubmit,
    required this.onBack
  });
  void Function(String code) onSubmit;
  void Function() onBack;

  @override
  State<StatefulWidget> createState() => _StateCodeAuth();
}

class _StateCodeAuth extends State<CodeAuth>{
  late final _S = S.of(context);
  String code = '';
  String? codeErrorText;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focusEmitter.watch((index){
      print('index: $index');
      if(index==1) _focus.requestFocus();
    });
  }

  void onSubmit(){
    setState(() {
      if(code.length<4){
        codeErrorText = "Длина меньше 4";
      }else{
        codeErrorText = null;
        widget.onSubmit(code);
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
        borderRadius: BorderRadius.circular(15),
        gapPadding: 0
    );

    return Stack(
        children: [
          Positioned(
              top: 20 + MediaQuery.of(context).padding.bottom,
              left: 0,
              child: TextButton(
                  onPressed: widget.onBack,
                  child: Row(
                      children: [
                        Icon(
                            Icons.arrow_back_ios_sharp,
                            color: theme.primaryColor
                        ),
                        Text(
                            'Back',
                            style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.primaryColor
                            )
                        )
                      ]
                  )
              )
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      _S.auth_code,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.primaryColor
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                      child: Pinput(
                        focusNode: _focus,
                        defaultPinTheme: PinTheme(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.primaryColor,
                              width: 2
                            )
                          )
                        ),
                        focusedPinTheme: PinTheme(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: theme.primaryColor,
                                    width: 4
                                )
                            )
                        ),
                        keyboardType: TextInputType.number,
                        onCompleted: widget.onSubmit
                      )
                  )
                ]
            ),
          )
        ]
    );
  }
}

// class _StateCodeAuth extends State<CodeAuth>{
//   late final _S = S.of(context);
//   String code = '';
//   String? codeErrorText;
//   final _focus = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     focusEmitter.watch((index){
//       if(index==1) _focus.requestFocus();
//     });
//   }
//
//   void onSubmit(){
//     setState(() {
//       if(code.length<4){
//         codeErrorText = "Длина меньше 4";
//       }else{
//         codeErrorText = null;
//         widget.onSubmit(code);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final borderTheme = OutlineInputBorder(
//         borderSide: BorderSide(
//             color: theme.primaryColor,
//             width: 3
//         ),
//         borderRadius: BorderRadius.circular(15),
//         gapPadding: 0
//     );
//
//     return Stack(
//       children: [
//         Positioned(
//             top: 20,
//             left: 0,
//             child: TextButton(
//                 onPressed: widget.onBack,
//                 child: Row(
//                   children: [
//                    Icon(
//                      Icons.arrow_back_ios_sharp,
//                      color: theme.primaryColor
//                    ),
//                    Text(
//                      'Back',
//                      style: theme.textTheme.bodyLarge!.copyWith(
//                        color: theme.primaryColor
//                      )
//                    )
//                   ]
//                 )
//             )
//         ),
//         Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                   _S.auth_code,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                       color: theme.primaryColor
//                   )
//               ),
//               Padding(
//                   padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
//                   child: TextFormField(
//                     focusNode: _focus,
//                     keyboardType: TextInputType.number,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                         fontSize: 40
//                     ),
//                     maxLength: 4,
//                     onChanged: (text){
//                       code = text;
//                     },
//                     decoration: InputDecoration(
//                         filled: true,
//                         errorText: codeErrorText,
//                         hintText: _S.auth_code,
//                         contentPadding:const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
//                         enabledBorder: borderTheme,
//                         focusedBorder: borderTheme
//                     ),
//                   )
//               ),
//               ElevatedButton(
//                   onPressed: onSubmit,
//                   style: ButtonStyle(
//                       elevation: const MaterialStatePropertyAll(0),
//                       backgroundColor: MaterialStatePropertyAll(theme.primaryColor),
//                       padding: const MaterialStatePropertyAll(
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 30)
//                       ),
//                       shape: MaterialStatePropertyAll<OutlinedBorder>(
//                           RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)
//                           )
//                       )
//                   ),
//                   child: Text(
//                     _S.log_btn,
//                     style: theme.textTheme.bodyLarge!.copyWith(
//                         color: Colors.white
//                     )
//                   )
//               )
//             ]
//         )
//       ]
//     );
//   }
// }