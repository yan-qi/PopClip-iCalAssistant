#!/usr/bin/env bash
set -uo pipefail

# PopClip passes selection in $POPCLIP_TEXT and options via POPCLIP_OPTION_* env vars
SEL_TEXT=${POPCLIP_TEXT:-}
PROVIDER=${POPCLIP_OPTION_PROVIDER:-"Ollama (local)"}
API_KEY=${POPCLIP_OPTION_API_KEY:-}
ENDPOINT_URL=${POPCLIP_OPTION_ENDPOINT_URL:-"https://api.openai.com/v1"}
MODEL=${POPCLIP_OPTION_MODEL:-"gpt-4o-mini"}
OLLAMA_MODEL=${POPCLIP_OPTION_OLLAMA_MODEL:-"deepseek-r1:latest"}
DEFAULT_CAL=${POPCLIP_OPTION_DEFAULT_CALENDAR:-}
DEFAULT_DUR=${POPCLIP_OPTION_DEFAULT_DURATION_MINUTES:-60}
DEFAULT_TZ=${POPCLIP_OPTION_DEFAULT_TIMEZONE:-}
ALERTS=${POPCLIP_OPTION_ALERTS_MINUTES_BEFORE_START:-"60,10"}
CONFIRM=${POPCLIP_OPTION_CONFIRM_BEFORE_CREATE:-1}
DEBUG=${POPCLIP_OPTION_DEBUG_LOGGING:-0}

if [[ -z "$SEL_TEXT" ]]; then
  # Fallback to clipboard when 'Before: copy' is used
  if command -v pbpaste >/dev/null 2>&1; then
    SEL_TEXT=$(pbpaste)
  fi
fi

# Provider sanity checks for clearer UX
if [[ "$PROVIDER" == Ollama* ]]; then
  if ! curl -fsS "http://localhost:11434/api/version" >/dev/null 2>&1; then
    echo "Error: Ollama not reachable at http://localhost:11434. Start Ollama (e.g. 'ollama serve') or switch provider to OpenAI in the extension options."
    exit 0
  fi
else
  if [[ -z "$API_KEY" ]]; then
    echo "Error: Missing API Key. Set your API key in the extension options or switch provider to Ollama."
    exit 0
  fi
fi

## Run the JXA script and surface all output to PopClip
set +e
OUTPUT=$(POPCLIP_TEXT="$SEL_TEXT" /usr/bin/osascript -l JavaScript "$(dirname "$0")/add_event.jxa" \
  --provider "$PROVIDER" \
  --apiKey "$API_KEY" \
  --endpoint "$ENDPOINT_URL" \
  --model "$MODEL" \
  --ollamaModel "$OLLAMA_MODEL" \
  --defaultCalendar "$DEFAULT_CAL" \
  --defaultDuration "$DEFAULT_DUR" \
  --defaultTimezone "$DEFAULT_TZ" \
  --alerts "$ALERTS" \
  --confirm "$CONFIRM" \
  --debug "$DEBUG" 2>&1)
RC=$?
echo "$OUTPUT"
exit 0
