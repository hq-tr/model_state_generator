# General model state generator script

## Introduction
This repository contains the script for a common procedure used for generating a model state in FQH study. The procedure is as follows:
1. Input with a "starter" state, which is given as a collection of monomials and the corresponding coefficients.
2. (Optional) append to the beginning of each monomial a certain binary string. The string could be empty, in which case no addition is made.
3. (Optional) normalize the starter state. This is only necessary if the starter state is a pure Jack polynomial.
4. Take another input, which is a list of monomials.
5. The output is a basis that consist of the starter state in step 1, along with all monomials in step 3 that do not appear in the starter state. Each monomial is saved as a separate state

## Using the script
### Pre-requisite
The script requires the [QHE_Julia](https://github.com/hq-tr/QHE_Julia) script. Modify the preamble in `model_state_gen_v2.jl` to link to the right script.

### Input paramters
To see the available parameters and the corresponding flags, use

```
julia model_state_gen_v2.jl -h
```

### Recommendation
To keep the working folder tidy, it is suggested that the starter state, list of monomials, and output are contained in separate sub-directories. The subdirectories `starter`, `squeezed`, and `output` have been created for that purpose.

### Example run
The necessary input files for an example run is included. This creates a basis necessary for constructing the Laughlin quasielectron state (following [arXiv:1308.4920](https://arxiv.org/abs/1308.4920)). Run the example with

```
julia model_state_gen_v2.jl -i starter/J_1001001001001001 -a 11000 --normalize -m squeezed/squeeze_110001001001001001001 --output-format decimal --full -o "output/qe_basis_8e"
```
