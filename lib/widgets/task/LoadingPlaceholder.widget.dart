import 'package:flutter/material.dart';
import '../ui/Skeleton.ui.dart';

class LoadingPlaceholder extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
            itemCount: 3,
            itemBuilder:(context, index){
              return Skeleton(
                height: 200,
                verticalOuterPadding: 5,
                horizontalOuterPadding: 10,
                colorFrom: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
                colorTo: theme.textTheme.bodyMedium!.color!.withOpacity(.3),
                borderRadius: 15,
              );
            }
        )
    );
  }
}