#!/bin/bash

nmt-tools/nmt-parser.py --files reports/nmt*.out --mode committed | column -t -s ';'

