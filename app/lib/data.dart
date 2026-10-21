/// Port of `src/webapp/data.ts`. Records are illustrative prototype data.
library;

class ResearchItem {
  const ResearchItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.reference,
    required this.meta,
    required this.excerpt,
    required this.label,
    required this.topic,
  });

  final String id;

  /// "Case" | "Legislation" | "Brief" | "Article" | "Course" | "Past question"
  final String kind;
  final String title;
  final String reference;
  final String meta;
  final String excerpt;

  /// "Primary source" | "Editorial brief" | "Study resource" | "External source"
  final String label;
  final String topic;
}

const illustrativeCase = ResearchItem(
  id: 'case-frustration-01',
  kind: 'Case',
  title: '[Illustrative party] v [Illustrative party]',
  reference: '[Year] [Report] [Page]',
  meta: 'Supreme Court · [Decision date] · Illustrative record',
  excerpt:
      'An illustrative judgment record used to demonstrate research, briefing, source review, and connected study workflows.',
  label: 'Primary source',
  topic: 'Frustration of contract',
);

const legislation = <ResearchItem>[
  ResearchItem(id: 'act-contract-01', kind: 'Legislation', title: '[Illustrative Act title]', reference: 'Act [X] · [Year]', meta: 'Act of Parliament · Status not verified', excerpt: 'Illustrative legal-text record. Check the source and current status before relying on this text.', label: 'Primary source', topic: 'Contract'),
  ResearchItem(id: 'bill-commerce-01', kind: 'Legislation', title: '[Illustrative Bill title]', reference: 'Bill · [Year]', meta: 'Proposed legislation · Not enacted law', excerpt: 'Illustrative Bill record presented separately from enacted legislation.', label: 'Primary source', topic: 'Commercial Law'),
  ResearchItem(id: 'li-procedure-01', kind: 'Legislation', title: '[Illustrative Legislative Instrument]', reference: 'L.I. [X]', meta: 'Legislative Instrument · Status not verified', excerpt: 'Illustrative subsidiary-legislation record with unverified legal status.', label: 'Primary source', topic: 'Procedure'),
  ResearchItem(id: 'ci-constitutional-01', kind: 'Legislation', title: '[Illustrative Constitutional Instrument]', reference: 'C.I. [X]', meta: 'Constitutional Instrument · Status not verified', excerpt: 'Illustrative constitutional-instrument record.', label: 'Primary source', topic: 'Constitutional Law'),
  ResearchItem(id: 'ei-executive-01', kind: 'Legislation', title: '[Illustrative Executive Instrument]', reference: 'E.I. [X]', meta: 'Executive Instrument · Status not verified', excerpt: 'Illustrative executive-instrument record.', label: 'Primary source', topic: 'Public Law'),
];

final researchItems = <ResearchItem>[
  illustrativeCase,
  ResearchItem(id: 'brief-frustration-01', kind: 'Brief', title: 'Case brief: ${illustrativeCase.title}', reference: illustrativeCase.reference, meta: 'Editorial explanation · Last reviewed [date]', excerpt: 'A structured, illustrative brief covering facts, issues, holding, ratio, principles, and disposition.', label: 'Editorial brief', topic: 'Frustration of contract'),
  legislation[0],
  legislation[1],
  const ResearchItem(id: 'course-contract', kind: 'Course', title: 'Law of Contract', reference: 'Course library', meta: 'Study resource · Illustrative pathway', excerpt: 'Learn, read authority, study the brief, practise, and review.', label: 'Study resource', topic: 'Contract'),
  const ResearchItem(id: 'question-frustration-01', kind: 'Past question', title: 'Illustrative problem question: frustration', reference: '[Category] · [Year not supplied]', meta: 'Provenance not supplied · Practice demonstration', excerpt: 'Apply the law of frustration to an unforeseen event affecting contractual performance.', label: 'Study resource', topic: 'Frustration of contract'),
];

class Course {
  const Course(this.id, this.title, this.progress, this.next, this.topics);
  final String id;
  final String title;
  final int progress;
  final String next;
  final int topics;
}

const courses = <Course>[
  Course('contract', 'Law of Contract', 42, 'Frustration of contract', 8),
  Course('torts', 'Torts', 24, 'Duty of care', 7),
  Course('commercial', 'Commercial Law', 10, 'Agency', 9),
  Course('criminal', 'Criminal Law', 36, 'Elements of an offence', 10),
  Course('jurisprudence', 'Jurisprudence', 18, 'Legal positivism', 6),
  Course('banking', 'Banking and Insurance', 8, 'Banker–customer relationship', 8),
  Course('evidence', 'Law of Evidence', 31, 'Relevance and admissibility', 9),
];

