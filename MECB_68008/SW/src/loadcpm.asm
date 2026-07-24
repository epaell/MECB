;
; Move CPM400 binary to the destination
; a1.l = destination
; d0.b = 1 : CPM 1.1
; d0.b = 2 : CPM 1.2
; d0.b = 3 : CPM 1.3
;
mv_cpm400bin:
         cmp.b    #1,d0
         beq      mv_cpm400bin1
         cmp.b    #2,d0
         beq      mv_cpm400bin2
         cmp.b    #3,d0
         beq      mv_cpm400bin3
         rts                        ; unknown version
mv_cpm400bin1:
         move.l   #CPM400_v1_1_start,a0
         move.w   #CPM400_v1_1_end-CPM400_v1_1_start,d0
         bra      mv_cpm400bin_exec
mv_cpm400bin2:
         move.l   #CPM400_v1_2_start,a0
         move.w   #CPM400_v1_2_end-CPM400_v1_2_start,d0
         bra      mv_cpm400bin_exec
mv_cpm400bin3:
         move.l   #CPM400_v1_3_start,a0
         move.w   #CPM400_v1_3_end-CPM400_v1_3_start,d0

mv_cpm400bin_exec:
         move.b   (a0)+,(a1)+
         dbra     d0,mv_cpm400bin_exec
         rts

;
; Move CPM15000 binary to the destination specified in a1
; d0.b = 1 : CPM 1.1
; d0.b = 2 : CPM 1.2
; d0.b = 3 : CPM 1.3
;
mv_cpm15000bin:
         cmp.b    #1,d0
         beq      mv_cpm15000bin1
         cmp.b    #2,d0
         beq      mv_cpm15000bin2
         cmp.b    #3,d0
         beq      mv_cpm15000bin3
         rts                        ; unknown version
mv_cpm15000bin1:
         move.l   #CPM15000_v1_1_start,a0
         move.w   #CPM15000_v1_1_end-CPM15000_v1_1_start,d0
         bra      mv_cpm15000bin_exec
mv_cpm15000bin2:
         move.l   #CPM15000_v1_2_start,a0
         move.w   #CPM15000_v1_2_end-CPM15000_v1_2_start,d0
         bra      mv_cpm15000bin_exec
mv_cpm15000bin3:
         move.l   #CPM15000_v1_3_start,a0
         move.w   #CPM15000_v1_3_end-CPM15000_v1_3_start,d0

mv_cpm15000bin_exec:
         move.b   (a0)+,(a1)+
         dbra     d0,mv_cpm15000bin_exec
         rts
