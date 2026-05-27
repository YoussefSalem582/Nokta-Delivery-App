import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/driver_chat/presentation/bloc/driver_chat_bloc.dart';
import 'package:delivery_app/features/trips/driver_chat/presentation/widgets/chat_message_bubble.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DriverChatPage extends StatefulWidget {
  const DriverChatPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<DriverChatPage> createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverChatBloc>()
        ..add(DriverChatLoadRequested(widget.tripId)),
      child: BlocConsumer<DriverChatBloc, DriverChatState>(
        listenWhen: (previous, current) =>
            current is DriverChatLoaded &&
            (previous is! DriverChatLoaded ||
                previous.messages.length != current.messages.length),
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          if (state is DriverChatLoading || state is DriverChatInitial) {
            return Scaffold(
              appBar: AppBar(title: Text('chat_title'.tr())),
              body: Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [SkeletonListTile(), SkeletonListTile()],
                ),
              ),
            );
          }

          if (state is DriverChatError) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text('chat_title'.tr()),
              ),
              body: ErrorView(
                message: state.message,
                onRetry: () => context.read<DriverChatBloc>().add(
                      DriverChatLoadRequested(widget.tripId),
                    ),
              ),
            );
          }

          if (state is DriverChatLoaded) {
            final driverName = state.trip.driverName ?? 'driver'.tr();

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Row(
                  children: [
                    AvatarImage(
                      imageUrl: state.trip.driverAvatarUrl,
                      fallback: driverName,
                      radius: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        driverName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return ChatMessageBubble(
                          message: state.messages[index],
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _messageController,
                              hintText: 'chat_hint'.tr(),
                              textInputAction: TextInputAction.send,
                              onSubmitted: state.isSending
                                  ? null
                                  : (value) => _send(context, value),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Semantics(
                            label: 'chat_send'.tr(),
                            button: true,
                            child: IconButton.filled(
                              onPressed: state.isSending
                                  ? null
                                  : () => _send(
                                        context,
                                        _messageController.text,
                                      ),
                              icon: state.isSending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _send(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    context.read<DriverChatBloc>().add(DriverChatMessageSent(text));
    _messageController.clear();
  }
}
