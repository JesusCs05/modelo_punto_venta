// Helper to send raw ESC/POS bytes to a Windows printer (USB) using Win32 APIs
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// Print raw bytes to the given printer name (if null, uses default printer)
Future<bool> printRawToPrinter(Uint8List bytes, {String? printerName}) async {
  final namePtr = printerName != null ? TEXT(printerName) : nullptr;

  final phPrinter = calloc<IntPtr>();
  final opened = OpenPrinter(namePtr, phPrinter, nullptr);
  if (opened == 0) {
    // OpenPrinter failed; return false so caller can fallback.
    if (namePtr != nullptr) calloc.free(namePtr);
    calloc.free(phPrinter);
    return false;
  }

  final hPrinter = phPrinter.value;

  final docNamePtr = TEXT('Ticket');
  final dataTypePtr = TEXT('RAW');

  final docInfo = calloc<DOC_INFO_1>();
  docInfo.ref.pDocName = docNamePtr;
  docInfo.ref.pOutputFile = nullptr;
  docInfo.ref.pDatatype = dataTypePtr;

  final started = StartDocPrinter(hPrinter, 1, docInfo.cast());
  if (started == 0) {
    // StartDocPrinter failed; return false so caller can fallback.
    ClosePrinter(hPrinter);
    calloc.free(docInfo);
    calloc.free(phPrinter);
    if (namePtr != nullptr) calloc.free(namePtr);
    return false;
  }

  StartPagePrinter(hPrinter);

  final dataPtr = calloc<Uint8>(bytes.length);
  final list = dataPtr.asTypedList(bytes.length);
  list.setAll(0, bytes);

  final bytesWrittenPtr = calloc<Uint32>();
  final wrote = WritePrinter(
    hPrinter,
    dataPtr.cast(),
    bytes.length,
    bytesWrittenPtr,
  );
  final wroteCount = bytesWrittenPtr.value;
  if (wrote == 0 || wroteCount == 0) {
    // WritePrinter failed; continue to finish doc to avoid stuck jobs
  }

  EndPagePrinter(hPrinter);
  EndDocPrinter(hPrinter);
  ClosePrinter(hPrinter);

  // free allocated memory
  calloc.free(dataPtr);
  calloc.free(bytesWrittenPtr);
  calloc.free(docInfo);
  calloc.free(phPrinter);
  if (namePtr != nullptr) calloc.free(namePtr);
  calloc.free(docNamePtr);
  calloc.free(dataTypePtr);

  return true;
}

// Attempt to get the default printer name
String? getDefaultPrinterName() {
  // First call to get required size
  final pcchBuffer = calloc<Uint32>();
  var success = GetDefaultPrinter(nullptr, pcchBuffer);
  var needed = pcchBuffer.value;
  if (success == 0) {
    // If GetDefaultPrinter fails because buffer is null, needed will contain required size
    if (needed == 0) {
      // No default printer or error
      calloc.free(pcchBuffer);
      return null;
    }
  }

  // Allocate a UTF-16 buffer and call GetDefaultPrinter again to fill it.
  final buffer = calloc<Uint16>(needed).cast<Utf16>();
  final pcchBuffer2 = calloc<Uint32>()..value = needed;
  success = GetDefaultPrinter(buffer, pcchBuffer2);
  String? name;
  if (success != 0) {
    name = buffer.toDartString();
  }

  calloc.free(buffer.cast<Uint16>());
  calloc.free(pcchBuffer);
  calloc.free(pcchBuffer2);
  return name;
}
