import { FormEvent, KeyboardEvent, useEffect, useState } from "react";
import {
  ArrowRight,
  BookOpen,
  Building2,
  Check,
  ChevronDown,
  Clock3,
  FileCheck2,
  FileText,
  FolderLock,
  Gavel,
  GraduationCap,
  Library,
  Link2,
  LockKeyhole,
  Mail,
  MapPin,
  Menu,
  MessageSquareText,
  Play,
  Quote,
  Scale,
  Search,
  ShieldCheck,
  Sparkles,
  Users,
  X,
} from "lucide-react";

const navItems = ["Library", "Study", "Courts & Judges", "Ask MMRA", "Pricing", "Blog"];
const libraryItems = ["Acts and Bills", "Instruments", "Case Bank", "Past Questions", "Resources", "Law Firms"];

const personas = {
  Student: {
    title: "Read the cases that matter, then be tested on them.",
    bullets: ["Course paths and case briefs", "Past questions by institution", "Progress that stays with you"],
    label: "Contract · Offer and acceptance",
    progress: "7 of 12 cases",
  },
  "Pupil / Junior": {
    title: "Prepare for Pre-Bar and Legal Practice Training with a plan.",
    bullets: ["Timed mocks", "Issue-spotting outlines", "Weak-topic radar"],
    label: "Pre-Bar preparation",
    progress: "Next: timed practice",
  },
  Practitioner: {
    title: "Find the authority and the right court, fast.",
    bullets: ["Consolidated Acts", "Still Good Law signal", "Courts Finder and Bench Record"],
    label: "Authority check",
    progress: "3 connected decisions",
  },
  Chambers: {
    title: "One subscription for the whole team.",
    bullets: ["Team seats", "Shared research folders", "Bill and Act Watch"],
    label: "Chambers workspace",
    progress: "Shared folder · Sample",
  },
  Faculty: {
    title: "Set reading lists and track cohorts.",
    bullets: ["Course reading lists", "Cohort progress", "Per-institution past questions"],
    label: "Faculty overview",
    progress: "Cohort progress · Sample",
  },
};

const libraryCards = [
  { icon: FileText, title: "Acts and Bills.", copy: "Acts as amended, with a date picker and Bills tracked through Parliament.", detail: "First reading → Committee → Passed → Assent", wide: true },
  { icon: Library, title: "Instruments.", copy: "Constitutional, Legislative and Executive Instruments, Gazette notices and court rules.", detail: "C.I. · L.I. · E.I. · Gazette · Rules" },
  { icon: Scale, title: "The Constitution.", copy: "The 1992 Constitution by article, linked to cases that interpret it.", detail: "Article [X] → [X] decisions" },
  { icon: BookOpen, title: "Case Bank.", copy: "By topic or course, with concise case briefs and articles.", detail: "Facts · Issues · Holding · Ratio", wide: true },
  { icon: GraduationCap, title: "Past Questions.", copy: "By course, Pre-Bar and Legal Practice Training, filtered by institution.", detail: "[University] · [Institution]" },
  { icon: FolderLock, title: "Resources.", copy: "Articles, books, slides and trusted websites, curated and reviewed.", detail: "Last reviewed [date]" },
  { icon: Building2, title: "Courts.", copy: "Supreme Court to District Courts, with contacts and map location.", detail: "Supreme → Appeal → High → Circuit → District" },
  { icon: Gavel, title: "Judges.", copy: "Profiles with bar date, bench date, current court and linked decisions.", detail: "[Judge name] · [Current court]" },
  { icon: Users, title: "Law Firms.", copy: "Find chambers and see who is open to pupils.", detail: "Open to pupils · [Location]" },
];

const courses = [
  ["Law of Contract", 68],
  ["Torts", 52],
  ["Commercial Law", 44],
  ["Criminal Law", 76],
  ["Jurisprudence", 38],
  ["Banking & Insurance", 61],
  ["Law of Evidence", 57],
] as const;

const faqs = [
  ["What happens after the 3 free months?", "You choose Monthly or Yearly. We will remind you before it ends."],
  ["Do I need a card to start?", "No."],
  ["How can I pay?", "By MoMo or card."],
  ["Can I download or copy content?", "No. Content is for in-platform reading and is watermarked."],
  ["Where do your cases and Acts come from?", "From official and licensed sources. Source and review details are shown in the library."],
  ["Is Ask MMRA legal advice?", "No. It is a research aid with citations."],
  ["Which courts and judges are listed?", "All five tiers; information is reviewed and dated."],
  ["Can my chambers or faculty join together?", "Yes, contact us for a chambers, team or campus plan."],
  ["How do I report an error or correction?", "Use the correction link on the relevant record or contact the editorial team."],
];

