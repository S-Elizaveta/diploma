import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/database.dart';
import '../notes.dart';
import 'states_create_page.dart';

class CubitCreatePage extends Cubit<StatesCreatePage> {
  CubitCreatePage() : super(StatesCreatePage());
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  void init(){
    setSelectedIconIndex(0);
  }

  void setSelectedIconIndex(int selectedIconIndex) =>
      emit(state.updateSelectedIconIndex(selectedIconIndex));

  void editPage(Notes notes) => _databaseProvider.updateNote(notes);

  void addPage(Notes notes) async =>
      notes.notesId = await _databaseProvider.insertNotes(notes);
}