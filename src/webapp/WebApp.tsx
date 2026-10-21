import {
  createContext,
  FormEvent,
  ReactNode,
  useContext,
  useMemo,
  useState,
} from "react";
import {
  AlertCircle,
  ArrowLeft,
  ArrowRight,
  Bell,
  Bookmark,
  BookmarkCheck,
  BookOpen,
  Building2,
  CalendarDays,
  Check,
  ChevronDown,
  ChevronRight,
  CircleHelp,
  Clock3,
  FileCheck2,
  FileQuestion,
  FileText,
  Filter,
  FolderOpen,
  GraduationCap,
  Gavel,
  History,
  Home,
  LayoutList,
  Library,
  LockKeyhole,
  Mail,
  Menu,
  MessageSquareWarning,
  MoreHorizontal,
  KeyRound,
  Plus,
  RefreshCw,
  Scale,
  Search,
  Settings,
  ShieldCheck,
  Sparkles,
  UserRound,
  Users,
  X,
} from "lucide-react";
import {
  Form,
  Link,
  NavLink,
  Outlet,
  useLocation,
  useNavigate,
  useParams,
  useSearchParams,
} from "react-router";
import {
  accreditedInstitutions,
  chambers,
  courses,
  directoryRecords,
  illustrativeCase,
  initialPlan,
  legislation,
  PlanItem,
  researchItems,
  ResearchItem,
} from "./data";

type AppContextValue = {
  saved: string[];
  toggleSaved: (id: string, title: string) => void;
  plan: PlanItem[];
  addPlan: (item: Omit<PlanItem, "id" | "done">) => void;
  togglePlan: (id: string) => void;
  toast: string;
  showToast: (message: string) => void;
  completedPractice: boolean;
  setCompletedPractice: (value: boolean) => void;
};

const AppContext = createContext<AppContextValue | null>(null);

function useApp() {
  const value = useContext(AppContext);
  if (!value) throw new Error("useApp must be used within AppStateProvider");
  return value;
}

export function AppStateProvider() {
  const [saved, setSaved] = useState<string[]>([]);
  const [plan, setPlan] = useState<PlanItem[]>(initialPlan);
  const [toast, setToast] = useState("");
  const [completedPractice, setCompletedPractice] = useState(false);

  const showToast = (message: string) => {
    setToast(message);
    window.setTimeout(() => setToast(""), 2600);
  };
  const toggleSaved = (id: string, title: string) => {
    setSaved((current) => {
      const removing = current.includes(id);
      showToast(removing ? `Removed “${title}” from your reading list.` : `Saved “${title}” to your reading list.`);
      return removing ? current.filter((item) => item !== id) : [...current, id];
    });
  };
  const addPlan = (item: Omit<PlanItem, "id" | "done">) => {
    setPlan((current) => [...current, { ...item, id: `plan-${Date.now()}`, done: false }]);
    showToast("Study session added. This prototype stores changes only for this visit.");
  };
  const togglePlan = (id: string) => {
    setPlan((current) => current.map((item) => item.id === id ? { ...item, done: !item.done } : item));
    showToast("Study plan updated.");
  };

  return (
    <AppContext.Provider value={{ saved, toggleSaved, plan, addPlan, togglePlan, toast, showToast, completedPractice, setCompletedPractice }}>
      <Outlet />
      {toast && <div className="wa-toast" role="status"><Check />{toast}</div>}
    </AppContext.Provider>
  );
}

const primaryNav = [
  { to: "/app", label: "Overview", icon: Home, end: true },
  { to: "/app/search", label: "Global search", icon: Search },
];

const navGroups = [
  {
    label: "Legal research",
    icon: Scale,
    links: [
      ["/app/cases", "Cases & judgments"],
      ["/app/briefs", "Case briefs"],
      ["/app/resources", "Articles & commentary"],
    ],
  },
  {
    label: "Ghana legal library",
    icon: Library,
    links: [
      ["/app/library", "Constitution & Acts"],
      ["/app/library?type=Bills", "Bills"],
      ["/app/library?type=Instruments", "L.I. · C.I. · E.I."],
    ],
  },
  {
    label: "Courses & study",
    icon: GraduationCap,
    links: [
      ["/app/courses", "My courses"],
      ["/app/practice", "Past questions"],
      ["/app/planner", "Study planner"],
    ],
  },
  {
    label: "Directories",
    icon: Building2,
    links: [
      ["/app/directory/courts", "Courts"],
      ["/app/directory/judges", "Judicial profiles"],
      ["/app/directory/firms", "Law firms"],
    ],
  },
];

function Brand() {
  return <Link to="/" className="wa-brand" aria-label="MMRA landing page"><span><img src="/mmra-logo.png" alt="" /></span><b>MMRA</b></Link>;
}

function GlobalSearch({ compact = false }: { compact?: boolean }) {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const submit = (event: FormEvent) => {
    event.preventDefault();
    navigate(`/app/search?q=${encodeURIComponent(query)}`);
  };
  return (
    <form className={`wa-global-search ${compact ? "compact" : ""}`} onSubmit={submit} role="search">
      <Search aria-hidden="true" />
      <label className="sr-only" htmlFor={compact ? "mobile-global-search" : "global-search"}>Search MMRA</label>
      <input id={compact ? "mobile-global-search" : "global-search"} value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search cases, legislation, topics, or resources" />
      {!compact && <kbd>⌘ K</kbd>}
    </form>
  );
}

function Sidebar({ open, close }: { open: boolean; close: () => void }) {
  const [expanded, setExpanded] = useState<string[]>(["Legal research"]);
  const toggle = (label: string) => setExpanded((current) => current.includes(label) ? current.filter((item) => item !== label) : [...current, label]);
  return (
    <>
      {open && <button className="wa-drawer-backdrop" aria-label="Close navigation" onClick={close} />}
      <aside className={`wa-sidebar ${open ? "open" : ""}`}>
        <div className="wa-sidebar-head"><Brand /><button className="wa-icon-button wa-mobile-only" onClick={close} aria-label="Close navigation"><X /></button></div>
        <nav aria-label="Application navigation">
          <div className="wa-nav-main">
            {primaryNav.map(({ to, label, icon: Icon, end }) => <NavLink end={end} to={to} onClick={close} key={to}><Icon />{label}</NavLink>)}
          </div>
          {navGroups.map(({ label, icon: Icon, links }) => {
            const isOpen = expanded.includes(label);
            return <div className="wa-nav-group" key={label}>
              <button onClick={() => toggle(label)} aria-expanded={isOpen}><Icon /><span>{label}</span><ChevronDown /></button>
              {isOpen && <div className="wa-nav-sub">{links.map(([to, text]) => <NavLink to={to} onClick={close} key={to}>{text}</NavLink>)}</div>}
            </div>;
          })}
          <div className="wa-nav-main wa-nav-bottom">
            <NavLink to="/app/saved" onClick={close}><Bookmark />Reading list</NavLink>
            <NavLink to="/app/account" onClick={close}><UserRound />Account & subscription</NavLink>
            <NavLink to="/app/help" onClick={close}><CircleHelp />Help & feedback</NavLink>
          </div>
        </nav>
        <div className="wa-prototype-note"><Sparkles /><p><b>Interactive prototype</b>Changes are stored only for this visit.</p></div>
      </aside>
    </>
  );
}

