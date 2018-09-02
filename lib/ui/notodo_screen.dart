import 'package:flutter/material.dart';
import 'package:notodo_app/util/databaseHelper.dart';
import 'package:notodo_app/modal/nodo_item.dart';
import 'package:intl/intl.dart';

class NotoDoScreen extends StatefulWidget {
  @override
  _NotoDoScreenState createState() => _NotoDoScreenState();
}

class _NotoDoScreenState extends State<NotoDoScreen> {

  var db = new DatabaseHelper();
  TextEditingController _noteController = new TextEditingController();
  TextEditingController _updateController = new TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    db.close();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[updateCredentialWidget()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            _showFormDialog(context);
          });
        },
        tooltip: "Add Item",
        backgroundColor: Colors.blueGrey,
        child: new ListTile(
          title: new Icon(Icons.add),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context) {
    var alert = new AlertDialog(
      title: new TextField(
        controller: _noteController,
        autofocus: true,
        decoration: new InputDecoration(
            labelText: "Item",
            hintText: "eg. Don't buy stuff",
            icon: new Icon(Icons.note_add)),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            String notodo = _noteController.text.trim();
            int time = new DateTime.now().millisecondsSinceEpoch;
            if (notodo.length > 0) {
              setState(() {
                saveItem(notodo, time);
              });
            }
            _noteController.text = "";
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    // showDialog(context: context, child: alert);
    showDialog(context: context, builder: (context) => alert);
  }

  void _updateFormDialog(BuildContext context, String prevText, int id) {
    var alert = new AlertDialog(
      title: new TextField(
        controller: _updateController,
        autofocus: true,
        decoration: new InputDecoration(
            labelText: "Item",
            hintText: prevText,
            icon: new Icon(Icons.update)),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Update"),
          onPressed: () {
            String notodo = _updateController.text.trim();
            int time = new DateTime.now().millisecondsSinceEpoch;
            if (notodo.length > 0) {
              setState(() {
                editItem(NoDoItem.update(notodo, time, id));
              });
            }
            _updateController.text = '';
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    // showDialog(context: context, child: alert);
    showDialog(context: context, builder: (context) => alert);
  }

  saveItem(item, timeStamp) async {
    await db.saveNote(new NoDoItem(item, timeStamp));
    int count = await db.getCount();
    print("Count: $count");
  }

  deleteItem(int id) async{
    await db.deleteNote(id);
  }

  editItem(NoDoItem item) async{
    await db.updateNote(item);
    print("Update");
    print(item.toMap().toString());
  }

  Widget updateCredentialWidget() {
    return new FutureBuilder(
        future: db.getAllNotes(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          try {
            List _notes = snapshot.data.toList();
            int length = _notes.length - 1;
            return new Flexible(
              child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (BuildContext context, int position) {
                    int id = NoDoItem.fromMap(_notes[length - position]).id;
                    String note =
                        NoDoItem.fromMap(_notes[length - position]).itemName;
                    var dateTime = new DateTime.fromMillisecondsSinceEpoch(
                        NoDoItem.fromMap(_notes[length - position]).dateCreated);
                    String formattedDateTime =
                    new DateFormat.yMMMd().add_jm().format(dateTime);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: new Card(
                        color: Colors.black12,
                        elevation: 2.0,
                        child: ListTile(
                          title: new Text(
                            "$note",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: new Text(
                            "Created on: $formattedDateTime",
                            style: TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: new Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: (){
                              setState(() {
                                deleteItem(id);
                              });
                            },
                          ),
                          onTap: (){
                              _updateFormDialog(context, note, id);
                          },
                        ),
                      ),
                    );
                  }),
            );
          } catch (e) {
            debugPrint("Error Handling");
            return new Text(
              "No Credential Saved!",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            );
          }
        });
  }
}


