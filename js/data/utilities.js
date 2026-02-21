// CellSense — Utility Company Database
// ~15 major US IOUs and Munis with metadata

export const utilities = [
  // ── California ──
  {
    id: "pge",
    name: "Pacific Gas & Electric (PG&E)",
    shortName: "PG&E",
    state: "CA",
    type: "IOU",
    ratePlanIds: ["pge-etou-c", "pge-etou-d", "pge-eelec"],
    vppProgramIds: ["ca-elrp", "ca-dsgs"],
    avgOutageHoursPerYear: 4.2,
    avgBlendedRate: 0.4146, // $/kWh avg residential Jan 2026
    hasNem3: true,
  },
  {
    id: "sce",
    name: "Southern California Edison (SCE)",
    shortName: "SCE",
    state: "CA",
    type: "IOU",
    ratePlanIds: ["sce-tou-d-4-9", "sce-tou-d-5-8", "sce-tou-prime"],
    vppProgramIds: ["ca-elrp", "ca-dsgs"],
    avgOutageHoursPerYear: 5.1,
    avgBlendedRate: 0.36,
    hasNem3: true,
  },
  {
    id: "sdge",
    name: "San Diego Gas & Electric (SDG&E)",
    shortName: "SDG&E",
    state: "CA",
    type: "IOU",
    ratePlanIds: ["sdge-tou-dr1", "sdge-tou-dr2", "sdge-ev-tou5"],
    vppProgramIds: ["ca-elrp"],
    avgOutageHoursPerYear: 3.8,
    avgBlendedRate: 0.45,
    hasNem3: true,
  },
  {
    id: "ladwp",
    name: "Los Angeles Dept. of Water & Power (LADWP)",
    shortName: "LADWP",
    state: "CA",
    type: "Muni",
    ratePlanIds: ["ladwp-r1a", "ladwp-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 3.0,
    avgBlendedRate: 0.22,
    hasNem3: false,
  },
  {
    id: "smud",
    name: "Sacramento Municipal Utility District (SMUD)",
    shortName: "SMUD",
    state: "CA",
    type: "Muni",
    ratePlanIds: ["smud-tou", "smud-fixed"],
    vppProgramIds: ["smud-vpp"],
    avgOutageHoursPerYear: 2.5,
    avgBlendedRate: 0.17,
    hasNem3: false,
  },

  // ── New York / New England ──
  {
    id: "coned",
    name: "Consolidated Edison (Con Edison)",
    shortName: "Con Edison",
    state: "NY",
    type: "IOU",
    ratePlanIds: ["coned-sc1", "coned-sc1-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 6.0,
    avgBlendedRate: 0.33,
    hasNem3: false,
  },
  {
    id: "national-grid",
    name: "National Grid",
    shortName: "National Grid",
    state: "NY/MA",
    type: "IOU",
    ratePlanIds: ["ngrid-sc1", "ngrid-tou"],
    vppProgramIds: ["ne-connected-solutions"],
    avgOutageHoursPerYear: 3.5,
    avgBlendedRate: 0.30,
    hasNem3: false,
  },
  {
    id: "eversource",
    name: "Eversource Energy",
    shortName: "Eversource",
    state: "CT/MA",
    type: "IOU",
    ratePlanIds: ["eversource-r1", "eversource-tou"],
    vppProgramIds: ["ne-connected-solutions"],
    avgOutageHoursPerYear: 4.8,
    avgBlendedRate: 0.32,
    hasNem3: false,
  },

  // ── Midwest ──
  {
    id: "comed",
    name: "Commonwealth Edison (ComEd)",
    shortName: "ComEd",
    state: "IL",
    type: "IOU",
    ratePlanIds: ["comed-bess", "comed-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 3.2,
    avgBlendedRate: 0.18,
    hasNem3: false,
  },

  // ── Southeast ──
  {
    id: "duke",
    name: "Duke Energy",
    shortName: "Duke Energy",
    state: "NC/SC",
    type: "IOU",
    ratePlanIds: ["duke-res", "duke-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 5.5,
    avgBlendedRate: 0.14,
    hasNem3: false,
  },
  {
    id: "fpl",
    name: "Florida Power & Light (FPL)",
    shortName: "FPL",
    state: "FL",
    type: "IOU",
    ratePlanIds: ["fpl-rs1", "fpl-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 7.0,
    avgBlendedRate: 0.14,
    hasNem3: false,
  },
  {
    id: "dominion",
    name: "Dominion Energy",
    shortName: "Dominion",
    state: "VA",
    type: "IOU",
    ratePlanIds: ["dominion-r1", "dominion-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 4.0,
    avgBlendedRate: 0.15,
    hasNem3: false,
  },

  // ── Southwest ──
  {
    id: "aps",
    name: "Arizona Public Service (APS)",
    shortName: "APS",
    state: "AZ",
    type: "IOU",
    ratePlanIds: ["aps-tou-e", "aps-saver-choice"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 2.8,
    avgBlendedRate: 0.14,
    hasNem3: false,
  },
  {
    id: "srp",
    name: "Salt River Project (SRP)",
    shortName: "SRP",
    state: "AZ",
    type: "Muni",
    ratePlanIds: ["srp-ez3", "srp-tou"],
    vppProgramIds: ["generic-vpp"],
    avgOutageHoursPerYear: 2.2,
    avgBlendedRate: 0.13,
    hasNem3: false,
  },

  // ── Mountain West ──
  {
    id: "xcel",
    name: "Xcel Energy",
    shortName: "Xcel",
    state: "CO",
    type: "IOU",
    ratePlanIds: ["xcel-r", "xcel-tou"],
    vppProgramIds: ["co-renewable-battery"],
    avgOutageHoursPerYear: 3.0,
    avgBlendedRate: 0.16,
    hasNem3: false,
  },

  // ── Texas ──
  {
    id: "oncor",
    name: "Oncor / TXU Energy (Texas)",
    shortName: "Oncor",
    state: "TX",
    type: "TDU",
    ratePlanIds: ["tx-flat", "tx-tou"],
    vppProgramIds: ["tx-ercot-vpp"],
    avgOutageHoursPerYear: 8.0,
    avgBlendedRate: 0.145,
    hasNem3: false,
  },
];

// Helper: group utilities by state
export function getUtilitiesByState() {
  const grouped = {};
  for (const u of utilities) {
    const key = u.state;
    if (!grouped[key]) grouped[key] = [];
    grouped[key].push(u);
  }
  return grouped;
}

// Helper: find by id
export function getUtilityById(id) {
  return utilities.find(u => u.id === id) || null;
}
