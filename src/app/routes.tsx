import { createBrowserRouter } from "react-router";
import LandingPage from "../App";
import { basename } from "./basePath";
import {
  AccountPage,
  AppShell,
  AppStateProvider,
  AuthPage,
  BriefsLibraryPage,
  CaseDetailPage,
  CasesLibraryPage,
  CourseDetailPage,
  CoursesPage,
  DirectoryPage,
  HelpPage,
  LegalTextPage,
  LibraryPage,
  NotFoundPage,
  OnboardingPage,
  OverviewPage,
  PlannerPage,
  PracticePage,
  ResourcesPage,
  SavedPage,
  SearchPage,
  TopicPage,
} from "../webapp/WebApp";

export const router = createBrowserRouter([
  { path: "/", Component: LandingPage },
  {
    path: "/app",
    Component: AppStateProvider,
    children: [
      { path: "onboarding", Component: OnboardingPage },
      { path: "auth", Component: AuthPage },
      {
        Component: AppShell,
        children: [
          { index: true, Component: OverviewPage },
          { path: "search", Component: SearchPage },
          { path: "cases", Component: CasesLibraryPage },
          { path: "cases/:id", Component: CaseDetailPage },
          { path: "briefs", Component: BriefsLibraryPage },
          { path: "briefs/:id", Component: CaseDetailPage },
          { path: "library", Component: LibraryPage },
          { path: "library/:id", Component: LegalTextPage },
          { path: "courses", Component: CoursesPage },
          { path: "courses/:id", Component: CourseDetailPage },
          { path: "topics/:id", Component: TopicPage },
          { path: "practice", Component: PracticePage },
          { path: "planner", Component: PlannerPage },
          { path: "saved", Component: SavedPage },
          { path: "resources", Component: ResourcesPage },
          { path: "directory/:type", Component: DirectoryPage },
          { path: "account", Component: AccountPage },
          { path: "help", Component: HelpPage },
          { path: "*", Component: NotFoundPage },
        ],
      },
    ],
  },
], { basename });
