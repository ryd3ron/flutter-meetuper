
import 'package:flutter/material.dart';
import 'package:flutter_meetuper/src/models/meetup.dart';
import 'package:flutter_meetuper/src/screens/meetup_detail_screen.dart';
import 'package:flutter_meetuper/src/services/meetup_api_service.dart';
import 'package:flutter_meetuper/src/services/auth_api_service.dart';

class MeetupDetailArguments {
  final String id;

  MeetupDetailArguments({this.id});
}


class MeetupHomeScreen extends StatefulWidget {
  static final String route = '/meetups';
  final MeetupApiService _api = MeetupApiService();

  MeetupHomeScreenState createState() => MeetupHomeScreenState();
}

class MeetupHomeScreenState extends State<MeetupHomeScreen> {
  List<Meetup> meetups = [];

  @override
  initState() {
    super.initState();
    _fetchMeetups();
  }

  _fetchMeetups() async {
    final meetups = await widget._api.fetchMeetups();
    setState(() => this.meetups = meetups);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _MeetupTitle(),
          _MeetupList(meetups: meetups)
        ],
      ),
      appBar: AppBar(
        title: Text('Home')
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){},
      ),
    );
  }
}

class _MeetupTitle extends StatelessWidget {
  final AuthApiService auth = AuthApiService();

  Widget _buildUserWelcome() {
    return FutureBuilder<bool>(
      future: auth.isAuthenticated(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          final user = auth.authUser;
          return Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              children: <Widget>[
                user.avatar != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.avatar),
                    )
                  : Container(width: 0, height: 0),
                Text('Welcome ${user.username}'),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    auth.logout()
                      .then((isLogout) => Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false));
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor
                    )
                  ),
                )
              ],
            )
          );
        } else {
          return Container(width: 0, height: 0);
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured Meetups', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
          _buildUserWelcome()
        ]
      )
    );
  }
}

class _MeetupCard extends StatelessWidget {
  final Meetup meetup;

  _MeetupCard({@required this.meetup});

  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(meetup.image),
            ),
            title: Text(meetup.title),
            subtitle: Text(meetup.description)
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('Visit Meetup'),
                  onPressed: () {
                    Navigator.pushNamed(context, MeetupDetailScreen.route, arguments: MeetupDetailArguments(id: meetup.id));
                  }
                ),
                FlatButton(
                  child: Text('Favorite'),
                  onPressed: () {}
                )
              ],
            )
          )
        ],
      )
    );
  }
}

class _MeetupList extends StatelessWidget {
  final List<Meetup> meetups;

  _MeetupList({@required this.meetups});

  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: meetups.length * 2,
        itemBuilder: (BuildContext context, int i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;

          return _MeetupCard(meetup: meetups[index]);
        },
      )
    );
  }
}






