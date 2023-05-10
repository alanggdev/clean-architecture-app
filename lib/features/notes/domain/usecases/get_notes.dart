import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/repositories/note_repository.dart';

class GetNotesUsecase {
  final NoteRepository noteRepository;

  GetNotesUsecase(this.noteRepository);

  Future<List<Note>> execute() async {
    return await noteRepository.getNotes();
  }
}