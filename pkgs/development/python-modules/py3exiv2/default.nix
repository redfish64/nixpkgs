{ buildPythonPackage, isPy3k, fetchPypi, stdenv, exiv2, boost, libcxx }:

buildPythonPackage rec {
  pname = "py3exiv2";
  version = "0.3.0";
  disabled = !(isPy3k);

  src = fetchPypi {
    inherit pname version;
    sha256 = "14626aaa83cae4cd3d54f51646a0fd048e8ee0e3caf205522b33020226da8c0e";
  };

  buildInputs = [ exiv2 boost ];

  # work around python distutils compiling C++ with $CC (see issue #26709)
  NIX_CFLAGS_COMPILE = stdenv.lib.optionalString stdenv.isDarwin "-I${libcxx}/include/c++/v1";

  # fix broken libboost_python3 detection
  patches = [ ./setup.patch ];

  meta = {
    homepage = "https://launchpad.net/py3exiv2";
    description = "A Python3 binding to the library exiv2";
    license = with stdenv.lib.licenses; [ gpl3 ];
    maintainers = with stdenv.lib.maintainers; [ vinymeuh ];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}
