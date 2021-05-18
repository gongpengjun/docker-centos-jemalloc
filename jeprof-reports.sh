#!/bin/bash

jeprof --svg /tmp/jeprof.* > /tmp/jprof/jeprof-report.svg 2>/dev/null
jeprof --text /tmp/jeprof.* > /tmp/jprof/jeprof-report.txt 2>/dev/null
