import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

abstract class Interop {
  static Interop get instance {
    if (_instance == null) {
      if (Platform.isWindows) {
        _instance = _WindowsInterop();
      } else {
        throw UnsupportedError("Unsupported platform!");
      }
    }
    return _instance!;
  }

  static Interop? _instance;

  List<Drive> getDrives();
}

typedef _GetLogicalDriveStringsW = Uint32 Function(Uint32 nBufferLength, Pointer<Utf16> lpBuffer);
typedef _GetLogicalDriveStrings = int Function(int nBufferLength, Pointer<Utf16> lpBuffer);

final class _WindowsInterop implements Interop {
  final _GetLogicalDriveStrings getLogicalDriveStrings;

  _WindowsInterop._(
    this.getLogicalDriveStrings,
  );

  factory _WindowsInterop() {
    final lib = DynamicLibrary.open("kernel32.dll");
    final getLogicalDriveStrings = lib.lookupFunction<_GetLogicalDriveStringsW, _GetLogicalDriveStrings>("GetLogicalDriveStringsW");
    return _WindowsInterop._(
      getLogicalDriveStrings,
    );
  }

  @override
  List<Drive> getDrives() {
    final buffer = calloc<Uint16>(256);

    final len = getLogicalDriveStrings(256, buffer.cast<Utf16>());

    if (len == 0) {
      calloc.free(buffer);
      return const [];
    }

    final drives = <Drive>[];

    int offset = 0;
    while (true) {
      final ptr = (buffer + offset).cast<Utf16>();
      final drive = ptr.toDartString();
      if (drive.isEmpty) break;
      drives.add(Drive(drive));
      offset += drive.length + 1;
    }

    calloc.free(buffer);
    return drives;
  }
}

final class Drive {
  final String name;

  Drive(this.name);
}