type ButtonProps = {
  children: React.ReactNode;
  variant?: "primary" | "secondary" | "ghost";
  href?: string;
  onClick?: () => void;
  className?: string;
  type?: "button" | "submit";
};

function Button({ children, variant = "primary", href, onClick, className = "", type = "button" }: ButtonProps) {
  const classes = `button button-${variant} ${className}`;
  if (href) return <a className={classes} href={href}>{children}</a>;
  return <button className={classes} onClick={onClick} type={type}>{children}</button>;
}

function Eyebrow({ children }: { children: React.ReactNode }) {
  return <span className="eyebrow"><span className="eyebrow-dot" />{children}</span>;
}

function SectionHeading({ eyebrow, title, copy }: { eyebrow?: string; title: string; copy?: string }) {
  return <div className="section-heading reveal">
    {eyebrow && <Eyebrow>{eyebrow}</Eyebrow>}
    <h2>{title}</h2>
    {copy && <p>{copy}</p>}
  </div>;
}

function SampleTag() {
  return <span className="sample-tag">Sample</span>;
}

function StatusBadge({ type }: { type: string }) {
  return <span className={`status status-${type.toLowerCase()}`}>{type}</span>;
}

function AppNav() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [megaOpen, setMegaOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 80);
    onScroll();
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return <>
    <div className="announcement">Free for your first 3 months. No card needed. <a href="#final-cta">Start free <ArrowRight size={14} /></a></div>
    <header className={`nav-wrap ${scrolled ? "is-scrolled" : ""}`}>
      <nav className="nav container" aria-label="Primary navigation">
        <a className="brand" href="#" aria-label="MMRA home">
          <span className="brand-mark"><img src="/mmra-logo.png" alt="" /></span>
          <span>MMRA</span>
        </a>
        <div className="nav-links">
          {navItems.map((item) => item === "Library" ? (
            <div className="mega-parent" key={item}>
              <button aria-expanded={megaOpen} onClick={() => setMegaOpen(!megaOpen)}>Library <ChevronDown size={14} /></button>
              {megaOpen && <div className="mega-menu">
                <span className="mega-kicker">The MMRA Library</span>
                {libraryItems.map((entry) => <a href="#library" key={entry} onClick={() => setMegaOpen(false)}>{entry}<ArrowRight size={14} /></a>)}
              </div>}
            </div>
          ) : <a href={`#${item.toLowerCase().replaceAll(" ", "-").replace("&", "and")}`} key={item}>{item}</a>)}
        </div>
        <div className="nav-actions">
          <Button variant="ghost" href="#footer">Log in</Button>
          <Button href="#final-cta">Start free</Button>
        </div>
        <div className="mobile-actions">
          <a href="#final-cta" className="mobile-cta">Start free</a>
          <button className="icon-button" onClick={() => setMobileOpen(true)} aria-label="Open menu"><Menu /></button>
        </div>
      </nav>
    </header>
    <div className={`mobile-menu ${mobileOpen ? "open" : ""}`} aria-hidden={!mobileOpen}>
      <div className="mobile-menu-head"><span className="brand">MMRA</span><button className="icon-button" onClick={() => setMobileOpen(false)} aria-label="Close menu"><X /></button></div>
      <div className="mobile-menu-links">
        {navItems.map((item) => <a key={item} href={`#${item.toLowerCase().replaceAll(" ", "-").replace("&", "and")}`} onClick={() => setMobileOpen(false)}>{item}<ArrowRight /></a>)}
      </div>
      <p>Ghana&apos;s law, courts, judges and study path, in one place.</p>
    </div>
  </>;
}

