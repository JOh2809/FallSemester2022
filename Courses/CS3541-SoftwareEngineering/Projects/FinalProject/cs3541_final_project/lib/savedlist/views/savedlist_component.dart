import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../presenter/savedlist_presenter.dart';
import '../../amazon/views/amazon_component.dart';

class SavedListPage extends StatefulWidget {
  final SavedListPresenter presenter;

  SavedListPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SavedListPageState createState() => _SavedListPageState();
}
class _SavedListPageState extends State<SavedListPage> {

  void initState(){
    super.initState();
    build(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Saved Books'),
          actions: [
            PopupMenuButton(
                itemBuilder: (context){
                  return [
                    PopupMenuItem<int>(
                        value: 0,
                        child: Text('Sort by Price')
                    ),
                    PopupMenuItem<int>(
                        value: 0,
                        child: Text('Sort by Rating')
                    ),
                  ];
                },
              onSelected: (value) {
                  if(value == 0){
                    ScaffoldMessenger.of(context)
                        .showSnackBar((SnackBar(content: Text('Sorting Books by Price'))));
                  }
                  else if(value == 1) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Sorting Books by Rating')));
                  }
              },
            )
          ],
        ),

        body: ListView.builder(
          itemCount: saved.length,
          itemBuilder: (BuildContext context, int index){
            final item = saved[index];
            return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    saved.removeAt(index);
                  });
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Book has been removed')));
                },
                // Show a red background as the item is swiped away.
                background: Container(color: Colors.red),
                child: ListTile(
                  leading: item.leading,
                  trailing: item.trailing,
                  title: item.title,
                  subtitle: item.subtitle,
                  isThreeLine: true,
                )
            );
          },
        )
    );
  }
}