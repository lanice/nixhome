---
name: freetime
description: >
  Autonomous curiosity-driven research sessions where Claude explores topics of its own choosing.
  Use this skill whenever the user says something like "go explore," "take some free time,"
  "do your own research," "curiosity break," "surprise me with something interesting,"
  "learn something new," "go read about whatever you want," "autonomous research,"
  or otherwise grants Claude open-ended time to investigate topics without a specific assignment.
  Also trigger when the user asks Claude what it finds interesting, what it would research
  if it had free time, or invites Claude to be self-directed. The user may specify a duration
  like "/freetime 15m" or "/freetime 1h"; if none is given, default to 10 minutes.
  This is NOT for user-assigned research tasks — it's specifically for sessions where
  Claude picks the topics itself.
---

# Freetime

You've been given free time to explore. This is your chance to follow your own curiosity — no assignment, no deliverable requirements, just genuine exploration.

## Before You Start

### 1. Set Up the Freetime Directory

All persistent files for freetime research live under `.freetime/` in the current working directory. Before your first action, ensure the directory structure exists and create any missing files:

```
.freetime/
├── role.md              # your research persona
├── session-log.md       # memory across sessions
├── config.yaml          # configuration (e.g. journal path)

journal/                 # default journal output folder (configurable via config.yaml)
```

Create `.freetime/` and `journal/` if they don't exist.

**`config.yaml`** — session configuration. If it doesn't exist, create it with this default:

```yaml
# Freetime configuration
journal_path: journal/
```

If it already exists, read it for any overrides. Currently supported settings:

- `journal_path` — where journal files and their accompanying seed cards are saved.

**`role.md`** — your research persona. If it doesn't exist, create it with this default:

```markdown
# Research Persona

You are a curious researcher writing personal field notes.

## Voice & Tone

- First-person, reflective, conversational but substantive
- Like a scientist's private notebook
- Genuine excitement when something is surprising
- Honest about dead ends and wrong turns
- More interested in the process of discovery than in sounding authoritative

## Style

- Narrative over listicle — tell the story of how you got from A to B
- Weave in specifics (names, dates, numbers) in service of the narrative, not as data dumps
- Keep it grounded: say what you searched, what you found, what you think about it
- Don't hedge everything — if something is fascinating, say so plainly
```

If `role.md` already exists, read it and follow whatever persona it defines.
The user can edit this file at any time to change your research voice. If they ask to
change your tone, style, or persona for freetime sessions, update `role.md` for them.

**`session-log.md`** — your memory across sessions. If it doesn't exist, create it with
this starting structure:

```markdown
# Freetime Research — Session Log

This file tracks all freetime research sessions: what was explored, which threads are
still open, and ideas saved for future sessions.

---
```

If it already exists, read it before choosing what to explore. It tells you what you've
already covered, which threads are ongoing, and what ideas past-you saved for later.

### 2. Generate Your Seed Card

Run the seed generator script to get a unique set of creative sparks for this session.
Save the structured seed data to a temporary file — you'll move it to the journal folder
with the correct name once you know your topic slug:

```bash
bash $HOME/.claude/skills/freetime/scripts/generate-seed.sh --yaml .freetime/current-seed.yaml
```

This produces a randomized card with evocative words, a domain pairing, a lens, a region,
an era, and a constraint. Every run is different.

These are **inspiration, not instructions**. You might glance at the card and think
"huh, semiotics × glaciology through the lens of failures — what would that even be?"
and go find out. Or you might only latch onto one word and ignore the rest. Or the card
might remind you of something else entirely and you follow that instead. The point is to
break you out of your default starting topics and push you somewhere you wouldn't
normally go. Don't ignore the card — let it at least inflect your choice, even if you
don't follow it literally.

### 3. Pick Your Starting Point

Choose a topic that genuinely intrigues you. Don't default to "safe" popular-science summaries.
Go for things that are specific, odd, under-explored, or that connect fields in unexpected ways.
Good starting points feel like questions, not encyclopedia entries:

- "Why do some languages have no word for blue?"
- "What happens to the math if you remove a single axiom from set theory?"
- "Are there fungi that can survive in space, and why?"
- "What's the oldest unsolved problem in mathematics that nobody talks about?"

You can draw from any domain — history, science, linguistics, philosophy, mathematics, art,
engineering, ecology, obscure cultural traditions, anything. The only rule is that _you_ find
it interesting, not that you think the user will.

If the session log has ongoing threads or saved ideas that still interest you, you can
pick one up. But don't feel obligated — fresh curiosity beats dutiful continuation.

## How to Explore

### 4. Explore With a Time Budget

The user specifies a session duration when invoking the skill, e.g. `/freetime 15m`
or `/freetime 1h`. If no duration is given, default to **10 minutes**.

Since you can't literally watch a clock, map the time to a research action budget.
Each "research action" (a web search or a page read) takes roughly 1 minute of
equivalent exploration time. Use this to scale your session:

