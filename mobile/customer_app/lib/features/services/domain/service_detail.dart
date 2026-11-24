/// Extra content shown on a service's detail screen.
class ServiceDetail {
  const ServiceDetail({
    required this.about,
    required this.duration,
    required this.included,
    required this.notIncluded,
    required this.reviews,
    required this.reviewCount,
  });

  /// Two or three sentences describing the service.
  final String about;

  /// Typical visit length, e.g. "1 hour".
  final String duration;
  final List<String> included;
  final List<String> notIncluded;
  final List<ServiceReview> reviews;
  final int reviewCount;
}

class ServiceReview {
  const ServiceReview({
    required this.name,
    required this.rating,
    required this.text,
    required this.when,
  });

  final String name;
  final int rating;
  final String text;
  final String when;
}
