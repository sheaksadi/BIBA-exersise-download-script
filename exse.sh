#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: .env file not found at $ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <week> <exercise(s)>"
  echo "  Example (single):   $0 1 1"
  echo "  Example (multiple): $0 1 1,2,3"
  exit 1
fi

WEEK="$1"
EXERCISES="$2"

COOKIE_FILE="$(mktemp /tmp/aud_session_XXXXXX.txt)"

echo "Logging in..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -c "$COOKIE_FILE" \
  -X POST \
  -d "user=${USER}&password=${PASSWORD}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  "${BASE_URL}/users/login")

if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "302" && "$HTTP_STATUS" != "303" ]]; then
  echo "Error: Login failed (HTTP $HTTP_STATUS)"
  rm -f "$COOKIE_FILE"
  exit 1
fi

echo "Login successful."

# ── Download each exercise ─────────────────────────────────────────────────────
IFS=',' read -ra EXERCISE_LIST <<< "$EXERCISES"

for EXERCISE in "${EXERCISE_LIST[@]}"; do
  WEEK_PADDED=$(printf "%02d" "$WEEK")

  URL="${BASE_URL}/assignment/a0${WEEK}${EXERCISE}/templates.zip"
  OUTPUT_DIR="week${WEEK}/exercise${EXERCISE}"
  ZIP_FILE="week${WEEK}/exercise${EXERCISE}.zip"

  echo ""
  echo "Downloading week ${WEEK}, exercise ${EXERCISE}..."
  echo "  URL: $URL"
  echo "  Output: $ZIP_FILE"

  mkdir -p "$OUTPUT_DIR"

  HTTP_STATUS=$(curl -s -o "$ZIP_FILE" -w "%{http_code}" \
    -b "$COOKIE_FILE" \
    "$URL")

  if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "  Error: Download failed (HTTP $HTTP_STATUS)"
    rm -f "$ZIP_FILE"
    continue
  fi

  echo "  Download complete. Extracting..."
  unzip -q "$ZIP_FILE" -d "$OUTPUT_DIR"

  if [[ $? -eq 0 ]]; then
    echo "  Extracted to: $OUTPUT_DIR/"
    rm -f "$ZIP_FILE"
  else
    echo "  Error: Extraction failed."
  fi

done

rm -f "$COOKIE_FILE"
echo ""
echo "Done."
