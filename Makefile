VERSION_0 = 0
VERSION_1 = 1
VERSION_2 = 0
BRANCH = $(VERSION_0).$(VERSION_1)
VERSION = $(BRANCH).$(VERSION_2)
REBOOT = 10		# ROM/RAM mode.
REBOOT = 210

LANG=
export MAX_SIZE=fb00

SRC = *.fr t-load

RCS = *.fr Makefile .build t-load

all:	llorri-boot.bin

# For rom/ram version, reboot is at 010.
# for ram only version, reboot is at 210.
# Note two places to change below, though 2nd is probably ignoreable.

# NOTE: MAY NOT BE VALID FOR NON-BOOT LAUNCH.

llorri-boot.bin: $(SRC)
	make version
	build
	@- /bin/echo -n "Build #" ; cat .build.num

	@-export BUILD=`cat .build.num` ; set -x +x ; \
	    /bin/cp llorri-boot.bin SREC/llorri.bin.$${BUILD} ; \
	    motor -d 5c0000 -g 5c0000 llorri-boot.bin > SREC/llorri.mot.$${BUILD} ; \
	    /bin/cp SREC/llorri.mot.$${BUILD} SREC/llorri-e.mot.latest ; \
	    motor -d 000000 -g 000000 llorri-boot.bin > llorri-boot.00.srec ; \
	    motor -d 1c0000 -g 1c0000 llorri-boot.bin > llorri-boot.1c.srec ; \
	    motor -d 5c0000 -g 5c0000 llorri-boot.bin > llorri-boot.5c.srec ; \
	    motor -d 5f0000 -g 5f0000 llorri-boot.bin > llorri-boot.5f.srec


clean:
	/bin/rm -f llorri-boot.bin

version:
	@- touch .cksum
	@- cat $(SRC) | cksum > .cksum_0
	@- if ( ! cmp -s .cksum .cksum_0 ) ; then \
	    date +%F\ %X\ `hostname` > .stamp ; \
	    cat .stamp >> .build ; \
	    export BUILD=`cat .build | wc -l ` ; \
	    cat $(SRC) | cksum > .cksum ; \
	    ci -q -l$(VERSION).$${BUILD} -m${VERSION}.$${BUILD} -t.stamp $(RCS) ; \
	    echo -n "New " ; \
	fi
	@- /bin/rm -f .cksum_0

	@- export BUILD=`cat .build | wc -l ` ; \
	    /bin/echo $${BUILD} > .build.num ; \
	    /bin/echo "d# $${BUILD} constant #sw-build" > .version.fr ; 

	@- /bin/echo -n "Build #" ; cat .build.num

rcs:
	export BUILD=`cat .build.num` ; \
	ci -f -l$(BRANCH) -m${BRANCH} -t.stamp $(RCS) ; \
	ci -f -l$(VERSION).$${BUILD} -m${VERSION}.$${BUILD} -t.stamp $(RCS)
