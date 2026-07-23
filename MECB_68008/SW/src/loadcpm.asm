;
; Move CPM0400 binary to the destination specified in a1
;
mv_cpm400:
         move.l   #CPM400_start,a0
         move.w   #CPM400_end-CPM400_start,d0
mv_cpm400b:
         move.b   (a0)+,(a1)+
         dbra     d0,mv_cpm400b
         rts

;
; Move CPM15000 binary to the destination specified in a1
;
mv_cpm15000:
         move.l   #CPM15000_start,a0
         move.w   #CPM15000_end-CPM15000_start,d0
mv_cpm15000b:
         move.b   (a0)+,(a1)+
         dbra     d0,mv_cpm15000b
         rts
