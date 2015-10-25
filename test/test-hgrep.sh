#!/usr/bin/env bash

. testlib.sh
HGREP=../hgrep.js
echo "hgrep tests started on" $(date)

HTML=./sample.html

# All tables
dtest hgrep.1 "cat $HTML | $HGREP table"

# All table rows
dtest hgrep.2 "cat $HTML | $HGREP tr"

# All table rows which contain at least one <td> whose text contains "Able"
dtest hgrep.3 "cat $HTML | $HGREP tr 'td:contains(Able)'"

# All table rows which have a descendant <a> whose href attribute contains '3'
dtest hgrep.4 "cat $HTML | $HGREP tr 'a[href*=3]'"

# All table data which have a descendant <a> whose href attribute contains '3'
dtest hgrep.5 "cat $HTML | $HGREP td 'a[href*=3]'"

# All tables which have a descendant <a> whose href attribute contains '3'
dtest hgrep.6 "cat $HTML | $HGREP table 'a[href*=3]'"

# Paragraph with class warning and containing text 'para'
dtest hgrep.7 "cat $HTML | $HGREP 'p.warning:contains(para)'"

# Address elements whose text contains 'Follow'
dtest hgrep.8 "cat $HTML | $HGREP 'a:contains(Follow)'"

# href attributes of all <a> elements
dtest hgrep.9 "cat $HTML | $HGREP -a href a"

# href attributes of all <a> elements whose text contains 'Follow'
dtest hgrep.10 "cat $HTML | $HGREP -a href 'a:contains(Follow)'"
# Text content of all <a> elements whose text contains 'Follow'
dtest hgrep.11 "cat $HTML | $HGREP -t 'a:contains(Follow)'"

# First (indexing starts from 0) <a> element
dtest hgrep.12 "cat $HTML | $HGREP -r 0 a"

# Last (negative indices start from the end) table row
dtest hgrep.13 "cat $HTML | $HGREP -r -1 tr"

# Slice 0:2 of table rows (first and second <tr> elements)
dtest hgrep.14 "cat $HTML | $HGREP -r 0:2 tr"

# Last row of first table
dtest hgrep.15 "cat $HTML | $HGREP -r 0 table | $HGREP -r -1 tr"

# Remove spans
dtest hgrep.16 "cat $HTML | $HGREP -v 'td span'"

# Remove table rows whose data contains 'INR'
dtest hgrep.17 "cat $HTML | $HGREP -v tr 'td:contains(INR)'"

# Last 2 table rows
dtest hgrep.18 "cat $HTML | $HGREP -r -2: tr"

# Penultimate table row
dtest hgrep.19 "cat $HTML | $HGREP -r -2:-1 tr"

# 2nd row onwards
dtest hgrep.20 "cat $HTML | $HGREP -r 1: tr"

# Strip 1st,2nd column of first table
dtest hgrep.21 "cat $HTML | $HGREP -r 0 table | $HGREP -v 'td:nth-child(-n+2)'"

# Check exit value
cat $HTML | $HGREP a.asd
expect $? 1 hgrep.22

cat $HTML | $HGREP -r 0 a >/dev/null
expect $? 0 hgrep.23
