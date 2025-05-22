{
  description = "solo";

  inputs = {
    # TODO: drop `/module` after https://github.com/Gepetto/nix/pull/54
    gepetto.url = "github:gepetto/nix/module";
    flake-parts.follows = "gepetto/flake-parts";
    nixpkgs.follows = "gepetto/nixpkgs";
    nix-ros-overlay.follows = "gepetto/nix-ros-overlay";
    systems.follows = "gepetto/systems";
    treefmt-nix.follows = "gepetto/treefmt-nix";
    # TODO: use gepetto/ ?
    utils.url = "github:Gepetto/nix-lib";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.gepetto.flakeModule ];
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          packages = {
            default = self'.packages.solo;
            solo = pkgs.python3Packages.buildPythonPackage {
              format = "pyproject";
              pname = "robot_properties_solo";
              version = inputs.utils.lib.pythonVersion pkgs ./pyproject.toml;

              nativeBuildInputs = [ pkgs.python3Packages.setuptools pkgs.rosPackages.rolling.xacro ];

              buildInputs = with pkgs.python3Packages; [ meshcat pybullet  ];

              src = builtins.path {
                name = "src";
                path = ./.;
              };
            };
          };
        };
    };
}
