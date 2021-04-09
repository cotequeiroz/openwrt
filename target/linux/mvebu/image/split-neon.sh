#!/bin/sh

cd target/linux/mvebu || {
  echo "Can't cd to target/linux/mvebu!" >&2
  echo "This must be run at the top dir." >&2
  exit 1
}
{ [ "$1" = "-f" ] || [ ! -e cortexa9neon ]; } && {
    echo "Performing full split." >&2
    git checkout Makefile || {
	echo "Can't restore Makefile via checkout" >&2
	exit 1
    }
    sed -i -Ee '/SUBTARGETS/s/cortexa9 cortexa53/cortexa9 cortexa9neon cortexa53/' Makefile || {
	echo "Can't add cortexa9neon to SUBTARGETS in Makefile" >&2
	exit 1
    }

    git rm -rf cortexa9neon || rm -rf cortexa9neon || {
	echo "Can't remove cortexa9neon dir!" >&2
	exit 1
    }
    mkdir cortexa9neon || {
	echo "Can't create cortexa9neon dir!" >&2
	exit 1
    }
    cd cortexa9neon || {
	echo "Can't cd to cortexa9neon dir!" >&2
	exit 1
    }

    ln -sf ../cortexa9/* . || {
	echo "Can't create symlinks from ../cortexa9" >&2
	exit 1
    }
    rm -f target.mk || {
	echo "Can't remove target.mk" >&2
	exit 1
    }
    sed -Ee '/BOARDNAME/s,(37x/|/XP),,g' \
	 -e '/CPU_SUBTYPE/s/vfpv3-d16/neon-fp16/' \
	 ../cortexa9/target.mk >target.mk || {
	echo "" >&2
	exit 1
    }
    sed -E -i '/BOARDNAME/s,/38x,,' ../cortexa9/target.mk || {
	echo "" >&2
	exit 1
    }
    cd ..
    sed -i -Ee '/^KernelPackage.*\/mvebu\/cortexa9=/{p;s,/mvebu/cortexa9=,/mvebu/cortexa9neon=,}' \
	../../../package/kernel/linux/modules/crypto.mk || {
	echo "Can't include crypto modules into package/kernel/linux/modules/crypto.mk" >&2
	exit 1
    }
    git add cortexa9/target.mk cortexa9neon Makefile \
	    ../../../package/kernel/linux/modules/crypto.mk || {
	echo "Error running 'git add cortexa9/target.mk cortexa9neon Makefile ../../../package/kernel/linux/modules/crypto.mk'" >&2
	exit 1
    }
}
cd image || {
    echo "Can't cd to image dir!" >&2
    exit 1
}

git rm -f cortexa9neon.mk || rm -f cortexa9neon.mk  || {
    echo "Can't remove cortexa9neon.mk" >&2
    exit 1
}
git checkout @ -- cortexa9.mk || {
    echo "Can't restore cortexa9 via checkout" >&2
    exit 1
}
./split-cortexa9.mk.pl || {
    echo "Error running split-cortexa9.mk.pl" >&2
    exit 1
}
git add cortexa9neon.mk cortexa9.mk || {
    echo "Error running 'git add cortexa9neon.mk cortexa9.mk'" >&2
    exit 1
}
echo 'All done!  Here is git status:' >&2
exec git status
