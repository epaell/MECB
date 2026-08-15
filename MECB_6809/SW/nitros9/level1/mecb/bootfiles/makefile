include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

BOOTFILE = $(MD)/ioman $(MD)/sysgo \
		$(MD)/clock $(MD)/clock2_mecbfn \
		$(MD)/scf.mn \
		$(MD)/sc6850.dr $(MD)/term_sc6850.dt \
		$(MD)/rbf.mn \
		$(MD)/rbmecbfn.dr $(MD)/ddh0.dd $(MD)/h1.dd $(MD)/h2.dd $(MD)/h3.dd \
		$(CMDSDIR)/shell_21

BOOTFILES	= bootfile

ALLOBJS		= $(BOOTFILES)

all:	$(ALLOBJS)

bootfile: $(BOOTFILE) $(DEPENDS)
	$(MERGE) $(BOOTFILE)>$@

clean:
	$(RM) $(ALLOBJS)

