#!/bin/bash
# الاستخدام: ./scripts/opencode_sync.sh A01 "رسالة الإنجاز"
flutter test && \
bd close $1 --reason "$2" && \
git add . && \
git commit -m "[$1] $2" && \
bd compact && \
bd sync
