// CellSense — VPP Earnings Calculator

import { estimateVppEarnings as lookupVppEarnings } from '../data/vppPrograms.js';

/**
 * Calculate estimated VPP program earnings for a battery at a specific utility.
 */
export function calculateVpp(utilityId, battery, options = {}) {
    const {
        participateInVpp = true,
        analysisYears = 10,
    } = options;

    if (!participateInVpp) {
        return {
            annualEarnings: { min: 0, max: 0, mid: 0 },
            upfrontIncentive: 0,
            program: null,
            totalOverPeriod: 0,
            details: {
                programName: 'Disabled',
                programType: 'none',
                notes: 'VPP participation disabled by user',
                capacityScale: 0
            }
        };
    }

    const result = lookupVppEarnings(
        utilityId,
        battery.usableCapacityKwh,
        battery.continuousPowerKw
    );

    // Scale earnings for multi-unit scenarios based on battery capacity
    // (most VPP programs scale roughly linearly with capacity)
    const capacityScale = battery.usableCapacityKwh >= 10 ? 1.0 :
        battery.usableCapacityKwh >= 5 ? 0.8 :
            0.5; // smaller batteries earn less in VPP

    const scaledEarnings = {
        min: Math.round(result.min * capacityScale),
        max: Math.round(result.max * capacityScale),
        mid: Math.round(result.mid * capacityScale),
    };

    const upfront = result.upfront || 0;

    return {
        annualEarnings: scaledEarnings,
        upfrontIncentive: upfront,
        program: result.program,
        totalOverPeriod: Math.round(scaledEarnings.mid * analysisYears + upfront),
        details: {
            programName: result.program?.name || 'No specific program',
            programType: result.program?.type || 'estimated',
            notes: result.program?.notes || '',
            capacityScale,
        },
    };
}
