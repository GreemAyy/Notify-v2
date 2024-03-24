import 'package:notify/http/tasks.http.dart';
import 'package:notify/widgets/task/SecondTasksList.widget.dart';
import 'package:notify/widgets/ui/FormTextField.ui.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../store/store.dart';

class SearchScreen extends StatefulWidget{
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen>{
  late final _S = S.of(context);
  late final screenSize = MediaQuery.of(context).size;
  bool isLoading = false;

  void search(String text) async {
    setState(() => isLoading = true);
    int id = store.get('id');
    int groupId = store.get('group');
    var search = await TasksHttp.searchTasks(text, id, groupId);
    setState((){
      store.updateWithData('search_tasks', search);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: SizedBox(
                width: screenSize.width,
                child: Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          padding: const EdgeInsets.all(15),
                          icon: const Icon(
                              Icons.arrow_back
                          )
                      ),
                      Expanded(
                          child: FormTextField(
                              onInput: search,
                              hintText: _S.search,
                              borderRadius: 10,
                              autoOpen: true,
                              icon: const Hero(
                                tag: 'hero_search',
                                child: Icon(Icons.search),
                              )
                          )
                      ),
                      const SizedBox(width: 10)
                    ]
                )
              )
            ),
            SliverToBoxAdapter(
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isLoading  ? 50 : 0,
                    child: Align(
                      child: CircularProgressIndicator(
                          color: theme.primaryColor
                      )
                    )
                )
            ),
            SecondTasksList(
                display: !isLoading,
                initLoad: false,
                isSliver: true
            )
          ]
        )
      )
    );
  }
}