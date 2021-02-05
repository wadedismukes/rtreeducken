#!/usr/bin/env sh

## Run an R command within LLDB, in batch mode.
: ${R_HOME="$(cd `R RHOME`; pwd -P)"}
: ${R_EXEC="${R_HOME}/bin/exec/R"}

R_HOME=${R_HOME} lldb --batch --file "${R_EXEC}" -o "process launch -- $1"