class Institution {
  const Institution(this.name, this.school, this.sector);
  final String name;
  final String school;
  final String sector;
}

const accreditedInstitutions = <Institution>[
  Institution('Accra Metropolitan University', 'School of Law', 'Private'),
  Institution('Ashesi University', 'Faculty of Humanities and Social Sciences', 'Private'),
  Institution('Central University', 'Faculty of Law', 'Private'),
  Institution('Ghana Institute of Management and Public Administration (GIMPA)', 'Faculty of Law', 'Public'),
  Institution('Greenfield College', 'Faculty of Law', 'Private'),
  Institution('KAAF University College', 'Faculty of Law', 'Private'),
  Institution('Kings University College', 'Faculty of Law, Governance and International Relations', 'Private'),
  Institution('Kwame Nkrumah University of Science and Technology (KNUST)', 'Faculty of Law', 'Public'),
  Institution('Lancaster University Ghana', 'Faculty of Law', 'Private'),
  Institution('Mountcrest University', 'Faculty of Law', 'Private'),
  Institution('Pentecost University', 'Faculty of Law', 'Private'),
  Institution('Presbyterian University', 'Faculty of Law', 'Private'),
  Institution('University of Business and Integrated Development Studies (UBIDS)', 'Faculty of Law', 'Public'),
  Institution('University of Cape Coast (UCC)', 'Faculty of Law', 'Public'),
  Institution('University for Development Studies (UDS)', 'Faculty of Law', 'Public'),
  Institution('University of Ghana', 'School of Law', 'Public'),
  Institution('University of Professional Studies, Accra (UPSA)', 'School of Law', 'Public'),
  Institution('Wisconsin International University College, Ghana', 'Faculty of Law', 'Private'),
  Institution('Zenith University College, Ghana', 'Faculty of Law', 'Private'),
];

class Chamber {
  const Chamber({
    required this.id,
    required this.name,
    required this.physicalAddress,
    required this.postalAddress,
    required this.phone,
    required this.email,
    required this.website,
    required this.source,
  });
  final String id;
  final String name;
  final String physicalAddress;
  final String postalAddress;
  final String phone;
  final String email;
  final String website;
  final String source;
}

const chambers = <Chamber>[
  Chamber(
    id: 'chamber-nsiah-akuetteh',
    name: 'Nsiah Akuetteh & Co',
    physicalAddress: 'No.21 Samora Machel Rd, Asylum Down',
    postalAddress: 'P.O. Box LA 329, Asylum Down, Accra Ghana',
    phone: '+233 302 974972',
    email: 'admin@nsiahakuetteh.com',
    website: 'https://nsiahakuetteh.com/',
    source: 'User-supplied List of Chambers spreadsheet',
  ),
];

class PlanItem {
  const PlanItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.duration,
    required this.done,
  });

  final String id;

  /// "Read a case" | "Review legislation" | "Attempt a question" | "Review a topic"
  final String type;
  final String title;
  final String date;
  final String duration;
  final bool done;

  PlanItem copyWith({bool? done}) => PlanItem(
        id: id,
        type: type,
        title: title,
        date: date,
        duration: duration,
        done: done ?? this.done,
      );
}

final initialPlan = <PlanItem>[
  PlanItem(id: 'plan-1', type: 'Read a case', title: illustrativeCase.title, date: 'Today', duration: '25 min', done: false),
  PlanItem(id: 'plan-2', type: 'Review legislation', title: legislation[0].title, date: 'Today', duration: '20 min', done: false),
  const PlanItem(id: 'plan-3', type: 'Attempt a question', title: 'Frustration problem question', date: 'Tomorrow', duration: '35 min', done: false),
];

class DirectoryRecord {
  const DirectoryRecord(this.id, this.title, this.subtitle, this.detail);
  final String id;
  final String title;
  final String subtitle;
  final String detail;
}

final directoryRecords = <String, List<DirectoryRecord>>{
  'courts': const [
    DirectoryRecord('court-01', '[Verified court name required]', 'Supreme Court · [Location not supplied]', 'Contact and location details will appear after source verification.'),
    DirectoryRecord('court-02', '[Verified court name required]', 'High Court · [Location not supplied]', 'This illustrative entry does not claim an exhaustive directory.'),
  ],
  'judges': const [
    DirectoryRecord('judge-01', '[Verified judicial profile required]', 'Current role not supplied', 'Biography, appointment date, and reported case history require verified public sources.'),
  ],
  'firms': [
    DirectoryRecord(chambers[0].id, chambers[0].name, chambers[0].physicalAddress, 'Contact information is reproduced from the supplied chambers spreadsheet. Directory presence is informational and is not an endorsement.'),
  ],
};
