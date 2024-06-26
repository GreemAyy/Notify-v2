import 'package:notify/sockets/chat_sockets.dart';
import 'package:notify/store/store.dart';
import 'package:notify/widgets/group/show_group_create_modal.dart';
import 'package:flutter/material.dart';
import 'package:notify/widgets/group/show_join_modal.dart';
import '../generated/l10n.dart';
import '../sockets/sockets.dart';
import '../widgets/group/MyGroupsList.widget.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _StateHomeScreen();
}

class _StateHomeScreen extends State<HomeScreen>{
  late final _S = S.of(context);

  @override
  void initState() {
    super.initState();
    startSocketUpdateWatcher();
    startChatSockets();
    connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showGroupCreateModal(context, (id) => store.update('groups')); // MyGroupList
          },
          backgroundColor: theme.primaryColor,
          child: const Icon(Icons.add, size: 40, color: Colors.white)
        ),
        body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => store.update('groups'),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(1),
                      title: Text(
                          _S.home_task_header,
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.primaryColor,
                              fontSize: (theme.textTheme.bodyLarge!.fontSize??0)+10
                          )
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal:10, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.textTheme.bodyMedium!.color!.withOpacity(.1),
                        borderRadius: const BorderRadius.all(Radius.circular(15))
                      ),
                      child: ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, '/my-tasks');
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        leading: const Icon(Icons.add),
                        title: Text(
                            _S.my_tasks_text,
                            style: theme.textTheme.bodyMedium
                        )
                      )
                    )
                  ),
                  SliverAppBar(
                      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(1),
                      title: Text(
                          _S.home_header,
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.primaryColor,
                              fontSize: (theme.textTheme.bodyLarge!.fontSize??0)+10
                          )
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: InkWell(
                        onTap: () => showJoinModal(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(S.of(context).join_to_group),
                              const Icon(Icons.add)
                            ]
                          )
                        )
                      ),
                    )
                  ),
                  const MyGroupsList()
                ]
              ),
            )
        )
    );
  }
}