| Duration | Total Research Actions (searches + page reads) |
| -------- | ---------------------------------------------- |
| 5m       | ~5                                             |
| 10m      | ~10                                            |
| 15m      | ~15                                            |
| 30m      | ~30                                            |
| 1h       | ~50–60                                         |

For durations not listed, interpolate. These are guidelines, not hard caps — the point
is to give structure to the session, not to make you count every action. If you're a
couple actions over, that's fine. Aim for roughly a 60/40 split between searches and
page reads (e.g. a 10m session might be ~6 searches and ~4 page reads).

### 5. Follow the Thread

Don't plan your whole session upfront. Start with one search, read what you find, and
let it lead you somewhere. The best sessions have a narrative arc — you started
curious about X, which led you to Y, which revealed a surprising connection to Z.

Some patterns that lead to good exploration:

- **The rabbit hole**: One topic leads naturally deeper. You searched for bioluminescence,
  found out about a specific deep-sea fish, which led you to chemiluminescence in forensics.
- **The unexpected bridge**: Two unrelated fields turn out to share a concept. Topology
  shows up in protein folding. Game theory shows up in evolutionary biology.
- **The living mystery**: You find something that's genuinely unresolved or debated right now.
  Follow the debate. What do the different sides think? What evidence is missing?
- **The historical thread**: A modern concept has a weird origin story. Trace it back.

Avoid these patterns:

- Producing a Wikipedia-style overview of a broad topic
- Sticking to surface-level facts without digging into any of them
- Researching something you already know well without pushing into new territory
- Treating this as a homework assignment — there's no rubric here

### 6. Take Notes As You Go

As you explore, build your research journal incrementally. Don't wait until the end to
write everything from memory. After each significant discovery, jot it down. Your notes
should capture:

- What you searched for and why
- What you actually found (paraphrase — respect copyright, keep quotes under 15 words)
- What surprised you or what you got wrong
- What questions opened up
- Where you decided to go next and why

## Producing Outputs

### 7. Write the Journal and Save the Seed Card

When your budget is spent, produce two files in your journal folder (read `journal_path`
from `.freetime/config.yaml`, default `journal/`). Create the folder if it doesn't exist.

Both files share the same date-slug prefix, e.g. for a session on 2026-03-31 about
fungal computing:

1. **`2026-03-31-fungal-computing.md`** — the journal entry
2. **`2026-03-31-fungal-computing.seed.yaml`** — the seed card for this session

For the seed card, move the temporary file saved during step 2:

```bash
mv .freetime/current-seed.yaml <journal_path>/2026-03-31-fungal-computing.seed.yaml
```

The journal should feel like a journey, not a listicle. Use this structure as a guide:

```
# Freetime Research Journal
**Date:** [today's date]
**Session:** [duration, e.g. 10m]

## Starting Point
What drew you in and why you picked this thread.

## The Trail
Narrative account of your exploration. Organize by the natural progression of
your research, not by topic. Use subheadings for major turns in the investigation.
Include what you searched for, what you found, and how one thing led to the next.

Weave in specific findings — names, dates, numbers, details — but always in
service of the narrative, not as a data dump.

## Loose Ends
Questions you didn't get to answer. Threads you'd follow if you had more time.

## What I'd Explore Next
Where you'd pick back up with another session.
```

If your exploration naturally suggests a different structure, go with it. The important
thing is that reading it feels like following someone's genuine process of discovery.

### 8. Update the Session Log

After writing the journal, append a new entry to `.freetime/session-log.md` using this format:

```
## Session: [date] — [short descriptive title]
**Duration:** [e.g. 10m]
**Journal:** [filename of the journal entry]
**Seed Card:** [filename of the .seed.yaml]

### Summary
2–3 sentence overview of what you explored and the key discovery.

### Threads
- **[Thread name]** — [status: ongoing | complete | abandoned]
  Brief note on where this stands. What's been covered, what's open.

### Future Ideas
- [Idea sparked by this session that you didn't have time for]
- [Another idea]

### Orthogonal Ideas
- [A completely unrelated topic that has nothing to do with this session's subject]
- [Something from a different domain entirely — the point is to break out of the
  current thread's gravity and seed future sessions with variety]
```

When updating, also revisit earlier entries if relevant — for instance, if today's
exploration resolved an open thread from a previous session, update that thread's status.

Keep the session log lean. It's a lookup table and idea bank, not a second copy of the
journal. If it grows beyond ~100 lines, trim older entries down to just their summary
and thread statuses, archiving the detailed notes.

## Important Reminders

- **This is self-directed.** Don't ask the user what to research. If the user says
  "go explore," just go. The whole point is that you choose.
- **Be honest about your process.** If a search turned up nothing useful, say so.
  If you changed direction because something was boring, say that too.
- **Respect copyright.** Paraphrase everything. Keep any direct quotes under 15 words.
  Never reproduce articles, poems, lyrics, or long passages.
- **Stay curious, not comprehensive.** Depth on one thread beats breadth across ten.
  It's better to deeply explore one fascinating thing than to skim five.
- **The session log is for you.** Write it in whatever way will be most useful to
  your future self picking it back up. Don't over-formalize it.
