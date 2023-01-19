import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'notes_model/note_model.dart';
import 'notes_model/noteget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(NotesModelAdapter());
  await Hive.openBox<NotesModel>('notes');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Notes(),
    );
  }
}

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  var titleControler = TextEditingController();
  var descriptionControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showDailog();
        },
        child: Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable:Boxes.getData().listenable(),
        builder:(context, box, _) {
          var data = box.values.toList().cast<NotesModel>();
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(data[index].title.toString(),style: TextStyle(fontSize: 30),),
                            Spacer(),
                            IconButton(onPressed: (){
                              delet(data[index]);
                            }, icon: Icon(Icons.delete,color: Colors.red,)),
                            IconButton(onPressed: (){
                              _editDailog(data[index], data[index].title.toString(), data[index].description.toString());
                            }, icon: Icon(Icons.edit))
                          ],
                        ),
                        Text(data[index].description.toString()),
                      ],
                    ),
                  ),
                ),
              );
            },);
        },),
    );
  }
  Future<void> _showDailog(){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                  controller: titleControler,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Title Here'
                  )
              ),
              SizedBox(height: 20,),
              TextFormField(
                  controller: descriptionControler,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Description Here'
                  )
              ),
            ],
          ),
        ),
        title: Text('Your Notes'),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          },child: Text('Cancel')),
          TextButton(onPressed: () async {
            var data = await NotesModel(titleControler.text.toString(), descriptionControler.text.toString());
            final box = Boxes.getData();
            box.add(data);
            titleControler.clear();
            descriptionControler.clear();
            Navigator.pop(context);
          },child: Text('Add')),
        ],
      );
    },);
  }
  Future<void> _editDailog(NotesModel notesModel, String title, String discription) async {
    titleControler.text = title;
    descriptionControler.text = title;
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                  controller: titleControler,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Title Here'
                  )
              ),
              SizedBox(height: 20,),
              TextFormField(
                  controller: descriptionControler,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Description Here'
                  )
              ),
            ],
          ),
        ),
        title: Text('Update Notes'),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          },child: Text('Cancel')),
          TextButton(onPressed: () async {
            NotesModel(titleControler.text, descriptionControler.text);
            titleControler.clear();
            descriptionControler.clear();
            Navigator.pop(context);
          },child: Text('Edit')),
        ],
      );
    },);
  }

  Future<void> delet(NotesModel notesModel) async {
    await notesModel.delete();
  }

}

