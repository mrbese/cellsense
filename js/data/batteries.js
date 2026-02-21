// CellSense — Battery System Specifications & Pricing

export const batteries = [
    {
        id: "powerwall3",
        name: "Tesla Powerwall 3",
        shortName: "Powerwall 3",
        manufacturer: "Tesla",
        capacityKwh: 13.5,
        usableCapacityKwh: 13.5,
        continuousPowerKw: 11.5,
        peakPowerKw: 22.0,
        roundTripEfficiency: 0.90,
        warrantyYears: 10,
        chemistry: "LFP",
        pricingModel: "purchase",
        equipmentCost: 9300,
        avgInstalledCost: 15400,
        installationIncluded: true,
        monthlyFee: 0,
        federalTaxCreditEligible: true,
        federalTaxCreditRate: 0.30,
        stackableUnits: 4,
        expandable: true,
        expansionUnitCost: 6000,
        expansionUnitCapacityKwh: 13.5,
        requiresProfessionalInstall: true,
        integratedInverter: true,
        solarInputKw: 20,
        color: "#e82127", // Tesla red
        icon: "⚡",
        highlights: [
            "Integrated solar inverter",
            "11.5 kW continuous output",
            "Flood resistant to 2 ft",
            "LFP chemistry — 10yr warranty"
        ],
        badge: null,
    },
    {
        id: "enphase5p",
        name: "Enphase IQ Battery 5P",
        shortName: "Enphase 5P",
        manufacturer: "Enphase",
        capacityKwh: 5.0,
        usableCapacityKwh: 5.0,
        continuousPowerKw: 3.84,
        peakPowerKw: 7.68,
        roundTripEfficiency: 0.90,
        warrantyYears: 15,
        chemistry: "LFP",
        pricingModel: "purchase",
        equipmentCost: 3649,
        avgInstalledCost: 5000, // single unit
        installationIncluded: true,
        monthlyFee: 0,
        federalTaxCreditEligible: true,
        federalTaxCreditRate: 0.30,
        stackableUnits: 8,
        expandable: true,
        expansionUnitCost: 3649,
        expansionUnitCapacityKwh: 5.0,
        requiresProfessionalInstall: true,
        integratedInverter: false,
        solarInputKw: 0, // AC-coupled
        recommendedUnits: 2, // typically sold as 2-pack (10 kWh)
        color: "#ff6600", // Enphase orange
        icon: "🔋",
        highlights: [
            "15-year warranty, 6000 cycles",
            "Microinverter architecture",
            "Passive cooling, no fans",
            "96% DC round-trip efficiency"
        ],
        badge: null,
    },
    {
        id: "pila",
        name: "Pila Mesh Home Battery",
        shortName: "Pila Mesh",
        manufacturer: "Pila Energy",
        capacityKwh: 1.6,
        usableCapacityKwh: 1.6,
        continuousPowerKw: 2.4,
        peakPowerKw: 7.8,
        roundTripEfficiency: 0.85,
        warrantyYears: 10,
        chemistry: "LFP",
        pricingModel: "purchase",
        equipmentCost: 1299,
        avgInstalledCost: 1299, // plug-and-play, no install
        installationIncluded: false, // self-install
        monthlyFee: 0,
        federalTaxCreditEligible: true,
        federalTaxCreditRate: 0.30,
        stackableUnits: 64,
        expandable: true,
        expansionUnitCost: 1199,
        expansionUnitCapacityKwh: 1.6,
        requiresProfessionalInstall: false,
        integratedInverter: true,
        solarInputKw: 0.1, // 100W direct, 1.2kW w/ expansion
        plugAndPlay: true,
        color: "#00c853", // Pila green
        icon: "🟢",
        highlights: [
            "Plug into any wall outlet",
            "No professional install needed",
            "Mesh up to 64 units",
            "20ms backup switchover"
        ],
        badge: "Most Portable",
    },
    {
        id: "basepower",
        name: "Base Power Home Battery",
        shortName: "Base Power",
        manufacturer: "Base Power",
        capacityKwh: 25.0,
        usableCapacityKwh: 25.0,
        continuousPowerKw: 11.0,
        peakPowerKw: 15.0,
        roundTripEfficiency: 0.90,
        warrantyYears: 15,
        chemistry: "LFP",
        pricingModel: "lease",
        equipmentCost: 0,
        avgInstalledCost: 0,
        installationFee: 695, // single battery
        installationFeeDouble: 995, // double battery
        monthlyFee: 19, // single
        monthlyFeeDouble: 29, // double
        energyRate: 0.085, // $/kWh
        avgDeliveryCharge: 0.06, // $/kWh
        allInRate: 0.145, // combined
        contractMonths: 36,
        federalTaxCreditEligible: false,
        stackableUnits: 2,
        expandable: true,
        expansionUnitCapacityKwh: 25.0,
        requiresProfessionalInstall: true,
        integratedInverter: true,
        solarInputKw: 0,
        doubleCapacityKwh: 50.0,
        color: "#6366f1", // Base Power indigo
        icon: "🏠",
        highlights: [
            "25 kWh — largest capacity",
            "$695 install, $19/mo lease",
            "No equipment purchase needed",
            "Up to 48hr backup (2 units)"
        ],
        badge: "Lowest Upfront",
    },
];

// Helper: get battery by id
export function getBatteryById(id) {
    return batteries.find(b => b.id === id) || null;
}

// Helper: get net cost after tax credit
export function getNetCost(battery, withTaxCredit = true, withSolar = true) {
    if (battery.pricingModel === "lease") {
        return {
            upfront: battery.installationFee,
            monthly: battery.monthlyFee,
            type: "lease",
        };
    }

    let cost = battery.avgInstalledCost;
    if (withTaxCredit && withSolar && battery.federalTaxCreditEligible) {
        cost = cost * (1 - battery.federalTaxCreditRate);
    }
    return {
        upfront: Math.round(cost),
        monthly: 0,
        type: "purchase",
    };
}
