import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<void> addNote(List<Note> notes);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(Note note);
}