function SearchDemo() {
  const phrase = "frustration of contract";
  const [query, setQuery] = useState("");
  const [tab, setTab] = useState("Cases");

  useEffect(() => {
    let index = 0;
    let direction = 1;
    const timer = window.setInterval(() => {
      index += direction;
      if (index >= phrase.length + 8) direction = -1;
      if (index <= 0) direction = 1;
      setQuery(phrase.slice(0, Math.min(index, phrase.length)));
    }, 110);
    return () => window.clearInterval(timer);
  }, []);

  return <div className="search-demo glass-card reveal">
    <div className="demo-top"><div><SampleTag /><span className="demo-title">Search the library</span></div><LockKeyhole size={16} /></div>
    <div className="search-input"><Search size={19} /><span>{query}</span><i /></div>
    <div className="tab-row" role="tablist" aria-label="Search result type">
      {["Cases", "Acts", "Past questions"].map((item) => <button role="tab" aria-selected={tab === item} className={tab === item ? "active" : ""} onClick={() => setTab(item)} key={item}>{item}</button>)}
    </div>
    <div className="result-list">
      {["[Case name] v [Case name]", "[Case name] v The Republic", "[Case name] v [Institution]"].map((name, index) => (
        <div className="result-row" key={name + index}>
          <div><h3>{tab === "Cases" ? name : tab === "Acts" ? `[Act name] · Section [${index + 1}]` : `[Institution] · [Year]`}</h3><span className="citation">[Year] [Report] [Page]</span></div>
          <div className="result-meta"><span className="court-chip">Supreme Court</span><StatusBadge type={index === 1 ? "Applied" : "Followed"} /></div>
          <button className="text-link">Read more <ArrowRight size={14} /></button>
        </div>
      ))}
    </div>
    <div className="watermark">Registered to you</div>
  </div>;
}

function Hero() {
  return <main>
    <section className="hero" id="top">
      <div className="pattern" />
      <div className="hero-glow" />
      <div className="container hero-grid">
        <div className="hero-copy reveal">
          <Eyebrow>Built for Ghanaian law</Eyebrow>
          <h1>Ghana&apos;s law. Courts. Judges. <em>Study path.</em> One place.</h1>
          <p>Search statutes and cases, find the right court and judge, and study with a plan that tracks every case you read. Made for law students, pupils and practitioners.</p>
          <div className="hero-actions"><Button href="#final-cta">Start free for 3 months <ArrowRight size={18} /></Button><Button variant="secondary" href="#pricing">See pricing</Button></div>
          <div className="no-card"><ShieldCheck size={15} /> No card needed. Pay later by MoMo or card.</div>
        </div>
        <SearchDemo />
      </div>
      <div className="hero-index">01 <span /> MMRA / GHANA</div>
    </section>
  </main>;
}

function TrustStrip() {
  return <section className="trust-section">
    <div className="container">
      <div className="trust-title">Designed for how Ghana studies and practises law</div>
      <div className="logo-placeholders">{[1,2,3,4].map((x) => <div key={x}>[Partner logo]</div>)}</div>
      <div className="segment-chips">{["Law students", "Pupils", "Practitioners", "Chambers", "Faculties"].map((x) => <span key={x}>{x}</span>)}</div>
      <div className="proof-stats">
        {["[X] cases", "[X] Acts and instruments", "[X] courts", "[X] judges"].map((x) => <div key={x}><strong>{x}</strong><small>to be confirmed</small></div>)}
      </div>
    </div>
  </section>;
}

function Personas() {
  const [active, setActive] = useState<keyof typeof personas>("Student");
  const data = personas[active];
  return <section className="section" id="who-its-for">
    <div className="container">
      <SectionHeading eyebrow="Built around your next step" title="One library. Different ways in." copy="From your first case brief to a chambers research note, MMRA meets you where you are." />
      <div className="persona-tabs tab-row" role="tablist">{Object.keys(personas).map((item) => <button role="tab" aria-selected={item === active} className={item === active ? "active" : ""} onClick={() => setActive(item as keyof typeof personas)} key={item}>{item}</button>)}</div>
      <div className="persona-panel reveal">
        <div><span className="number-label">0{Object.keys(personas).indexOf(active) + 1}</span><h3>{data.title}</h3><ul>{data.bullets.map((item) => <li key={item}><Check />{item}</li>)}</ul></div>
        <div className="mini-product">
          <div className="mini-product-head"><SampleTag /><span>{active} view</span></div>
          <BookOpen />
          <strong>{data.label}</strong><p>{data.progress}</p>
          <div className="progress-line"><span /></div>
        </div>
      </div>
    </div>
  </section>;
}

