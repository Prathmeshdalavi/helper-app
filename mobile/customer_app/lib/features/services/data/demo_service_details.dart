import '../domain/service_detail.dart';

/// Demo detail content keyed by [ServiceCategory.id].
/// TODO(catalog): replace with GET /catalog/categories/{id}.
abstract final class DemoServiceDetails {
  static ServiceDetail? byId(String id) => _all[id];

  static const _all = <String, ServiceDetail>{
    'cooking': ServiceDetail(
      about:
          'A verified helper cooks fresh, home-style meals in your kitchen, '
          'the way your family likes them.',
      duration: '1 hour',
      included: [
        'Up to 3 dishes per visit',
        'Chopping, cooking and plating',
        'Kitchen counter wiped after cooking',
      ],
      notIncluded: ['Groceries', 'Deep cleaning of the kitchen'],
      reviewCount: 1280,
      reviews: [
        ServiceReview(
          name: 'Meera K.',
          rating: 5,
          text: 'Dal and sabzi tasted just like home. Very neat and on time.',
          when: '2 days ago',
        ),
        ServiceReview(
          name: 'Rohit S.',
          rating: 5,
          text: 'Polite, clean and quick. Booking again for next week.',
          when: '1 week ago',
        ),
      ],
    ),
    'cleaning': ServiceDetail(
      about:
          'Everyday home cleaning by a trained helper. Floors, kitchen and '
          'dusting, done to a checklist.',
      duration: '1 hour',
      included: [
        'Sweeping and mopping',
        'Dusting furniture and surfaces',
        'Kitchen platform and sink',
        'Bathroom wash basin and floor',
      ],
      notIncluded: ['Window exteriors', 'Moving heavy furniture'],
      reviewCount: 2140,
      reviews: [
        ServiceReview(
          name: 'Anita R.',
          rating: 5,
          text: 'The house looked fresh in an hour. Really thorough.',
          when: '3 days ago',
        ),
        ServiceReview(
          name: 'Kabir M.',
          rating: 4,
          text: 'Good work and friendly. Arrived a few minutes late.',
          when: '2 weeks ago',
        ),
      ],
    ),
    'baby': ServiceDetail(
      about:
          'Gentle, trained caregivers who look after your little one while '
          'you get things done.',
      duration: '3 hours',
      included: [
        'Feeding and burping',
        'Play and story time',
        'Nap supervision',
        'Updates to you after the visit',
      ],
      notIncluded: ['Medical care', 'Cooking for the family'],
      reviewCount: 640,
      reviews: [
        ServiceReview(
          name: 'Sneha P.',
          rating: 5,
          text: 'Our daughter took to her at once. Very caring and patient.',
          when: '4 days ago',
        ),
        ServiceReview(
          name: 'Arjun V.',
          rating: 5,
          text: 'Trustworthy and well trained. Peace of mind for us.',
          when: '1 week ago',
        ),
      ],
    ),
    'pets': ServiceDetail(
      about:
          'Walks, play and feeding for your pet, by someone who is '
          'comfortable around animals.',
      duration: '45 minutes',
      included: [
        'Walk or playtime',
        'Feeding and fresh water',
        'Quick brush',
        'Photo update for you',
      ],
      notIncluded: ['Grooming and bathing', 'Vet visits'],
      reviewCount: 410,
      reviews: [
        ServiceReview(
          name: 'Divya N.',
          rating: 5,
          text: 'Bruno was so happy after his walk. Sent me lovely photos.',
          when: '5 days ago',
        ),
        ServiceReview(
          name: 'Imran A.',
          rating: 4,
          text: 'Reliable and gentle with our cat.',
          when: '3 weeks ago',
        ),
      ],
    ),
    'elder': ServiceDetail(
      about:
          'Kind, everyday support for elders at home: company, small errands '
          'and help with daily routines.',
      duration: '3 hours',
      included: [
        'Companionship and conversation',
        'Help with meals and medicine reminders',
        'Light walking support',
        'Small household errands',
      ],
      notIncluded: ['Nursing or medical procedures', 'Overnight stay'],
      reviewCount: 530,
      reviews: [
        ServiceReview(
          name: 'Lata D.',
          rating: 5,
          text: 'My mother looks forward to her visits. Very respectful.',
          when: '1 week ago',
        ),
        ServiceReview(
          name: 'Suresh T.',
          rating: 5,
          text: 'Patient and caring. Exactly what we needed.',
          when: '2 weeks ago',
        ),
      ],
    ),
    'laundry': ServiceDetail(
      about:
          'Washing, drying and folding at home with your own machine, '
          'handled neatly and with care.',
      duration: '1.5 hours',
      included: [
        'Sorting by colour and fabric',
        'Machine wash and dry',
        'Folding and stacking',
      ],
      notIncluded: ['Ironing', 'Dry cleaning'],
      reviewCount: 760,
      reviews: [
        ServiceReview(
          name: 'Pooja G.',
          rating: 5,
          text: 'Everything folded perfectly. Saved my whole Sunday.',
          when: '6 days ago',
        ),
        ServiceReview(
          name: 'Nikhil B.',
          rating: 4,
          text: 'Good job and careful with delicate clothes.',
          when: '2 weeks ago',
        ),
      ],
    ),
    'full-day': ServiceDetail(
      about:
          'One helper for the whole day. Cooking, cleaning and the little '
          'jobs in between, on your schedule.',
      duration: '8 hours',
      included: [
        'Cooking up to 2 meals',
        'Cleaning and tidying',
        'Laundry and dishes',
        'Errands around the house',
      ],
      notIncluded: ['Overnight stay', 'Heavy deep cleaning'],
      reviewCount: 320,
      reviews: [
        ServiceReview(
          name: 'Ritu J.',
          rating: 5,
          text: 'A full day of help. I finally had time for myself.',
          when: '1 week ago',
        ),
        ServiceReview(
          name: 'Vivek H.',
          rating: 4,
          text: 'Hardworking and organised. Good value.',
          when: '3 weeks ago',
        ),
      ],
    ),
    'monthly': ServiceDetail(
      about:
          'The same trusted helper, every visit, for the whole month. '
          'Plan once and forget about it.',
      duration: '1 hour, daily',
      included: [
        'Same verified helper every day',
        'Your choice of tasks, fixed once',
        'Replacement if your helper is away',
        'One monthly bill',
      ],
      notIncluded: ['Weekly off days (6 days a week)', 'Groceries'],
      reviewCount: 290,
      reviews: [
        ServiceReview(
          name: 'Farah Q.',
          rating: 5,
          text: 'Having the same person each day makes all the difference.',
          when: '1 week ago',
        ),
        ServiceReview(
          name: 'Gaurav L.',
          rating: 5,
          text: 'Smooth and reliable. The replacement was arranged quickly.',
          when: '1 month ago',
        ),
      ],
    ),
  };
}
