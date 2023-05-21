import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/data/models/note_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

String apiURI = '959f-177-227-12-67.ngrok-free.app';

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

    await http.post(url, body: convert.jsonEncode(body), headers: headers);
    // print('Added');
  }

  @override
  Future<void> updateNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('updateNoteOffline')){
      String? encodedDataCache = prefs.getString('updateNoteOffline');
      prefs.remove('updateNoteOffline');
      if (encodedDataCache != null) {
        List<dynamic> decodedList = json.decode(encodedDataCache);
        List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

        List<Map<String, Object>> body = [];
        for (var updateNote in notes) {
          var object = {
            'id': updateNote.id,
            'data' : {
              'title': updateNote.title,
              'body': updateNote.body,
            }
          };
          body.add(object);
        }
        var url = Uri.https(apiURI, '/api/notes/multiple');
        var headers = {'Content-Type': 'application/json'};
        await http.patch(url, body: convert.jsonEncode(body), headers: headers);
      }
    } else {
      var url = Uri.https(apiURI, '/api/note/${note.id}');
      var body = {
        'title': note.title,
        'body': note.body,
      };
      var headers = {'Content-Type': 'application/json'};
      await http.patch(url, body: convert.jsonEncode(body), headers: headers);
    }
    // print('Updated');
  }

  @override
  Future<void> deleteNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('deleteNoteOffline')){
      String? encodedPkCache = prefs.getString('deleteNoteOffline');
      prefs.remove('deleteNoteOffline');
      if (encodedPkCache != null) {
        List<dynamic> decodedList = json.decode(encodedPkCache);
        List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

        List<int> pks = [];
        for (var deletePk in notes) {
          pks.add(deletePk.id);
        }
        var object = {'primary_keys': pks};
        var url = Uri.https(apiURI, '/api/notes/multiple');
        var headers = {'Content-Type': 'application/json'};
        await http.post(url, body: convert.jsonEncode(object), headers: headers);
      }
    } else {
      var url = Uri.https(apiURI, '/api/note/${note.id}');
      await http.delete(url);
    }
    // print('Deleted');
  }
}