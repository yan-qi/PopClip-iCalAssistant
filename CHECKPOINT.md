## Checkpoint: PopClip iCal Assistant - Initial Scaffold & Stabilization (2025-08-09)

Summary of what’s implemented and configured so far:

- Extension bundle: `iCalAssistant.popclipext/`
  - `Config.plist`
    - Action “Add to Calendar”; After: `show-status` (does not overwrite selection)
    - Options: provider (Ollama/OpenAI), api key (secret), endpoint, model, ollama model (default `deepseek-r1:latest`), default calendar, default duration, timezone, alerts, confirm (boolean), debug (boolean)
    - Icons: `Icon File` set to `icon.png` at bundle and action level
  - `add_event.sh`
    - Reads selection from `$POPCLIP_TEXT`, falls back to clipboard
    - Validates provider readiness (Ollama reachable or API key present)
    - Invokes JXA with env; pipes stdout/stderr to PopClip status
  - `add_event.jxa`
    - Reads options & selection from environment
    - Builds LLM prompt (strict JSON schema)
    - LLM providers: Ollama via curl (default model `deepseek-r1:latest`), OpenAI via curl (JSON mode)
    - Robust fallback: if LLM fails, creates a simple event (now + default duration)
    - Event creation via AppleScript bridge executed from JXA for maximum macOS compatibility
    - Logs steps and displays macOS notification on success
  - `icon.png` included and wired up

Important decisions:
- Use AppleScript to create Calendar events (more stable than Calendar JXA across macOS versions)
- `show-status` to avoid overwriting selection content
- Default local provider: Ollama with `deepseek-r1:latest`
- Networking via `/usr/bin/curl` in JXA using `doShellScript` for reliability

Open items / next steps:
- Re-enable alerts and attendees after baseline reliability confirmed
- Add provider adapters for Anthropic, Gemini (OpenAI-compatible or native)
- Add confirmation dialog option prior to creation
- Enhance parsing: better timezone resolution, natural language date edges
- Add unit-ish test harness (scriptable samples)
- Optional: ICS export to file when Calendar is unavailable

How to run now:
- Install the bundle by opening `iCalAssistant.popclipext`
- Set provider & options (Ollama: ensure it runs; OpenAI: set API key)
- Select text and run the action; check Calendar and notification
