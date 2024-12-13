{
  description = "Flake to manage a Java 22 workspace.";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = inputs:
    let
      supportedSystems = [ "x86_64-linux" ];

      overlay = import ./overlays/default.nix;

      forAllSystems = f: builtins.listToAttrs (
        map (system: {
          name = system;
          value = f system;
        }) supportedSystems
      );

    in
    {
      packages = forAllSystems (system: 
        let
          pkgs = (inputs.nixpkgs.legacyPackages.${system}.extend overlay);
        in
          {
            inherit (pkgs) jdk22;
          }
      );

      devShell = forAllSystems (system: 
        let
          pkgs = (inputs.nixpkgs.legacyPackages.${system}.extend overlay);
        in
          pkgs.mkShell rec {
            name = "java-shell";
            buildInputs = with pkgs; [ jdk22 llvm ];

            shellHook = ''
              export JAVA_HOME=${pkgs.jdk22}
              PATH="${pkgs.jdk22}/bin:$PATH"
            '';
          }
      );
    };
}

