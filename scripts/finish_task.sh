#!/bin/bash
# الاستخدام: ./scripts/complete.sh A01 "رسالة الإغلاق"
bd close $1 --reason "$2"
git add .
git commit -m "[$1] $2"
bd compact
