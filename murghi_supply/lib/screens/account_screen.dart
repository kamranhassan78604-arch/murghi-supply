import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/account.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Account> _accounts = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _loading = true);
    final accounts = await _db.getAllAccounts();
    setState(() {
      _accounts = accounts;
      _loading = false;
    });
  }

  List<Account> get _filteredAccounts {
    if (_query.isEmpty) return _accounts;
    return _accounts
        .where((a) => a.accountName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Future<void> _showAccountDialog({Account? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.accountName ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final vehicleController = TextEditingController(text: existing?.supplyVehicle ?? '');
    final balanceController =
        TextEditingController(text: existing?.previousBalance.toString() ?? '0');
    final discountController =
        TextEditingController(text: existing?.supplyDiscount.toString() ?? '0');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Account' : 'Edit Account'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Account Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: vehicleController,
                    decoration: const InputDecoration(
                      labelText: 'Supply Vehicle',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. Truck No. LEA-1234',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Previous Balance',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: discountController,
                    decoration: const InputDecoration(
                      labelText: 'Supply Discount',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
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
                final account = Account(
                  id: existing?.id,
                  accountName: nameController.text.trim(),
                  address: addressController.text.trim(),
                  supplyVehicle: vehicleController.text.trim(),
                  previousBalance:
                      double.tryParse(balanceController.text) ?? 0.0,
                  supplyDiscount:
                      double.tryParse(discountController.text) ?? 0.0,
                );
                if (existing == null) {
                  await _db.insertAccount(account);
                } else {
                  await _db.updateAccount(account);
                }
                if (context.mounted) Navigator.pop(context);
                _loadAccounts();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Delete account "${account.accountName}"?'),
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
      await _db.deleteAccount(account.id!);
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search account...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAccounts.isEmpty
              ? _EmptyState(onAdd: () => _showAccountDialog())
              : RefreshIndicator(
                  onRefresh: _loadAccounts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredAccounts.length,
                    itemBuilder: (context, index) {
                      final account = _filteredAccounts[index];
                      final balanceColor = account.previousBalance > 0
                          ? Colors.red
                          : account.previousBalance < 0
                              ? Colors.green
                              : Colors.grey;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              account.accountName.isNotEmpty
                                  ? account.accountName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(
                            account.accountName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Balance: Rs. ${account.previousBalance.toStringAsFixed(2)}',
                            style: TextStyle(color: balanceColor),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: account.address.isEmpty ? '-' : account.address),
                                  _InfoRow(icon: Icons.local_shipping_outlined, label: 'Supply Vehicle', value: account.supplyVehicle.isEmpty ? '-' : account.supplyVehicle),
                                  _InfoRow(icon: Icons.account_balance_wallet_outlined, label: 'Previous Balance', value: 'Rs. ${account.previousBalance.toStringAsFixed(2)}'),
                                  _InfoRow(icon: Icons.percent_outlined, label: 'Supply Discount', value: 'Rs. ${account.supplyDiscount.toStringAsFixed(2)}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAccountDialog(existing: account),
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        label: const Text('Edit'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _confirmDelete(account),
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Colors.red),
                                        label: const Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
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
          Icon(Icons.people_outline,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('No accounts yet'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add first account'),
          ),
        ],
      ),
    );
  }
}
