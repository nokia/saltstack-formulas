#!/usr/bin/env bash

(ls -t | grep 'log.INFO.*'|head -n {{ max_files }};ls) | sort | uniq -u | grep 'log.INFO.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.WARNING.*'|head -n {{ max_files }};ls) | sort | uniq -u | grep 'log.WARNING.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.ERROR.*'|head -n {{ max_files }};ls) | sort | uniq -u | grep 'log.ERROR.*'|xargs --no-run-if-empty rm
