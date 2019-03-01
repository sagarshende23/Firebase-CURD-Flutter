import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreCRUDPage extends StatefulWidget {
  @override
  _FirestoreCRUDPageState createState() => _FirestoreCRUDPageState();
}

class _FirestoreCRUDPageState extends State<FirestoreCRUDPage> {
  String id;

  final _formKey = GlobalKey<FormState>();
  String name;

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'name: ${doc.data['name']}',
              style: TextStyle(fontSize: 24.0),
            ),
            Text(
              'todo: ${doc.data['todo']}',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateData(doc),
                  child: Text(
                    'Update Toto',
                    style: TextStyle(),
                  ),
                  color: Colors.green,
                ),
                FlatButton(
                  onPressed: () => deleteData(doc),
                  child: Text('delete'),
                  color: Colors.white12,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore CRUD"),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Form(
            key: _formKey,
            child: buildTextFormField(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: createData,
                child: Text(
                  'Create',
                  style: TextStyle(color: Colors.blue),
                ),
                color: Colors.green,
              ),
              RaisedButton(
                onPressed: id != null ? readData : null,
                child: Text(
                  'Read',
                  style: TextStyle(color: Colors.blue),
                ),
                color: Colors.white,
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('CRUD').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.documents
                        .map((doc) => buildItem(doc))
                        .toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Name',
        filled: true,
      ),
      validator: (value) => value.isEmpty ? 'Please Enter some Text' : null,
      onSaved: (value) => name = value,
    );
  }

  void createData() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      DocumentReference ref = await Firestore.instance
          .collection('CRUD')
          .add({'name': '$name 😎', 'todo': randomTodo()});
      setState(() => id = ref.documentID);
      print(ref.documentID);
    }
  }

  void readData() async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection("CURD").document(id).get();
    print(snapshot.data['name']);
  }

  updateData(DocumentSnapshot doc) async {
    await Firestore.instance
        .collection('CRUD')
        .document(doc.documentID)
        .updateData({'todo': 'please 🤫'});
  }

  deleteData(DocumentSnapshot doc) async {
    await Firestore.instance
        .collection('CRUD')
        .document(doc.documentID)
        .delete();
    setState(() {
      id = null;
    });
  }

  String randomTodo() {
    final randomNumber = Random().nextInt(4);
    String todo;
    switch (randomNumber) {
      case 1:
        todo = 'Like and subscribe 💩';
        break;
      case 2:
        todo = 'Twitter @sagarshende 🤣';
        break;
      case 3:
        todo = 'Patreon in the description 🤗';
        break;
      default:
        todo = 'Leave a comment 🤓';
        break;
    }
    return todo;
  }
}
