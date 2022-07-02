import 'package:diagnostico/app/model/config.dart';
import 'package:diagnostico/app/model/test.dart';
import 'package:flutter/material.dart';

class RoomList extends StatelessWidget {
  const RoomList({
    required this.matterConfig,
    required this.tests,
    Key? key,
  }) : super(key: key);

  final MatterConfiguration matterConfig;
  final Tests tests;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: matterConfig.rooms.length,
      itemBuilder: (BuildContext context, int index) {
        String room = matterConfig.rooms[index];

        return ListTile(
          onTap: () {
            final int year = int.parse(room[1]);
            final String link = matterConfig.getLink(year);
            final Test test = tests.getTest(matterConfig.matter, year);

            Navigator.pushNamed(
              context,
              '/students',
              arguments: {
                'room': room,
                'link': link,
                'test': test,
                'matter': test.matter
              },
            );
          },
          title: Text(room),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
