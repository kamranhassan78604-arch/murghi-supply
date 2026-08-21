import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/daily_rate.dart';

class DailyRateScreen extends StatefulWidget {
  const DailyRateScreen({super.key});

  @override
  State<DailyRateScreen> createState() => _DailyRateScreenState();
}

class _DailyRateScreenState extends State<DailyRateScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<DailyRate> _rates = [];
  bool _loading = true;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _loading = true);
    final rates = await _db.getAllDailyRates();
    setState(() {
      _rates = rates;
      _loading = false;
    });
  }

  Future<void> _showRateDialog({DailyRate? existing}) async {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = existing != null
        ? _dateFormat.parse(existing.date)
        : DateTime.now();
    final rateController =
        TextEditingController(text: existing?.rate.toString() ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Daily Rate' : 'Edit Daily Rate'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_displayFormat.format(selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: rateController,
                        decoration: const InputDecoration(
                          labelText: 'Rate (per kg / unit)',
                          border: OutlineInputBorder(),
                          prefixText: 'Rs. ',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Rate is required';
                          if (double.tryParse(v) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final rate = DailyRate(
                      id: existing?.id,
                      date: _dateFormat.format(selectedDate),
                      rate: double.parse(rateController.text),
                      description: descController.text.trim(),
                    );
                    if (existing == null) {
                      await _db.insertDailyRate(rate);
                    } else {
                      await _db.updateDailyRate(rate);
                    }
                    if (context.mounted) Navigator.pop(context);
                    _loadRates();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(DailyRate rate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rate'),
        content: Text('Delete rate entry for ${_displayFormat.format(_dateFormat.parse(rate.date))}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteDailyRate(rate.id!);
      _loadRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Rate')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rates.isEmpty
              ? _EmptyState(onAdd: () => _showRateDialog())
              : RefreshIndicator(
                  onRefresh: _loadRates,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _rates.length,
                    itemBuilder: (context, index) {
                      final rate = _rates[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.egg_alt_outlined),
                          ),
                          title: Text(
                            _displayFormat.format(_dateFormat.parse(rate.date)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            rate.description.isEmpty
                                ? 'Rs. ${rate.rate.toStringAsFixed(2)}'
                                : 'Rs. ${rate.rate.toStringAsFixed(2)} • ${rate.description}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showRateDialog(existing: rate);
                              } else if (value == 'delete') {
                                _confirmDelete(rate);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Rate'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('No daily rates yet'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add first rate'),
          ),
        ],
      ),
    );
  }
}
