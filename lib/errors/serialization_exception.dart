final class SerializationException implements Exception {
  final String? message;

  const SerializationException([this.message]);

  @override
  String toString() {
    if (message == null) return "SerializationException";
    return "SerializationException: $message";
  }
}