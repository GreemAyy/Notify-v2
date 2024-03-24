import 'package:dart_flutter/custom_classes/group.dart';
import 'package:dart_flutter/widgets/group/MyGroupsList.widget.dart';
import 'package:dart_flutter/widgets/task/SecondTaskSlider.widget.dart';
import 'package:dart_flutter/widgets/task/ShowCreateTaskModal.dart';
import 'package:dart_flutter/widgets/task/ShowDatePickerModal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store/store.dart';

class TasksScreen extends StatefulWidget{
  const TasksScreen({
    super.key,
    this.group
  });
  final Group? group;

  @override
  State<StatefulWidget> createState() => _StateTasksScreen();
}

class _StateTasksScreen extends State<TasksScreen>{
  final headerHeight = (60).toDouble();
  final tabHeight = (150).toDouble();
  late var groupBarHeight = (widget.group!=null?67.5:0).toDouble();
  var date = DateTime.now();
  var dateWatchIndex = 0;

  void go(int days){
    setState((){
      date = date.add(Duration(days: days));
      store.mapMultiSet({
        'date':date,
        'task_is_loading':true
      });
    });
  }

  @override
  void initState() {
    super.initState();
    dateWatchIndex = store.watch<DateTime>('date', (newDate) {
      setState(() => date = newDate);
    });
  }

  @override
  void dispose() {
    super.dispose();
    store.unSeeAt('date', dateWatchIndex);
    store.set('group', 0, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final safeAreaSize = MediaQuery.of(context).padding.top;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:() => showCreateTaskModal(context, (id) {}, store.get('group')),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, size: 40, color: Colors.white)
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if(widget.group != null)
              SliverToBoxAdapter(
                  child: SizedBox(
                    height: groupBarHeight,
                    child: GroupListItem(
                      onTap: (){
                        Navigator.of(context)
                            .pushNamed('/group',arguments: {"group":widget.group});
                      },
                      group: widget.group!,
                      padding: (horizontal: 15, vertical: 5),
                      heroTag: 'hero_group_image_${widget.group!.id}'
                    )
                  )
              ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: SizedBox(
                  height: headerHeight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            padding: const EdgeInsets.all(15),
                            icon: const Icon(Icons.arrow_back)
                        ),
                        IconButton(
                            onPressed: (){
                              Navigator.pushNamed(context, '/search');
                            },
                            padding: const EdgeInsets.all(15),
                            icon: const Hero(
                                tag: 'hero_search',
                                child: Icon(Icons.search)
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                                onPressed: () =>
                                    showDatePickerModal(context, date, (newDate){
                                      setState(() => date = newDate);
                                      store.set('date', newDate);
                                    }),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(theme.primaryColor)
                                ),
                                child: Text(
                                    DateFormat('dd.MM.yyyy').format(date),
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                        color: Colors.white
                                    )
                                )
                            )
                        )
                      ]
                  )
              )
            ),
            SliverToBoxAdapter(
              child: SecondTaskSlider(
                  height: screenSize.height - headerHeight - safeAreaSize - groupBarHeight,
                  onNext:() => go(1),
                  onPrevious:() => go(-1)
              )
            )
          ]
        )
      )
    );
  }
}