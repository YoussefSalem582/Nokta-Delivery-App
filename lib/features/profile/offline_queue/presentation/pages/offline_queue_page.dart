import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/profile/offline_queue/presentation/bloc/pending_sync_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/shared/widgets/feedback/empty_state_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfflineQueuePage extends StatelessWidget {
  const OfflineQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PendingSyncBloc(
        pendingSync: sl<PendingSyncLocalDataSource>(),
        syncService: sl<SyncService>(),
      )..add(const PendingSyncLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('offline_queue'.tr()),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'retry_all'.tr(),
                  onPressed: () {
                    context
                        .read<PendingSyncBloc>()
                        .add(const PendingSyncRetryRequested());
                  },
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<PendingSyncBloc, PendingSyncState>(
          listenWhen: (previous, current) =>
              current is PendingSyncError ||
              (current is PendingSyncLoaded && current.justSynced),
          listener: (context, state) {
            if (state is PendingSyncLoaded && state.justSynced) {
              AppToast.success(context, 'sync_complete'.tr());
            } else if (state is PendingSyncError) {
              AppToast.error(context, 'sync_failed'.tr());
            }
          },
          builder: (context, state) {
            if (state is PendingSyncLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PendingSyncError) {
              return ErrorView(
                message: 'sync_failed',
                onRetry: () => context
                    .read<PendingSyncBloc>()
                    .add(const PendingSyncLoadRequested()),
              );
            }
            if (state is PendingSyncLoaded) {
              if (state.items.isEmpty) {
                return EmptyStateView(
                  icon: Icons.cloud_done,
                  title: 'queue_empty'.tr(),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined),
                      title: Text('queue_action_${item.action.name}'.tr()),
                      subtitle: Text(
                        '${'queue_item_retries'.tr(namedArgs: {'count': '${item.retryCount}'})}'
                        ' • ${TimeOfDay.fromDateTime(item.createdAt).format(context)}',
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          context
                              .read<PendingSyncBloc>()
                              .add(PendingSyncRemoveItemRequested(item.id));
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