function AuthorityTrail() {
  const [active, setActive] = useState(0);
  const cases = ["Followed", "Distinguished", "Overruled"];
  return <section className="section section-alt" id="authority-trail">
    <div className="container">
      <SectionHeading eyebrow="Everything connects" title="Start with one section. Follow the whole trail." copy="Open an Act and see the cases that interpreted it, the course that teaches it and the past questions that tested it." />
      <div className="trail" data-active={active}>
        <div className="trail-col"><span className="column-label">01 / STATUTE</span><button className="trail-card statute-card"><FileText /><small>Section [X]</small><strong>[Act name]</strong><span>As at [date]</span></button></div>
        <div className="trail-lines" aria-hidden="true"><i /><i /><i /></div>
        <div className="trail-col"><span className="column-label">02 / AUTHORITIES</span>{cases.map((item, index) => <button className={`trail-card ${active === index ? "selected" : ""}`} key={item} onClick={() => setActive(index)}><span className="citation">[Year] [Report] [Page]</span><strong>[Case name] v [Case name]</strong><StatusBadge type={item} /></button>)}</div>
        <div className="trail-lines right" aria-hidden="true"><i /><i /></div>
        <div className="trail-col"><span className="column-label">03 / STUDY</span><button className={`trail-card destination ${active !== 2 ? "selected" : ""}`} onClick={() => setActive(0)}><GraduationCap /><small>Course</small><strong>Law of Contract</strong><span>Chapter [X]</span></button><button className={`trail-card destination ${active === 2 ? "selected" : ""}`} onClick={() => setActive(2)}><Quote /><small>Past question</small><strong>[Institution] · [Year]</strong><span>View linked authorities</span></button></div>
      </div>
      <p className="interaction-hint"><Sparkles size={15} /> Select an authority to trace its connections.</p>
    </div>
  </section>;
}

function LibrarySection() {
  return <section className="section" id="library">
    <div className="container">
      <SectionHeading eyebrow="The library" title="Every source of Ghanaian law, organised the way you think." />
      <div className="bento">{libraryCards.map(({icon: Icon, title, copy, detail, wide}) => <article className={`bento-card ${wide ? "wide" : ""}`} key={title}><div className="card-icon"><Icon /></div><span className="number-label">0{libraryCards.findIndex(x => x.title === title)+1}</span><h3>{title}</h3><p>{copy}</p><div className="mini-detail">{detail}</div></article>)}</div>
      <a className="section-link" href="#top">Explore the full library <ArrowRight /></a>
    </div>
  </section>;
}

function Study() {
  const [mode, setMode] = useState("Read");
  return <section className="section section-alt" id="study">
    <div className="container study-grid">
      <div>
        <SectionHeading eyebrow="Your study path" title="A dashboard that knows what you have read and what is left." />
        <ul className="check-list">{["Reading progress per course and topic", "Cases read and remaining, ordered by importance", "Exam countdown with a daily plan", "Weak-topic radar from past-question results", "Notes, highlights and saved folders", "Read, Watch or Visualise every topic"].map((x) => <li key={x}><Check />{x}</li>)}</ul>
      </div>
      <div className="dashboard-preview reveal">
        <div className="preview-head"><div><SampleTag /><strong>Good evening, [Name]</strong></div><span>Study overview</span></div>
        <div className="mode-toggle">{["Read", "Watch", "Visualise"].map(x => <button className={mode === x ? "active" : ""} onClick={() => setMode(x)} key={x}>{x}</button>)}</div>
        <div className="continue-card">
          {mode === "Read" && <BookOpen />}
          {mode === "Watch" && <span className="play-icon"><Play /></span>}
          {mode === "Visualise" && <div className="flow-mini"><i /><i /><i /></div>}
          <div><small>CONTINUE {mode.toUpperCase()}</small><h3>Frustration of contract</h3><p>{mode === "Read" ? "Case brief · 8 min" : mode === "Watch" ? "Explainer · 12 min" : "Formation flow · 6 steps"}</p></div>
          <ArrowRight />
        </div>
        <div className="course-rings">{courses.map(([name, progress]) => <div className="course-ring" key={name}><span style={{"--progress": progress} as React.CSSProperties}>{progress}%</span><small>{name}</small></div>)}</div>
        <div className="dashboard-bottom"><div><small>CASES READ / REMAINING</small><strong>[X] / [X]</strong><div className="progress-line"><span /></div></div><div className="countdown"><Clock3 /><small>EXAM COUNTDOWN</small><strong>[X] days</strong></div><div className="streak"><strong>[X]</strong><small>week streak</small></div></div>
      </div>
    </div>
  </section>;
}