export function AppShell() {
  const [drawer, setDrawer] = useState(false);
  const { showToast } = useApp();
  return (
    <div className="wa-app">
      <Sidebar open={drawer} close={() => setDrawer(false)} />
      <div className="wa-shell">
        <header className="wa-topbar">
          <button className="wa-icon-button wa-menu-button" onClick={() => setDrawer(true)} aria-label="Open navigation"><Menu /></button>
          <GlobalSearch />
          <div className="wa-top-actions">
            <Link className="wa-icon-button" to="/app/help" aria-label="Help"><CircleHelp /></Link>
            <button className="wa-icon-button" aria-label="Notifications" onClick={() => showToast("No new notifications in this prototype.")}><Bell /><i /></button>
            <Link to="/app/account" className="wa-profile"><span>AK</span><div><b>Akua K.</b><small>Prototype account</small></div><ChevronDown /></Link>
          </div>
        </header>
        <main className="wa-main"><Outlet /></main>
      </div>
    </div>
  );
}

function Breadcrumbs({ items }: { items: [string, string?][] }) {
  return <nav className="wa-breadcrumbs" aria-label="Breadcrumb">{items.map(([label, to], index) => <span key={label}>{index > 0 && <ChevronRight />}{to ? <Link to={to}>{label}</Link> : <b>{label}</b>}</span>)}</nav>;
}

function PageHeader({ eyebrow, title, description, action }: { eyebrow?: string; title: string; description: string; action?: ReactNode }) {
  return <div className="wa-page-header"><div>{eyebrow && <span className="wa-eyebrow">{eyebrow}</span>}<h1>{title}</h1><p>{description}</p></div>{action && <div className="wa-page-action">{action}</div>}</div>;
}

function Button({ children, kind = "primary", onClick, type = "button", disabled = false }: { children: ReactNode; kind?: "primary" | "secondary" | "quiet" | "danger"; onClick?: () => void; type?: "button" | "submit"; disabled?: boolean }) {
  return <button className={`wa-button ${kind}`} onClick={onClick} type={type} disabled={disabled}>{children}</button>;
}

function SourceLabel({ label }: { label: string }) {
  return <span className={`wa-source-label ${label.toLowerCase().replaceAll(" ", "-")}`}><FileCheck2 />{label}</span>;
}

function SaveButton({ item, label = false }: { item: ResearchItem; label?: boolean }) {
  const { saved, toggleSaved } = useApp();
  const active = saved.includes(item.id);
  return <button className={`wa-save ${active ? "active" : ""}`} onClick={() => toggleSaved(item.id, item.title)} aria-label={active ? `Remove ${item.title} from reading list` : `Save ${item.title} to reading list`}>{active ? <BookmarkCheck /> : <Bookmark />}{label && (active ? "Saved" : "Save")}</button>;
}

function Progress({ value, label }: { value: number; label?: string }) {
  return <div className="wa-progress" aria-label={`${label || "Progress"}: ${value}%`}><i style={{ width: `${value}%` }} /></div>;
}

function ResultRow({ item }: { item: ResearchItem }) {
  const to = item.kind === "Case" ? `/app/cases/${illustrativeCase.id}` : item.kind === "Brief" ? `/app/briefs/${item.id}` : item.kind === "Legislation" ? `/app/library/${item.id}` : item.kind === "Course" ? "/app/courses/contract" : "/app/practice";
  return <article className="wa-result-row">
    <div className="wa-result-icon">{item.kind === "Case" ? <Scale /> : item.kind === "Legislation" ? <FileText /> : item.kind === "Past question" ? <FileQuestion /> : <BookOpen />}</div>
    <div className="wa-result-body"><div className="wa-result-labels"><SourceLabel label={item.label} /><span>{item.kind}</span></div><Link to={to}><h3>{item.title}</h3></Link><code>{item.reference}</code><p>{item.excerpt}</p><div className="wa-result-meta"><span>{item.meta}</span><span>{item.topic}</span></div></div>
    <SaveButton item={item} />
  </article>;
}

export function OnboardingPage() {
  const [step, setStep] = useState(1);
  const [role, setRole] = useState("");
  const [interests, setInterests] = useState<string[]>([]);
  const [institution, setInstitution] = useState("");
  const [goal, setGoal] = useState("Course learning");
  const navigate = useNavigate();
  const roles = ["Law Student", "Pre-Bar / Legal Practice Training Student", "Legal Professional / Researcher", "Lecturer / Institution", "Other"];
  const interestOptions = ["Case law", "Legislation", "Study materials", "Past questions", "Legal directory"];
  const toggleInterest = (item: string) => setInterests((current) => current.includes(item) ? current.filter((entry) => entry !== item) : [...current, item]);
  const continueOnboarding = () => {
    if (step < 3) setStep((current) => current + 1);
    else navigate("/app/auth?mode=create");
  };
  return <div className="wa-onboarding">
    <header><Brand /><Link to="/app/auth?mode=create">Skip setup</Link></header>
    <div className="wa-onboarding-card">
      <div className="wa-onboarding-progress"><span>Step {step} of 3</span><Progress value={step * 33.33} /></div>
      {step === 1 && <div className="wa-onboarding-step"><span className="wa-eyebrow">Welcome to MMRA</span><h1>Set up your legal workspace.</h1><p>Choose the context that best fits your work. You can change this later in Settings.</p><div className="wa-choice-grid">{roles.map((item) => <button className={role === item ? "selected" : ""} onClick={() => setRole(item)} key={item}><UserRound /><span>{item}</span>{role === item && <Check />}</button>)}</div></div>}
      {step === 2 && <div className="wa-onboarding-step"><span className="wa-eyebrow">Study context</span><h1>Choose your current focus.</h1><p>Institution is optional. The list comes from the supplied October 2026 research report and should be checked against current GLC and GTEC records.</p><div className="wa-onboarding-fields"><label>Study goal<select value={goal} onChange={(event) => setGoal(event.target.value)}><option>Course learning</option><option>Exam preparation</option><option>Legal research</option><option>Continuing reference</option></select></label><label>Institution, if relevant<select value={institution} onChange={(event) => setInstitution(event.target.value)}><option value="">Prefer not to say / not applicable</option>{accreditedInstitutions.map((item) => <option value={item.name} key={item.name}>{item.name}</option>)}</select></label></div><div className="wa-report-caution"><AlertCircle /><span>Interim list stated at October 2026. Verify present accreditation directly with the regulators.</span></div></div>}
      {step === 3 && <div className="wa-onboarding-step"><span className="wa-eyebrow">Your library</span><h1>What would you like close at hand?</h1><p>Choose any areas you want MMRA to prioritize. These preferences can be changed later.</p><div className="wa-choice-grid compact">{interestOptions.map((item) => <button className={interests.includes(item) ? "selected" : ""} onClick={() => toggleInterest(item)} key={item}><span>{item}</span>{interests.includes(item) && <Check />}</button>)}</div><div className="wa-onboarding-summary"><Check /><span><b>{role}</b> · {goal}{institution && ` · ${institution}`}</span></div></div>}
      <div className="wa-onboarding-footer">
        <Button kind="quiet" onClick={() => step === 1 ? navigate("/") : setStep((current) => current - 1)}><ArrowLeft />{step === 1 ? "Back to MMRA" : "Back"}</Button>
        <Button onClick={continueOnboarding} disabled={step === 1 && !role}>{step === 3 ? "Create account" : "Continue"} <ArrowRight /></Button>
      </div>
      <div className="wa-privacy-note"><LockKeyhole /><span>MMRA uses study activity to show your progress and continue where you left off. Prototype data is not submitted to a backend.</span></div>
    </div>
  </div>;
}

