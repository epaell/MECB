# FLEX

6800FLEX.DSK - FLEX 2.0 boot disk that can be used with a 6800/6802 System

FLEX3-DS.DSK - FLEX 3.0 boot disk that can be used with a 6800/6802 System

flex2fuji.py - a simple conversion script to convert original FLEX disks to a format FujiNet will accept.

lsflex.py - lists information associated with the FLEX disk and outputs a directory listing

FujiNet/. - Converted FLEX disks for use with FujiNet

To boot FLEX 2.0 with FujiNet
1. run "flex2fuji.py 6800FLEX.DSK", this will create a Fujinet compatible image (6800FLEX.IMG) in the FujiNet sub-directory
2. copy the resultant 6800FLEX.IMG disk to the FujiNet SD or a TNFS.
3. in FujiNet, attach the disk (via SD or TNFS) to Drive Slot 2
4. In DigiBug, load flex2_load.hex onto the 6800/6802 board
5. Run the loaded - J A100
6. The loader should mount the Fujinet disks, load FLEX and start running the OS

To boot FLEX 3.0 with FujiNet
1. run "./flex2fuji.py FLEX3-DS.DSK", this will create a Fujinet compatible image (FLEX3-DS.IMG) in the FujiNet sub-directory
2. copy the resultant FLEX3-DS.IMG disk to the FujiNet SD or a TNFS.
3. in FujiNet, attach the disk (via SD or TNFS) to Drive Slot 2
4. In DigiBug, load flex2_load.hex onto the 6800/6802 board
5. Run the loaded - J A100
6. The loader should mount the Fujinet disks, load FLEX and start running the OS

