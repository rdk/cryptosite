#!/usr/bin/env python

"""Evaluate SOAP score for each AllosMod model."""

from __future__ import print_function, absolute_import
import glob
import optparse

def soap_score():
    import modeller
    from modeller.scripts import complete_pdb
    from modeller import soap_protein_od

    env = modeller.environ()
    env.libs.topology.read(file='$(LIB)/top_heav.lib')
    env.libs.parameters.read(file='$(LIB)/par.lib')

    # Set up SOAP-Protein-OD scoring (we create the scorer once and keep it
    # around, since reading in the potential from disk can take a long time).
    sp = soap_protein_od.Scorer()

    out = open('SnapList.txt','w')

    cnt = 0
    files = [i for i in glob.glob('pm.pdb*.pdb')
             if 'pm.pdb.B10010002.pdb' not in i]
    for fil in files:

        try:
            cnt += 1
            # Read a model previously generated by Modeller's automodel class
            mdl = complete_pdb(env, fil)
            # Select all atoms
            atmsel = modeller.selection(mdl)

            # Assess with the above Scorer
            try:
                score = atmsel.assess(sp)
                out.write(fil+'\t'+str(score)+'\n')
            except modeller.ModellerError:
                print("The SOAP-Protein-OD library file is not included "
                      "with MODELLER.")
                print("Please get it from https://salilab.org/SOAP/.")
        # Was 'except: pass' but this will hide genuine errors. Replace with
        # a more specific list of exceptions (and test)
        except: raise

    out.close()

def parse_args():
    usage = """%prog [opts]

Evaluate SOAP-Protein score for each AllosMod model in the current directory.
A new file SnapList.txt is created which tabulates this score for each model.
This file is used as input by 'cryptosite am_bmi' and 'cryptosite pockets'.

Note that the SOAP-Protein potential is not included with MODELLER; it can
be downloaded separately from https://salilab.org/SOAP/.
"""
    parser = optparse.OptionParser(usage)
    opts, args = parser.parse_args()
    if len(args) != 0:
        parser.error("incorrect number of arguments")

def main():
    parse_args()
    soap_score()

if __name__ == '__main__':
    main()