export function AuthPage() {
  const [params, setParams] = useSearchParams();
  const mode = params.get("mode") === "signin" ? "signin" : "create";
  const navigate = useNavigate();
  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    navigate("/app");
  };
  return <div className="wa-auth-page">
    <div className="wa-auth-brand"><Brand /><p>Find the authority. Understand the principle. Practise the application.</p><Link to="/"><ArrowLeft />Return to landing page</Link></div>
    <div className="wa-auth-card">
      <span className="wa-eyebrow">{mode === "create" ? "Start your three-month access" : "Welcome back"}</span>
      <h1>{mode === "create" ? "Create your MMRA account." : "Sign in to your workspace."}</h1>
      <p>{mode === "create" ? "Continue into the interactive prototype. No backend account will be created." : "Prototype sign-in accepts any validly formatted email and password."}</p>
      <div className="wa-auth-tabs"><button className={mode === "create" ? "active" : ""} onClick={() => setParams({ mode: "create" })}>Create account</button><button className={mode === "signin" ? "active" : ""} onClick={() => setParams({ mode: "signin" })}>Sign in</button></div>
      <form className="wa-form-stack" onSubmit={submit}>
        {mode === "create" && <label>Full name<input required autoComplete="name" placeholder="Your name" /></label>}
        <label>Email address<div className="wa-auth-input"><Mail /><input required type="email" autoComplete="email" placeholder="you@example.com" /></div></label>
        <label>Password<div className="wa-auth-input"><KeyRound /><input required minLength={8} type="password" autoComplete={mode === "create" ? "new-password" : "current-password"} placeholder="At least 8 characters" /></div></label>
        {mode === "create" && <label className="wa-consent"><input required type="checkbox" /><span>I agree to the prototype Terms and Privacy notice.</span></label>}
        <Button type="submit">{mode === "create" ? "Create account and enter MMRA" : "Sign in"} <ArrowRight /></Button>
      </form>
      <div className="wa-auth-notice"><ShieldCheck /><span>Authentication is simulated locally for this prototype. Credentials are not sent or stored.</span></div>
    </div>
  </div>;
}

export function OverviewPage() {
  const { plan, completedPractice } = useApp();
  const navigate = useNavigate();
  const completed = plan.filter((item) => item.done).length;
  return <div className="wa-page">
    <PageHeader eyebrow="Overview" title="Good morning, Akua." description="Pick up your research or continue the next step in your study plan." action={<span className="wa-demo-badge">Illustrative activity</span>} />
    <form className="wa-hero-search" onSubmit={(event) => { event.preventDefault(); const data = new FormData(event.currentTarget); navigate(`/app/search?q=${encodeURIComponent(String(data.get("q") || ""))}`); }}><Search /><input name="q" aria-label="Search MMRA" placeholder="Search cases, legislation, legal topics, or resources" /><Button type="submit">Search MMRA</Button></form>
    <div className="wa-quick-actions">
      {[["/app/cases","Search cases",Scale],["/app/library","Browse legislation",Library],["/app/courses/contract","Continue studying",BookOpen],["/app/practice","Practise questions",FileQuestion]].map(([to,label,Icon]) => { const I = Icon as typeof Scale; return <Link to={to as string} key={label as string}><I /><span>{label as string}</span><ArrowRight /></Link>})}
    </div>
    <div className="wa-metric-grid">
      <article><span>Reading progress</span><strong>42%</strong><Progress value={42} /><small>Law of Contract · demo data</small></article>
      <article><span>Plan completed</span><strong>{completed} / {plan.length}</strong><Progress value={plan.length ? completed / plan.length * 100 : 0} /><small>Updates from planner activity</small></article>
      <article><span>Practice</span><strong>{completedPractice ? "1 reviewed" : "Not started"}</strong><small>{completedPractice ? "Feedback available" : "Try an illustrative question"}</small></article>
      <article><span>Revision queue</span><strong>{completedPractice ? "1 topic" : "Empty"}</strong><small>Based only on completed practice</small></article>
    </div>
    <div className="wa-dashboard-grid">
      <section className="wa-panel wa-continue"><div className="wa-panel-head"><div><span className="wa-eyebrow">Continue where you left off</span><h2>Frustration of contract</h2></div><BookOpen /></div><p>Law of Contract · Authority and case brief</p><Progress value={42} /><div className="wa-card-actions"><Link className="wa-button primary" to={`/app/cases/${illustrativeCase.id}`}>Continue reading <ArrowRight /></Link><Link to="/app/courses/contract">View course</Link></div></section>
      <section className="wa-panel"><div className="wa-panel-title"><h2>Today&apos;s plan</h2><Link to="/app/planner">Open planner</Link></div><div className="wa-plan-list compact">{plan.filter((item) => item.date === "Today").map((item) => <PlanRow item={item} key={item.id} />)}</div></section>
      <section className="wa-panel"><div className="wa-panel-title"><h2>Recently viewed</h2><Link to="/app/saved">Reading list</Link></div>{researchItems.slice(0,3).map((item) => <Link className="wa-mini-row" to={item.kind === "Legislation" ? `/app/library/${item.id}` : `/app/cases/${illustrativeCase.id}`} key={item.id}><div><SourceLabel label={item.label} /><strong>{item.title}</strong><code>{item.reference}</code></div><ChevronRight /></Link>)}</section>
      <section className="wa-panel"><div className="wa-panel-title"><h2>Recommended next</h2><span className="wa-demo-badge">Illustrative</span></div><div className="wa-recommend"><div className="wa-result-icon"><FileQuestion /></div><div><span>Practice · Frustration</span><h3>Apply the principle to a problem question</h3><p>Review a worked feedback structure after submitting your response.</p><Link to="/app/practice">Start practice <ArrowRight /></Link></div></div></section>
    </div>
  </div>;
}

function FilterBar({ active, setActive }: { active: string[]; setActive: (filters: string[]) => void }) {
  const options = ["Cases", "Legislation", "Briefs", "Courses", "Past questions"];
  return <div className="wa-filter-bar"><button className="wa-filter-button"><Filter />Filters <span>{active.length}</span></button><div className="wa-filter-options">{options.map((item) => <button className={active.includes(item) ? "active" : ""} onClick={() => setActive(active.includes(item) ? active.filter((entry) => entry !== item) : [...active, item])} key={item}>{item}{active.includes(item) && <X />}</button>)}</div>{active.length > 0 && <button className="wa-reset" onClick={() => setActive([])}>Reset all</button>}</div>;
}

