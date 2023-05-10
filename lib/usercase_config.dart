import 'package:clean_architecture_app/features/notes/data/datasources/note_remote.dart';
import 'package:clean_architecture_app/features/notes/data/repositories/note_repository_impl.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/add_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/delete_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/get_notes.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/update_note.dart';

class UsecaseConfig {
  GetNotesUsecase? getNotesUsecase;
  AddNoteUsecase? addNoteUsecase;
  UpdateNoteUsecase? updateNoteUsecase;
  DeleteNoteUsecase? deleteNoteUsecase;
  NoteRepositoryImpl? noteRepositoryImpl;
  NoteRemoteDataSourceImp? noteRemoteDataSourceImp;

  UsecaseConfig() {
    noteRemoteDataSourceImp = NoteRemoteDataSourceImp();
    noteRepositoryImpl = NoteRepositoryImpl(noteRemoteDataSource: noteRemoteDataSourceImp!);
    getNotesUsecase = GetNotesUsecase(noteRepositoryImpl!);
    addNoteUsecase = AddNoteUsecase(noteRepositoryImpl!);
    updateNoteUsecase = UpdateNoteUsecase(noteRepositoryImpl!);
    deleteNoteUsecase = DeleteNoteUsecase(noteRepositoryImpl!);
  }
}