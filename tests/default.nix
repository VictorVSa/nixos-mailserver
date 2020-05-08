# Generate an attribute sets containing all tests for all releaeses
# It looks like:
# - extern.nixpkgs_19_09
# - extern.nixpkgs_20.03
# - extern.nixpkgs_unstable
# - intern.nixpkgs_19_09
# - intern.nixpkgs_20.03
# - intern.nixpkgs_unstable

with builtins;

let
  sources = import ../nix/sources.nix;

  releases = listToAttrs (map genRelease releaseNames);

  genRelease = name: {
    name = name;
    value = import sources."${name}" {};
  };

  genTest = testName: release:
  let
    pkgs = releases."${release}";
    test = pkgs.callPackage (./. + "/${testName}.nix") { };
  in {
    "name"= builtins.replaceStrings ["." "-"] ["_" "_"] release;
    "value"= test { inherit pkgs; };
  };

  releaseNames = [
    "nixpkgs-19.09"
    "nixpkgs-20.03"
    "nixpkgs-unstable"
  ];

  testNames = [
    "intern"
    "extern"
    "clamav"
  ];

  # Generate an attribute set containing one test per releases
  genTests = testName: {
    name = testName;
    value = listToAttrs (map (genTest testName) (builtins.attrNames releases));
  };
  
in listToAttrs (map genTests testNames)