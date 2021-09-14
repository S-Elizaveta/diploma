import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/database.dart';
import '../db/shared_preferences_provider.dart';
import '../notes.dart';

import 'states_home_page.dart';

class CubitHomePage extends Cubit<StatesHomePage> {
  CubitHomePage() : super(StatesHomePage());
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  void init() async {
    setNoteList(<Notes>[]);
    initSharedPreferences();
    await _databaseProvider.initDB();
    setNoteList(await _databaseProvider.fetchNotesList());
  }

  void initSharedPreferences() => emit(
      state.copyWith(isLightTheme: SharedPreferencesProvider().fetchTheme()));

  void setNoteList(List<Notes> noteList) =>
      emit(state.copyWith(noteList: noteList));

  void changeTheme() {
    SharedPreferencesProvider().changeTheme(!state.isLightTheme);
    emit(state.copyWith(isLightTheme: !state.isLightTheme));
  }

  void removeNote(int index) {
    _databaseProvider.deleteNotes(state.noteList[index]);
    _databaseProvider.deleteEventsFromNote(state.noteList[index].notesId);
    state.noteList.removeAt(index);
    noteListRedrawing();
  }

  void noteListRedrawing() => emit(state.copyWith(noteList: state.noteList));
}