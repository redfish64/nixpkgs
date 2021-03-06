{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

#
# USAGE:
# install the following package globally or in nix-shell:
#
#   (terraform.withPlugins ( plugins: [ terraform-provider-ibm ]))
#
# examples:
# https://github.com/IBM-Cloud/terraform-provider-ibm/tree/master/examples
#

buildGoPackage rec {
  name = "terraform-provider-ibm-${version}";
  version = "0.10.0";

  goPackagePath = "github.com/terraform-providers/terraform-provider-ibm";
  subPackages = [ "./" ];

  src = fetchFromGitHub {
    owner = "IBM-Cloud";
    repo = "terraform-provider-ibm";
    sha256 = "03drvhhh6pkk8yzzp8iiq478kcky9swxvxadxzxh0v4jzdprg9lr";
    rev = "v${version}";
  };

  # Terraform allow checking the provider versions, but this breaks
  # if the versions are not provided via file paths.
  postBuild = "mv go/bin/terraform-provider-ibm{,_v${version}}";

  meta = with stdenv.lib; {
    homepage = https://github.com/IBM-Cloud/terraform-provider-ibm;
    description = "Terraform provider is used to manage IBM Cloud resources.";
    platforms = platforms.all;
    license = licenses.mpl20;
    maintainers = with maintainers; [ jensbin ];
  };
}
