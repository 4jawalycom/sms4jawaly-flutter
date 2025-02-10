# SMS 4Jawaly Flutter Package

A Flutter package for sending SMS messages using the 4jawaly API. This package provides a simple way to interact with the 4jawaly SMS service, allowing you to send messages, check balance, and manage sender names.

## Features

- Send SMS messages
- Check account balance
- Get sender names
- Support for multiple recipients
- Error handling
- Clean and simple API

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sms_4jawaly: ^1.0.0
```

## Usage

### Initialize the Gateway

```dart
final gateway = Gateway(
  apiKey: 'YOUR_API_KEY',
  apiSecret: 'YOUR_API_SECRET',
);
```

### Get Account Balance

```dart
final balance = await gateway.getBalance();
if (balance['success']) {
  print('Balance: ${balance['data']}');
} else {
  print('Error: ${balance['error']}');
}
```

### Get Sender Names

```dart
final senders = await gateway.getSenders();
if (senders['success']) {
  print('All senders: ${senders['all_senders']}');
  print('Default senders: ${senders['default_senders']}');
} else {
  print('Error: ${senders['error']}');
}
```

### Send SMS

```dart
final result = await gateway.sendSms(
  message: 'Hello from Flutter!',
  numbers: ['966500000000', '966500000001'],
  sender: 'SENDER_NAME',
);

if (result['success']) {
  print('Successfully sent to ${result['total_success']} numbers');
  print('Job IDs: ${result['job_ids']}');
} else {
  print('Failed: ${result['errors']}');
}
```

### Dispose

Don't forget to dispose of the gateway when you're done:

```dart
gateway.dispose();
```

## Example

Check the `example` folder for a complete Flutter application demonstrating how to use this package.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
