import 'dart:io';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/http/tasks.http.dart';
import 'package:notify/store/store_flutter_lib.dart';
import 'package:notify/widgets/FilePicker.widget.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:notify/widgets/ui/Optional.dart';
import 'package:notify/widgets/ui/TImerPicker.ui.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../generated/l10n.dart';
import '../../http/images.http.dart';
import '../../sockets/sockets.dart';
import '../../store/store.dart';
import '../ui/DatePicker.ui.dart';

var ImagesList = Reactive(<({String type, File file})>[]);

bool moreThen(TimeOfDay from, TimeOfDay to) =>
    (from.hour==to.hour&&from.minute>to.minute)||from.hour>to.hour;

void showCreateTaskModal(BuildContext context, void Function(int id) onCreate, [int groupId = 0]){
  showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => _CreateTask(groupId: groupId)
  );
}

class _CreateTask extends StatefulWidget{
  _CreateTask({
    required this.groupId
  });
  int groupId;

  @override
  State<StatefulWidget> createState() => _StateCreateTask();
}

class _StateCreateTask extends State<_CreateTask>{
  late final _S = S.of(context);
  bool isLoading = false;
  String title = '';
  String description = '';
  DateTime dateFrom = store.get<DateTime>('date')!;
  DateTime dateTo = store.get<DateTime>('date')!;
  TimeOfDay timeFrom = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay timeTo = const TimeOfDay(hour: 0, minute: 30);

  @override
  void dispose() {
    super.dispose();
    ImagesList.value = [];
  }

  void showMessage(){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                _S.error,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white
                )
            )
        )
    );
  }

  void createTask() async {
    setState(() => isLoading = true);
    var imagesId = [0];
    if(ImagesList.value.isNotEmpty){
      imagesId.clear();
      for(var file in ImagesList.value){
        var imageReq = await ImagesHttp.sendSingleFile(file.file);
        if(imageReq['added'] as bool){
          imagesId.add(imageReq['id']);
        }
      }
    }
    var task = Task(
        id: 0,
        dayFrom: dateFrom.day,
        monthFrom: dateFrom.month,
        yearFrom: dateFrom.year,
        dayTo: dateTo.day,
        monthTo: dateTo.month,
        yearTo: dateTo.year,
        hourFrom: timeFrom.hour,
        minuteFrom: timeFrom.minute,
        hourTo: timeTo.hour,
        minuteTo: timeTo.minute,
        title: title,
        description: description,
        creatorId: store.get<int>('id')!,
        groupId: widget.groupId,
        imagesId: imagesId,
        status: TaskStatus.uncompleted
    );
    try{
      final createTask = await TasksHttp.createTask(task);
      if(createTask['created'] as bool){
        store.update('update_tasks_list');
        if(store.get<int>('group')!=0){
          task.id = createTask['id'];
          updateSocket(task, SocketCommand.update);
        }
      }else{
        setState(() => isLoading = false);
        showMessage();
      }
    }catch(_){
      setState(() => isLoading = false);
      showMessage();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeAreaSize = View.of(context).padding.top;

    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: (MediaQuery.of(context).size.height)-safeAreaSize,
            child: SingleChildScrollView(
              child:
                 Optional(
                   conditional: isLoading,
                   complited:Align(
                       heightFactor: 16,
                       child: Center(
                           child: CircularProgressIndicator(
                               color: theme.primaryColor
                           )
                       )
                   ),
                   uncomplited:Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                             _S.task_title,
                             style: theme.textTheme.bodyLarge
                         ),
                         const SizedBox(height: 5),
                         FormTextField(
                           onInput: (String text) => title = text,
                           hintText: '${_S.write} ${_S.task_title.toLowerCase()}',
                           borderRadius: 10,
                         ),
                         const SizedBox(height: 5),
                         Text(
                             _S.task_description,
                             style: theme.textTheme.bodyLarge
                         ),
                         const SizedBox(height: 5),
                         FormTextField(
                           onInput: (String text) => description = text,
                           hintText: '${_S.write} ${_S.task_description.toLowerCase()}',
                           borderRadius: 10,
                           maxLines: 3
                         ),
                         const SizedBox(height: 5),
                         Text(
                             _S.task_date,
                             style: theme.textTheme.bodyLarge
                         ),
                         DatePicker(
                             date: dateFrom,
                             selectionMode: DateRangePickerSelectionMode.range,
                             onDateChange: (args){
                               var date = args.value as PickerDateRange;
                               setState(() {
                                 dateFrom = date.startDate!=null?date.startDate!:date.endDate!;
                                 dateTo = date.endDate!=null?date.endDate!:date.startDate!;
                               });
                             }
                         ),
                         Text(
                             _S.task_time,
                             style: theme.textTheme.bodyLarge
                         ),
                         const SizedBox(height: 10),
                         TimerPicker(
                             timeFrom: timeFrom,
                             timeTo: timeTo,
                             onDateChange: (dates){
                               setState(() {
                                 timeFrom = dates.from;
                                 timeTo = dates.to;
                               });
                             }
                         ),
                         const SizedBox(height: 10),
                         Text(
                             _S.photo,
                             style: theme.textTheme.bodyLarge
                         ),
                         const SizedBox(height: 10),
                         Row(
                             children: [
                               CameraFilePicker(
                                   size: 40,
                                   onPick: (path){
                                     var files = ImagesList.value;
                                     if(files.length<=8){
                                       ImagesList.value = [...files, (file: File(path!), type: FileType.photo)];
                                     }else{

                                     }
                                   }
                               ),
                               FilePicker(
                                   onPick: (paths, fileType){
                                     var files = ImagesList.value;
                                     if(files.length+paths.length<=9){
                                       var generated = List.generate(paths.length, (index) =>
                                       (type: fileType, file:File(paths[index])));
                                       ImagesList.value = [ ...files, ...generated];
                                     }else{

                                     }
                                   },
                                   multiple: true,
                                   icon: Icon(
                                     Icons.photo,
                                     color: theme.primaryColor,
                                     size: 40,
                                   )
                               )
                             ]
                         ),
                         const SizedBox(height: 10),
                         const ImagesGrid(),
                         const SizedBox(height: 10),
                         Align(
                             alignment: Alignment.center,
                             child: ElevatedButton(
                                 onPressed: createTask,
                                 style: ButtonStyle(
                                     backgroundColor: MaterialStatePropertyAll(
                                         theme.primaryColor
                                     )
                                 ),
                                 child: Text(
                                     _S.create,
                                     style: theme.textTheme.bodyLarge!.copyWith(
                                         color: Colors.white
                                     )
                                 )
                             )
                         ),
                         const SizedBox(height: 10)
                       ]
                   )
                 )
            )
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child:IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(theme.primaryColor.withOpacity(.75))
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 40
                  )
              )
          )
      ],
    );
  }
}

