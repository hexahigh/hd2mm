final class NotInitializedError extends Error {
  final String? objectName;

  NotInitializedError([this.objectName]);

  @override
  String toString() {
    if (objectName != null) {
      return "Object `$objectName` was not initialized before use!";
    }
      return "Object was not initialized before use!";
  }
}