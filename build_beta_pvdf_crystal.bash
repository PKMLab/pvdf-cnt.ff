#!/usr/bin/env bash
# Ref: Zhu et al. 2008, Comput. Mat. Sci. 44, 224-229
# Usage: ./build_beta_pvdf_crystal.bash <path to .gro file of single chain/molecule> [<distance between solute and box>=0.491/2(nm)]
set -e
mol_gro="${1}" # .gro file of molecule (beta pvdf)
gap="${2:-0.2455}"
tmpfile="$(mktemp -u).gro"
gmx editconf -princ -rotate 0 90 0 -o "${tmpfile}" -f "${mol_gro}" -c # Align principal axes of a single molecule - long axis along z and C-F-F bisector along Y
gmx genconf -norot -nbox 5 5 1 -dist 0.850 0.491 0 -f "${tmpfile}" -o assemble_1.gro # Build first rectangular grid from single molecules
gmx editconf -translate 0.425 0.2455 0 -f assemble_1.gro -o assemble_2.gro # Shift the first grid in the X-Y plane to get the second grid
# Superimpose both grids to get the quasi hexagonal lattice
natoms="$(sed -n 2p assemble_1.gro)"
natoms="$((natoms*2))"
echo -e PVDF\\n$natoms > assembly.gro
head -n -1 assemble_1.gro | tail -n +3 >> assembly.gro
head -n -1 assemble_2.gro | tail -n +3 >> assembly.gro
echo 0.0 0.0 0.0 >> assembly.gro # Dummy box size to make the file legit .gro
# Setup Box dimensions
gmx editconf -f assembly.gro -o crystal.gro -bt triclinic -angles 90.0 90.0 90.0 -d "${gap}" -resnr 1 # Note the -resnr option to renumber the residues
rm "${tmpfile}" assemble_1.gro assemble_2.gro assembly.gro # Cleanup

