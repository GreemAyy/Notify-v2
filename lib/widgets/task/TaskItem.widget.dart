import 'package:notify/widgets/task/ShowTaskOptionsModal.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import 'package:flutter/material.dart';
import '../../custom_classes/task.dart';
import '../../generated/l10n.dart';
import '../../store/store.dart';

class TaskItem extends StatefulWidget{
  TaskItem({
    super.key,
    required this.task
  });
  Task task;

  @override
  State<StatefulWidget> createState() => _StateTaskItem();
}

class _StateTaskItem extends State<TaskItem>{
  late final _S = S.of(context);
  late final task = widget.task;
  static const _imageHeight = 200.0;
  static const _imageWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: task.status==TaskStatus.uncompleted ? 1 : .5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
        child: InkWell(
          onTap: (){
             Navigator.pushNamed(context,'/task',arguments: {'task':task});
          },
          onLongPress: (){
            var group = store.get('group');
            if(group==0||task.creatorId==store.get('id')){
              showTaskOptionsModal(context, task);
            }
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: theme.textTheme.bodyMedium!.color!.withOpacity(.05)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    widget.task.title,
                    style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600
                    )
                ),
                const SizedBox(height: 10),
                if(task.imagesId[0]!=0)
                  Row(
                      children: [
                        ImagePlaceholder(
                            imageId: task.imagesId[0],
                            imageHeight: _imageHeight,
                            imageWidth: _imageWidth
                        ),
                        if(task.imagesId[0]!=0)
                          PicturesGrid(
                              imagesId: task.imagesId,
                              imageHeight: _imageHeight,
                              imageWidth: _imageWidth,
                              showFirst: false
                          )
                      ]
                  )
                else
                  Text(
                      "- ${_S.no_photo}",
                      style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600
                      )
                  ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${task.dayFrom}/${task.monthFrom}/${task.yearFrom}'
                              +' ${task.hourFrom<10?'0':''}${task.hourFrom}:${task.minuteFrom<10?'0':''}${task.minuteFrom}',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              fontSize: 15
                          )
                      ),
                      const Icon(Icons.arrow_right_alt),
                      Text(
                          '${task.dayTo}/${task.monthTo}/${task.yearTo}'
                              +' ${task.hourTo<10?'0':''}${task.hourTo}:${task.minuteTo<10?'0':''}${task.minuteTo}',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              fontSize: 15
                          )
                      )
                    ]
                ),
                Row(
                    children: [
                      const Icon(
                          Icons.fiber_manual_record,
                          size: 15
                      ),
                      const SizedBox(width: 5),
                      Text(
                          task.status==TaskStatus.uncompleted?
                          _S.status_uncompleted:
                          _S.status_completed
                      )
                    ]
                )
              ]
            )
          )
        )
      )
    );
  }
}

//Если я буду использовать hero
/*
* Navigator.push(context, PageRouteBuilder(
                 pageBuilder: (context , from, to){
                   return TaskScreen(task: task);
                 }
             ));
* */