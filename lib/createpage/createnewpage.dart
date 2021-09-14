import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../homepage/homepage.dart';
import '../icons.dart';
import '../notes.dart';
import 'cubit_create_page.dart';
import 'states_create_page.dart';

class CreateNewPage extends StatefulWidget {
  final List<Notes> noteList;
  final bool isEditing;
  final int index;

  CreateNewPage({Key key, this.noteList, this.isEditing, this.index})
      : super(key: key);

  @override
  _CreateNewPageState createState() => _CreateNewPageState(noteList, isEditing, index);
}

class _CreateNewPageState extends State<CreateNewPage> {
  final TextEditingController createPageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final bool _isEditing;
  final int _index;
  final List<Notes> _noteList;

  _CreateNewPageState(this._noteList, this._isEditing, this._index);

  @override
  void initState() {
    BlocProvider.of<CubitCreatePage>(context).init();
    if (_isEditing) {
      createPageController.text = _noteList[_index].notesTitle;
    }
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CubitCreatePage, StatesCreatePage>(
        builder: (context, state) {
      return Scaffold(
        appBar:
            _isEditing ? _appBar('Edit event') : _appBar('Create new event'),
        body: _createPageBody(state),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _isEditing ? _editPage(state) : _createPage(state);
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      );
    });
  }
Column _createPageBody(StatesCreatePage state){

 return Column(
   children: <Widget>[
     _inputArea(state),
     _iconsGrid,
   ],
 );
}

  Widget _inputArea(StatesCreatePage state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(right: 15),
            child: Ink(
              child: _circleAvatar(
                  Icon(icons[state.selectedIconIndex]), Colors.green),
            ),
          ),
          Expanded(
            child: TextField(
              controller: createPageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Enter name of the page...',
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Expanded get _iconsGrid {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 3.0,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return _iconButton(index);
        },
      ),
    );
  }

  IconButton _iconButton(int index) {
    return IconButton(
      icon: _circleAvatar(Icon(icons[index]), Theme.of(context).accentColor),
      onPressed: () =>
          BlocProvider.of<CubitCreatePage>(context).setSelectedIconIndex(index),
    );
  }

  CircleAvatar _circleAvatar(Icon icon, Color color) {
    return CircleAvatar(
      child: icon,
      backgroundColor: color,
      foregroundColor: Colors.white,
    );
  }
  void _editPage(StatesCreatePage state) {
    _noteList[_index].notesTitle = createPageController.text;
    _noteList[_index].circleAvatarIndex = state.selectedIconIndex;
    BlocProvider.of<CubitCreatePage>(context).editPage(_noteList[_index]);
  }


  void _createPage(StatesCreatePage state) async {
    var note = Notes(
      notesTitle: createPageController.text,
      notesSubtitle: 'No events. Click to create one.',
      circleAvatarIndex: state.selectedIconIndex,
      date: DateFormat.yMMMd().format(
        DateTime.now(),
      ),
    );
    _noteList.insert(0, note);
    await BlocProvider.of<CubitCreatePage>(context).addPage(note);
  }

  AppBar _appBar(String title) {
    return AppBar(
      title: Text(
        title,
      ),
    );
  }
}



