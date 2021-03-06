{ lib, pythonPackages }:

let
  truffleHogRegexes = pythonPackages.buildPythonPackage rec {
    pname = "truffleHogRegexes";
    version = "0.0.4";
    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "09vrscbb4h4w01gmamlzghxx6cvrqdscylrbdcnbjsd05xl7zh4z";
    };
  };
in
  pythonPackages.buildPythonApplication rec {
    pname = "truffleHog";
    version = "2.0.91";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0r4c9ihy6wjh5cwli7lb6cr2yfvxrh7r6cgznql1src5gzlnkymx";
    };

    # Relax overly restricted version constraint
    postPatch = ''
      substituteInPlace setup.py --replace "GitPython ==" "GitPython >= "
    '';

    propagatedBuildInputs = [ pythonPackages.GitPython truffleHogRegexes ];

    # Test cases run git clone and require network access
    doCheck = false;

    meta = {
      homepage = https://github.com/dxa4481/truffleHog;
      description = "Searches through git repositories for high entropy strings and secrets, digging deep into commit history";
      license = with lib.licenses; [ gpl2 ];
      maintainers = with lib.maintainers; [ bhipple ];
    };
  }
