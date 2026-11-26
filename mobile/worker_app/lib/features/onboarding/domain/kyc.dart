enum KycDoc {
  aadhaar('Aadhaar card', 'Identity and address proof', true),
  pan('PAN card', 'Lowers the tax cut from your pay', false),
  photo('Your photo', 'Customers see this before you arrive', true),
  police('Police verification', 'Keeps you and customers safe', true);

  const KycDoc(this.title, this.why, this.required);
  final String title;
  final String why;
  final bool required;
}

enum DocStatus { missing, inReview, verified }
