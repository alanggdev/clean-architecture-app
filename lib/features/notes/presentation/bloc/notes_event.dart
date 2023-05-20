part of 'notes_bloc.dart';

abstract class NotesEvent {}

class GetNotes extends NotesEvent {}

class AddNotes extends NotesEvent {
  final List<Note> notes;

  AddNotes({required this.notes});
}

class UpdateNote extends NotesEvent {
  final Note note;

  UpdateNote({required this.note});
}

class DeleteNote extends NotesEvent {
  final Note note;

  DeleteNote({required this.note});
}

class GetNotesOffline extends NotesEvent {}