/// Help articles. TODO(support): replace with GET /support/faq.
class Faq {
  const Faq(this.question, this.answer, {this.action});

  final String question;
  final String answer;

  /// A button under the answer: 'chat', 'profile', 'book'.
  final String? action;
}

class FaqCategory {
  const FaqCategory(this.title, this.items);

  final String title;
  final List<Faq> items;
}

abstract final class DemoFaq {
  static const categories = [
    FaqCategory('Frequently asked', [
      Faq(
        'Why was my booking cancelled?',
        'A booking can be cancelled automatically if no expert is free, we '
            'could not reach you, or something unexpected came up. Anything '
            'you paid is refunded to your original payment source within 7 to '
            '10 business days.',
      ),
      Faq(
        'I have not received my refund',
        'Wallet refunds are instant. Other payment methods can take up to 7 '
            'to 10 business days.',
      ),
      Faq(
        'Why have I been charged a cancellation fee?',
        'A fee can apply if a booking is cancelled close to the start time or '
            'after an expert has been assigned and set off. It covers the '
            "expert's reserved time and travel.",
        action: 'chat',
      ),
      Faq(
        "Why can't I see any available slots?",
        'Slots depend on expert availability in your area. If none show, it is '
            'likely high demand. Check again later or book for a future time.',
        action: 'book',
      ),
    ]),
    FaqCategory('Booking', [
      Faq(
        'How do I book a service immediately?',
        'On Home, choose Instant, pick a helper and a duration, then continue '
            'to pay. An expert is on the way within minutes.',
      ),
      Faq(
        'How do I schedule a booking for later?',
        'On Home, choose Schedule, pick a day, duration and start time, then '
            'continue to pay.',
      ),
      Faq(
        'How do I make daily or multiple bookings?',
        'Book each visit from Schedule. Daily plans are coming soon.',
      ),
      Faq(
        'How do custom bookings work?',
        'Tell us what you need in chat and our team will set it up for you.',
        action: 'chat',
      ),
    ]),
    FaqCategory('Account', [
      Faq(
        'I want to change my registered mobile number',
        'Each account is linked to one number. To use a new number, create a '
            'new account.',
      ),
      Faq(
        'I want to change my email ID',
        'Go to Profile, tap your name and edit your email address.',
        action: 'profile',
      ),
      Faq(
        'I want to change my address',
        'Go to Profile, then Saved addresses, and edit the address.',
      ),
      Faq(
        'I want to add a new address',
        'Go to Profile, then Saved addresses, and tap Add address.',
      ),
    ]),
    FaqCategory('Payments', [
      Faq(
        'I am not able to make the payment',
        'Check your internet connection and payment method. If the problem '
            'continues, restart the app or try another payment option.',
        action: 'chat',
      ),
      Faq(
        'How do offers work?',
        'Offers apply automatically at checkout when your booking is '
            'eligible. See Offers for what you can use.',
      ),
    ]),
    FaqCategory('Feedback', [
      Faq(
        'I want to report an issue with the expert',
        "We're sorry for the trouble. Please chat with us and share the "
            'details so our team can help.',
        action: 'chat',
      ),
      Faq(
        'Report a safety incident',
        'If something was damaged or lost during a service, chat with us and '
            'share the booking details. Our team will help you further.',
        action: 'chat',
      ),
    ]),
    FaqCategory('Safety', [
      Faq(
        'How are experts verified?',
        'Every expert is ID-verified and background-checked before joining, '
            'and trained and assessed before taking bookings.',
      ),
      Faq('Do you record my home?', 'No. We never record inside your home.'),
    ]),
  ];
}
