#!/bin/bash
VER=cote-2023-01
ssh gateway mkdir -p /home/equeiroz/src/openwrt/www/${VER} || exit 1
ulimit -n 2048

LIST="mediatek ath79_mips74k mvebu ramips_mt7621 ramips_mt76x8 ramips_rt3883"
[ "$#" -ge 1 ] && LIST="$*"
for f in ${LIST}; do
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:rm bin build_dir staging_dir logs $(date)\007"
  rm -rf bin/* build_dir/t* staging_dir/t* logs/* staging_dir/packages
  sed -e "s/^\\(CONFIG_VERSION_NUMBER=\\).*/\\1\"${VER}\"/" "diffconfig.$f" >.config
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:make defconfig $(date)\007"
  make defconfig
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:make -j12 $(date)\007"
  make -j12 || {
    echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:tar logs $(date)\007"
    tar czf "log.$f.tar.gz" logs && \
        scp "log.$f.tar.gz" gateway:/home/equeiroz/src/openwrt/
    rm -f "log.$f.tar.gz"
    continue;
  }
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:tar packages targets $(date)\007"
  tar cf - -C bin packages targets | \
	ssh gateway tar xvf - -C /home/equeiroz/src/openwrt/www/${VER}
done
