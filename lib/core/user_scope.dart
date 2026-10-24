import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Pemegang data user aktif. Widget yang membaca lewat [UserScope] otomatis
/// rebuild ketika [update] dipanggil (mis. setelah Edit Profile).
class UserController extends ChangeNotifier {
  UserController([UserProfile initial = UserProfile.demo]) : _profile = initial;

  UserProfile _profile;

  UserProfile get profile => _profile;

  void update(UserProfile next) {
    if (next == _profile) return;
    _profile = next;
    notifyListeners();
  }
}

/// Menyediakan [UserController] ke seluruh pohon widget (taruh di atas
/// `MaterialApp` supaya semua route ikut terjangkau).
///
/// Memakai InheritedNotifier bawaan Flutter. Kalau nanti proyek memakai
/// Provider/Riverpod, cukup ganti isi [of]; pemanggil lewat
/// `context.currentUser` tidak perlu diubah.
class UserScope extends InheritedNotifier<UserController> {
  const UserScope({
    super.key,
    required UserController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Controller untuk memanggil aksi (mis. `update`). Juga mendaftarkan
  /// [context] sebagai pendengar perubahan.
  static UserController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserScope>();
    assert(scope != null, 'UserScope tidak ditemukan di atas context ini.');
    return scope!.notifier!;
  }
}

extension UserContext on BuildContext {
  /// User yang sedang aktif. Widget pemanggil rebuild saat datanya berubah.
  UserProfile get currentUser => UserScope.of(this).profile;
}
