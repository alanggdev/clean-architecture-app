part of 'notes_bloc.dart';

abstract class NotesEvent {}

class GetNotes extends NotesEvent {}

class AddNotes extends NotesEvent {
  final Note note;

  AddNotes({required this.note});
}

class UpdateNote extends NotesEvent {
  final Note note;

  UpdateNote({required this.note});
}

class DeleteNote extends NotesEvent {
  final Note note;

  DeleteNote({required this.note});
}