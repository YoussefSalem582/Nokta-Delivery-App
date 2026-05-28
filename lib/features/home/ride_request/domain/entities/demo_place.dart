import 'package:equatable/equatable.dart';

class DemoPlace extends Equatable {
  const DemoPlace({
    required this.id,
    required this.nameKey,
    required this.destinationKey,
    this.subtitleKey,
    this.iconKey = 'location',
  });

  final String id;
  final String nameKey;
  final String destinationKey;
  final String? subtitleKey;
  final String iconKey;

  @override
  List<Object?> get props => [id, nameKey, destinationKey, subtitleKey, iconKey];
}
