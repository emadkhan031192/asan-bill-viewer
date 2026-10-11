/// Due-date status logic for saved bills.
///
/// Rules (from the design brief):
/// - paid            → green chip
/// - 3 or fewer days remain (but not today) → amber chip
/// - due today or overdue → red chip
/// - otherwise / no due date → muted chip
enum DueStatus { paid, overdue, dueToday, dueSoon, upcoming, noDueDate }

DueStatus dueStatusOf({
  required bool paid,
  required DateTime? dueDate,
  required DateTime now,
}) {
  if (paid) return DueStatus.paid;
  if (dueDate == null) return DueStatus.noDueDate;
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diffDays = d.difference(today).inDays;
  if (diffDays < 0) return DueStatus.overdue;
  if (diffDays == 0) return DueStatus.dueToday;
  if (diffDays <= 3) return DueStatus.dueSoon;
  return DueStatus.upcoming;
}

/// Days remaining until [dueDate] (negative when overdue). Null without a date.
int? daysRemaining(DateTime? dueDate, DateTime now) {
  if (dueDate == null) return null;
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return d.difference(today).inDays;
}