function ExamMode() {
  const [open, setOpen] = useState(false);
  return <section className="section" id="exam-mode">
    <div className="container">
      <SectionHeading eyebrow="Exam mode" title="Practise the way you will be marked." copy="Move from a problem question to a structured answer, with the authorities beside you." />
      <div className="exam-flow reveal">
        <article><span>01</span><small>PAST QUESTION</small><h3>A contract is discharged after an unforeseen event…</h3><p>Identify the issues and advise the parties.</p></article>
        <ArrowRight className="flow-arrow" />
        <article><span>02</span><small>ISSUE SPOTTING</small><ul><li>Formation</li><li>Supervening event</li><li>Allocation of risk</li></ul></article>
        <ArrowRight className="flow-arrow" />
        <article><span>03</span><small>IRAC BUILDER</small><div className="irac-grid">{["I", "R", "A", "C"].map(x => <b key={x}>{x}</b>)}</div><p>Build your answer in marked steps.</p></article>
        <div className="authority-dock"><Link2 /><span>Linked authorities</span><span className="citation">[Year] [Report] [Page]</span><span className="citation">Section [X]</span></div>
      </div>
      <div className="feature-pills"><span>Timed Pre-Bar mocks</span><span>Legal Practice Training drills</span><span>Citation Builder (OSCOLA)</span></div>
      <div className="center-action"><Button variant="secondary" onClick={() => setOpen(true)}>Try a sample question <ArrowRight /></Button></div>
      {open && <div className="modal-backdrop" role="presentation" onMouseDown={() => setOpen(false)}><div className="modal" role="dialog" aria-modal="true" aria-labelledby="sample-title" onMouseDown={e => e.stopPropagation()}><button className="modal-close" onClick={() => setOpen(false)} aria-label="Close sample question"><X /></button><SampleTag /><h3 id="sample-title">Problem question</h3><p>A supplier agrees to deliver goods for a public event. The event is cancelled after an unforeseen order. Advise the parties on frustration and any available remedies.</p><div className="modal-note">This is sample content for demonstration only.</div></div></div>}
    </div>
  </section>;
}

function CourtsJudges() {
  const tiers = ["Supreme", "Appeal", "High", "Circuit", "District"];
  const [tier, setTier] = useState("Supreme");
  const [flipped, setFlipped] = useState(false);
  const flipKeys = (event: KeyboardEvent<HTMLDivElement>) => {
    if (event.key === "Enter" || event.key === " ") { event.preventDefault(); setFlipped(!flipped); }
  };
  return <section className="section section-alt" id="courts-and-judges">
    <div className="container">
      <SectionHeading eyebrow="Courts & judges" title="Know the court. Know the bench." />
      <div className="courts-grid">
        <div className="finder-card">
          <div className="card-header"><div><MapPin /><strong>Courts Finder</strong></div><SampleTag /></div>
          <div className="tier-tabs">{tiers.map(x => <button className={tier === x ? "active" : ""} onClick={() => setTier(x)} key={x}>{x}</button>)}</div>
          <div className="ghana-map" aria-label="Stylised map of Ghana with court locations">
            <svg viewBox="0 0 250 330" role="img"><path d="M82 15 L163 25 L178 75 L215 112 L194 174 L184 246 L151 312 L92 293 L57 230 L34 160 L52 97 Z" /><circle cx="145" cy="264" r="5"/><circle cx="104" cy="188" r="5"/><circle cx="152" cy="102" r="5"/><path className="map-route" d="M145 264 Q80 220 104 188 T152 102"/></svg>
            <span className="map-region">GHANA · {tier.toUpperCase()} TIER</span>
          </div>
          <div className="court-result"><span className="court-chip">{tier} Court</span><h3>[Court name]</h3><p><MapPin /> [Address], [Region]</p><div><span>[website]</span><span>[email]</span><span>[phone]</span></div></div>
        </div>
        <div>
          <div className="tier-tabs judge-tabs">{tiers.map(x => <button className={tier === x ? "active" : ""} onClick={() => setTier(x)} key={x}>{x}</button>)}</div>
          <div className={`judge-flip ${flipped ? "flipped" : ""}`} role="button" tabIndex={0} aria-label="Flip judge card to view bench record" aria-pressed={flipped} onClick={() => setFlipped(!flipped)} onKeyDown={flipKeys}>
            <div className="judge-face front">
              <div className="silhouette"><div /><span /></div>
              <small>{tier.toUpperCase()} COURT</small><h3>[Judge name]</h3><p>Current court · [{tier} Court]</p>
              <span className="flip-hint">Select to view Bench Record <ArrowRight /></span>
            </div>
            <div className="judge-face back">
              <small>BENCH RECORD</small><h3>[Judge name]</h3>
              <dl><div><dt>Bar date</dt><dd>[Date]</dd></div><div><dt>Bench date</dt><dd>[Date]</dd></div><div><dt>Current court</dt><dd>[Court]</dd></div><div><dt>Case history</dt><dd>[X] decisions</dd></div></dl>
              <p>Profile drawn from public records.</p><span className="flip-hint">Return to profile <ArrowRight /></span>
            </div>
          </div>
          <div className="review-row"><span>Last reviewed [date]</span><a href="#footer">Suggest a correction</a></div>
        </div>
      </div>
    </div>
  </section>;
}

