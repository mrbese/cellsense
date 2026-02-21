// CellSense — TOU Arbitrage Calculator

/**
 * Calculate annual TOU arbitrage savings for a given battery and rate plan.
 * Arbitrage = charge during off-peak (cheapest rate), discharge during peak.
 */
export function calculateArbitrage(ratePlan, battery, options = {}) {
    const {
        hasSolar = false,
        cyclesPerDay = 1, // typically 1 full cycle per day
        degradationPerYear = 0.02, // 2% annual capacity degradation
        analysisYears = 10,
    } = options;

    const efficiency = battery.roundTripEfficiency;
    const capacity = battery.usableCapacityKwh;

    // Summer (Jun-Sep = 122 days) and Winter (Oct-May = 243 days)
    const summerDays = 122;
    const winterDays = 243;

    // Get rates
    const summerPeak = ratePlan.seasons.summer.peak?.rate || ratePlan.seasons.summer.offPeak.rate;
    const summerOffPeak = getLowestChargeRate(ratePlan, 'summer');
    const winterPeak = ratePlan.seasons.winter.peak?.rate || ratePlan.seasons.winter.offPeak.rate;
    const winterOffPeak = getLowestChargeRate(ratePlan, 'winter');

    // Daily arbitrage = (peak_rate - charge_rate) × usable_capacity × efficiency
    const summerDailyArbitrage = Math.max(0, (summerPeak - summerOffPeak) * capacity * efficiency * cyclesPerDay);
    const winterDailyArbitrage = Math.max(0, (winterPeak - winterOffPeak) * capacity * efficiency * cyclesPerDay);

    // Weekday-only plans: only ~260 weekdays per year
    const weekdayFactor = ratePlan.weekdaysOnly ? (5 / 7) : 1;

    const year1 = (summerDailyArbitrage * summerDays + winterDailyArbitrage * winterDays) * weekdayFactor;

    // Calculate multi-year with degradation
    const yearlyBreakdown = [];
    let cumulative = 0;
    for (let y = 0; y < analysisYears; y++) {
        const degradationFactor = Math.pow(1 - degradationPerYear, y);
        const yearSavings = year1 * degradationFactor;
        cumulative += yearSavings;
        yearlyBreakdown.push({
            year: y + 1,
            savings: Math.round(yearSavings),
            cumulative: Math.round(cumulative),
        });
    }

    // NEM 3.0 bonus: if solar + NEM3, battery captures the peak-vs-export differential
    let nem3Bonus = 0;
    if (hasSolar && ratePlan.nem3ExportRates) {
        const summerExportRate = ratePlan.nem3ExportRates.summer.offPeak; // midday solar export
        const winterExportRate = ratePlan.nem3ExportRates.winter.offPeak;

        // Additional value: instead of exporting at low rate, store and use at peak rate
        const summerNem3Daily = Math.max(0, (summerPeak - summerExportRate) * capacity * efficiency) - summerDailyArbitrage;
        const winterNem3Daily = Math.max(0, (winterPeak - winterExportRate) * capacity * efficiency) - winterDailyArbitrage;

        nem3Bonus = Math.max(0,
            (Math.max(0, summerNem3Daily) * summerDays + Math.max(0, winterNem3Daily) * winterDays) * weekdayFactor
        );
    }

    return {
        annualSavings: Math.round(year1),
        nem3Bonus: Math.round(nem3Bonus),
        totalAnnual: Math.round(year1 + nem3Bonus),
        yearlyBreakdown,
        details: {
            summerDailyArbitrage: summerDailyArbitrage.toFixed(2),
            winterDailyArbitrage: winterDailyArbitrage.toFixed(2),
            summerPeakRate: summerPeak,
            summerOffPeakRate: summerOffPeak,
            winterPeakRate: winterPeak,
            winterOffPeakRate: winterOffPeak,
            differential: {
                summer: (summerPeak - summerOffPeak).toFixed(3),
                winter: (winterPeak - winterOffPeak).toFixed(3),
            },
            capacity,
            efficiency,
        },
    };
}

/**
 * Get the lowest available charge rate for a season
 * (prefers superOffPeak if available)
 */
function getLowestChargeRate(ratePlan, season) {
    const s = ratePlan.seasons[season];
    const offPeak = s.offPeak?.rate || 0;
    const superOffPeak = s.superOffPeak?.rate;

    if (superOffPeak !== undefined && superOffPeak !== null) {
        return Math.min(offPeak, superOffPeak);
    }
    return offPeak;
}
