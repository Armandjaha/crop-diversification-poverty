*==================================================
* 00_setup.do — It guarantees that all scripts will run correctly, regardless of the computer, as long as Stata is launched from the repository's root directory.
*==================================================

* 1. Initialize environment
clear all
set more off
set linesize 255
version 17

* 2. Define the project paths
global ROOT "data\raw"
global OUT  "output"
global CODE "code"

* 3. Create output folders
cap mkdir "$OUT"
cap mkdir "$OUT/tables"
cap mkdir "$OUT/figures"
cap mkdir "$OUT/logs"

* 4. Check that we're in the repo root
capture confirm file "$CODE/00_setup.do"
if _rc {
    di as error "Cannot find code/00_setup.do in current folder."
    di as error "Set working directory to the repository root (the folder containing 'code' and 'data')."
    di as error "Tip: in Stata, use: pwd "
    exit 198
}


di as txt "Setup OK. ROOT=$ROOT | OUT=$OUT"