function AskMmra() {
  const [citation, setCitation] = useState(1);
  return <section className="section" id="ask-mmra">
    <div className="container ask-grid">
      <div><SectionHeading eyebrow="Cited answers" title="Ask a legal question. Get an answer you can verify." copy="Ask MMRA answers only from the MMRA library and shows its sources. If there is no authority, it says so." /><div className="notice"><ShieldCheck />Research aid, not legal advice.</div></div>
      <div className="chat-demo reveal">
        <div className="chat-top"><MessageSquareText /><strong>Ask MMRA</strong><SampleTag /></div>
        <div className="question-bubble">What is required to establish frustration of contract?</div>
        <div className="answer-bubble"><Sparkles /><div><p>Frustration may arise where a supervening event, without fault of either party, makes performance impossible or radically different from what was agreed.</p><div className="citations">{[1,2,3].map(x => <button className={citation === x ? "active" : ""} onClick={() => setCitation(x)} key={x}>[{x}]</button>)}</div><div className="passage"><span className="citation">[Year] [Report] [Page] · passage {citation}</span><p>“[Exact cited passage from the authority appears here.]”</p></div></div></div>
        <div className="no-authority"><FileCheck2 /><div><strong>No authority found</strong><p>MMRA will say when the library does not support an answer.</p></div></div>
      </div>
    </div>
  </section>;
}

function Protected() {
  const items = [[LockKeyhole,"Registered-user access only"],[ShieldCheck,"Watermarked to you"],[FolderLock,"No downloads or copying"],[FileCheck2,"Editor reviewed and dated"]];
  return <section className="protected-strip"><div className="container"><SectionHeading eyebrow="Protected reading" title="Built to respect the work behind the law." /><div className="protected-items">{items.map(([Icon,label]) => { const I = Icon as typeof LockKeyhole; return <div key={label as string}><I /><span>{label as string}</span><small>Last reviewed [date]</small></div>})}</div></div></section>;
}

function Pricing() {
  const [yearly, setYearly] = useState(true);
  return <section className="section" id="pricing">
    <div className="container">
      <SectionHeading eyebrow="Pricing" title="Start free. Stay for the way it works." copy="One library, every core feature. Choose how you pay after your free period." />
      <div className="pricing-toggle"><button className={!yearly ? "active" : ""} onClick={() => setYearly(false)}>Monthly</button><button className={yearly ? "active" : ""} onClick={() => setYearly(true)}>Yearly <span>Best value</span></button></div>
      <div className="pricing-cards">
        <article className="pricing-card"><small>FREE</small><h3>3 months.</h3><div className="price">GH₵ 0</div><p>Full access to try MMRA. No card needed.</p><Button variant="secondary" href="#final-cta">Start free</Button></article>
        <article className="pricing-card"><small>{yearly ? "YEARLY EQUIVALENT" : "MONTHLY"}</small><h3>Monthly.</h3><div className="price">GH₵ [X] <span>/ month</span></div><p>Flexible. Cancel any time.</p><Button variant="secondary" href="#final-cta">Choose Monthly</Button></article>
        <article className="pricing-card featured"><span className="best">BEST VALUE</span><small>YEARLY</small><h3>Yearly.</h3><div className="price">GH₵ [X] <span>/ year</span></div><p>Save [X]%. One payment, full access.</p><Button href="#final-cta">Choose Yearly</Button></article>
      </div>
      <div className="payments"><span>Pay with</span>{["MTN MoMo","Telecel Cash","AT Money","Visa","Mastercard"].map(x => <i key={x}>{x}</i>)}</div>
      <div className="included"><strong>Every plan includes</strong>{["Library","Case Bank","Past Questions","Courts and Judges","Ask MMRA","Study dashboard","Notes and folders"].map(x => <span key={x}><Check />{x}</span>)}</div>
      <div className="team-cards"><article><Users /><div><h3>Chambers and teams</h3><p>Shared access for your whole team.</p></div><a href="mailto:[email]">Contact us <ArrowRight /></a></article><article><GraduationCap /><div><h3>Campus plans</h3><p>Access for faculties and cohorts.</p></div><a href="mailto:[email]">Contact us <ArrowRight /></a></article></div>
    </div>
  </section>;
}

