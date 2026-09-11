# Self-contained Playwright for screencasts: playwright-test, the matching browser set (Chromium
# plus the minimal ffmpeg Playwright records with, versions pinned together in nixpkgs) and a
# full ffmpeg for contact sheets and MP4. Nothing comes from the project under test.
#
#   nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = [
    pkgs.nodejs
    pkgs.playwright-test
    pkgs.ffmpeg-headless
  ];
  PLAYWRIGHT_TEST_DIR = pkgs.playwright-test;
  PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
  FFMPEG = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
}
