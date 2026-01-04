import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Milestone {
  final int days;
  final String title;
  final String subtitle;
  final IconData icon;

  Milestone({
    required this.days,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// Define your milestones here
final List<Milestone> recoveryMilestones = [
  Milestone(
    days: 0,
    title: "The Beginning",
    subtitle: "You took the first step.",
    icon: PhosphorIcons.footprints(),
  ),
  Milestone(
    days: 1,
    title: "24 Hours",
    subtitle: "One day clean.",
    icon: PhosphorIcons.sun(),
  ),
  Milestone(
    days: 3,
    title: "3 Days",
    subtitle: "The chemical fog lifts.",
    icon: PhosphorIcons.drop(),
  ),
  Milestone(
    days: 7,
    title: "1 Week",
    subtitle: "First major hurdle passed.",
    icon: PhosphorIcons.calendarCheck(),
  ),
  Milestone(
    days: 14,
    title: "2 Weeks",
    subtitle: "Building the foundation.",
    icon: PhosphorIcons.wall(),
  ),
  Milestone(
    days: 30,
    title: "30 Days",
    subtitle: "A new month, a new you.",
    icon: PhosphorIcons.star(),
  ),
  Milestone(
    days: 90,
    title: "90 Days",
    subtitle: "Lifestyle change confirmed.",
    icon: PhosphorIcons.medal(),
  ),
  Milestone(
    days: 365,
    title: "1 Year",
    subtitle: "A full trip around the sun.",
    icon: PhosphorIcons.trophy(),
  ),
];
