import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/repositories/note_repository.dart';

class DeleteNoteUsecase {
  final NoteRepository noteRepository;

  DeleteNoteUsecase(this.noteRepository);

  Future<void> execute(Note note) async {
    return await noteRepository.deleteNote(note);
  }
}