export function SearchPage() {
  const [params, setParams] = useSearchParams();
  const [filters, setFilters] = useState<string[]>(params.get("type") ? [params.get("type")!] : []);
  const query = params.get("q") || "";
  const [draft, setDraft] = useState(query);
  const results = useMemo(() => researchItems.filter((item) => {
    const matchesQuery = !query || `${item.title} ${item.topic} ${item.reference}`.toLowerCase().includes(query.toLowerCase()) || query.toLowerCase().includes("frustration");
    const typeName = item.kind === "Case" ? "Cases" : item.kind === "Legislation" ? "Legislation" : item.kind === "Brief" ? "Briefs" : item.kind === "Course" ? "Courses" : "Past questions";
    return matchesQuery && (!filters.length || filters.includes(typeName));
  }), [query, filters]);
  return <div className="wa-page">
    <Breadcrumbs items={[["Overview","/app"],["Search"]]} />
    <PageHeader eyebrow="Legal research" title="Search MMRA" description="Search illustrative cases, legal texts, briefs, study resources, and questions." />
    <form className="wa-search-page-field" onSubmit={(event) => { event.preventDefault(); setParams(draft ? { q: draft } : {}); }}><Search /><input value={draft} onChange={(event) => setDraft(event.target.value)} aria-label="Search cases and legal materials" placeholder="Try “frustration of contract”" /><Button type="submit">Search</Button></form>
    {!query && <div className="wa-search-empty"><History /><div><h2>Begin with a title, citation, or legal topic.</h2><p>Try an illustrative query to explore the connected research workflow.</p><button onClick={() => { setDraft("frustration of contract"); setParams({ q: "frustration of contract" }); }}>Use “frustration of contract”</button></div></div>}
    {query && <><FilterBar active={filters} setActive={setFilters} /><div className="wa-results-head"><div><h2>{results.length} illustrative results</h2><p>Searching all available prototype records for “{query}”</p></div><select aria-label="Sort search results"><option>Most relevant</option><option>Newest first</option><option>Alphabetical</option></select></div>{results.length ? <div className="wa-results-list">{results.map((item) => <ResultRow item={item} key={item.id} />)}</div> : <StateCard icon={Search} title="No matching records" copy="Try a broader phrase, remove a filter, or search by content type." action={<Button kind="secondary" onClick={() => { setFilters([]); setDraft(""); setParams({}); }}>Clear search</Button>} />}</>}
  </div>;
}

export function CasesLibraryPage() {
  const [view, setView] = useState<"compact" | "comfortable">("compact");
  return <div className="wa-page">
    <Breadcrumbs items={[["Overview","/app"],["Legal research"],["Cases & judgments"]]} />
    <PageHeader eyebrow="Primary legal sources" title="Cases & judgments" description="Search and inspect court decisions, citations, source metadata, and the available judgment text." action={<Link className="wa-button secondary" to="/app/briefs"><BookOpen />Open case briefs</Link>} />
    <form className="wa-search-page-field" onSubmit={(event) => event.preventDefault()}><Search /><input aria-label="Search cases and judgments" placeholder="Search by case name, citation, court, judge, or legal topic" /><Button type="submit">Search cases</Button></form>
    <div className="wa-filter-bar"><button className="wa-filter-button"><Filter />Court</button><button className="wa-filter-button"><Filter />Decision year</button><button className="wa-filter-button"><Filter />Judge</button><button className="wa-filter-button"><Filter />Subject</button><div className="wa-view-toggle wa-push-right"><button className={view === "compact" ? "active" : ""} onClick={() => setView("compact")}><LayoutList />Compact</button><button className={view === "comfortable" ? "active" : ""} onClick={() => setView("comfortable")}><BookOpen />Comfortable</button></div></div>
    <div className="wa-source-notice"><Scale /><div><b>Authority-first module</b><p>Records here represent primary legal sources. Editorial summaries are kept in the separate Case Briefs module.</p></div></div>
    <div className={`wa-results-list ${view === "comfortable" ? "comfortable" : ""}`}><ResultRow item={illustrativeCase} /></div>
  </div>;
}

export function BriefsLibraryPage() {
  const brief = researchItems.find((item) => item.kind === "Brief")!;
  return <div className="wa-page">
    <Breadcrumbs items={[["Overview","/app"],["Legal research"],["Case briefs"]]} />
    <PageHeader eyebrow="Editorial legal content" title="Case briefs" description="Understand facts, issues, holding, reasoning, principles, and disposition before checking the full authority." action={<Link className="wa-button secondary" to="/app/cases"><Scale />Open cases & judgments</Link>} />
    <form className="wa-search-page-field" onSubmit={(event) => event.preventDefault()}><Search /><input aria-label="Search editorial case briefs" placeholder="Search briefs by course, topic, case, court, or principle" /><Button type="submit">Search briefs</Button></form>
    <div className="wa-brief-explainer"><FileCheck2 /><div><b>Editorial, not primary law</b><p>Every brief is visually separated from the judgment and should link back to the underlying authority.</p></div><div className="wa-brief-structure">{["Facts","Issues","Holding","Ratio","Principles","Disposition"].map((item) => <span key={item}>{item}</span>)}</div></div>
    <div className="wa-brief-grid">
      <article className="wa-brief-card"><div className="wa-result-labels"><SourceLabel label="Editorial brief" /><span>Last reviewed [date]</span></div><h2>{brief.title}</h2><code>{brief.reference}</code><p>{brief.excerpt}</p><div className="wa-brief-sections"><div><span>ISSUE</span><b>Effect of a supervening event</b></div><div><span>PRINCIPLE</span><b>Verify against the full judgment</b></div></div><div className="wa-card-actions"><Link className="wa-button primary" to={`/app/briefs/${brief.id}`}>Read structured brief <ArrowRight /></Link><SaveButton item={brief} label /></div></article>
      <StateCard icon={BookOpen} title="More briefs will appear here" copy="No additional verified or editor-reviewed briefs were supplied for this prototype." />
    </div>
  </div>;
}

export function CaseDetailPage() {
  const location = useLocation();
  const isBriefModule = location.pathname.startsWith("/app/briefs");
  const [tab, setTab] = useState<"brief" | "judgment">(isBriefModule ? "brief" : "judgment");
  const [report, setReport] = useState(false);
  return <div className="wa-page wa-reader-page">
    <Breadcrumbs items={[["Legal research",isBriefModule ? "/app/briefs" : "/app/cases"],[isBriefModule ? "Case briefs" : "Cases & judgments",isBriefModule ? "/app/briefs" : "/app/cases"],[illustrativeCase.title]]} />
    <div className="wa-document-header"><div><div className="wa-result-labels"><SourceLabel label={tab === "brief" ? "Editorial brief" : "Primary source"} /><span className="wa-unverified"><AlertCircle />Illustrative record</span></div><h1>{illustrativeCase.title}</h1><code>{illustrativeCase.reference}</code><p>{illustrativeCase.meta}</p></div><div className="wa-document-actions"><SaveButton item={illustrativeCase} label /><Button kind="secondary" onClick={() => navigator.clipboard?.writeText(illustrativeCase.reference)}>Copy citation</Button></div></div>
    <div className="wa-source-notice"><ShieldCheck /><div><b>Check the underlying authority.</b><p>This illustrative record is not verified legal content. The brief is editorial and does not replace the full judgment.</p></div></div>
    <div className="wa-document-tabs" role="tablist"><button role="tab" aria-selected={tab === "brief"} className={tab === "brief" ? "active" : ""} onClick={() => setTab("brief")}>Case brief <span>Editorial</span></button><button role="tab" aria-selected={tab === "judgment"} className={tab === "judgment" ? "active" : ""} onClick={() => setTab("judgment")}>Full judgment <span>Primary source</span></button></div>
    {tab === "brief" ? <div className="wa-reader-layout"><aside className="wa-toc"><b>On this page</b>{["At a glance","Material facts","Issues","Decision","Reasoning","Legal principles","Disposition"].map((item) => <a href={`#${item.toLowerCase().replaceAll(" ","-")}`} key={item}>{item}</a>)}</aside><article className="wa-legal-reader"><section id="at-a-glance"><span className="wa-eyebrow">At a glance</span><h2>Editorial case brief</h2><p>This demonstration shows how a structured brief can help a reader orient themselves before checking the underlying authority.</p></section>{[["Material facts","[Illustrative facts] An unforeseen event affected performance of an agreement after formation."],["Issues","Whether the supervening event changed the obligation in a way recognised by the relevant legal principle."],["Decision","[Illustrative holding] The prototype does not state a real court decision."],["Reasoning","The reasoning area separates the ratio from background commentary and links each proposition to the source passage when verified."],["Legal principles","A principle card would state the proposition narrowly, with citation and source context."],["Disposition","[Order or disposition not supplied]."]].map(([title,copy]) => <section id={title.toLowerCase().replaceAll(" ","-")} key={title}><h2>{title}</h2><p>{copy}</p>{title === "Legal principles" && <blockquote>Illustrative editorial explanation. Verify every proposition against the underlying judgment.</blockquote>}</section>)}</article><aside className="wa-related-panel"><span className="wa-eyebrow">Connected research</span><h3>Follow the authority trail</h3><Link to={`/app/library/${legislation[0].id}`}><FileText /><div><b>{legislation[0].title}</b><small>{legislation[0].reference}</small></div><ChevronRight /></Link><Link to="/app/courses/contract"><GraduationCap /><div><b>Law of Contract</b><small>Frustration topic</small></div><ChevronRight /></Link><Link to="/app/practice"><FileQuestion /><div><b>Practice application</b><small>Illustrative problem</small></div><ChevronRight /></Link></aside></div>
    : <div className="wa-reader-layout"><aside className="wa-toc"><b>Document sections</b><a href="#judgment-intro">Source information</a><a href="#judgment-body">Illustrative text</a></aside><article className="wa-legal-reader judgment"><section id="judgment-intro"><span className="wa-eyebrow">Primary source view</span><h2>Full judgment reader</h2><p className="wa-reader-lead">A licensed or publicly available judgment would be shown in this focused reading column with source metadata, paragraph navigation, and linked references.</p></section><section id="judgment-body"><h2>Source text unavailable in prototype</h2><p>The original judgment text has not been supplied. MMRA does not fabricate or reconstruct the authority.</p><StateCard icon={LockKeyhole} title="Source unavailable" copy="Add a verified or licensed source record before publishing full text." /></section></article><aside className="wa-related-panel"><SourceLabel label="Primary source" /><h3>Source details</h3><dl><div><dt>Origin</dt><dd>Not supplied</dd></div><div><dt>Date checked</dt><dd>Not available</dd></div><div><dt>Access</dt><dd>Restricted in prototype</dd></div></dl></aside></div>}
    <div className="wa-report-row"><button onClick={() => setReport(true)}><MessageSquareWarning />Report a citation or metadata issue</button><span>Personal notes are private in this prototype.</span></div>
    {report && <ReportDialog close={() => setReport(false)} item={illustrativeCase.title} />}
  </div>;
}

