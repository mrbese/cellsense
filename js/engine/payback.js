// CellSense — Payback Period & TCO Calculator

import { calculateArbitrage } from './arbitrage.js';
import { calculateVpp } from './vpp.js';
import { calculateBackup } from './backup.js';

/**
 * Calculate complete ROI analysis for a battery system.
 * Returns payback period, 10-year net benefit, monthly savings, etc.
 */
export function calculatePayback(battery, ratePlan, utility, options = {}) {
    const {
        hasSolar = false,
        participateInVpp = true,
        userBackupValue = null,
        useFederalTaxCredit = true,
        monthlyBill = 200,
        analysisYears = 10,
    } = options;

    // ── 1. Calculate each savings component ──
    const arbitrage = calculateArbitrage(ratePlan, battery, { hasSolar, analysisYears });
    const vpp = calculateVpp(utility.id, battery, { participateInVpp, analysisYears });
    const backup = calculateBackup(battery, utility, { userBackupValue });

    // ── 2. Total annual savings ──
    const annualSavings = arbitrage.totalAnnual + vpp.annualEarnings.mid + backup.annualValue;

    // ── 3. System cost calculation ──
    let result;

    if (battery.pricingModel === "purchase") {
        result = calculatePurchasePayback(battery, annualSavings, vpp, {
            useFederalTaxCredit,
            hasSolar,
            analysisYears,
            arbitrage,
            backup,
        });
    } else {
        // Lease model (Base Power)
        result = calculateLeasePayback(battery, utility, monthlyBill, {
            vpp,
            analysisYears,
            arbitrage,
            backup,
        });
    }

    // ── 4. Build final result ──
    return {
        battery: {
            id: battery.id,
            name: battery.name,
            shortName: battery.shortName,
            color: battery.color,
            icon: battery.icon,
            badge: battery.badge,
            pricingModel: battery.pricingModel,
        },
        ...result,
        components: {
            arbitrage: {
                annual: arbitrage.totalAnnual,
                base: arbitrage.annualSavings,
                nem3Bonus: arbitrage.nem3Bonus,
                details: arbitrage.details,
            },
            vpp: {
                annual: vpp.annualEarnings.mid,
                range: vpp.annualEarnings,
                upfront: vpp.upfrontIncentive,
                program: vpp.details,
            },
            backup: {
                annual: backup.annualValue,
                hoursFullLoad: backup.hoursFullLoad,
                hoursEssentials: backup.hoursEssentials,
                details: backup,
            },
        },
        annualSavings,
        monthlySavings: Math.round(annualSavings / 12),
        yearlyProjection: buildYearlyProjection(result, arbitrage, vpp, backup, analysisYears),
    };
}

/**
 * Calculate payback for purchase-model batteries (Powerwall, Enphase, Pila)
 */
function calculatePurchasePayback(battery, annualSavings, vpp, options) {
    const { useFederalTaxCredit, hasSolar, analysisYears, arbitrage, backup } = options;

    let systemCost = battery.avgInstalledCost;

    // Apply federal tax credit (30% ITC when installed with solar)
    let taxCreditAmount = 0;
    if (useFederalTaxCredit && hasSolar && battery.federalTaxCreditEligible) {
        taxCreditAmount = Math.round(systemCost * battery.federalTaxCreditRate);
        systemCost -= taxCreditAmount;
    }

    // Apply VPP upfront incentive
    const vppUpfront = vpp.upfrontIncentive || 0;
    systemCost -= vppUpfront;
    systemCost = Math.max(0, systemCost);

    // Payback period
    const paybackYears = annualSavings > 0 ? systemCost / annualSavings : Infinity;

    // 10-year net benefit
    const totalSavings10yr = annualSavings * analysisYears;
    const netBenefit = totalSavings10yr - systemCost;

    return {
        type: "purchase",
        systemCost: Math.round(battery.avgInstalledCost),
        netSystemCost: Math.round(systemCost),
        taxCreditAmount: Math.round(taxCreditAmount),
        vppUpfrontIncentive: vppUpfront,
        paybackYears: Math.round(paybackYears * 10) / 10,
        paybackMonths: Math.round(paybackYears * 12),
        totalSavings: Math.round(totalSavings10yr),
        netBenefit: Math.round(netBenefit),
        roi: systemCost > 0 ? Math.round((netBenefit / systemCost) * 100) : 0,
    };
}

