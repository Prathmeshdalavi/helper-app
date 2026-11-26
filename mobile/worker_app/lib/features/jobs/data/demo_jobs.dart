import '../../../shared/widgets/task_art.dart';
import '../domain/job.dart';

/// TODO(jobs): replace with offers pushed by the dispatch service.
const demoJobs = <Job>[
  Job(
    id: 'J-4821',
    service: 'Home cleaning',
    customer: 'Meera Iyer',
    area: 'Hiranandani Estate',
    address: 'B-1204, Lotus Tower, Hiranandani Estate, Thane West',
    distanceKm: 1.2,
    etaMinutes: 9,
    durationMinutes: 60,
    pay: 210,
    coins: 5,
    tasks: [HomeTask.mopping, HomeTask.dusting, HomeTask.surfaces],
    note: 'Please ring once. We have a friendly cat.',
  ),
  Job(
    id: 'J-4822',
    service: 'Kitchen help',
    customer: 'Sana Shaikh',
    area: 'Manpada',
    address: '302, Sai Krupa Society, Manpada, Thane West',
    distanceKm: 2.4,
    etaMinutes: 15,
    durationMinutes: 90,
    pay: 285,
    coins: 6,
    tasks: [HomeTask.dishes, HomeTask.chopping, HomeTask.fridge],
    note: 'Lift is under repair, third floor by stairs.',
  ),
  Job(
    id: 'J-4823',
    service: 'Laundry and tidying',
    customer: 'Ritu Kapoor',
    area: 'Kolshet Road',
    address: 'C-701, Green Acres, Kolshet Road, Thane West',
    distanceKm: 0.8,
    etaMinutes: 6,
    durationMinutes: 45,
    pay: 160,
    coins: 4,
    tasks: [HomeTask.laundry, HomeTask.tidying],
    note: 'Iron is in the study.',
  ),
];
