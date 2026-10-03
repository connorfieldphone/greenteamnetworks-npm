# GreenTeam Networks v6.0.0

This directory contains the v6.0.0 update material for the `Update` branch.

## Update source

- Repository: `connorfieldphone/greenteamnetworks-npm`
- Branch: `Update`
- Version: `6.0.0`

## Update behaviour

The v6 updater is designed to:

1. Read the installed version from `package.json`.
2. Check the GitHub update source.
3. Download the matching update ZIP.
4. Validate the archive before changing the project.
5. Back up the current installation.
6. Replace only files supplied by the update.
7. Preserve local files that are not present in the update.
8. Validate the resulting `package.json` and CLI syntax.
9. Show `updatenotes@v6.0.0.txt` after a successful update.
10. Report failure instead of claiming success when an operation did not complete.

The local project directory does not need to be renamed when its package version changes.
