import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/data/models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(Note note);
}

class NoteRemoteDataSourceImp implements NoteRemoteDataSource {
  @override
  Future<List<NoteModel>> getNotes() async {
    var url = Uri.https('4978-2806-10ae-1b-a78a-71f9-7912-dd2b-9877.ngrok-free.app', '/api/notes');
    var response = await http.get(url);

    if(response.statusCode == 200) {
      return convert.jsonDecode(response.body)
              .map<NoteModel>((data) => NoteModel.fromJson(data))
              .toList();
    } else {
      throw Exception('Error');
    }
  }

  @override
  Future<void> addNote(Note note) async {
    var url = Uri.https('4978-2806-10ae-1b-a78a-71f9-7912-dd2b-9877.ngrok-free.app', '/api/notes');
    var body = {
      'title': note.title,
      'body': note.body,
    };
    var headers = {'Content-Type': 'application/json'};
    var response = await http.post(url, body: convert.jsonEncode(body), headers: headers);

    print(response.body.toString());
  }

  @override
  Future<void> updateNote(Note note) async {
    var url = Uri.https('4978-2806-10ae-1b-a78a-71f9-7912-dd2b-9877.ngrok-free.app', '/api/note/${note.id}');
    var body = {
      'title': note.title,
      'body': note.body,
    };
    var headers = {'Content-Type': 'application/json'};
    var response = await http.patch(url, body: convert.jsonEncode(body), headers: headers);

    print(response.body.toString());
  }

  @override
  Future<void> deleteNote(Note note) async {
    var url = Uri.https('4978-2806-10ae-1b-a78a-71f9-7912-dd2b-9877.ngrok-free.app', '/api/note/${note.id}');
    var response = await http.delete(url);

    print(response.body.toString());
  }
}