part of 'notes_bloc.dart';

abstract class NotesState {}

class Updating extends NotesState {}

class Updated extends NotesState{}

class Loading extends NotesState {}

class Loaded extends NotesState {
  final List<Note> notes;

  Loaded({required this.notes});
}

class Error extends NotesState {
  final String error;

  Error({required this.error});
}