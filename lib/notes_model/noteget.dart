

import 'package:hive/hive.dart';
import 'package:notes/notes_model/note_model.dart';

class Boxes {
  static Box<NotesModel> getData() => Hive.box<NotesModel>('notes');
}