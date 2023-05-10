import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({
    required int id,
    required String title,
    required String body
  }) : super(id: id, title: title, body: body);

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      body: json['body']
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      body: note.body
    );
  }
}