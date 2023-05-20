import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/data/models/note_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

String apiURI = 'ad46-177-227-15-19.ngrok-free.app';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote(List<Note> notes);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(Note note);
}

class NoteRemoteDataSourceImp implements NoteRemoteDataSource {

  @override
  Future<List<NoteModel>> getNotes() async {
    var url = Uri.https(apiURI, '/api/notes');
    var response = await http.get(url);

    if(response.statusCode == 200) {
      var returnData = convert.jsonDecode(response.body)
              .map<NoteModel>((data) => NoteModel.fromJson(data))
              .toList();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('localUserData', response.body);
      return returnData;
    } else {
      throw Exception('Error');
    }
  }

  @override
  Future<void> addNote(List<Note> notes) async {
    var url = Uri.https(apiURI, '/api/notes');
    var headers = {'Content-Type': 'application/json'};

    List<Map<String, String>> body = [];
    for (var note in notes) {
      var object = {
        'title': note.title,
        'body': note.body,
      };
      body.add(object);
    }

    var response = await http.post(url, body: convert.jsonEncode(body), headers: headers);
    print('Added');
  }

  @override
  Future<void> updateNote(Note note) async {
    var url = Uri.https(apiURI, '/api/note/${note.id}');
    var body = {
      'title': note.title,
      'body': note.body,
    };
    var headers = {'Content-Type': 'application/json'};
    var response = await http.patch(url, body: convert.jsonEncode(body), headers: headers);

    // print(response.body.toString());
    print('Updated');
  }

  @override
  Future<void> deleteNote(Note note) async {
    var url = Uri.https(apiURI, '/api/note/${note.id}');
    var response = await http.delete(url);

    // print(response.body.toString());
    print('Deleted');
  }
}