export type ContentLabel = "Primary source" | "Editorial brief" | "Study resource" | "External source";

export type ResearchItem = {
  id: string;
  kind: "Case" | "Legislation" | "Brief" | "Article" | "Course" | "Past question";
  title: string;
  reference: string;
  meta: string;
  excerpt: string;
  label: ContentLabel;
  topic: string;
};

export const illustrativeCase: ResearchItem = {
  id: "case-frustration-01",
  kind: "Case",
  title: "[Illustrative party] v [Illustrative party]",
  reference: "[Year] [Report] [Page]",
  meta: "Supreme Court · [Decision date] · Illustrative record",
  excerpt: "An illustrative judgment record used to demonstrate research, briefing, source review, and connected study workflows.",
  label: "Primary source",
  topic: "Frustration of contract",
};

export const legislation: ResearchItem[] = [
  { id: "act-contract-01", kind: "Legislation", title: "[Illustrative Act title]", reference: "Act [X] · [Year]", meta: "Act of Parliament · Status not verified", excerpt: "Illustrative legal-text record. Check the source and current status before relying on this text.", label: "Primary source", topic: "Contract" },
  { id: "bill-commerce-01", kind: "Legislation", title: "[Illustrative Bill title]", reference: "Bill · [Year]", meta: "Proposed legislation · Not enacted law", excerpt: "Illustrative Bill record presented separately from enacted legislation.", label: "Primary source", topic: "Commercial Law" },
  { id: "li-procedure-01", kind: "Legislation", title: "[Illustrative Legislative Instrument]", reference: "L.I. [X]", meta: "Legislative Instrument · Status not verified", excerpt: "Illustrative subsidiary-legislation record with unverified legal status.", label: "Primary source", topic: "Procedure" },
  { id: "ci-constitutional-01", kind: "Legislation", title: "[Illustrative Constitutional Instrument]", reference: "C.I. [X]", meta: "Constitutional Instrument · Status not verified", excerpt: "Illustrative constitutional-instrument record.", label: "Primary source", topic: "Constitutional Law" },
  { id: "ei-executive-01", kind: "Legislation", title: "[Illustrative Executive Instrument]", reference: "E.I. [X]", meta: "Executive Instrument · Status not verified", excerpt: "Illustrative executive-instrument record.", label: "Primary source", topic: "Public Law" },
];

export const researchItems: ResearchItem[] = [
  illustrativeCase,
  { id: "brief-frustration-01", kind: "Brief", title: `Case brief: ${illustrativeCase.title}`, reference: illustrativeCase.reference, meta: "Editorial explanation · Last reviewed [date]", excerpt: "A structured, illustrative brief covering facts, issues, holding, ratio, principles, and disposition.", label: "Editorial brief", topic: "Frustration of contract" },
  legislation[0],
  legislation[1],
  { id: "course-contract", kind: "Course", title: "Law of Contract", reference: "Course library", meta: "Study resource · Illustrative pathway", excerpt: "Learn, read authority, study the brief, practise, and review.", label: "Study resource", topic: "Contract" },
  { id: "question-frustration-01", kind: "Past question", title: "Illustrative problem question: frustration", reference: "[Category] · [Year not supplied]", meta: "Provenance not supplied · Practice demonstration", excerpt: "Apply the law of frustration to an unforeseen event affecting contractual performance.", label: "Study resource", topic: "Frustration of contract" },
];

export const courses = [
  { id: "contract", title: "Law of Contract", progress: 42, next: "Frustration of contract", topics: 8 },
  { id: "torts", title: "Torts", progress: 24, next: "Duty of care", topics: 7 },
  { id: "commercial", title: "Commercial Law", progress: 10, next: "Agency", topics: 9 },
  { id: "criminal", title: "Criminal Law", progress: 36, next: "Elements of an offence", topics: 10 },
  { id: "jurisprudence", title: "Jurisprudence", progress: 18, next: "Legal positivism", topics: 6 },
  { id: "banking", title: "Banking and Insurance", progress: 8, next: "Banker–customer relationship", topics: 8 },
  { id: "evidence", title: "Law of Evidence", progress: 31, next: "Relevance and admissibility", topics: 9 },
] as const;

