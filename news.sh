#!/bin/sh

# Displays number of unread news items and an loading icon if updating.

 cat /tmp/newsupdate 2>/dev/null || echo "$(newsboat -x print-unread | awk '{ print "📰 " $1}' | sed s/^0$//g)$(cat ~/.config/newsboat/.update 2>/dev/null)"
