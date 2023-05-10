import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/repositories/note_repository.dart';

class AddNoteUsecase {
  final NoteRepository noteRepository;

  AddNoteUsecase(this.noteRepository);

  Future<void> execute(Note note) async {
    return await noteRepository.addNote(note);
  }
}