import 'package:notify/custom_classes/group.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/store/store.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

void showTaskOptionsModal(BuildContext context, Task task){
  showModalBottomSheet(
      context: context,
      builder: (context){
        final _S = S.of(context);
        final theme = Theme.of(context);
        final screenSize = MediaQuery.of(context).size;
        final isPicked = rxPickedTasksList.value.map((e) => e.id).contains(task.id);

        return Container(
          width: screenSize.width,
          padding: const EdgeInsets.only(top: 15),
          height: task.groupId!=0?200:150,
          child: Column(
            children: [
              Text(
                "${_S.edit_task} №${task.id}",
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600
                )
              ),
              if(task.groupId!=0)
              ElevatedButton(
                  onPressed: (){
                    if(isPicked) {
                      rxPickedTasksList.value.remove(task);
                      Navigator.pop(context);
                    }
                    else {
                      if(rxPickedTasksList.value.length>=3){
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(
                              '${_S.max} 3',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              )
                            ),
                            backgroundColor: Colors.red,
                          )
                        ); return;
                      }
                      rxPickedTasksList.value.add(task);
                      final groupId = store.get<int>('group')!;
                      Navigator.pushReplacementNamed(
                          context, '/chat',
                          arguments: {"group":
                            (store.get<List<Group>>('groups')!).where((e) => e.id==groupId).first
                          }
                      );
                    }
                  },
                  style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 5)
                      ),
                      backgroundColor: MaterialStatePropertyAll(theme.scaffoldBackgroundColor.withOpacity(
                          isPicked ? .5 : 1
                      )),
                      minimumSize: MaterialStatePropertyAll(Size(screenSize.width-20,0))
                  ),
                  child: Text(
                      !isPicked?_S.send:_S.already_picked,
                      style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor.withOpacity(isPicked ? .5 : 1)
                      )
                  )
              ),
              if(task.status==TaskStatus.uncompleted)
                ElevatedButton(
                    onPressed: () {
                      store.updateWithData('change_task_status', (status:TaskStatus.completed, task:task));
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 5)
                        ),
                        backgroundColor: MaterialStatePropertyAll(theme.primaryColor),
                        minimumSize: MaterialStatePropertyAll(Size(screenSize.width-20,0))
                    ),
                    child: Text(
                        _S.btn_complete,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        )
                    )
                )
              else
                ElevatedButton(
                    onPressed: () {
                      store.updateWithData('change_task_status', (status:TaskStatus.uncompleted, task:task));
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 5)
                      ),
                      minimumSize: MaterialStatePropertyAll(Size(screenSize.width-20,0))
                    ),
                    child: Text(
                        _S.btn_cancel,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        )
                    )
                ),
              ElevatedButton(
                  onPressed: (){
                    store.updateWithData('delete_task', task);
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 5)
                      ),
                      backgroundColor: const MaterialStatePropertyAll(Colors.red),
                      minimumSize: MaterialStatePropertyAll(Size(screenSize.width-20,0))
                  ),
                  child: Text(
                      _S.btn_delete,
                      style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                      )
                  )
              )
            ],
          )
        );
      }
  );
}