export function LibraryPage() {
  const [params] = useSearchParams();
  const type = params.get("type");
  const filtered = type === "Bills" ? legislation.filter((item) => item.reference.startsWith("Bill")) : type === "Instruments" ? legislation.filter((item) => /L\.I\.|C\.I\.|E\.I\./.test(item.reference)) : legislation;
  return <div className="wa-page">
    <Breadcrumbs items={[["Overview","/app"],["Ghana legal library"]]} />
    <PageHeader eyebrow="Primary legal materials" title="Ghana legal library" description="Browse illustrative legal-text records by distinct document type. Verify source and status before relying on any record." />
    <div className="wa-library-types">{[["Constitution","Foundational text",Scale],["Acts","Enacted legislation",FileCheck2],["Bills","Proposed, not enacted",FileText],["L.I.","Legislative instruments",Library],["C.I.","Constitutional instruments",Library],["E.I.","Executive instruments",Library]].map(([title,copy,Icon]) => { const I=Icon as typeof Scale; return <article key={title as string}><I /><b>{title as string}</b><span>{copy as string}</span></article>})}</div>
    <div className="wa-help-panel"><CircleHelp /><div><b>Acts, Bills, and instruments are different.</b><p>An Act is enacted legislation. A Bill is a proposal and is not law in force. L.I., C.I., and E.I. are kept as distinct instrument types.</p></div></div>
    <div className="wa-results-head"><div><h2>{type || "Legal texts"}</h2><p>Illustrative records · legal status not verified</p></div><button className="wa-filter-button"><Filter />Year & status</button></div>
    <div className="wa-results-list">{filtered.map((item) => <ResultRow item={item} key={item.id} />)}</div>
  </div>;
}

export function LegalTextPage() {
  const { id } = useParams();
  const { showToast } = useApp();
  const item = legislation.find((record) => record.id === id) || legislation[0];
  const isBill = item.reference.startsWith("Bill");
  const [sectionQuery, setSectionQuery] = useState("");
  return <div className="wa-page wa-reader-page">
    <Breadcrumbs items={[["Legal library","/app/library"],[item.title]]} />
    <div className="wa-document-header"><div><div className="wa-result-labels"><SourceLabel label="Primary source" /><span className={isBill ? "wa-bill-label" : "wa-unverified"}>{isBill ? "Proposed legislation — not enacted law" : "Legal status not verified"}</span></div><h1>{item.title}</h1><code>{item.reference}</code><p>{item.meta}</p></div><div className="wa-document-actions"><SaveButton item={item} label /><Button kind="secondary" onClick={() => { navigator.clipboard?.writeText(item.reference); showToast("Reference copied."); }}>Copy reference</Button></div></div>
    <div className="wa-source-notice warning"><AlertCircle /><div><b>Check source and current status.</b><p>No official source, commencement date, amendment history, or currentness data has been supplied for this illustrative record.</p></div></div>
    <div className="wa-within-search"><Search /><input value={sectionQuery} onChange={(event) => setSectionQuery(event.target.value)} placeholder="Search within this document" aria-label="Search within document" /><span>{sectionQuery ? "0 verified matches" : "Section search"}</span></div>
    <div className="wa-reader-layout"><aside className="wa-toc"><b>Table of contents</b><a href="#part-one">Part I · [Heading]</a><a href="#section-one">Section [X]</a><a href="#source-record">Source record</a></aside><article className="wa-legal-reader judgment"><section id="part-one"><span className="wa-eyebrow">Part I</span><h2>[Verified heading required]</h2><p className="wa-reader-lead">Full legal text is not included because no verified or licensed source document has been supplied.</p></section><section id="section-one"><h2>Section [X] · [Heading]</h2><p>[Primary source text will appear here when an authorized source record is connected.]</p><div className="wa-restricted"><LockKeyhole /><div><b>Text unavailable</b><p>This prototype does not create or imply access to unsupplied source content.</p></div></div></section></article><aside className="wa-related-panel" id="source-record"><span className="wa-eyebrow">Document record</span><dl><div><dt>Document type</dt><dd>{isBill ? "Bill" : item.reference.split(" ")[0]}</dd></div><div><dt>Issuing authority</dt><dd>Not available</dd></div><div><dt>Effective date</dt><dd>Not available</dd></div><div><dt>Official source</dt><dd>Not supplied</dd></div></dl><h3>Related, illustrative</h3><Link to={`/app/cases/${illustrativeCase.id}`}><Scale /><div><b>{illustrativeCase.title}</b><small>Relationship not verified</small></div><ChevronRight /></Link></aside></div>
  </div>;
}

export function CoursesPage() {
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Courses & study"]]} /><PageHeader eyebrow="Courses & study" title="Build understanding from source to application." description="Course pathways are illustrative and do not imply a shared syllabus across institutions." action={<Link className="wa-button secondary" to="/app/planner"><CalendarDays />Open study planner</Link>} /><div className="wa-course-grid">{courses.map((course) => <Link to={`/app/courses/${course.id}`} className="wa-course-card" key={course.id}><div className="wa-course-number">{String(courses.indexOf(course)+1).padStart(2,"0")}</div><BookOpen /><h2>{course.title}</h2><p>{course.topics} illustrative topics</p><Progress value={course.progress} /><div><span>{course.progress}% demo progress</span><span>Next: {course.next}</span></div></Link>)}</div></div>;
}

