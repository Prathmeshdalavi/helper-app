import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/kyc.dart';

/// Document statuses for the signed-in expert.
class KycNotifier extends Notifier<Map<KycDoc, DocStatus>> {
  @override
  Map<KycDoc, DocStatus> build() => {
    for (final d in KycDoc.values) d: DocStatus.missing,
  };

  /// TODO(kyc): open the camera, upload the image and read the status back.
  void upload(KycDoc doc) => state = {...state, doc: DocStatus.inReview};

  /// The demo account has finished everything except PAN.
  void seedVerified() => state = {
    for (final d in KycDoc.values)
      d: d == KycDoc.pan ? DocStatus.missing : DocStatus.verified,
  };

  void reset() => state = build();
}

final kycProvider = NotifierProvider<KycNotifier, Map<KycDoc, DocStatus>>(
  KycNotifier.new,
);
