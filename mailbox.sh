#!/bin/sh

# Displays number of unread mail and an loading icon if updating.

unread="$(find ~/.local/share/mail/*/INBOX/new/* -type f | wc -l 2>/dev/null)"

icon="$(cat "/tmp/imapsyncicon_$USER")"

[ "$unread" = "0" ] && [ "$icon" = "" ] || echo "📬 $unread$(cat "/tmp/imapsyncicon_$USER" 2>/dev/null)"
