part of 'notes_bloc.dart';

abstract class NotesEvent {}

class GetNotes extends NotesEvent {}

class AddNotes extends NotesEvent {
  final Note note;

  AddNotes({required this.note});
}