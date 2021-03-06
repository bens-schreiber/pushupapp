import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pushupapp/api/requests.dart';
import 'package:pushupapp/api/pojo.dart';
import 'package:pushupapp/ui/dialog.dart';
import 'package:flutter/services.dart';
import '../dialog.dart';

class MyGroupPage extends StatefulWidget {
  const MyGroupPage({Key? key}) : super(key: key);

  @override
  _MyGroupPageState createState() => _MyGroupPageState();
}

class _MyGroupPageState extends State<MyGroupPage> {
  @override
  Widget build(BuildContext context) {
    return API.builder((groups) {
      return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groups
                    .where((group) => API.username == group.creator)
                    .isNotEmpty
                ? _displayGroup(groups)
                : displayCreate(groups)),
      );
    });
  }

  List<Widget> displayCreate(List<Group> groups) {
    return [
      const Padding(
          padding: EdgeInsets.only(top: 35.0, left: 25),
          child: Text("Create a Group",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))),
      Padding(
          padding: const EdgeInsets.only(top: 15, left: 25),
          child: Container(
              height: 100,
              width: 100,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, size: 100, color: Colors.white),
                  onPressed: () => MDialog.confirmationDialog(
                          context, "Are you sure you'd like to create a group?",
                          () async {
                        await API.post().create();
                        await API.get().groups();
                      })),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                      colors: [Colors.deepOrangeAccent, Colors.orangeAccent]))))
    ];
  }

  List<Widget> _displayGroup(List<Group> groups) {
    return [
      const Padding(
          padding: EdgeInsets.only(top: 35.0, left: 25, bottom: 10),
          child: Text("My Group",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))),
      Padding(
          padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
          child: _creatorButtons(groups)),
      Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[800]!,
                  borderRadius: BorderRadius.circular(5)),
              child: SingleChildScrollView(
                  child: Column(
                children: _groupWidgets(groups),
              )))),
    ];
  }

  Widget _creatorButtons(List<Group> groups) {
    return Container(
        width: 400,
        height: 70,
        decoration: BoxDecoration(
            color: Colors.grey[800]!, borderRadius: BorderRadius.circular(5)),
        child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(children: [
              const Icon(
                Icons.group,
                size: 50,
                color: Colors.white,
              ),
              const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text("My Group",
                      style: TextStyle(fontSize: 27, color: Colors.white))),
              const Spacer(),
              IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.content_copy,
                      size: 45, color: Colors.grey[600]),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                            text: groups
                                .where((group) => API.username == group.creator)
                                .first
                                .id))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(milliseconds: 500),
                          content: Text("Group code copied.")));
                    });
                  }),
              Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.block_rounded,
                          size: 50, color: Colors.red),
                      onPressed: () {
                        MDialog.confirmationDialog(context,
                            "Are you sure you'd like to disband the group?",
                            () async {
                          await API.del().disband();
                          await API.get().groups();
                        });
                      }))
            ])));
  }

  List<Widget> _groupWidgets(List<Group> groups) {
    List<Widget> _groupWidgets = List.empty(growable: true);
    Group group = groups.where((g) => g.creator == API.username).first;
    _groupWidgets = group.members
        .where((member) => member != API.username)
        .map((member) => Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: Container(
                width: 400,
                height: 70,
                decoration: BoxDecoration(
                    color: Colors.grey[800]!,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(children: [
                  const Icon(Icons.account_circle_outlined,
                      size: 50, color: Colors.white),
                  Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(member,
                          style: const TextStyle(
                              fontSize: 27, color: Colors.white))),
                  const Spacer(),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15, right: 5),
                      child: IconButton(
                          icon: const Icon(Icons.block_rounded,
                              size: 50, color: Colors.red),
                          onPressed: () {
                            MDialog.confirmationDialog(
                                context,
                                "Are you sure you'd like to kick " +
                                    member +
                                    "?", () async {
                              await API.del().kick(member);
                              await API.get().groups();
                            });
                          }))
                ]))))
        .toList(growable: false);
    return _groupWidgets;
  }
}
