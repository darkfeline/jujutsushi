{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = builtin.currentSystem; # Use builting
      pkgs = nixpkgs.legacyPackages.${system};

      jujutsushi = pkgs.emacsPackages.trivialBuild {
        pname = "jujutsushi";
        version = "0.0.1";
        src = ./jujutsushi.el;
        packageRequires = [ pkgs.emacsPackages.with-editor ];
        meta = {
          description = "Bring jj into your domain expansion";
          license = nixpkgs.lib.licenses.gpl3;
        };
      };
    in
    {
      packages.${system}.default = jujutsushi;
    };
}
