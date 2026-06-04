# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.0.1] - 2026-06-04

### Added
- Updated the README to highlight support for California NEM 3.0, New England ConnectedSolutions, and Texas ERCOT VPP programs.

### Fixed
- Fixed battery comparison card sorting to handle systems with infinite payback periods gracefully.
- Prevented division-by-zero crashes in lease payback calculations when a utility rate plan has a zero average blended rate.
- Fixed a TypeError console crash when resizing the window before any calculation results have generated.
- Fixed a TypeError console crash in the cumulative savings chart dot renderer when data points are empty.
- Corrected Virtual Power Plant (VPP) calculation logic to prevent double-scaling capacity and event earnings.
- Replaced inline details toggle click handlers with programmatic event listeners to ensure full Content Security Policy (CSP) compliance.
