// DEMO data (no backend yet): contacts + history so every screen has real content.
class DemoContact {
  final String id;
  final String name;
  final String purposeHint;
  const DemoContact(this.id, this.name, this.purposeHint);
}

class DemoRecording {
  final String id;
  final String who;
  final String purpose;
  final int minutes;
  final String quality;
  final String status;
  final String date;
  final String deletesIn;
  const DemoRecording({
    required this.id,
    required this.who,
    required this.purpose,
    required this.minutes,
    required this.quality,
    required this.status,
    required this.date,
    required this.deletesIn,
  });
}

const demoContacts = [
  DemoContact('u1', 'Ada Obi', 'Interview'),
  DemoContact('u2', 'Tunde Bello', 'Sales call'),
  DemoContact('u3', 'Ngozi Eze', 'Research session'),
];

const demoHistory = [
  DemoRecording(id: 'r1', who: 'Ada Obi', purpose: 'Interview', minutes: 12, quality: '720p', status: 'STOPPED', date: '09 Oct 2026', deletesIn: '6 days'),
  DemoRecording(id: 'r2', who: 'Tunde Bello', purpose: 'Sales call', minutes: 25, quality: '480p', status: 'CONSENT_WITHDRAWN', date: '07 Oct 2026', deletesIn: '4 days'),
  DemoRecording(id: 'r3', who: 'Ngozi Eze', purpose: 'Research session', minutes: 8, quality: '720p', status: 'EXPIRED', date: '01 Oct 2026', deletesIn: 'deleted'),
];
