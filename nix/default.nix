{ self, nixpkgs, system }:
let buildVars = import ./build-vars.nix;
in {
  overlay = final: prev: rec {
    loki =
      let
        # self.rev is only set on a clean git tree
        gitRevision = if (self ? rev) then self.rev else "dirty";
        shortGitRevsion = with prev.lib;
          if (self ? rev) then
            (strings.concatStrings
              (lists.take 8 (strings.stringToCharacters gitRevision)))
          else
            "dirty";

        # the image tag script is hard coded to take only 7 characters
        imageTagVersion = with prev.lib;
          if (self ? rev) then
            (strings.concatStrings
              (lists.take 8 (strings.stringToCharacters gitRevision)))
          else
            "dirty";

        imageTag =
          if (self ? rev) then
            "${buildVars.gitBranch}-${imageTagVersion}"
          else
            "${buildVars.gitBranch}-${imageTagVersion}-WIP";
      in
      prev.callPackage ./loki.nix {
        inherit imageTag;
        inherit (buildVars) gitBranch;
        version = shortGitRevsion;
        pkgs = prev;
      };

    faillint = prev.callPackage ./faillint.nix {
      inherit (prev) lib buildGoModule fetchFromGitHub;
    };
  };
}
