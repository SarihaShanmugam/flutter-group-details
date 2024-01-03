import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'group_model.dart';
import 'main.dart';

class GroupNameListScreen extends StatefulWidget {
  const GroupNameListScreen({super.key});

  @override
  State<GroupNameListScreen> createState() => _GroupNameListScreenState();
}

class _GroupNameListScreenState extends State<GroupNameListScreen> {
  var _groupNameController = TextEditingController();
  late List<GroupNameModel> _groupNameList = <GroupNameModel>[];

  @override
  void initState() {
    super.initState();
    _getAllGroupNamesRecord();
  }

  _getAllGroupNamesRecord() async {
    print('------------------> _getAllGroupNamesRecord');
    _groupNameList.clear();
    _groupNameController.clear();

    var groupDetails = await dbHelper.getGroupNames();

    groupDetails.forEach((groupDetail) {
      setState(() {
        print(groupDetail[DatabaseHelper.columnId]);
        print(groupDetail[DatabaseHelper.columnGroupName]);

        var groupModel = GroupNameModel(groupDetail[DatabaseHelper.columnId],
            groupDetail[DatabaseHelper.columnGroupName]);

        _groupNameList.add(groupModel);
      });
    });
  }

  _showFromDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true, //true-out side click dismisses
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  print('---------->Cancel Clicked');
                  Navigator.pop(context);
                  _groupNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  print('---------->Save Clicked');
                  _save();
                },
                child: Text('Save'),
              )
            ],
            title: Text('Enter Group Name'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter group name',
                  ),
                ),
              ]),
            ),
          );
        });
  }

  void _save() async {
    print('---------->save Clicked');
    print('---------------> Group Name: ${_groupNameController.text}');

    Map<String, dynamic> row = {
      DatabaseHelper.columnGroupName: _groupNameController.text,
    };

    final result = await dbHelper.insertGroupName(row);

    debugPrint('-----------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      debugPrint('-----------> Successfully saved.');
      _showSuccessSnackBar(context, 'Saved');
      _getAllGroupNamesRecord();
    } else {
      debugPrint('-----------> Failed to save.');
    }
  }

  _editGroupName(BuildContext context, groupNameId) async {
    print(groupNameId);

    var row = await dbHelper.readDataById(groupNameId);

    setState(() {
      _groupNameController.text = row[0]['_groupName'] ?? 'No Date';
    });

    _editFromDialog(context, groupNameId);
  }

  _editFromDialog(BuildContext context, groupNameId) {
    return showDialog(
      context: context,
      barrierDismissible: true, //true-out side click dismisses
      builder: (param) {
        return AlertDialog(
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                print('---------->Cancel Clicked');
                Navigator.pop(context);
                _groupNameController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () async {
                print('---------->Update Clicked');
                _update(groupNameId);
              },
              child: Text('Update'),
            )
          ],
          title: Text('Edit Group Name'),
          content: SingleChildScrollView(
            child: Column(children: <Widget>[
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Enter group name',
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _update(int groupNameId) async {
    debugPrint('--------> _update');
    print('---------------> Group Name: ${_groupNameController.text}');
    print('---------------> Group Name id: $groupNameId');

    Map<String, dynamic> row = {
      DatabaseHelper.columnId: groupNameId,
      DatabaseHelper.columnGroupName: _groupNameController.text
    };

    final result = await dbHelper.updateGroupName(row);

    debugPrint('--------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      debugPrint('-----------> Successfully updated.');
      _showSuccessSnackBar(context, 'Updated');
      _getAllGroupNamesRecord();
    } else {
      debugPrint('-----------> Failed to save.');
    }
  }

  _deleteFormDialog(BuildContext context, groupNameId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  _deleteGroupName(groupNameId);
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),

          );
        });
  }

  void _deleteGroupName(groupNameId) async{
    print('---------->Delete Clicked: id: $groupNameId');

    final result = await dbHelper.deleteGroupName(groupNameId);

    debugPrint('--------> Deleted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Deleted');
      _getAllGroupNamesRecord();
    }else {
      debugPrint('-----------> Failed to save.');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Name List',
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _groupNameList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Card(
              elevation: 8.0,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print('---------------> Edit: $_groupNameList[index].id');
                    _editGroupName(context, _groupNameList[index].id);
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_groupNameList[index].groupName),
                    IconButton(
                      onPressed: () {
                        print('---------------> Delete');
                        _deleteFormDialog(context, _groupNameList[index].id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(15, 53, 73, 1),
        foregroundColor: Colors.white,
        onPressed: () {
          print('---------->FAB Clicked');
          _showFromDialog(context);
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
