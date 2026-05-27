import 'package:bloc/bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

Talker createTalker() {
  return TalkerFlutter.init(
    settings: TalkerSettings(
      enabled: true,
      useHistory: true,
      maxHistoryItems: 500,
    ),
  );
}

bool _isHighFrequencyTrackingLog(Bloc bloc, Object? event) {
  if (bloc.runtimeType.toString() != 'TrackingBloc') return false;
  final name = event.runtimeType.toString();
  return name == 'TrackingTick' || name == 'TrackingStatusPollRequested';
}

TalkerBlocObserver createTalkerBlocObserver(Talker talker) {
  return TalkerBlocObserver(
    talker: talker,
    settings: TalkerBlocLoggerSettings(
      printChanges: false,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
      eventFilter: (bloc, event) => !_isHighFrequencyTrackingLog(bloc, event),
      transitionFilter: (bloc, transition) =>
          !_isHighFrequencyTrackingLog(bloc, transition.event),
    ),
  );
}
