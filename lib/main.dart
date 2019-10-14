import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

mongo_dart.Db dbConnector = mongo_dart.Db('mongodb://192.168.1.233/todo');
mongo_dart.DbCollection coll = dbConnector.collection('todo');

ThemeData theme = ThemeData(
  // primaryColor: Colors.white,
  unselectedWidgetColor: Colors.white,
  // appBarTheme: AppBarTheme(
  //   color: Colors.white,
  //   textTheme: TextTheme(
  //     title: TextStyle(
  //       color: Colors.black,
  //     ),
  //   ),
  //   actionsIconTheme: IconThemeData(color: Colors.black),
  // ),
);

var todoList;

void main() async {
  await dbConnector.open();
  todoList = await coll.find().toList();
  print(todoList);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  TextEditingController _textController = TextEditingController();

  Widget cardListBuilder() {
    return Expanded(
      child: ListView.builder(
        // reverse: true,
        itemCount: todoList.length,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Checkbox(
                  value: todoList[position]['isDone'],
                  checkColor: Colors.black,
                  activeColor: Colors.white,
                  onChanged: (bool newValue) async {
                    coll.update(
                        mongo_dart.where.eq('_id', todoList[position]['_id']),
                        mongo_dart.modify.set('isDone', newValue));
                    var temp = await coll.find().toList();
                    setState(() {
                      todoList = temp;
                    });
                  },
                ),
                Text(
                  todoList[position]['title'],
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () async {
                    coll.remove(
                        mongo_dart.where.eq('_id', todoList[position]['_id']));
                    var temp = await coll.find().toList();
                    setState(() {
                      todoList = temp;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                var temp = await coll.find().toList();
                setState(() {
                  todoList = temp;
                });
              },
            )
          ],
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the Todo',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (_textController.text != '' &&
                        _textController.text != ' ' &&
                        _textController.text != null) {
                      coll.insert(
                          {'title': _textController.text, 'isDone': false});

                      _textController.clear();
                      var temp = await coll.find().toList();
                      setState(() {
                        todoList = temp;
                      });
                    }
                  },
                ),
              ),
              cardListBuilder(),
            ],
          ),
        ),
      ),
    );
  }
}