class ImagesGrid extends StatefulWidget{
  const ImagesGrid({super.key});

  @override
  State<ImagesGrid> createState() => _StateImages();
}

class _StateImages extends State<ImagesGrid>{
  var indexes = <int>[];

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder(
        reactive: ImagesList,
        builder: (context){
          var files = ImagesList.value;

          return Column(
            children: [
              if(indexes.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: indexes.isNotEmpty ? 50 : 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: (){
                            var list = ImagesList.value;
                            ImagesList.value = (() sync* {
                              for(var i=0; i<list.length; i++){
                                if(!indexes.contains(i)) yield list[i];
                              }
                            }()).toList();
                            indexes.clear();
                            setState(() {});
                          },
                          style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.red)
                          ),
                          icon: const Icon(
                            Icons.delete,
                            size: 30,
                            color: Colors.white
                          )
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: (){
                            indexes.clear();
                            setState(() {});
                          },
                          style:ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)
                          ),
                          icon: const Icon(
                            Icons.highlight_off,
                            size: 30,
                            color: Colors.white,
                          )
                      )
                    ]
                )
              ),
              if(indexes.isNotEmpty)
                const SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: files.isNotEmpty ? (files.length/3).ceil()*110 : 0,
                  child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(files.length, (index){
                        return AnimatedPadding(
                              duration: const Duration(milliseconds: 100),
                              padding: indexes.contains(index)?
                                        const EdgeInsets.all(15):
                                        EdgeInsets.zero,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: indexes.contains(index)?0.5:1,
                                child: InkWell(
                                  onLongPress: (){
                                    // var list = ImagesList.value;
                                    // list.removeAt(index);
                                    // ImagesList.value = list;
                                    indexes.add(index);
                                    setState(() {});
                                  },
                                  onTap: (){
                                    if(indexes.isNotEmpty){
                                      if(indexes.contains(index)) indexes.remove(index);
                                      else indexes.add(index);
                                      setState(() {});
                                    }
                                  },
                                  child: Image.file(
                                      files[index].file,
                                      fit: BoxFit.fill
                                  )
                              )
                            )
                        );
                      })
                  )
              ),
            ],
          );
        }
    );
  }
}