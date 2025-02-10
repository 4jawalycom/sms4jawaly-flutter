import 'package:flutter/material.dart';
import 'package:sms_4jawaly/sms_4jawaly.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS 4Jawaly Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _gateway = Gateway(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
  );
  final _messageController = TextEditingController();
  final _numbersController = TextEditingController();
  String _selectedSender = '';
  List<String> _senders = [];
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadSenders();
  }

  Future<void> _loadSenders() async {
    final result = await _gateway.getSenders();
    if (result['success']) {
      setState(() {
        _senders = List<String>.from(result['all_senders']);
        if (_senders.isNotEmpty) {
          _selectedSender = _senders.first;
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty ||
        _numbersController.text.isEmpty ||
        _selectedSender.isEmpty) {
      setState(() {
        _result = 'Please fill all fields';
      });
      return;
    }

    final numbers = _numbersController.text.split(',').map((e) => e.trim()).toList();
    final result = await _gateway.sendSms(
      message: _messageController.text,
      numbers: numbers,
      sender: _selectedSender,
    );

    setState(() {
      _result = result['success']
          ? 'Message sent successfully to ${result['total_success']} numbers'
          : 'Failed to send message: ${result['error']}';
    });
  }

  @override
  void dispose() {
    _gateway.dispose();
    _messageController.dispose();
    _numbersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS 4Jawaly Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedSender,
              items: _senders.map((sender) {
                return DropdownMenuItem(
                  value: sender,
                  child: Text(sender),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSender = value;
                  });
                }
              },
              hint: const Text('Select Sender'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numbersController,
              decoration: const InputDecoration(
                labelText: 'Phone Numbers (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send Message'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
