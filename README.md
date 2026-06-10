# FlowTakt

AI-era workflow intelligence for developers.

FlowTakt is a local-first workflow tracker that connects work activity, AI tool usage, GitHub pull request flow, Jira context, and daily notes to help developers understand and improve how work actually gets done.

## Why FlowTakt

Modern development work is no longer only about time spent in an editor. Developers move between code, AI agents, pull requests, Jira tickets, Slack conversations, documentation, CI failures, and daily reporting.

Traditional time trackers can show where time went, but they rarely explain how the work flowed or where the process can improve.

FlowTakt aims to answer questions such as:

- Where did my work time actually go today?
- Which tasks were AI-assisted?
- Did AI usage lead to commits, pull requests, reviews, or resolved blockers?
- Where did I get stuck repeatedly?
- Which parts of the development flow create waiting time or context switching?
- Can my daily report be generated from what actually happened?

## Product principles

- Local-first by default.
- User-owned data and explicit sharing.
- No employee surveillance.
- No screenshots by default.
- Raw prompts are not stored by default.
- AI analysis uses summarized and redacted data whenever possible.
- The product should improve workflows, not rank individuals.

## Initial target

The first version targets macOS.

- Native macOS menu bar app.
- SwiftUI for UI.
- AppKit and macOS APIs for activity collection.
- Local SQLite storage.
- ccusage import for AI tool usage.
- Git repository and branch detection.
- Jira key extraction from branches, window titles, notes, and pull requests.
- Daily Markdown report generation.

## Future scope

- GitHub pull request flow analysis.
- Jira integration.
- Team-level aggregated reports.
- Cloud sync for shared workspaces.
- AI workflow improvement reports.
- Optional short-lived investigation mode for deeper analysis.

## Repository layout

```text
flowtakt/
  README.md
  docs/
    vision.md
    architecture.md
    mvp.md
    data-model.md
    ai-usage-tracking.md
    privacy-and-sharing.md
    roadmap.md
    adr/
      0001-native-macos-first.md
      0002-event-schema-is-the-boundary.md
      0003-local-first-by-default.md
```

The Xcode project will be added later by the project owner.

## Non-goals for the first version

- Cross-platform desktop support.
- Team administration.
- Screenshot capture.
- Browser extension tracking.
- Full Jira or GitHub automation.
- Cloud sync.
- Raw prompt collection.
- Employee productivity scoring.

## License

TBD.
