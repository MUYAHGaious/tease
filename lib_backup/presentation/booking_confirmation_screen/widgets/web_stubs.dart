// Stub implementations for mobile platforms to avoid dart:html errors

class Blob {
  Blob(List<dynamic> data);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  AnchorElement({required String href});
  void setAttribute(String name, String value) {}
  void click() {}
}

class Navigator {
  Clipboard? clipboard;
}

class Clipboard {
  Future<void> writeText(String text) async {}
}

class Window {
  Navigator navigator = Navigator();
}

final window = Window();