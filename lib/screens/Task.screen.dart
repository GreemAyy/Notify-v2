import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/http/tasks.http.dart';
import 'package:notify/widgets/ui/DatePicker.ui.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:notify/widgets/ui/Optional.dart';
import 'package:notify/widgets/ui/PicturesGrid.ui.dart';
import 'package:notify/widgets/ui/TImerPicker.ui.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../generated/l10n.dart';
import '../store/store.dart';

class TaskScreen extends StatefulWidget{
  const TaskScreen({
    super.key,
    required this.task,
    this.isChild = false
  });
  final Task task;
  final bool isChild;

  @override
  State<StatefulWidget> createState() => _StateTaskScreen();
}

class _StateTaskScreen extends State<TaskScreen>{
  late final _S = S.of(context);
  late var dateFrom = DateTime(task.yearFrom, task.monthFrom, task.dayFrom);
  late var dateTo = DateTime(task.yearTo, task.monthTo, task.dayTo);
  late var timeFrom = TimeOfDay(hour: task.hourFrom, minute: task.minuteFrom);
  late var timeTo = TimeOfDay(hour: task.hourTo, minute: task.minuteTo);
  late var task = widget.task;
  late var title = task.title;
  late var description = task.description;
  final _controller = ScrollController();
  final pickedImages = <int>[];
  static const _imageWidth = 200.0;
  static const _imageHeight = 275.0;
  var userId = store.get('id')!;
  var pickedIndex = 0;
  late bool isInitLoading = !widget.task.fullAccess;
  late bool isHaveAccess = widget.task.fullAccess;
  bool isLoading = false;
  bool showBottomBar = false;
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    if(!widget.task.fullAccess){
      accessCheck().then((result){
        setState(() {
          isInitLoading = false;
          isHaveAccess = result;
        });
      });
    }
    initTimer();
  }

  Future<bool> accessCheck() async {
    final taskAccesses = await TasksHttp.getTaskAccess(widget.task.id);
    if(taskAccesses!=null){
      final userId = store.get<int>('id')!;
      return !taskAccesses.usersId.contains(userId);
    }
    return false;
  }

  void initTimer(){
    Timer? timer;
    timer = Timer(const Duration(milliseconds: 100), (){
      if(widget.isChild) return;
      setState((){
        if(store.get('group')==0){
          showBottomBar = true;
        } else if(task.creatorId==userId){
          showBottomBar = true;
        }
      });
      timer!.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void updateTask() async {
    if(isLoading) return;
    setState(() => isLoading = true);
    _controller.jumpTo(0);
    final updatedTask = Task(
        id: task.id,
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
        creatorId: task.creatorId,
        groupId: task.groupId,
        imagesId: task.imagesId,
        status: task.status,
        fullAccess: task.fullAccess
    );
    if(jsonEncode(updatedTask.toJson()) != jsonEncode(task.toJson())){
      var update = await TasksHttp.updateTask(updatedTask);
      if(update) store.updateWithData('update_tasks_list', updatedTask);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    if(isInitLoading || !isHaveAccess){
      return Scaffold(
        appBar: AppBar(),
        extendBodyBehindAppBar: true,
        body: Align(
          alignment: Alignment.center,
          child: (
            isInitLoading ?
            CircularProgressIndicator(
                color: theme.primaryColor
            ) :
            Text(_S.deny_access, style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.primaryColor
            ))
          )
        )
      );
    }

    return PopScope(
      onPopInvoked: (isPop){
        setState((){
          if(!isPop) canPop = true;
          pickedImages.clear();
        });
      },
      canPop: canPop,
      child: Scaffold(
        floatingActionButton:
        !widget.isChild&&task.creatorId==userId?
        AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: showBottomBar ? 70 : 0),
            child: FloatingActionButton(
                onPressed: updateTask,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.save)
            )
        ):null,
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                controller: _controller,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    automaticallyImplyLeading: !widget.isChild,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)
                      )
                    ),
                    title: Text(
                      '${_S.task} №${task.id}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600
                      )
                    )
                  ),
                  SliverToBoxAdapter(
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: isLoading ? 50 : 0,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: theme.primaryColor
                              )
                          )
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _S.task_title,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600
                                )
                            ),
                            FormTextField(
                              onInput: (String text) => title = text,
                              getFocusNode: (node){
                                node.addListener(() {
                                  setState(() => showBottomBar = !node.hasFocus);
                                });
                              },
                              initValue: task.title,
                              enabled: !widget.isChild,
                              hintText: "${_S.write} ${_S.task_title.toLowerCase()}",
                              borderRadius: 10,
                              backgroundColor: theme.scaffoldBackgroundColor,
                            )
                          ]
                        )
                    )
                  ),
                  if(task.imagesId[0]!=0)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                              itemCount: task.imagesId.length,
                              options: CarouselOptions(
                                  height: _imageHeight,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index,_){
                                    setState(() => pickedIndex = index);
                                  }
                              ),
                              itemBuilder: (BuildContext context, int index, int viewIndex) {
                                final heroTag = 'hero_task_screen${widget.isChild?'_child':''}_@1_image_${task.id}_${task.imagesId[index]}';
                                return InkWell(
                                  onTap: (){
                                    if(canPop){
                                      Navigator.pushNamed(context, '/image', arguments: {
                                        "image":ImagePlaceholder(
                                          imageId: task.imagesId[index],
                                          imageHeight: screenSize.height,
                                          imageWidth: screenSize.width,
                                          fit: BoxFit.contain,
                                        ),
                                        "hero":heroTag
                                      });
                                    }else{
                                      setState((){
                                        if(pickedImages.contains(index)){
                                          pickedImages.remove(index);
                                        }else{
                                          pickedImages.add(index);
                                        }
                                        if(pickedImages.isEmpty) setState(() => canPop = true);
                                      });
                                    }
                                  },
                                  child: Hero(
                                      tag: heroTag,
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 100),
                                        opacity: pickedImages.contains(index) ? 0.25 : 1,
                                        child: ImagePlaceholder(
                                            imageId: task.imagesId[index],
                                            imageHeight: _imageHeight,
                                            imageWidth: _imageWidth
                                        )
                                      )
                                  )
                                );
                              }
                          ),
                          const SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  task.imagesId.length,
                                      (index){
                                    return Opacity(
                                        opacity: pickedIndex==index?1:.3,
                                        child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 15,
                                            color: theme.textTheme.bodyMedium!.color
                                        )
                                    );
                                  }
                              )
                          )
                        ]
                      )
                    ),
                  SliverToBoxAdapter(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _S.task_description,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w600
                                  )
                              ),
                              const SizedBox(height: 5),
                              FormTextField(
                                onInput: (String text) => description = text,
                                textStyle: theme.textTheme.bodyMedium!.copyWith(
                                    fontSize: 15
                                ),
                                getFocusNode: (node){
                                  node.addListener(() {
                                    setState(() => showBottomBar = !node.hasFocus);
                                  });
                                },
                                enabled: !widget.isChild,
                                maxLines: 3,
                                borderRadius: 10,
                                hintText: '${_S.write} ${_S.task_description.toLowerCase()}',
                                initValue: task.description,
                                backgroundColor: theme.scaffoldBackgroundColor,
                              )
                            ]
                          )
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _S.task_date,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600
                            )
                          ),
                          const SizedBox(height: 5),
                          DatePicker(
                            date: dateFrom,
                            toDate: dateTo,
                            selectionMode: DateRangePickerSelectionMode.range,
                            onDateChange: (args){
                              if(!widget.isChild){
                                final date = args.value as PickerDateRange;
                                setState(() {
                                  dateFrom = date.startDate!;
                                  dateTo = date.endDate==null ? date.startDate! : date.endDate!;
                                });
                              }
                            }
                          )
                        ]
                      )
                    )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                               _S.task_time,
                               style: theme.textTheme.bodyMedium!.copyWith(
                                   fontWeight: FontWeight.w600
                               )
                           ),
                           const SizedBox(height: 5),
                           TimerPicker(
                              timeFrom: timeFrom,
                              timeTo: timeTo,
                              disabled: widget.isChild,
                              onDateChange: (dates){
                                setState(() {
                                  timeFrom = dates.from;
                                  timeTo = dates.to;
                                });
                              }
                            )
                        ]
                      )
                    )
                  ),
                  if(!widget.isChild&&task.creatorId==userId)
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150
                      )
                    )
                ]
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                bottom: showBottomBar ? 0 : -screenSize.height/2,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaY: 2,
                            sigmaX: 2
                          ),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                                  color: theme.primaryColor.withOpacity(.1)
                              ),
                              child: Optional(
                                  conditional: canPop,
                                  complited: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if(task.status == TaskStatus.uncompleted)
                                          ElevatedButton(
                                              onPressed: () {
                                                store.updateWithData('change_task_status', (status:TaskStatus.completed, task:task));
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: theme.primaryColor
                                              ),
                                              child: Text(
                                                  _S.btn_complete,
                                                  style: theme.textTheme.bodyMedium!.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 17.5,
                                                  )
                                              )
                                          )
                                        else
                                          ElevatedButton(
                                              onPressed: () {
                                                store.updateWithData('change_task_status', (status:TaskStatus.uncompleted, task:task));
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                  _S.btn_cancel,
                                                  style: theme.textTheme.bodyMedium!.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryColor,
                                                    fontSize: 17.5,
                                                  )
                                              )
                                          ),
                                        ElevatedButton(
                                            onPressed: (){
                                              store.updateWithData('delete_task', task);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red
                                            ),
                                            child: Text(
                                                _S.btn_delete,
                                                style: theme.textTheme.bodyMedium!.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 17.5
                                                )
                                            )
                                        )
                                      ]
                                  ),
                                  uncomplited: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              if(pickedImages.isNotEmpty){
                                                setState(() => isLoading = true);
                                                var listAt = <int>[];
                                                for (var index in pickedImages) {
                                                  listAt.add(task.imagesId[index]);
                                                }
                                                var deleted = await TasksHttp.deleteImages(task.id, listAt);
                                                _controller.jumpTo(0);
                                                if(deleted) store.update('update_tasks_list');
                                                setState((){
                                                  var after = task.imagesId.where((image) => !listAt.contains(image)).toList();
                                                  task.imagesId = after.isNotEmpty?after:[0];
                                                  pickedImages.clear();
                                                  isLoading = false;
                                                  canPop = true;
                                                  pickedIndex = 0;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: theme.primaryColor
                                            ),
                                            child: Text(
                                                _S.btn_delete,
                                                style: theme.textTheme.bodyMedium!.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                )
                                            )
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState((){
                                                canPop = true;
                                                pickedImages.clear();
                                              });
                                            },
                                            child: Text(
                                                _S.btn_cancel,
                                                style: theme.textTheme.bodyMedium!.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.primaryColor,
                                                  fontSize: 17.5,
                                                )
                                            )
                                        )
                                      ]
                                  )
                              )
                          )
                        )
                      )
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}