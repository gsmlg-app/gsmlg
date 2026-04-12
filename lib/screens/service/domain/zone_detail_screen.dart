import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_data_list/app_data_list.dart';
import 'package:app_database/app_database.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';

class ZoneDetailScreen extends StatefulWidget {
  static const name = 'ZoneDetail';
  static const path = ':zoneId';

  final int zoneId;

  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  DnsZoneTableData? _zone;
  final _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _loadZone();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _loadZone() {
    final state = context.read<ZoneBloc>().state;
    if (state is ZoneLoaded) {
      final zone = state.zones.where((z) => z.id == widget.zoneId).firstOrNull;
      if (zone != null) {
        setState(() => _zone = zone);
        context.read<RecordBloc>().add(RecordSync(zone));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_zone == null) {
      return AppAdaptiveScaffold(
        selectedIndex: Destinations.indexOf(
          const Key(ServiceScreen.name),
          context,
        ),
        destinations: Destinations.navs(context),
        onSelectedIndexChange: (idx) =>
            Destinations.changeHandler(idx, context),
        body: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    final zone = _zone!;

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => BlocListener<RecordBloc, RecordState>(
        listener: (context, state) {
          if (state is RecordFailure) {
            showErrorToast(context: context, message: state.error);
          }
        },
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(zone.zoneName),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/service/domain'),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddRecordDialog(context, zone),
                    tooltip: 'Add Record',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        context.read<RecordBloc>().add(RecordSync(zone)),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              // Zone info header
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              zone.provider == DnsProvider.route53
                                  ? Icons.cloud_outlined
                                  : Icons.cloud_circle_outlined,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              zone.provider == DnsProvider.route53
                                  ? 'AWS Route 53'
                                  : 'Cloudflare',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Zone ID: ${zone.zoneId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (zone.comment != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            zone.comment!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Filter field
              SliverToBoxAdapter(
                child: DataListFilterField(
                  controller: _filterController,
                  onChanged: (value) => setState(() => _filterText = value),
                  hintText: 'Filter records...',
                ),
              ),
              // Loading indicator (shown at top when refreshing with existing records)
              BlocBuilder<RecordBloc, RecordState>(
                builder: (context, state) {
                  if (state is RecordLoading && state.records != null) {
                    return const SliverToBoxAdapter(
                      child: LinearProgressIndicator(),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              // Records list
              BlocBuilder<RecordBloc, RecordState>(
                builder: (context, state) {
                  return switch (state) {
                    RecordInitial() => const SliverFillRemaining(
                      child: Center(
                        child: Text('Select a zone to view records'),
                      ),
                    ),
                    // Initial loading (no existing records)
                    RecordLoading(:final records) when records == null =>
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    // Refreshing with existing records - show the records
                    RecordLoading(:final records!) when records.isEmpty =>
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.dns_outlined, size: 64),
                              const SizedBox(height: 16),
                              const Text('No DNS records'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddRecordDialog(context, zone),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Record'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    RecordLoading(:final records!) => _buildRecordList(
                      context,
                      zone,
                      records,
                    ),
                    RecordFailure(:final error) => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<RecordBloc>().add(
                                RecordSync(zone),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RecordLoaded(:final records) when records.isEmpty =>
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.dns_outlined, size: 64),
                              const SizedBox(height: 16),
                              const Text('No DNS records'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddRecordDialog(context, zone),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Record'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    RecordLoaded(:final records) => _buildRecordList(
                      context,
                      zone,
                      records,
                    ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList(
    BuildContext context,
    DnsZoneTableData zone,
    List<DnsRecordModel> records,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverResponsiveDataList<DnsRecordModel>(
      items: records,
      filterText: _filterText,
      columns: [
        DataColumnDef<DnsRecordModel>(
          label: 'Type',
          getValue: (r) => r.type,
          buildCell: (r) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              r.type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        DataColumnDef<DnsRecordModel>(
          label: 'Name',
          getValue: (r) => r.name,
          isPrimary: true,
          maxWidth: 250,
        ),
        DataColumnDef<DnsRecordModel>(
          label: 'Content',
          getValue: (r) => r.content,
          maxWidth: 300,
        ),
        DataColumnDef<DnsRecordModel>(
          label: 'TTL',
          getValue: (r) => r.ttl == 1 ? 'Auto' : r.ttl.toString(),
        ),
        if (zone.provider == DnsProvider.cloudflare)
          DataColumnDef<DnsRecordModel>(
            label: 'Proxied',
            getValue: (r) => r.proxied == true ? 'Yes' : 'No',
            showInList: false,
          ),
      ],
      actionsBuilder: (record) => [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _showEditRecordDialog(context, zone, record),
          tooltip: 'Edit',
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: Icon(Icons.delete, size: 20, color: colorScheme.error),
          onPressed: () => _showDeleteRecordDialog(context, zone, record),
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  void _showAddRecordDialog(BuildContext context, DnsZoneTableData zone) {
    showDialog(
      context: context,
      builder: (context) => _RecordFormDialog(
        zone: zone,
        title: 'Add DNS Record',
        onSave: (record) {
          context.read<RecordBloc>().add(RecordAdd(zone: zone, record: record));
        },
      ),
    );
  }

  void _showEditRecordDialog(
    BuildContext context,
    DnsZoneTableData zone,
    DnsRecordModel record,
  ) {
    showDialog(
      context: context,
      builder: (context) => _RecordFormDialog(
        zone: zone,
        record: record,
        title: 'Edit DNS Record',
        onSave: (updatedRecord) {
          context.read<RecordBloc>().add(
            RecordUpdate(zone: zone, record: updatedRecord),
          );
        },
      ),
    );
  }

  void _showDeleteRecordDialog(
    BuildContext context,
    DnsZoneTableData zone,
    DnsRecordModel record,
  ) {
    showDmDialog(
      context: context,
      title: const Text('Delete Record'),
      content: Text(
        'Are you sure you want to delete this record?\n\n'
        '${record.type} ${record.name}\n'
        '→ ${record.content}',
      ),
      actions: [
        DmDialogAction(
          onPressed: (ctx) => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        DmDialogAction(
          onPressed: (ctx) {
            context.read<RecordBloc>().add(
              RecordRemove(zone: zone, record: record),
            );
            Navigator.of(ctx).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _RecordFormDialog extends StatefulWidget {
  final DnsZoneTableData zone;
  final DnsRecordModel? record;
  final String title;
  final void Function(DnsRecordModel record) onSave;

  const _RecordFormDialog({
    required this.zone,
    this.record,
    required this.title,
    required this.onSave,
  });

  @override
  State<_RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<_RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final TextEditingController _ttlController;
  bool _proxied = false;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _type = widget.record?.type ?? 'A';
    _nameController = TextEditingController(text: widget.record?.name ?? '');
    _contentController = TextEditingController(
      text: widget.record?.content ?? '',
    );
    _ttlController = TextEditingController(
      text: (widget.record?.ttl ?? 300).toString(),
    );
    _proxied = widget.record?.proxied ?? false;
    _commentController = TextEditingController(
      text: widget.record?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _ttlController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordTypes = widget.zone.provider == DnsProvider.route53
        ? DnsRecordTypes.route53
        : DnsRecordTypes.cloudflare;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: recordTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: widget.zone.provider == DnsProvider.route53
                        ? 'subdomain (or @ for root)'
                        : widget.zone.zoneName,
                    helperText: widget.zone.provider == DnsProvider.route53
                        ? 'Will be appended with .${widget.zone.zoneName}'
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: _getContentHint(_type),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: _type == 'TXT' ? 3 : 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ttlController,
                  decoration: const InputDecoration(
                    labelText: 'TTL (seconds)',
                    hintText: '300',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (widget.zone.provider == DnsProvider.cloudflare) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Proxied'),
                    subtitle: const Text('Route traffic through Cloudflare'),
                    value: _proxied,
                    onChanged: (value) => setState(() => _proxied = value),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // For Route53, ensure name is fully qualified
              var recordName = _nameController.text.trim();
              if (widget.zone.provider == DnsProvider.route53) {
                final zoneName = widget.zone.zoneName.endsWith('.')
                    ? widget.zone.zoneName
                    : '${widget.zone.zoneName}.';
                if (!recordName.endsWith(zoneName) &&
                    !recordName.endsWith(widget.zone.zoneName)) {
                  // Append zone name
                  if (recordName.endsWith('.')) {
                    recordName = '$recordName$zoneName';
                  } else if (recordName.isEmpty || recordName == '@') {
                    recordName = zoneName;
                  } else {
                    recordName = '$recordName.$zoneName';
                  }
                }
              }

              widget.onSave(
                DnsRecordModel(
                  id: widget.record?.id,
                  name: recordName,
                  type: _type,
                  content: _contentController.text,
                  ttl: int.tryParse(_ttlController.text) ?? 300,
                  proxied: widget.zone.provider == DnsProvider.cloudflare
                      ? _proxied
                      : null,
                  comment: _commentController.text.isEmpty
                      ? null
                      : _commentController.text,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getContentHint(String type) {
    return switch (type) {
      'A' => '192.168.1.1',
      'AAAA' => '2001:db8::1',
      'CNAME' => 'target.example.com',
      'MX' => 'mail.example.com',
      'TXT' => '"v=spf1 include:_spf.example.com ~all"',
      'NS' => 'ns1.example.com',
      'SRV' => '10 5 5060 sipserver.example.com',
      'CAA' => '0 issue "letsencrypt.org"',
      _ => '',
    };
  }
}
