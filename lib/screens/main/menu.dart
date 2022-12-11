import 'package:flutter/material.dart';
import 'package:seguro/screens/main/chat_command.dart';

import '../../globals/preferences.dart';
import '../../reusable_widgets/reusable_widget.dart';
import 'input_photo.dart';
import 'list_photo.dart';
import 'cctv.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: logoWidget("lib/assets/image/segurologo.jpg"),
            ),
          ),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        ButtonImage(
                          name: "Input Photo",
                          iconURL: "lib/assets/image/camera.jpeg",
                          navigateTo: InputPhoto(),
                        ),
                        ButtonImage(
                          name: "My Photo",
                          iconURL: "lib/assets/image/my_picture.jpeg",
                          navigateTo: ListPhoto(),
                        ),
                        ButtonImage(
                          name: "CCTV",
                          iconURL: "lib/assets/image/icon_cctv.jpeg",
                          navigateTo: CCTV(channel: "channel"),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        LockWidget(),
                        LightWidget(),
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }
}

class ButtonImage extends StatelessWidget {
  const ButtonImage(
      {Key? key,
      required this.name,
      required this.iconURL,
      required this.navigateTo})
      : super(key: key);
  final String iconURL;
  final String name;
  final Widget navigateTo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(17)
      ),
      height: 100,
      width: 100,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => navigateTo))
                  },
                  child: Image.asset(
                    iconURL,
                    width: 50,
                    height: 50,
                  ),
                )
            ),
            Expanded(
                child: Center(
                  child: Text(name, style: TextStyle(fontWeight: FontWeight. bold),)
                )
            )
          ]
      ),
    );
  }
}

class LockWidget extends StatefulWidget {
  const LockWidget({Key? key}) : super(key: key);

  @override
  State<LockWidget> createState() => _LockWidgetState();
}
class _LockWidgetState extends State<LockWidget> {
  bool _state = false;

  @override
  void initState() {
    getLockStatus().then( (value) =>
        setState(() {
          _state = value;
        })
    );
    super.initState();
  }

  void _onSwitch(bool value) {
    telegramClient.sendMessage(value == true ? "/lock" : "/unlock");
    saveLockStatus(value);
    getLockStatus().then((value) => {
      setState(() {
        _state = value;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: (_state == true ? Colors.red : Colors.green)),
          borderRadius: BorderRadius.circular(17)
      ),
      height: 150,
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Center(
                    child: Row(
                        children:[
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 35.0, 10.0,0.0),
                            child: Image.asset('lib/assets/image/locked_switch.png', width: 50,height: 50),
                          ),
                          Transform.scale( scale: 1.5,
                            child: Switch(
                              activeColor: Colors.red.withOpacity(0.1),
                              inactiveThumbColor: Colors.green.withOpacity(0.1),
                              inactiveTrackColor: Colors.green,
                              inactiveThumbImage: const AssetImage("lib/assets/image/unlocked_switch.png"),
                              activeThumbImage: const AssetImage("lib/assets/image/locked_switch.png"),
                              value: _state,
                              onChanged: _onSwitch,
                            ),
                          )
                        ]
                    )
                )
              ],
            ),
          ),
          Expanded(
              child: Center(
                child: Text(_state == true ? 'LOCKED' : 'UNLOCKED',style: const TextStyle(fontWeight: FontWeight. bold, fontSize: 18),
                ),
              )
          )
        ],
      ),

    );
  }
}


class LightWidget extends StatefulWidget {
  const LightWidget({Key? key}) : super(key: key);

  @override
  State<LightWidget> createState() => _LightWidgetState();
}
class _LightWidgetState extends State<LightWidget> {
  bool _state = false;

  @override
  void initState() {
    getLightStatus().then( (value) =>
        setState(() {
          _state = value;
        })
    );
    super.initState();
  }

  void _onSwitch(bool value) {
    telegramClient.sendMessage(value == true ? "/light_on" : "/light_off");
    saveLightStatus(value);
    getLightStatus().then((value) => {
      setState(() {
        _state = value;
      })
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: (_state == true ? Colors.orangeAccent : Colors.blue)),
          borderRadius: BorderRadius.circular(17)
      ),
      height: 150,
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              flex: 2,
              child: Column(
                children: [
                  Center(
                    child: Row(
                      children:[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0,0.0),
                          // child: Image.asset('lib/assets/image/light.jpg', width: 60,height: 60),
                        ),
                        Transform.scale( scale: 1.5,
                          child: Switch(
                            activeColor: Colors.orangeAccent.withOpacity(0.1),
                            inactiveThumbColor: Colors.blue.withOpacity(0.1),
                            inactiveTrackColor: Colors.blue,
                            value: _state,
                            onChanged: _onSwitch,
                          ),
                        )
                      ]
                    )
                  )
                ],
              ),
          ),
          Expanded(
              child: Center(
                child: Text(_state == true ? 'LIGHT ON' : 'LIGHT OFF',style: const TextStyle(fontWeight: FontWeight. bold, fontSize: 18),),
              )
          )
        ],
      ),
    );
  }
}
