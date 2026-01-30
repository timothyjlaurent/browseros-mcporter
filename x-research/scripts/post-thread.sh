#!/bin/bash
# Post a tweet thread from a markdown file
# Format: Each tweet separated by "---" on its own line

set -e

FILE="${1:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <markdown-file>"
  echo ""
  echo "Format: Separate tweets with '---' on its own line"
  echo ""
  echo "Example:"
  echo "  First tweet here..."
  echo "  ---"
  echo "  Second tweet here..."
  echo "  ---"
  echo "  Third tweet..."
  exit 1
fi

# Check if bird is configured
if ! bird whoami &>/dev/null; then
  echo "❌ bird CLI not configured"
  echo "💡 Run: ./scripts/bird-quick-setup.sh"
  echo "   Or just login to https://x.com and run: bird check"
  exit 1
fi

echo "📝 Posting thread from: $FILE"
echo ""

# Parse file and post tweets
TWEET_COUNT=0
FIRST_TWEET_ID=""
CURRENT_TWEET=""

while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" == "---" ]]; then
    # Post current tweet
    if [ -n "$CURRENT_TWEET" ]; then
      TWEET_COUNT=$((TWEET_COUNT + 1))

      # Clean up tweet text (remove leading/trailing whitespace, empty lines)
      CURRENT_TWEET=$(echo "$CURRENT_TWEET" | sed '/^$/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' )

      if [ $TWEET_COUNT -eq 1 ]; then
        echo "📤 Posting tweet $TWEET_COUNT..."
        OUTPUT=$(bird tweet "$CURRENT_TWEET" 2>&1)
        FIRST_TWEET_ID=$(echo "$OUTPUT" | grep -oP 'x.com/\K[0-9]+' || echo "$OUTPUT" | grep -oP 'status/\K[0-9]+')

        if [ -z "$FIRST_TWEET_ID" ]; then
          echo "❌ Failed to post first tweet"
          echo "   Output: $OUTPUT"
          exit 1
        fi

        echo "   ✅ Posted: https://x.com/i/status/$FIRST_TWEET_ID"
      else
        echo "📤 Posting tweet $TWEET_COUNT..."
        bird reply "$FIRST_TWEET_ID" "$CURRENT_TWEET" &>/dev/null
        echo "   ✅ Posted (reply to $FIRST_TWEET_ID)"
      fi

      CURRENT_TWEET=""
    fi
  else
    # Accumulate tweet text
    CURRENT_TWEET="$CURRENT_TWEET"$'\n'"$line"
  fi
done < "$FILE"

# Post last tweet if file doesn't end with ---
if [ -n "$CURRENT_TWEET" ]; then
  TWEET_COUNT=$((TWEET_COUNT + 1))
  CURRENT_TWEET=$(echo "$CURRENT_TWEET" | sed '/^$/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' )

  if [ $TWEET_COUNT -eq 1 ]; then
    echo "📤 Posting tweet $TWEET_COUNT..."
    OUTPUT=$(bird tweet "$CURRENT_TWEET" 2>&1)
    FIRST_TWEET_ID=$(echo "$OUTPUT" | grep -oP 'x.com/\K[0-9]+' || echo "$OUTPUT" | grep -oP 'status/\K[0-9]+')

    if [ -z "$FIRST_TWEET_ID" ]; then
      echo "❌ Failed to post tweet"
      echo "   Output: $OUTPUT"
      exit 1
    fi

    echo "   ✅ Posted: https://x.com/i/status/$FIRST_TWEET_ID"
  else
    echo "📤 Posting tweet $TWEET_COUNT..."
    bird reply "$FIRST_TWEET_ID" "$CURRENT_TWEET" &>/dev/null
    echo "   ✅ Posted (reply to $FIRST_TWEET_ID)"
  fi
fi

echo ""
echo "🎉 Thread complete! $TWEET_COUNT tweets posted."
echo "🔗 View: https://x.com/i/status/$FIRST_TWEET_ID"