export function CourseDetailPage() {
  const { id } = useParams();
  const { addPlan } = useApp();
  const course = courses.find((item) => item.id === id) || courses[0];
  return <div className="wa-page"><Breadcrumbs items={[["Courses","/app/courses"],[course.title]]} /><PageHeader eyebrow="Course pathway · illustrative" title={course.title} description="Learn → Read authority → Study brief → Practise → Review." action={<Button onClick={() => addPlan({ type: "Review a topic", title: course.next, date: "Tomorrow", duration: "30 min" })}><Plus />Add to study plan</Button>} /><div className="wa-course-hero"><div><span>Course progress</span><strong>{course.progress}%</strong><Progress value={course.progress} /></div><div><span>Next topic</span><strong>{course.next}</strong><Link to="/app/topics/frustration">Continue topic <ArrowRight /></Link></div><div><span>Syllabus mapping</span><strong>Not supplied</strong><small>No institution assumed</small></div></div><section className="wa-panel"><div className="wa-panel-title"><h2>Topics</h2><span className="wa-demo-badge">Illustrative sequence</span></div><div className="wa-topic-list">{["Formation and agreement","Terms and interpretation","Frustration of contract","Remedies","Third-party rights"].map((topic,index) => <Link to="/app/topics/frustration" key={topic}><span className={index < 2 ? "complete" : index === 2 ? "current" : ""}>{index < 2 ? <Check /> : String(index+1).padStart(2,"0")}</span><div><b>{topic}</b><small>{index === 2 ? "Case · legal text · practice question" : "Illustrative topic outline"}</small></div><ChevronRight /></Link>)}</div></section></div>;
}

export function TopicPage() {
  const { addPlan } = useApp();
  return <div className="wa-page"><Breadcrumbs items={[["Courses","/app/courses"],["Law of Contract","/app/courses/contract"],["Frustration of contract"]]} /><PageHeader eyebrow="Topic · illustrative" title="Frustration of contract" description="Move from explanation to authority, then apply the principle in practice." action={<Button kind="secondary" onClick={() => addPlan({ type: "Review a topic", title: "Frustration of contract", date: "Tomorrow", duration: "30 min" })}><Plus />Add to revision</Button>} /><div className="wa-learning-path">{[["01","Learn","Read the topic outline"],["02","Authority","Open the illustrative case"],["03","Legislation","Check connected legal text"],["04","Practise","Attempt a problem question"],["05","Review","Use feedback to revise"]].map(([number,title,copy],index) => <div className={index === 0 ? "active" : ""} key={title}><span>{number}</span><b>{title}</b><small>{copy}</small></div>)}</div><div className="wa-topic-grid"><article className="wa-panel wa-topic-copy"><span className="wa-eyebrow">Topic outline</span><h2>When performance changes after formation</h2><p>This illustrative outline shows how educational explanation can be placed beside, but clearly distinguished from, primary legal sources.</p><h3>Key questions</h3><ul><li>Was there a supervening event?</li><li>Did the agreement allocate the relevant risk?</li><li>How did the event affect the promised performance?</li></ul><div className="wa-source-notice compact"><FileCheck2 /><div><b>Study resource</b><p>Explanations require editorial review and source references before publication.</p></div></div></article><aside className="wa-panel wa-topic-links"><h2>Connected materials</h2><Link to={`/app/cases/${illustrativeCase.id}`}><Scale /><div><SourceLabel label="Primary source" /><b>{illustrativeCase.title}</b><code>{illustrativeCase.reference}</code></div><ChevronRight /></Link><Link to={`/app/library/${legislation[0].id}`}><FileText /><div><SourceLabel label="Primary source" /><b>{legislation[0].title}</b><code>{legislation[0].reference}</code></div><ChevronRight /></Link><Link to="/app/practice"><FileQuestion /><div><SourceLabel label="Study resource" /><b>Illustrative problem question</b><small>Practise application</small></div><ChevronRight /></Link></aside></div></div>;
}

export function PracticePage() {
  const [started, setStarted] = useState(false);
  const [answer, setAnswer] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const { setCompletedPractice, addPlan } = useApp();
  const submit = () => { setSubmitted(true); setCompletedPractice(true); };
  if (!started) return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Past questions & practice"]]} /><PageHeader eyebrow="Past questions" title="Practise with clear provenance." description="This question is illustrative. No institution, exam session, model answer, or marking guide is claimed." /><div className="wa-practice-browser"><aside><b>Category</b>{["All questions","LLB / University","Pre-Bar","Legal Practice Training"].map((item,index) => <button className={index === 0 ? "active" : ""} key={item}>{item}<span>{index ? "0" : "1"}</span></button>)}</aside><section><div className="wa-filter-bar"><button className="wa-filter-button"><Filter />Course: Contract</button><button className="wa-filter-button"><Filter />Topic: Frustration</button></div><article className="wa-question-card"><div><SourceLabel label="Study resource" /><span>Illustrative · provenance not supplied</span></div><h2>Problem question: unforeseen event and performance</h2><p>A supplier agrees to deliver goods for an event. After an unforeseen order, the event cannot proceed. Identify the relevant issues and explain how you would structure your analysis.</p><div><span><Clock3 />Suggested: 25 minutes</span><span><FileText />Problem question</span></div><Button onClick={() => setStarted(true)}>Start practice <ArrowRight /></Button></article></section></div></div>;
  return <div className="wa-page wa-practice-session"><Breadcrumbs items={[["Past questions","/app/practice"],["Practice attempt"]]} /><div className="wa-practice-top"><div><span className="wa-eyebrow">Illustrative practice</span><h1>Frustration problem question</h1></div><span><Clock3 />Untimed prototype</span></div><div className="wa-practice-layout"><article className="wa-panel"><span className="wa-question-number">Question 1 of 1</span><h2>Problem question</h2><p>A supplier agrees to deliver goods for an event. After an unforeseen order, the event cannot proceed. Identify the relevant issues and explain how you would structure your analysis.</p><div className="wa-question-note"><AlertCircle />This question is created only to demonstrate interface behaviour. It is not a verified past paper.</div></article><section className="wa-answer-panel"><label htmlFor="practice-answer">Your answer</label><textarea id="practice-answer" value={answer} onChange={(event) => setAnswer(event.target.value)} disabled={submitted} placeholder="Structure your response using issues, relevant rule, application, and conclusion…" /><div className="wa-answer-footer"><span>{answer.split(/\s+/).filter(Boolean).length} words</span>{!submitted ? <Button onClick={submit} disabled={answer.trim().length < 20}>Submit for demo feedback</Button> : <span className="wa-success-inline"><Check />Attempt submitted</span>}</div></section></div>{submitted && <section className="wa-feedback"><div className="wa-feedback-head"><div className="wa-complete-mark"><Check /></div><div><span className="wa-eyebrow">Demo feedback</span><h2>Review the structure, then return to the authority.</h2></div></div><div className="wa-feedback-grid"><article><b>Issues</b><p>Identify formation, the supervening event, allocation of risk, effect on performance, and potential consequences.</p></article><article><b>Source discipline</b><p>Support each legal proposition with a verified authority. No score is calculated for this free-text prototype.</p></article><article><b>Next revision step</b><p>Return to the topic and compare your structure with the connected sources.</p></article></div><div className="wa-card-actions"><Link className="wa-button primary" to="/app/topics/frustration">Review topic</Link><Link className="wa-button secondary" to={`/app/cases/${illustrativeCase.id}`}>Open case brief</Link><Button kind="quiet" onClick={() => addPlan({ type: "Review a topic", title: "Frustration of contract", date: "Tomorrow", duration: "20 min" })}>Add to revision</Button></div></section>}</div>;
}

