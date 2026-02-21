// CellSense — Virtual Power Plant Programs Database

export const vppPrograms = [
    // ── California ──
    {
        id: "ca-elrp",
        name: "CA Emergency Load Reduction Program (ELRP)",
        utilityIds: ["pge", "sce", "sdge"],
        type: "event-based",
        payPerKwh: 2.00,
        estimatedEventsPerYear: 15,
        estimatedAnnualEarnings: { min: 300, max: 1000, mid: 650 },
        notes: "Pays $2/kWh for additional discharge during grid events. Typically 10-20 events/year during summer peaks.",
    },
    {
        id: "ca-dsgs",
        name: "CA Demand Side Grid Support (DSGS)",
        utilityIds: ["pge", "sce"],
        type: "grid-support",
        estimatedAnnualPerUnit: 350,
        estimatedAnnualEarnings: { min: 200, max: 350, mid: 275 },
        notes: "Up to $350/yr per Powerwall through demand-side grid support.",
    },

    // ── Sacramento ──
    {
        id: "smud-vpp",
        name: "SMUD Virtual Power Plant",
        utilityIds: ["smud"],
        type: "rebate+ongoing",
        upfrontPerUnit: 5400,
        maxUpfrontPerHousehold: 10000,
        annualPerUnit: 440,
        estimatedAnnualEarnings: { min: 440, max: 880, mid: 440 },
        notes: "Up to $5,400 upfront per Powerwall (max $10k/household) + $440/yr ongoing per unit.",
    },

    // ── New England ──
    {
        id: "ne-connected-solutions",
        name: "ConnectedSolutions (New England)",
        utilityIds: ["eversource", "national-grid"],
        type: "capacity-based",
        payPerKwSummer: 250,
        maxDispatchesPerSummer: 60,
        estimatedAnnualEarnings: { min: 1000, max: 1500, mid: 1300 },
        notes: "$225-275/kW per summer season. Dispatched up to 60 times Jun-Sep. Average payout ~$1,500/yr.",
    },

    // ── Texas ──
    {
        id: "tx-ercot-vpp",
        name: "Texas ERCOT Aggregation Pilot",
        utilityIds: ["oncor"],
        type: "fixed+sellback",
        monthlyPerUnit: 33,
        sellbackRatePerKwh: 0.05,
        estimatedAnnualEarnings: { min: 400, max: 800, mid: 600 },
        notes: "$33/mo fixed + $0.05/kWh sellback credits. Estimated ~$600-800/yr per unit.",
    },

    // ── Colorado ──
    {
        id: "co-renewable-battery",
        name: "Xcel Renewable Battery Connect",
        utilityIds: ["xcel"],
        type: "rebate+credits",
        rebatePerKw: 350,
        maxRebate: 5000,
        annualCredits: 100,
        estimatedAnnualEarnings: { min: 100, max: 200, mid: 150 },
        notes: "Up to $5,000 rebate ($350/kW) + ~$100/yr in ongoing VPP credits.",
    },

    // ── Generic fallback ──
    {
        id: "generic-vpp",
        name: "Estimated VPP Participation",
        utilityIds: ["*"],
        type: "estimated",
        estimatedAnnualEarnings: { min: 200, max: 500, mid: 350 },
        notes: "Conservative estimate based on national averages for emerging VPP programs. Actual availability varies by region.",
    },
];

// Helper: find VPP programs for a given utility
export function getVppProgramsForUtility(utilityId) {
    return vppPrograms.filter(
        p => p.utilityIds.includes(utilityId) || p.utilityIds.includes("*")
    );
}

// Helper: estimate annual VPP earnings for a utility + battery combo
export function estimateVppEarnings(utilityId, batteryCapacityKwh, batteryPowerKw) {
    const programs = getVppProgramsForUtility(utilityId);

    // Use the best specific program (non-generic), or fall back to generic
    const specific = programs.find(p => p.id !== "generic-vpp");
    const program = specific || programs.find(p => p.id === "generic-vpp");

    if (!program) return { min: 0, max: 0, mid: 0, program: null };

    let earnings = { ...program.estimatedAnnualEarnings };

    // Scale capacity-based programs by battery size
    if (program.type === "capacity-based" && program.payPerKwSummer) {
        const base = program.payPerKwSummer * batteryPowerKw;
        earnings = {
            min: Math.round(base * 0.7),
            max: Math.round(base * 1.1),
            mid: Math.round(base * 0.9),
        };
    }

    // Scale event-based programs by capacity
    if (program.type === "event-based" && program.payPerKwh) {
        const eventsPerYear = program.estimatedEventsPerYear || 15;
        const avgDischargePerEvent = batteryCapacityKwh * 0.5; // 50% depth per event
        const base = program.payPerKwh * avgDischargePerEvent * eventsPerYear;
        earnings = {
            min: Math.round(base * 0.5),
            max: Math.round(base * 1.2),
            mid: Math.round(base * 0.8),
        };
    }

    return {
        ...earnings,
        program,
        upfront: program.upfrontPerUnit || 0,
    };
}
