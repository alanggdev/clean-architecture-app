import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/repositories/note_repository.dart';

class UpdateNoteUsecase {
  final NoteRepository noteRepository;

  UpdateNoteUsecase(this.noteRepository);

  Future<void> execute(Note note) async {
    return await noteRepository.updateNote(note);
  }
}