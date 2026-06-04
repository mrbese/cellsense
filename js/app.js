// CellSense — App Entry Point

import { batteries } from './data/batteries.js';
import { getUtilityById } from './data/utilities.js';
import { getRatePlanById } from './data/ratePlans.js';
import { calculateAll } from './engine/payback.js';
import { initForm } from './ui/form.js';
import { renderResults } from './ui/results.js';

// ── Initialize App ──
document.addEventListener('DOMContentLoaded', () => {
    console.log('⚡ CellSense initialized');

    // Initialize form and pass the calculate handler
    const formState = initForm(handleCalculate);

    // Handle window resize for chart redrawing
    let resizeTimeout;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(() => {
            const resultsEl = document.getElementById('results-section');
            if (resultsEl?.classList.contains('results--visible') && window._lastResults && window._lastResults.length > 0) {
                // Import charts and redraw
                import('./ui/charts.js').then(({ drawPaybackChart, drawCumulativeChart, drawSavingsDonut }) => {
                    drawPaybackChart('payback-chart', window._lastResults);
                    drawCumulativeChart('cumulative-chart', window._lastResults);
                    const best = window._lastResults.reduce((a, b) => a.netBenefit > b.netBenefit ? a : b);
                    drawSavingsDonut('savings-donut', best);
                });
            }
        }, 250);
    });
});

/**
 * Main calculation handler — called when user clicks "Calculate"
 */
function handleCalculate(state) {
    const utility = getUtilityById(state.utilityId);
    const ratePlan = getRatePlanById(state.ratePlanId);

    if (!utility || !ratePlan) {
        console.error('Missing utility or rate plan');
        return;
    }

    const options = {
        hasSolar: state.hasSolar,
        participateInVpp: state.participateInVpp,
        userBackupValue: state.backupValue,
        useFederalTaxCredit: state.useFederalTaxCredit,
        monthlyBill: state.monthlyBill,
        analysisYears: 10,
    };

    // Run calculations for all batteries
    const results = calculateAll(batteries, ratePlan, utility, options);

    // Store for resize handler
    window._lastResults = results;

    // Log for debugging
    console.log('📊 Calculation results:', results);

    // Render
    renderResults(results);

    // Animate the calculate button
    const btn = document.getElementById('calculate-btn');
    if (btn) {
        btn.textContent = '✓ Results Below';
        btn.classList.add('btn--calculated');
        setTimeout(() => {
            btn.textContent = 'Recalculate';
            btn.classList.remove('btn--calculated');
        }, 2000);
    }
}
