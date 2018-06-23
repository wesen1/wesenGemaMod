#!/bin/bash
# Runs the unit tests and prints the coverage summary

lua testSuite.lua
echo ""
sed -ne "/File.*Hits.*Missed.*Coverage/,$ p" luacov.report.out
