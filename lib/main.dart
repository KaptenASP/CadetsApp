import 'dart:math';

import 'package:cadets/Auth/cadetnet_auth.dart';
import 'package:cadets/Helpers/network_helper.dart';
import 'package:flutter/material.dart';
import 'Rolls/roll.dart';
import 'activity_home.dart';
import 'Rolls/user_mappings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          backgroundColor: const Color(0xff0d1117),
          cardColor: const Color(0xff010409),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RollManager rollManager = RollManager();
  final UserMappings userMappings = UserMappings();
  TextEditingController rollNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String name = '';
  String unit = '';
  int currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  void createRoll(String rollname) {
    RollManager.createRoll(rollname);
    setState(() {});
  }

  void deleteRoll(String rollname) {
    RollManager.deleteRoll(rollname);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadets V2.0"),
        actions: <Widget>[
          TextButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Enter Roll Name'),
                content: TextFormField(
                  controller: rollNameController,
                  decoration: const InputDecoration(
                    hintText: 'Roll Name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      createRoll(rollNameController.text);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Create Roll'),
          ),
          TextButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Enter Roll Name To Confirm Delete'),
                content: TextFormField(
                  controller: rollNameController,
                  decoration: const InputDecoration(
                    hintText: 'Roll Name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteRoll(rollNameController.text);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Delete roll'),
          ),
        ],
      ),
      body: <Widget>[
        Container(
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {});
              });
            },
            child: ListView(
              scrollDirection: Axis.vertical,
              children: (RollManager.rolls)
                  .map((e) => Card(
                        margin: const EdgeInsets.all(0),
                        elevation: 0,
                        color: const Color(0xff0d1117),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xff30363d)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          splashColor: const Color(0xff161b22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActivityHome(
                                        roll: e,
                                      )),
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: Align(
                                // Add some left padding to text
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          e.synced
                                              ? const Icon(Icons.wifi_outlined,
                                                  color: Color(0xff7d8590))
                                              : const Icon(
                                                  Icons.wifi_off_outlined,
                                                  color: Color(0xff7d8590)),
                                          Text(
                                            '    ${e.title.substring(0, min(e.title.length, 40))}',
                                          ),
                                        ],
                                      ),
                                      // Date of activity
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e.dateString,
                                          style: const TextStyle(
                                            color: Color(0xff7d8590),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Container(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Enter username and password'),
                        content: Column(
                          children: [
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                hintText: 'username',
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cadetnet username';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                hintText: 'password',
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cadetnet password';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await CadetNetAuth.instance.saveCredentials(
                                usernameController.text,
                                passwordController.text,
                              );

                              Navigator.pop(context, 'OK');

                              Session session = Session.instance;

                              bool loggedInCheck = await session.checkLogin();

                              if (!loggedInCheck) {
                                return;
                              }

                              Map<dynamic, dynamic> details =
                                  await session.getDetails();

                              CadetNetAuth.instance.addUserInfo(
                                details["User"]["FullName"],
                                details["User"]['UnitName'],
                              );

                              setState(() {
                                name = details["User"]["FullName"];
                                unit = details["User"]['UnitName'];
                              });

                              await UserMappings.syncOnline();
                              await RollManager.syncOnline();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Cadetnet Login'),
                  ),
                  TextButton(
                      onPressed: () async {
                        Session session = Session.instance;
                        session.checkLogin().then((value) async {
                          if (!value) {
                            return;
                          }

                          Map<dynamic, dynamic> details =
                              await session.getDetails();

                          CadetNetAuth.instance.addUserInfo(
                            details["User"]["FullName"],
                            details["User"]['UnitName'],
                          );

                          setState(() {
                            name = details["User"]["FullName"];
                            unit = details["User"]['UnitName'];
                          });

                          await UserMappings.syncOnline();
                          await RollManager.syncOnline();
                        });
                      },
                      child: const Text('Sync')),
                ],
              ),
              Column(
                children: [
                  // Add heading 'user details'
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  // Add user details
                  Text(
                    'Name: $name',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Unit: $unit',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Container(
          child: const Center(
            child: Text("Settings"),
          ),
        ),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
