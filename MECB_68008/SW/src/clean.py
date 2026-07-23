#!/usr/bin/env python

import glob

def clean(flist):
    for fname in flist:
        print(f"Processing {fname}")
        fin = open(fname, "r")
        lines = fin.readlines()
        fin.close()
        new_lines = []
        changed = False
        for line in lines:
            if line[0] == "*":
                new_line = ";"+line[1:]
                changed = True
            else:
                new_line = line
            new_lines.append(new_line)
        if changed == True:
            print(f"{fname} changed")
            fout = open(f"{fname}", "wt")
            for line in new_lines:
                fout.write(line)
            fout.close()
for ext in [".inc", ".asm", ".ASM", ".X68"]:
    clean(glob.glob(f"*{ext}"))