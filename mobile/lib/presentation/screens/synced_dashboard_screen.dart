import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:CollegeBuddy/domain/entities/assignment_entity.dart';
import 'package:CollegeBuddy/domain/entities/mail_entity.dart';
import 'package:CollegeBuddy/presentation/providers/providers.dart';
import 'package:CollegeBuddy/services/sync_service.dart';

/// Dashboard that always renders from SQLite and never calls APIs directly.
/// The SyncService pushes fresh data in the background; reactive streams
/// update the UI automatically without any manual refresh logic here.
class SyncedDashboardScreen extends ConsumerStatefulWidget {
  const SyncedDashboardScreen({super.key});

  @override
  ConsumerState<SyncedDashboardScreen> createState() =>
      _SyncedDashboardScreenState();
}

class _SyncedDashboardScreenState
    extends ConsumerState<SyncedDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger background sync after first frame; UI shows cached data
    // immediately while this runs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).syncIfStale();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(syncServiceProvider).forceSync();
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final mails = ref.watch(mailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Sync status indicator
          syncStatus.when(
            data: (status) => _SyncIndicator(status: status),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(Icons.cloud_off, color: Colors.red),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // ── Upcoming Deadlines ──────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Upcoming Deadlines',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            deadlines.when(
              data: (assignments) => assignments.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No upcoming deadlines.'),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AssignmentTile(assignment: assignments[i]),
                        childCount: assignments.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text('Error: $e'),
              ),
            ),

            // ── Inbox ───────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Inbox',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            mails.when(
              data: (mailList) => mailList.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No emails cached yet.'),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _MailTile(mail: mailList[i]),
                        childCount: mailList.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _SyncIndicator extends StatelessWidget {
  final SyncStatus status;

  const _SyncIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SyncStatus.syncing => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      SyncStatus.success => const Icon(Icons.cloud_done, color: Colors.green),
      SyncStatus.failure => const Icon(Icons.cloud_off, color: Colors.orange),
      SyncStatus.idle => const SizedBox.shrink(),
    };
  }
}

class _AssignmentTile extends StatelessWidget {
  final AssignmentEntity assignment;

  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final dueLabel = assignment.hasDueDate
        ? _formatDueDate(assignment.dueDate)
        : 'No due date';

    return ListTile(
      leading: const Icon(Icons.assignment),
      title: Text(assignment.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(assignment.courseName),
      trailing: Text(
        dueLabel,
        style: TextStyle(
          color: _isDueSoon(assignment.dueDate) ? Colors.red : null,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDueDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return raw;
    }
  }

  bool _isDueSoon(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return dt.difference(DateTime.now()).inDays <= 2;
    } catch (_) {
      return false;
    }
  }
}

class _MailTile extends StatelessWidget {
  final MailEntity mail;

  const _MailTile({required this.mail});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.email)),
      title: Text(mail.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(mail.from, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(mail.date, style: const TextStyle(fontSize: 11)),
    );
  }
}
