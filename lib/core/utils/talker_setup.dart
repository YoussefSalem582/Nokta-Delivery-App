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

TalkerBlocObserver createTalkerBlocObserver(Talker talker) {
  return TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printChanges: true,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
    ),
  );
}
