{ stdenv, lib, fetchurl, writeScript, coreutils, ncurses, gzip, flex, bison, less }:

let
  platform =
    if stdenv.hostPlatform.isUnix then "unix"
    else throw "Unknown platform for NetHack: ${stdenv.system}";
  unixHint =
    /**/ if stdenv.hostPlatform.isLinux  then "linux"
    else if stdenv.hostPlatform.isDarwin then "macosx10.10"
    # We probably want something different for Darwin
    else "unix";
  userDir = "~/.config/nethack";
  binPath = lib.makeBinPath [ coreutils less ];

in stdenv.mkDerivation {
  name = "nethack-3.6.1";

  src = fetchurl {
    url = "https://nethack.org/download/3.6.1/nethack-361-src.tgz";
    sha256 = "1dha0ijvxhx7c9hr0452h93x81iiqsll8bc9msdnp7xdqcfbz32b";
  };

  buildInputs = [ ncurses ];

  nativeBuildInputs = [ flex bison ];

  makeFlags = [ "PREFIX=$(out)" ];

  patchPhase = ''
    sed -e '/^ *cd /d' -i sys/unix/nethack.sh
    sed \
      -e 's/^YACC *=.*/YACC = bison -y/' \
      -e 's/^LEX *=.*/LEX = flex/' \
      -i sys/unix/Makefile.utl
    sed \
      -e 's,/bin/gzip,${gzip}/bin/gzip,g' \
      -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
      -i sys/unix/hints/linux
    sed \
      -e 's,^CC=.*$,CC=cc,' \
      -e 's,^HACKDIR=.*$,HACKDIR=\$(PREFIX)/games/lib/\$(GAME)dir,' \
      -e 's,^SHELLDIR=.*$,SHELLDIR=\$(PREFIX)/games,' \
      -i sys/unix/hints/macosx10.10
    sed -e '/define CHDIR/d' -i include/config.h
  '';

  configurePhase = ''
    cd sys/${platform}
    ${lib.optionalString (platform == "unix") ''
      sh setup.sh hints/${unixHint}
    ''}
    cd ../..
  '';

  postInstall = ''
    mkdir -p $out/games/lib/nethackuserdir
    for i in xlogfile logfile perm record save; do
      mv $out/games/lib/nethackdir/$i $out/games/lib/nethackuserdir
    done

    mkdir -p $out/bin
    cat <<EOF >$out/bin/nethack
    #! ${stdenv.shell} -e
    PATH=${binPath}:\$PATH

    if [ ! -d ${userDir} ]; then
      mkdir -p ${userDir}
      cp -r $out/games/lib/nethackuserdir/* ${userDir}
      chmod -R +w ${userDir}
    fi

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR
    }
    trap cleanup EXIT

    cd \$RUNDIR
    for i in ${userDir}/*; do
      ln -s \$i \$(basename \$i)
    done
    for i in $out/games/lib/nethackdir/*; do
      ln -s \$i \$(basename \$i)
    done
    $out/games/nethack
    EOF
    chmod +x $out/bin/nethack
  '';

  meta = with stdenv.lib; {
    description = "Rogue-like game";
    homepage = http://nethack.org/;
    license = "nethack";
    platforms = platforms.unix;
    maintainers = with maintainers; [ abbradar ];
  };
}
