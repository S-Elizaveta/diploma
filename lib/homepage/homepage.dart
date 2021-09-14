import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '../createpage/createnewpage.dart';
import '../eventpage/eventpage.dart';
import '../icons.dart';
import '../theme.dart';
import 'cubit_home_page.dart';
import 'states_home_page.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool selected = true;

  @override
  void initState() {
    BlocProvider.of<CubitHomePage>(context).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CubitHomePage, StatesHomePage>(
      builder: (context, state) {
        return Scaffold(
          appBar: _appBar(state),
          body: _homePageBody(state),
          floatingActionButton: _floatingActionButton(state),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.article),
              //   label: 'Daily',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.bar_chart),
              //   label: 'Timeline',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              )
            ],
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.black,
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }

  AppBar _appBar(StatesHomePage state){
    return AppBar(
      title: Text('Home'),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          tooltip: 'Settings',
          icon: (selected)
              ? Icon(
            Icons.brightness_1_outlined,
          )
              : Icon(
            Icons.bedtime,
          ),
          onPressed: () {
            AppTheme.of(context).changeTheme();
            setState(() {
              selected = !selected;
            });
          },
        ),
      ],
    );
  }

  Widget _homePageBody(StatesHomePage state) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: state.noteList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          state.noteList[index].notesTitle,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: CircleAvatar(
            child: Icon(icons[state.noteList[index].circleAvatarIndex]),
          ),
          iconSize: 35,
          padding: const EdgeInsets.all(4.0),
          onPressed: () => _openEventPage(state,index),
        ),
        subtitle: Text(
          state.noteList[index].notesSubtitle,
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        onTap: () => _openEventPage(state, index),
        onLongPress: () {
          _showEditingDialog(state, context, index);
        },
      ),
    );
  }
  void _openEventPage(StatesHomePage state, var index) async {
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: EventPage(
           notes: state.noteList[index],
           noteList: state.noteList,
        ),
      ),
    );
    BlocProvider.of<CubitHomePage>(context).noteListRedrawing();
  }

  void _showEditingDialog(StatesHomePage state, BuildContext context, var index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 120,
          child: _bottomSheetMenu(state, index),
        );
      },
    );
  }

  Column _bottomSheetMenu(StatesHomePage state, var index) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.edit,
            color: Theme.of(context).accentColor,
          ),
          onTap: () => _editEvent(state, index),
          title: Text(
            'Edit event',
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          title: Text(
            'Delete event',
          ),
          onTap: () {
            BlocProvider.of<CubitHomePage>(context).removeNote(index);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _editEvent(StatesHomePage state, var index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewPage(
          isEditing: true,
          noteList: state.noteList,
          index: index,
        ),
      ),
    );
    BlocProvider.of<CubitHomePage>(context).noteListRedrawing();
    Navigator.pop(context);
  }

  FloatingActionButton _floatingActionButton(StatesHomePage state) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateNewPage(
              noteList: state.noteList,
              isEditing: false,
            ),
          ),
        );
        BlocProvider.of<CubitHomePage>(context).noteListRedrawing();
      },
    );
  }
}
