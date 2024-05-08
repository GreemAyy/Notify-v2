import 'package:flutter/material.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import '../../generated/l10n.dart';

class NameAuth extends StatefulWidget{
  const NameAuth({
    super.key,
    required this.onSubmit
  });
  final void Function(String name) onSubmit;

  @override
  State<StatefulWidget> createState() => _StateNameAuth();
}

class _StateNameAuth extends State<NameAuth>{
  String name = '';
  String? nameError;

  @override
  Widget build(BuildContext context) {
    final _S = S.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _S.hint_name,
              style: theme.textTheme.bodyLarge
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: FormTextField(
                onInput: (text) => name = text,
                hintText: _S.hint_name,
                errorText: nameError,
                borderRadius: 10,
              )
            ),
            ElevatedButton(
                onPressed: (){
                  setState(() => nameError = name.length<2 ? _S.name_error : null);
                  if(name.length>=2) widget.onSubmit(name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor
                ),
                child: Text(
                  _S.save,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600
                  )
                )
            )
          ]
      )
    );
  }
}