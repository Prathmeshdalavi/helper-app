import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/domain/booking.dart';

/// The customer's saved addresses and which one is selected.
/// TODO(addresses): load from and save to GET/POST /users/me/addresses.
class AddressState {
  const AddressState({required this.addresses, required this.selectedId});

  final List<Address> addresses;
  final String selectedId;

  Address get selected => addresses.firstWhere(
    (a) => a.id == selectedId,
    orElse: () => addresses.first,
  );
}

const _home = Address(
  id: 'home',
  label: 'Home',
  line1: 'B104, Sai Prasad Enclave, 36 Kamothe Marg',
  line2: 'Shalome CHS, Sector 8, Kamothe, Panvel, Maharashtra 410209',
);

class AddressNotifier extends Notifier<AddressState> {
  int _seq = 0;

  @override
  AddressState build() =>
      const AddressState(addresses: [_home], selectedId: 'home');

  void select(String id) =>
      state = AddressState(addresses: state.addresses, selectedId: id);

  Address add({
    required String label,
    required String line1,
    required String line2,
  }) {
    _seq += 1;
    final a = Address(id: 'a$_seq', label: label, line1: line1, line2: line2);
    state = AddressState(addresses: [...state.addresses, a], selectedId: a.id);
    return a;
  }

  void update(Address a) => state = AddressState(
    addresses: [for (final x in state.addresses) x.id == a.id ? a : x],
    selectedId: state.selectedId,
  );

  void remove(String id) {
    final left = [
      for (final a in state.addresses)
        if (a.id != id) a,
    ];
    if (left.isEmpty) return; // keep at least one address
    state = AddressState(
      addresses: left,
      selectedId: state.selectedId == id ? left.first.id : state.selectedId,
    );
  }
}

final addressProvider = NotifierProvider<AddressNotifier, AddressState>(
  AddressNotifier.new,
);

/// The address bookings are made for.
final selectedAddressProvider = Provider<Address>(
  (ref) => ref.watch(addressProvider).selected,
);
