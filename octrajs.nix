{
  lib,
  buildNpmPackage,
  pkgs,
}:
buildNpmPackage (finalAttrs: {
  pname = "octrajs";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [pkgs.libxml2]; # Add libxml2 to nativeBuildInputs
  buildInputs = [pkgs.libxml2]; # Also add it to buildInputs

  forceEmptyCache = true;
  # makeCacheWritable = true;
  # npmFlags = ["--legacy-peer-deps"];

  # npmDepsHash = lib.fakeHash;
  npmDepsHash = "sha256-hPWD5EvognJ3o3FINgozXBWgOhCQCOgHSMZ2TqfqmsA=";

  # # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = ["--ignore-scripts"];

  NODE_OPTIONS = "--openssl-legacy-provider";

  # buildPhase = ''
  #   npm run build
  # '';

  # installPhase = ''
  #   mkdir -p $out/lib
  #   cp -r build/* $out/lib/  # Adjust this line based on your actual output
  # '';

  meta = {
    description = "JavaScript bindings to the OCTRA package";
    homepage = "";
    license = lib.licenses.unlicense;
    maintainers = "Jordan Schupbach";
  };
})
