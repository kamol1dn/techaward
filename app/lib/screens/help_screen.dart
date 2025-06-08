
import 'package:flutter/material.dart';
import '../data/help_data.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help & Tutorials')),
      body: ListView.builder(
        itemCount: HelpData.topics.length,
        itemBuilder: (context, index) {
          final topic = HelpData.topics[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(topic.icon, color: topic.color),
              title: Text(topic.title),
              subtitle: Text(topic.subtitle),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HelpDetailScreen(topic: topic)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HelpDetailScreen extends StatelessWidget {
  final HelpTopic topic;

  HelpDetailScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.headline,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  topic.content,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}