/**
 * Calculate effective savings for lease-model battery (Base Power)
 */
function calculateLeasePayback(battery, utility, monthlyBill, options) {
    const { vpp, analysisYears, arbitrage, backup } = options;

    const months = analysisYears * 12;

    // Current utility cost over analysis period
    const currentTotalCost = monthlyBill * months;

    // Base Power cost over analysis period
    const installFee = battery.installationFee;
    const monthlyMembership = battery.monthlyFee * months;
    const energyCost = battery.allInRate * (monthlyBill / utility.avgBlendedRate) * months;
    // Base Power claims to replace most of your utility bill with their fixed rate
    const basePowerTotalCost = installFee + monthlyMembership + energyCost;

    // VPP earnings
    const vppTotal = vpp.annualEarnings.mid * analysisYears;

    // Total savings
    const totalSavings = currentTotalCost - basePowerTotalCost + vppTotal + (backup.annualValue * analysisYears);
    const monthlySavings = totalSavings / months;

    // Effective "payback" = how many months until cumulative savings > install fee
    const monthlyNet = monthlySavings;
    const paybackMonths = monthlyNet > 0 ? Math.ceil(installFee / monthlyNet) : Infinity;
    const paybackYears = paybackMonths / 12;

    return {
        type: "lease",
        systemCost: installFee,
        netSystemCost: installFee,
        taxCreditAmount: 0,
        vppUpfrontIncentive: 0,
        monthlyLeaseCost: battery.monthlyFee,
        energyRate: battery.allInRate,
        paybackYears: Math.round(paybackYears * 10) / 10,
        paybackMonths: Math.round(paybackMonths),
        totalSavings: Math.round(totalSavings),
        netBenefit: Math.round(totalSavings),
        roi: installFee > 0 ? Math.round((totalSavings / installFee) * 100) : 0,
        monthlySavingsVsUtility: Math.round(monthlySavings),
        annualSavings: Math.round(totalSavings / analysisYears),
    };
}

/**
 * Build year-by-year projection for charting
 */
function buildYearlyProjection(result, arbitrage, vpp, backup, years) {
    const projection = [];
    let cumulative = -(result.netSystemCost);

    for (let y = 1; y <= years; y++) {
        // Use arbitrage yearly breakdown if available, otherwise use flat
        const arbYear = arbitrage.yearlyBreakdown?.[y - 1]?.savings || arbitrage.totalAnnual;
        const yearTotal = arbYear + vpp.annualEarnings.mid + backup.annualValue;

        // For lease model, subtract monthly fees
        let yearNet = yearTotal;
        if (result.type === "lease") {
            yearNet -= (result.monthlyLeaseCost || 0) * 12;
        }

        cumulative += yearNet;
        projection.push({
            year: y,
            savings: Math.round(yearNet),
            cumulative: Math.round(cumulative),
            positive: cumulative >= 0,
        });
    }

    return projection;
}

/**
 * Calculate all batteries at once and return sorted results
 */
export function calculateAll(batteries, ratePlan, utility, options = {}) {
    const results = batteries.map(battery =>
        calculatePayback(battery, ratePlan, utility, options)
    );

    // Assign badges based on comparison
    const purchaseResults = results.filter(r => r.type === "purchase");

    if (purchaseResults.length > 0) {
        // Fastest payback among purchasable
        const fastest = purchaseResults.reduce((a, b) =>
            a.paybackYears < b.paybackYears ? a : b
        );
        fastest.computedBadge = "Fastest Payback";

        // Best 10-year value
        const bestValue = results.reduce((a, b) =>
            a.netBenefit > b.netBenefit ? a : b
        );
        if (bestValue.computedBadge) {
            bestValue.computedBadge += " • Best Value";
        } else {
            bestValue.computedBadge = "Best 10-Year Value";
        }
    }

    // Sort by payback years (shortest first), with lease models at end
    results.sort((a, b) => {
        if (a.type !== b.type) return a.type === "purchase" ? -1 : 1;
        return a.paybackYears - b.paybackYears;
    });

    return results;
}
