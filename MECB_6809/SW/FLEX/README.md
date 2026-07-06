# FLEX

FN09BOOT.DSK - FLEX 3.0 boot disk that can be used with a 6809 System

flex2fuji.py - a simple conversion script to convert original FLEX disks to a format FujiNet will accept.

lsflex.py - lists information associated with the FLEX disk and outputs a directory listing

FujiNet/. - Converted FLEX disks for use with FujiNet

To boot FLEX with FujiNet
1. run "./flex2fuji.py FN09BOOT.DSK", this will create a Fujinet compatible image (FN09BOOT.IMG) in the FujiNet sub-directory
2. copy the resultant FN09BOOT.IMG disk to the FujiNet SD or a TNFS.
3. in FujiNet, attach the disk (via SD or TNFS) to Drive Slot 2
4. In Assist09, load flex_load.hex onto the 6809 board
5. Run the loader - G C100
6. The loader should mount the Fujinet disks, load FLEX and start running the OS

