import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Codelab: https://codelabs.developers.google.com/codelabs/flutter-firebase
class MainCloudFirestore extends StatefulWidget {
  @override
  _MainCloudFirestoreState createState() => _MainCloudFirestoreState();
}

class _MainCloudFirestoreState extends State<MainCloudFirestore> {
  static const String CODELAB_LINK =
      'https://codelabs.developers.google.com/codelabs/flutter-firebase';

  static const String NO_DATA_OR_ERROR = '''  No data.
  
  Please verify the project is configured accordingly.
    - Android: android/app/google-services.json
    - iOS: ios/Runner/GoogleService-Info.plist
    
  More info in the Cloud Firebase CodeLab: 
    $CODELAB_LINK''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
    );
  }

  int sortByVotes(DocumentSnapshot a, DocumentSnapshot b) {
    return b.data['votes'] - a.data['votes'];
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        if (snapshot.hasError || snapshot.data.documents.isEmpty)
          return _buildConfigurationNotice();
        snapshot.data.documents.sort(sortByVotes);
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildConfigurationNotice() => Container(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(NO_DATA_OR_ERROR),
        ),
      );

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.votes.toString()),
          onTap: () =>
              record.reference.updateData({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'] {
    print("Created record: $this");
  }

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
