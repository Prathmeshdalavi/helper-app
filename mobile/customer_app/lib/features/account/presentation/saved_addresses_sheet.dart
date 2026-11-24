import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/domain/booking.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/address_store.dart';

/// Lists saved addresses; tap one to use it, or add a new one.
Future<void> showSavedAddressesSheet(BuildContext context) =>
    showPremiumSheet<void>(context, builder: (_) => const _AddressesSheet());

class _AddressesSheet extends ConsumerWidget {
  const _AddressesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Saved addresses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Pressable(
                onTap: () => showAddressForm(context),
                scale: 0.96,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppInk.hairline),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Add address',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            children: [
              for (final a in state.addresses)
                _AddressRow(
                  address: a,
                  selected: a.id == state.selectedId,
                  canDelete: state.addresses.length > 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends ConsumerWidget {
  const _AddressRow({
    required this.address,
    required this.selected,
    required this.canDelete,
  });

  final Address address;
  final bool selected;
  final bool canDelete;

  static const _icons = {
    'Home': Icons.home_rounded,
    'Work': Icons.work_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Pressable(
      onTap: () {
        ref.read(addressProvider.notifier).select(address.id);
        Navigator.of(context).pop();
      },
      scale: 0.99,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? premiumSelectedFill : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.lavender : AppInk.hairline,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _icons[address.label] ?? Icons.location_on_rounded,
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: premiumGreenFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SELECTED',
                            style: TextStyle(
                              fontSize: 10.5,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w700,
                              color: premiumGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.full,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppInk.muted,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (v) {
                if (v == 'edit') showAddressForm(context, existing: address);
                if (v == 'delete') {
                  ref.read(addressProvider.notifier).remove(address.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDelete)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Add a new address, or edit [existing].
Future<void> showAddressForm(BuildContext context, {Address? existing}) =>
    showPremiumSheet<void>(
      context,
      builder: (_) => _AddressForm(existing: existing),
    );

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({this.existing});

  final Address? existing;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  late String _label = widget.existing?.label ?? 'Home';
  late final _line1 = TextEditingController(text: widget.existing?.line1);
  late final _line2 = TextEditingController(text: widget.existing?.line2);

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    super.dispose();
  }

  bool get _valid =>
      _line1.text.trim().length > 3 && _line2.text.trim().length > 3;

  void _save() {
    final store = ref.read(addressProvider.notifier);
    final e = widget.existing;
    if (e == null) {
      store.add(
        label: _label,
        line1: _line1.text.trim(),
        line2: _line2.text.trim(),
      );
    } else {
      store.update(
        Address(
          id: e.id,
          label: _label,
          line1: _line1.text.trim(),
          line2: _line2.text.trim(),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.existing == null ? 'Add address' : 'Edit address',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final l in const ['Home', 'Work', 'Other'])
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Pressable(
                    onTap: () => setState(() => _label = l),
                    scale: 0.97,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: l == _label ? premiumSelectedFill : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: l == _label
                              ? AppColors.lavender
                              : AppInk.hairline,
                          width: l == _label ? 1.3 : 1,
                        ),
                      ),
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: l == _label
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Field(
            controller: _line1,
            label: 'House, building and street',
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _line2,
            label: 'Area, city and pincode',
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: widget.existing == null ? 'Save address' : 'Update',
            onPressed: _valid ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textCapitalization: TextCapitalization.words,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF6F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
