# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.0.1] - 2026-06-04

### Added
- Updated the README with specific optimizations for California NEM 3.0, New England ConnectedSolutions, and Texas ERCOT VPP programs.

### Fixed
- Fixed unstable comparison card sorting in the results engine when payback years evaluate to Infinity.
- Fixed potential division-by-zero risk in lease payback calculations if a utility's blended rate is zero.
- Guarded the window resize event handler from throwing a TypeError when calculation results are empty.
- Guarded the cumulative savings chart dot renderer from throwing a TypeError when data points are empty.
- Corrected VPP calculation logic to prevent double-scaling of capacity-based and event-based earnings.
- Replaced inline details toggle click handlers in the comparison view with programmatic event listeners to ensure CSP compliance.