function PlanRow({ item }: { item: PlanItem }) {
  const { togglePlan } = useApp();
  return <div className={`wa-plan-row ${item.done ? "done" : ""}`}><button onClick={() => togglePlan(item.id)} aria-label={item.done ? `Mark ${item.title} incomplete` : `Mark ${item.title} complete`}>{item.done && <Check />}</button><div><b>{item.title}</b><span>{item.type} · {item.duration}</span></div><time>{item.date}</time><button className="wa-more" aria-label={`Options for ${item.title}`}><MoreHorizontal /></button></div>;
}

export function PlannerPage() {
  const { plan, addPlan } = useApp();
  const [adding, setAdding] = useState(false);
  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    addPlan({ type: String(data.get("type")) as PlanItem["type"], title: String(data.get("title")), date: String(data.get("date")), duration: String(data.get("duration")) });
    setAdding(false);
  };
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Study planner"]]} /><PageHeader eyebrow="Study planner" title="Plan the next useful step." description="Keep the routine light. Complete, reschedule, or recover without penalty." action={<Button onClick={() => setAdding(true)}><Plus />Add study session</Button>} /><div className="wa-planner-layout"><section className="wa-panel"><div className="wa-panel-title"><h2>This week</h2><div className="wa-view-toggle"><button className="active"><LayoutList />List</button><button><CalendarDays />Calendar</button></div></div><div className="wa-plan-list">{plan.map((item) => <PlanRow item={item} key={item.id} />)}</div></section><aside className="wa-panel wa-revision"><span className="wa-eyebrow">Revision queue</span><h2>Topics to revisit</h2><p>Topics appear here only after actual practice activity in this visit.</p><div className="wa-revision-item"><RefreshCw /><div><b>Frustration of contract</b><span>Review after practice</span></div><Link to="/app/topics/frustration">Open</Link></div></aside></div>{adding && <div className="wa-modal-backdrop"><form className="wa-modal" onSubmit={submit}><div className="wa-modal-head"><div><span className="wa-eyebrow">New session</span><h2>Add to your plan</h2></div><button type="button" className="wa-icon-button" onClick={() => setAdding(false)} aria-label="Close"><X /></button></div><label>Task type<select name="type"><option>Read a case</option><option>Review legislation</option><option>Attempt a question</option><option>Review a topic</option></select></label><label>Topic or resource<input name="title" required placeholder="e.g. Frustration of contract" /></label><div className="wa-form-row"><label>When<select name="date"><option>Today</option><option>Tomorrow</option><option>Later this week</option></select></label><label>Duration<select name="duration"><option>20 min</option><option>30 min</option><option>45 min</option></select></label></div><div className="wa-modal-actions"><Button kind="quiet" onClick={() => setAdding(false)}>Cancel</Button><Button type="submit">Add session</Button></div></form></div>}</div>;
}

export function SavedPage() {
  const { saved } = useApp();
  const items = researchItems.filter((item) => saved.includes(item.id)).concat(legislation.filter((item) => saved.includes(item.id) && !researchItems.some((r) => r.id === item.id)));
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Reading list"]]} /><PageHeader eyebrow="Private workspace" title="Your reading list" description="Saved items and personal study activity are private in this prototype." />{items.length ? <div className="wa-results-list">{items.map((item) => <ResultRow item={item} key={item.id} />)}</div> : <StateCard icon={Bookmark} title="Your reading list is empty" copy="Save a case, legal text, brief, resource, or question to find it here." action={<Link className="wa-button primary" to="/app/search?q=frustration">Explore illustrative records</Link>} />}</div>;
}

export function ResourcesPage() {
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Resources"]]} /><PageHeader eyebrow="Resources" title="Articles, guides, and authorized learning materials." description="Access and rights must be known before a resource is made available." /><div className="wa-state-grid"><StateCard icon={FolderOpen} title="No authorized resources supplied" copy="Books, slides, and course materials will appear only when access rights and provenance are known." /><StateCard icon={AlertCircle} title="External source unavailable" copy="A broken or unavailable external source should offer a retry or reporting path." action={<Button kind="secondary">Report source</Button>} /><StateCard icon={RefreshCw} title="Loading resources" copy="Skeletons will preserve layout while real metadata is fetched." loading /></div></div>;
}

export function DirectoryPage() {
  const { type = "courts" } = useParams();
  const safeType = (["courts","judges","firms"].includes(type) ? type : "courts") as keyof typeof directoryRecords;
  const titles = { courts: "Courts directory", judges: "Judicial profiles", firms: "Law firm directory" };
  const records = directoryRecords[safeType];
  const [selected, setSelected] = useState(records[0]);
  const isFirm = safeType === "firms";
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Directories"],[titles[safeType]]]} /><PageHeader eyebrow="Source-aware directory" title={titles[safeType]} description={isFirm ? "The supplied spreadsheet contains one complete chambers record. It is shown with source context and is not presented as an exhaustive register." : "Illustrative layout only. No contacts, biographies, locations, affiliations, or exhaustive coverage are claimed."} /><div className="wa-directory-search"><Search /><input aria-label={`Search ${safeType}`} placeholder={`Search ${safeType === "firms" ? "by chambers name or location" : `verified ${safeType}`}`} /><button className="wa-filter-button"><Filter />Filters</button></div><div className="wa-directory-layout"><div className="wa-directory-list">{records.map((record) => <button className={selected.id === record.id ? "active" : ""} onClick={() => setSelected(record)} key={record.id}><div className="wa-result-icon">{safeType === "courts" ? <Building2 /> : safeType === "judges" ? <Gavel /> : <Users />}</div><div><b>{record.title}</b><span>{record.subtitle}</span></div><ChevronRight /></button>)}</div><article className="wa-directory-detail"><div className="wa-directory-portrait">{safeType === "courts" ? <Building2 /> : safeType === "judges" ? <UserRound /> : <Users />}</div><span className="wa-demo-badge">{isFirm ? "Supplied chambers spreadsheet" : "Verification required"}</span><h2>{selected.title}</h2><p>{selected.subtitle}</p><div className="wa-source-notice compact"><ShieldCheck /><div><b>Source-aware record</b><p>{selected.detail}</p></div></div><dl>{isFirm ? <><div><dt>Postal address</dt><dd>{chambers[0].postalAddress}</dd></div><div><dt>Phone</dt><dd>{chambers[0].phone}</dd></div><div><dt>Email</dt><dd>{chambers[0].email}</dd></div><div><dt>Website</dt><dd><a href={chambers[0].website} target="_blank" rel="noreferrer">Open website</a></dd></div><div><dt>Source</dt><dd>{chambers[0].source}</dd></div></> : <><div><dt>Public source</dt><dd>Not supplied</dd></div><div><dt>Last checked</dt><dd>Not available</dd></div><div><dt>Contact details</dt><dd>Not available</dd></div></>}</dl><Link className="wa-button secondary" to="/app/help?report=directory"><MessageSquareWarning />Report a record issue</Link></article></div></div>;
}

