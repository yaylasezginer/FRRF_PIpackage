# FRRF_PIpackage
FRRF PI curve analysis

This package contains scripts needed to get started analyzing FRRF photosynthesis-irradiance curve data.

Step 1. Read and compile FRRF soliense .csv output data. use script: FRRFread
2. Identify complete FRRF PI curves (i.e. data for each light step) within the compiled frrf data. script: PIfind
3. In a loop, fit a photosynthesis-irradiance model to data and save resulting PIparameters. script: FRRF_PIanalysis and PvI_ys4
