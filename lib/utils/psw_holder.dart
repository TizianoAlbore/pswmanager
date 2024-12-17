import 'dart:async';

/// A class that holds a temporized master passphrase and automatically clears it after a set duration.
///
/// The [PasswordHolder] class manages a master passphrase that is stored temporarily.
/// The passphrase is automatically cleared after 15 minutes to enhance security.
///
/// Example usage:
/// ```dart
/// var passwordHolder = PasswordHolder('mySecretPassphrase');
/// print(passwordHolder.temporizedMasterPassphrase); // Outputs: mySecretPassphrase
/// // After 15 minutes
/// print(passwordHolder.temporizedMasterPassphrase); // Outputs: null
/// ```
///
/// The timer is reset every time the passphrase is updated.
///
/// To avoid memory leaks, call [dispose] when the [PasswordHolder] is no longer needed.
class PasswordHolder {
  /// The temporarily stored master passphrase.
  String? _temporizedMasterPassphrase;

  /// The timer that clears the passphrase after a set duration.
  Timer? _timer;

  final int time;

  /// Creates a [PasswordHolder] with an initial passphrase and starts the timer.
  PasswordHolder(this._temporizedMasterPassphrase, this.time) {
    _startTimer();
  }

  /// Starts or resets the timer to clear the passphrase after [time] minutes.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: this.time), () {
      _temporizedMasterPassphrase = null;
    });
  }

  /// Gets the current temporized master passphrase.
  String? get temporizedMasterPassphrase => _temporizedMasterPassphrase;

  /// Sets a new temporized master passphrase and resets the timer.
  void set temporizedMasterPassphrase(String? passphrase,) {
    _temporizedMasterPassphrase = passphrase;
    _startTimer();
  }

  /// Cancels the timer to avoid memory leaks. Should be called when the [PasswordHolder] is no longer needed.
  void dispose() {
    _timer?.cancel();
  }
}