export function AccountPage() {
  const [tab, setTab] = useState("Account");
  const { showToast } = useApp();
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Account & subscription"]]} /><PageHeader eyebrow="Account" title="Your workspace and plan." description="Pricing, payment methods, renewal terms, and cancellation terms remain placeholders until confirmed." /><div className="wa-settings-layout"><aside>{["Account","Study preferences","Privacy & security","Accessibility","Subscription"].map((item) => <button className={tab === item ? "active" : ""} onClick={() => setTab(item)} key={item}>{item}<ChevronRight /></button>)}</aside><section className="wa-panel">{tab !== "Subscription" ? <><span className="wa-eyebrow">{tab}</span><h2>{tab}</h2>{tab === "Account" && <div className="wa-form-stack"><label>Display name<input defaultValue="Akua K." /></label><label>Role<select defaultValue="Law Student"><option>Law Student</option><option>Pre-Bar / Legal Practice Training Student</option><option>Legal Professional / Researcher</option><option>Lecturer / Institution</option><option>Other</option></select></label><Button onClick={() => showToast("Account changes saved for this visit.")}>Save changes</Button></div>}{tab === "Study preferences" && <div className="wa-form-stack"><label>Current focus<select><option>Course learning</option><option>Exam preparation</option><option>Legal research</option><option>Continuing reference</option></select></label><label>Institution, if relevant<select><option value="">Not applicable / prefer not to say</option>{accreditedInstitutions.map((institution) => <option key={institution.name}>{institution.name}</option>)}</select></label><p className="wa-setting-copy">Institution list from the supplied report, stated at October 2026. Verify current accreditation with GLC and GTEC.</p><Button onClick={() => showToast("Study preferences saved for this visit.")}>Save preferences</Button></div>}{tab === "Privacy & security" && <div className="wa-setting-list"><div><b>Private study activity</b><p>Your reading progress, notes, and practice activity are private by default.</p></div><div><b>Prototype storage</b><p>Changes exist only during this browser visit. No backend account is connected.</p></div></div>}{tab === "Accessibility" && <div className="wa-setting-list"><label className="wa-switch-row"><div><b>Reduce motion</b><p>Your system preference is respected automatically.</p></div><input type="checkbox" /></label><label className="wa-switch-row"><div><b>Comfortable reading size</b><p>Legal text uses a larger base size and focused measure.</p></div><input type="checkbox" defaultChecked /></label></div>}</> : <SubscriptionPanel />}</section></div></div>;
}

function SubscriptionPanel() {
  return <><span className="wa-eyebrow">Subscription</span><h2>Choose a plan when terms are confirmed.</h2><div className="wa-pending"><Clock3 /><div><b>Prototype subscription status: pending</b><p>No payment method, renewal date, or billing history is connected.</p></div></div><div className="wa-subscription-grid"><article><span>FREE ACCESS</span><h3>3 months</h3><strong>GH₵ 0</strong><p>Current brief concept. Final terms not supplied.</p><Button kind="secondary" disabled>Prototype plan</Button></article><article><span>MONTHLY</span><h3>Monthly access</h3><strong>GH₵ [X]</strong><p>Price and payment terms are not supplied.</p><Button kind="secondary" disabled>Not yet available</Button></article><article><span>YEARLY</span><h3>Yearly access</h3><strong>GH₵ [X]</strong><p>No savings or renewal terms are claimed.</p><Button kind="secondary" disabled>Not yet available</Button></article></div><p className="wa-setting-copy">Payment methods will appear only after an actual integration is confirmed.</p></>;
}

export function HelpPage() {
  const [open, setOpen] = useState(0);
  const [reported, setReported] = useState(false);
  return <div className="wa-page"><Breadcrumbs items={[["Overview","/app"],["Help & feedback"]]} /><PageHeader eyebrow="Help & feedback" title="Find help or flag a source issue." description="Prototype submissions are confirmed locally and are not sent to a support backend." /><div className="wa-help-layout"><section className="wa-panel"><h2>Help topics</h2>{["How source labels work","Saving to your reading list","Using the study planner","Understanding legal status labels"].map((item,index) => <div className="wa-help-accordion" key={item}><button onClick={() => setOpen(open === index ? -1 : index)} aria-expanded={open === index}>{item}<ChevronDown /></button>{open === index && <p>MMRA distinguishes primary law, editorial explanation, study resources, and external sources. Always check the underlying authority and available source metadata.</p>}</div>)}</section><section className="wa-panel"><span className="wa-eyebrow">Report content</span><h2>Report a citation or metadata issue</h2>{reported ? <div className="wa-report-success"><div className="wa-complete-mark"><Check /></div><h3>Prototype report recorded.</h3><p>No backend is connected, so this report was not transmitted. The confirmation demonstrates the intended product state.</p><Button kind="secondary" onClick={() => setReported(false)}>Submit another</Button></div> : <form className="wa-form-stack" onSubmit={(event) => { event.preventDefault(); setReported(true); }}><label>Issue category<select required><option value="">Choose a category</option><option>Citation</option><option>Legal status</option><option>Source link</option><option>Directory record</option><option>Other metadata</option></select></label><label>Reference link or item<input placeholder="Paste an MMRA link or enter a title" required /></label><label>What should we check?<textarea placeholder="Describe the possible issue without including private or sensitive information." required /></label><Button type="submit">Submit prototype report</Button></form>}</section></div><section className="wa-state-showcase"><h2>Product states</h2><div className="wa-state-grid"><StateCard icon={RefreshCw} title="Network error" copy="We could not load this content. Check your connection and try again." action={<Button kind="secondary">Retry</Button>} /><StateCard icon={LockKeyhole} title="Restricted resource" copy="This material is unavailable under the current access conditions." /><StateCard icon={AlertCircle} title="Status not verified" copy="Check the official source before relying on this legal-status record." /></div></section></div>;
}

function StateCard({ icon: Icon, title, copy, action, loading = false }: { icon: typeof Search; title: string; copy: string; action?: ReactNode; loading?: boolean }) {
  return <div className={`wa-state-card ${loading ? "loading" : ""}`}><div className="wa-state-icon"><Icon /></div><div><h3>{title}</h3><p>{copy}</p>{action}</div></div>;
}

function ReportDialog({ close, item }: { close: () => void; item: string }) {
  const [sent, setSent] = useState(false);
  return <div className="wa-modal-backdrop" role="presentation" onMouseDown={close}><div className="wa-modal" role="dialog" aria-modal="true" aria-labelledby="report-title" onMouseDown={(event) => event.stopPropagation()}><div className="wa-modal-head"><div><span className="wa-eyebrow">Source quality</span><h2 id="report-title">Report an issue</h2></div><button className="wa-icon-button" onClick={close} aria-label="Close"><X /></button></div>{sent ? <div className="wa-report-success"><div className="wa-complete-mark"><Check /></div><h3>Prototype report recorded.</h3><p>This demonstration does not send data to a backend.</p><Button onClick={close}>Done</Button></div> : <form className="wa-form-stack" onSubmit={(event) => { event.preventDefault(); setSent(true); }}><label>Item<input value={item} readOnly /></label><label>Issue category<select required><option>Citation or reference</option><option>Source metadata</option><option>Editorial content</option></select></label><label>Details<textarea required placeholder="What should the editorial team check?" /></label><Button type="submit">Submit prototype report</Button></form>}</div></div>;
}

export function NotFoundPage() {
  return <div className="wa-page"><StateCard icon={AlertCircle} title="This page is not available" copy="The link may be outdated or outside the current prototype scope." action={<Link className="wa-button primary" to="/app">Return to overview</Link>} /></div>;
}
