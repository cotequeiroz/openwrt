#!/bin/bash
# shellcheck disable=SC2029
VER="$(git branch --show-current)"
VER="${VER//[!-[:alnum:]]/_}"
SSH_OPTS=(-o BatchMode=yes)
TAR_BIN_OPTS=()
TAR_LOG_OPTS=()

ssh "${SSH_OPTS[*]}" gateway "mkdir -p \"/home/equeiroz/src/openwrt/www/${VER}\"" || exit 1
ulimit -n 8192

NPROC=$(nproc)
#LIST="filogic mt7622 ath79 mvebu ramips"
LIST="filogic mt7622 ath79 mvebu"
[ "$#" -ge 1 ] && LIST="$*"
for f in ${LIST}; do
  sed -e "s/^\\(CONFIG_VERSION_NUMBER=\\).*/\\1\"${VER}\"/" "diffconfig.$f" >.config
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:rm bin/t\* logs/\* staging_dir/pacakges $(date)\007"
  rm -rf bin/t* logs/* staging_dir/packages
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:make -j${NPROC} defconfig $(date)\007"
  make "-j${NPROC}" defconfig
  ARCH_PACKAGES=$(sed -ne '/CONFIG_TARGET_ARCH_PACKAGES=/{s/.*=\|\"//g;p}' .config)
  [ "$ARCH_PACKAGES" != "$PREV_ARCH_PACKAGES" ] && {
    echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:make package/postgresql/host/clean $(date)\007"
    make package/postgresql/host/clean
    echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:rm bin/\* build_dir/\* staging_dir/t* $(date)\007"
    rm -rf bin/* build_dir/t* staging_dir/t* staging_dir/packages
    PREV_ARCH_PACKAGES=""
  }
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:make -j${NPROC} $(date)\007"
  make "-j${NPROC}" || {
    echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:tar logs $(date)\007"
    tar caf "log.$f.tar.zstd" "${TAR_LOG_OPTS[@]}" logs && \
        scp "${SSH_OPTS[@]}" "log.$f.tar.zstd" gateway:/home/equeiroz/src/openwrt/
    rm -f "log.$f.tar.zstd"
    continue;
  }
  echo -ne "\033]0;${USER}@${HOSTNAME} [$f]:tar packages targets $(date)\007"
  tar cf - "${TAR_BIN_OPTS[@]}" -C bin packages targets | \
	ssh "${SSH_OPTS[@]}" gateway tar "${TAR_BIN_OPTS[@]}" xvf - -C "\"/home/equeiroz/src/openwrt/www/${VER}\""
  PREV_ARCH_PACKAGES="$ARCH_PACKAGES"
done
