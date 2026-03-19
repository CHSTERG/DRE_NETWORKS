This repository contains the scripts used to generate the networks presented in:

Christos Stergiadis, David M. Halliday, Dimitrios Kazis, Manousos A. Klados. High-frequency directed networks can identify epileptogenic tissue and predict surgical outcome in drug-resistant epilepsy.

## Files
- step1_compute_connectivity.m : Computes the connectivity matrices using direct Directed Tranfer Function (dDTF). The computation of the correponding matrices for orthogonalized Amplitute Envelope Correlation (oAEC) was implemented in Brainstorm, as mentioned in the publication.
- step2_compute_metrics.m : Generates the networks, by comptutimg the local graph measures at each iEEG electrode, corresponding to the oAEC-based and dDTF-based connectivity matrices.

## Requirements
MATLAB / FieldTrip / Brain Connectivity Toolbox
