// lib/utils/password_hasher.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package.pointycastle/export.dart';

/// Provides secure password hashing and verification using PBKDF2.
class PasswordHasher {
  // --- Configuration ---
  static const int _saltLength = 32; // 32 bytes is a good standard
  static const int _iterations = 100000; // High number of iterations
  static const int _keyLength = 64; // SHA-512 output length
  // --- End Configuration ---

  /// Generates a cryptographically secure random salt.
  static Uint8List _generateSalt([int length = _saltLength]) {
    final random = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(256));
    }
    random.seed(KeyParameter(Uint8List.fromList(seeds)));
    return random.nextBytes(length);
  }

  /// Hashes a password with a newly generated salt.
  ///
  /// Returns a map containing both the generated salt and the derived hash,
  /// both encoded as Base64 strings for easy storage.
  static Map<String, String> hashPassword(String password) {
    final salt = _generateSalt();
    final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _iterations, _keyLength));

    final hashBytes = derivator.process(Uint8List.fromList(utf8.encode(password)));

    return {
      'salt': base64.encode(salt),
      'hash': base64.encode(hashBytes),
    };
  }

  /// Verifies a password against a known salt and hash.
  ///
  /// [password]: The clear-text password to check.
  /// [saltB64]: The Base64 encoded salt that was used to create the hash.
  /// [hashB64]: The Base64 encoded hash to compare against.
  ///
  /// Returns `true` if the password is correct, `false` otherwise.
  static bool verifyPassword(String password, String saltB64, String hashB64) {
    try {
      final salt = base64.decode(saltB64);
      final storedHash = base64.decode(hashB64);

      final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 64))
        ..init(Pbkdf2Parameters(salt, _iterations, _keyLength));

      final derivedHash = derivator.process(Uint8List.fromList(utf8.encode(password)));

      // Compare the derived hash with the stored hash
      if (derivedHash.length != storedHash.length) {
        return false;
      }
      for (int i = 0; i < derivedHash.length; i++) {
        if (derivedHash[i] != storedHash[i]) {
          return false;
        }
      }
      return true;

    } catch (e) {
      // If any decoding fails, it's an invalid format.
      print('Error verifying password: $e');
      return false;
    }
  }
}