export const accreditedInstitutions = [
  { name: "Accra Metropolitan University", school: "School of Law", sector: "Private" },
  { name: "Ashesi University", school: "Faculty of Humanities and Social Sciences", sector: "Private" },
  { name: "Central University", school: "Faculty of Law", sector: "Private" },
  { name: "Ghana Institute of Management and Public Administration (GIMPA)", school: "Faculty of Law", sector: "Public" },
  { name: "Greenfield College", school: "Faculty of Law", sector: "Private" },
  { name: "KAAF University College", school: "Faculty of Law", sector: "Private" },
  { name: "Kings University College", school: "Faculty of Law, Governance and International Relations", sector: "Private" },
  { name: "Kwame Nkrumah University of Science and Technology (KNUST)", school: "Faculty of Law", sector: "Public" },
  { name: "Lancaster University Ghana", school: "Faculty of Law", sector: "Private" },
  { name: "Mountcrest University", school: "Faculty of Law", sector: "Private" },
  { name: "Pentecost University", school: "Faculty of Law", sector: "Private" },
  { name: "Presbyterian University", school: "Faculty of Law", sector: "Private" },
  { name: "University of Business and Integrated Development Studies (UBIDS)", school: "Faculty of Law", sector: "Public" },
  { name: "University of Cape Coast (UCC)", school: "Faculty of Law", sector: "Public" },
  { name: "University for Development Studies (UDS)", school: "Faculty of Law", sector: "Public" },
  { name: "University of Ghana", school: "School of Law", sector: "Public" },
  { name: "University of Professional Studies, Accra (UPSA)", school: "School of Law", sector: "Public" },
  { name: "Wisconsin International University College, Ghana", school: "Faculty of Law", sector: "Private" },
  { name: "Zenith University College, Ghana", school: "Faculty of Law", sector: "Private" },
] as const;

export const chambers = [
  {
    id: "chamber-nsiah-akuetteh",
    name: "Nsiah Akuetteh & Co",
    physicalAddress: "No.21 Samora Machel Rd, Asylum Down",
    postalAddress: "P.O. Box LA 329, Asylum Down, Accra Ghana",
    phone: "+233 302 974972",
    email: "admin@nsiahakuetteh.com",
    website: "https://nsiahakuetteh.com/",
    source: "User-supplied List of Chambers spreadsheet",
  },
] as const;

export type PlanItem = {
  id: string;
  type: "Read a case" | "Review legislation" | "Attempt a question" | "Review a topic";
  title: string;
  date: string;
  duration: string;
  done: boolean;
};

export const initialPlan: PlanItem[] = [
  { id: "plan-1", type: "Read a case", title: illustrativeCase.title, date: "Today", duration: "25 min", done: false },
  { id: "plan-2", type: "Review legislation", title: legislation[0].title, date: "Today", duration: "20 min", done: false },
  { id: "plan-3", type: "Attempt a question", title: "Frustration problem question", date: "Tomorrow", duration: "35 min", done: false },
];

export const directoryRecords = {
  courts: [
    { id: "court-01", title: "[Verified court name required]", subtitle: "Supreme Court · [Location not supplied]", detail: "Contact and location details will appear after source verification." },
    { id: "court-02", title: "[Verified court name required]", subtitle: "High Court · [Location not supplied]", detail: "This illustrative entry does not claim an exhaustive directory." },
  ],
  judges: [
    { id: "judge-01", title: "[Verified judicial profile required]", subtitle: "Current role not supplied", detail: "Biography, appointment date, and reported case history require verified public sources." },
  ],
  firms: [
    { id: chambers[0].id, title: chambers[0].name, subtitle: chambers[0].physicalAddress, detail: "Contact information is reproduced from the supplied chambers spreadsheet. Directory presence is informational and is not an endorsement." },
  ],
};
