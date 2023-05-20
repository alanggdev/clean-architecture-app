import 'package:clean_architecture_app/features/notes/data/datasources/note_remote.dart';
import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource noteRemoteDataSource;

  NoteRepositoryImpl({required this.noteRemoteDataSource});

  @override
  Future<List<Note>> getNotes() async {
    return await noteRemoteDataSource.getNotes();
  }

  @override
  Future<void> addNote(List<Note> notes) async {
    return await noteRemoteDataSource.addNote(notes);
  }

  @override
  Future<void> updateNote(Note note) async {
    return await noteRemoteDataSource.updateNote(note);
  }

  @override
  Future<void> deleteNote(Note note) async {
    return await noteRemoteDataSource.deleteNote(note);
  }
}