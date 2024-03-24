import 'package:dart_flutter/custom_classes/task.dart';
import 'package:dart_flutter/store/store.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

void showTaskOptionsModal(BuildContext context,Task task){
  showModalBottomSheet(
      context: context,
      builder: (context){
        final _S = S.of(context);
        final theme = Theme.of(context);
        final screenSize = MediaQuery.of(context).size;

        return Container(
          width: screenSize.width,
          padding: const EdgeInsets.only(top: 15),
          height: 150,
          child: Column(
            children: [
              Text(
                "${_S.edit_task} №${task.id}",
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600
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