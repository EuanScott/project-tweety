# Can Claude Code in Ghostty use the global ~/.claude output style?

Researched to answer: the user hit `Unknown command: /output-style` in Claude Code
running inside Ghostty, after being told to run it to check/switch output styles. Is
this a Ghostty problem, and does a global `~/.claude` output-style setting apply
automatically?

**Direct answer: yes, and it has nothing to do with Ghostty.** Output styles are a
terminal-agnostic settings/system-prompt feature — Claude Code never inspects which
terminal emulator is hosting it to decide whether output styles work. A style set in
the global `~/.claude/settings.json` applies to every project and session by default,
same as any other user-scope setting, unless a project or local settings file
overrides it. The `Unknown command` error is a **version issue, not an environment
issue**: `/output-style` as a standalone slash command was deprecated in Claude Code
v2.1.73 and fully removed in v2.1.91. The user's installed CLI is v2.1.220 (checked via
`claude --version` during this research), well past removal — so the command no longer
exists, in Ghostty or any other terminal. The fix is to use `/config` → **Output
style**, or edit the `outputStyle` field directly in a settings file.

## 1. What output styles are and where they're configured

Per the official docs page ([Output styles — code.claude.com](https://code.claude.com/docs/en/output-styles)):

- Output styles modify Claude Code's **system prompt** — role, tone, and output format
  — not what Claude knows. They're unrelated to CLAUDE.md (project conventions) or
  `--append-system-prompt` (one-off additions).
- Four built-in styles: **Default**, **Proactive**, **Explanatory**, **Learning**.
- Change it via `/config` → **Output style**. The selection is saved to
  `.claude/settings.local.json` at the **local project level** by default when picked
  through the menu — but the underlying mechanism is just the `outputStyle` field in
  any settings file:

  ```json
  { "outputStyle": "Explanatory" }
  ```

- Custom output styles are Markdown files (frontmatter + instructions), loadable from
  three levels: user (`~/.claude/output-styles`), project (`.claude/output-styles`),
  and managed policy. Plugins can also ship them.
- Output style is read **once at session start**; changes take effect after `/clear`
  or a new session, not mid-session.

## 2. Terminal-agnostic — confirmed, not inferred

Nothing in the output-styles doc, the settings doc, or the changelog references
terminal emulators at all. Output styles are a system-prompt/settings mechanism, not a
rendering feature (unlike things like the statusline or keybindings, which do interact
with terminal capabilities). There is no Ghostty-specific gate, flag, or known
incompatibility in the official docs. The `Unknown command` error is explained
entirely by CLI version, below.

## 3. Why `/output-style` reports "Unknown command"

Straight from the docs page ([Output styles — code.claude.com](https://code.claude.com/docs/en/output-styles)):

> The standalone `/output-style` command was deprecated in v2.1.73 and removed in
> v2.1.91. Use `/config` or edit the `outputStyle` setting directly.

The user's local `claude --version` reports **2.1.220** — over a hundred patch
versions past removal, so the command genuinely does not exist anymore; this isn't a
rollout gap, an install-channel difference, or a settings-gated feature. Community
write-ups corroborate the same removal/replacement story (e.g. searches surfacing
"older versions used a standalone `/output-style` command... current versions use the
settings menu" — consistent with, and secondary to, the primary docs statement above).

Separately, the changelog history shows Anthropic briefly **deprecated the entire
output-styles feature** around v2.0.30 (Oct 31, 2025) and reversed that four days later
in v2.0.32 after community pushback — that episode is about the feature's existence,
not the slash command, and predates the later `/output-style` command removal in
v2.1.73–2.1.91. No distinction between "Claude Code CLI" vs. SDK-based agents, VS Code
extension, or the web harness was needed to explain the error — this is a plain CLI
version fact, reproducible identically in any terminal.

## 4. Does global `~/.claude` scope apply automatically?

Yes. Per the settings docs ([Settings — code.claude.com](https://code.claude.com/docs/en/settings)),
precedence top to bottom is:

1. **Managed** (enterprise policy) — always wins
2. **Command-line arguments** — session override
3. **Local** (`.claude/settings.local.json`) — overrides project and user
4. **Project** (`.claude/settings.json`) — overrides user
5. **User** (`~/.claude/settings.json`) — applies whenever nothing more specific sets it

So an `outputStyle` set in the global `~/.claude/settings.json` is the effective
default for every project/session unless a project-level or local-level settings file
(or the `/config` menu, which writes to `.claude/settings.local.json`) overrides it.
This is exactly why picking a style via `/config` inside one project can silently
shadow the global choice for that project only — the menu writes to the local file,
which sits above user scope in precedence.

## 5. Practical takeaway for the user

- Ignore `/output-style` — it's gone as of v2.1.91, current version is 2.1.220.
- Run `/config`, select **Output style**, confirm/change it there. It will apply on
  the next `/clear` or session restart.
- To verify the global default is actually taking effect in a given project, check for
  a competing `outputStyle` key in that project's `.claude/settings.json` or
  `.claude/settings.local.json` — either would shadow the global `~/.claude/settings.json`
  value per the precedence order above.
- Ghostty is not a factor at any point in this chain.

## Sources

- [Output styles — code.claude.com/docs/en/output-styles](https://code.claude.com/docs/en/output-styles)
  (built-in styles, `/config` flow, `/output-style` deprecation/removal versions,
  file-based `outputStyle` config, custom style file locations, session-start-only
  reload behavior)
- [Settings — code.claude.com/docs/en/settings](https://code.claude.com/docs/en/settings)
  (settings-file precedence order; `outputStyle` reload-on-restart caveat)
- Local environment check: `claude --version` → `2.1.220 (Claude Code)`