function FAQ() {
  const [open, setOpen] = useState(0);
  return <section className="section section-alt" id="faq"><div className="container faq-grid"><SectionHeading eyebrow="Questions, answered" title="Before you start." /><div className="accordion">{faqs.map(([q,a], index) => <div className={`accordion-item ${open === index ? "open" : ""}`} key={q}><button aria-expanded={open === index} onClick={() => setOpen(open === index ? -1 : index)}><span>{String(index+1).padStart(2,"0")}</span>{q}<ChevronDown /></button><div className="accordion-answer"><p>{a}</p></div></div>)}</div></div></section>;
}

function FinalCta() {
  const [sent, setSent] = useState(false);
  const submit = (e: FormEvent) => { e.preventDefault(); setSent(true); };
  return <section className="final-cta" id="final-cta"><div className="pattern" /><div className="final-glow" /><div className="container"><Eyebrow>Three months free</Eyebrow><h2>Your next case starts here.</h2><p>Join MMRA free for 3 months.</p><form onSubmit={submit}>{sent ? <div className="success-message"><Check /> You&apos;re on the list. We&apos;ll be in touch.</div> : <><label className="sr-only" htmlFor="email">Email address</label><div className="email-input"><Mail /><input id="email" type="email" required placeholder="Your email address" /><Button type="submit">Start free <ArrowRight /></Button></div></>}<small>No card needed.</small></form></div></section>;
}

function Footer() {
  const cols = [
    ["Library","Acts and Bills","Case Bank","Past Questions","Resources"],
    ["Study","Study paths","Exam Mode","Course guides","Citation Builder"],
    ["Courts and Judges","Courts Finder","Judge profiles","Law Firms","Corrections"],
    ["Company","About","Contact","Careers","Blog"],
    ["Legal","Terms","Privacy","Data protection","Content and takedown"],
  ];
  return <footer id="footer"><div className="container"><div className="footer-top"><div className="footer-brand"><a className="brand" href="#"><span className="brand-mark"><img src="/mmra-logo.png" alt="" /></span><span>MMRA</span></a><p>Ghana&apos;s law, courts, judges and study path, in one protected workspace.</p><div className="contact"><span>[email]</span><span>[phone]</span><span>[address]</span></div></div><div className="footer-cols">{cols.map(([title,...items]) => <div key={title}><strong>{title}</strong>{items.map(x => <a href="#" key={x}>{x}</a>)}</div>)}</div></div><div className="footer-bottom"><p>MMRA is a research and study aid and does not provide legal advice.</p><span>© [Year] MMRA</span></div></div></footer>;
}

export default function App() {
  const [showMobileCta, setShowMobileCta] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(entries => entries.forEach(entry => entry.isIntersecting && entry.target.classList.add("visible")), { threshold: 0.08 });
    document.querySelectorAll(".reveal").forEach(el => observer.observe(el));
    const updateMobileCta = () => setShowMobileCta(window.scrollY > Math.min(window.innerHeight * 0.8, 700));
    updateMobileCta();
    window.addEventListener("scroll", updateMobileCta, { passive: true });
    return () => {
      observer.disconnect();
      window.removeEventListener("scroll", updateMobileCta);
    };
  }, []);

  return <div className="app">
    <AppNav />
    <Hero />
    <TrustStrip />
    <Personas />
    <AuthorityTrail />
    <LibrarySection />
    <Study />
    <ExamMode />
    <CourtsJudges />
    <AskMmra />
    <Protected />
    <Pricing />
    <FAQ />
    <FinalCta />
    <Footer />
    <a className={`mobile-sticky ${showMobileCta ? "show" : ""}`} href="#final-cta">Start free for 3 months <ArrowRight /></a>
  </div>;
}
