import '../../adzan/data/adzan_repository.dart';
import '../../adzan/data/models/prayer_time_model.dart';
import '../../auth/logic/auth_state.dart';

class HomeController {
  HomeController(this._repository);

  final AdzanRepository _repository;

  PrayerSnapshotModel snapshotFor(AuthState state, DateTime nowUtc) {
    return _repository.buildSnapshot(
      locationLabel: state.currentLocation,
      nowUtc: nowUtc,
    );
  }
}
