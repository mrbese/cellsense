// CellSense — Results Rendering & Comparison Cards

import { drawPaybackChart, drawSavingsDonut, drawCumulativeChart } from './charts.js';

/**
 * Render all results to the dashboard
 */
export function renderResults(results) {
  const container = document.getElementById('results-section');
  if (!container) return;

  // Show results section
  container.classList.add('results--visible');

  // Render comparison cards
  renderComparisonCards(results);

  // Render charts
  setTimeout(() => {
    drawPaybackChart('payback-chart', results);
    drawCumulativeChart('cumulative-chart', results);

    // Draw donut for the best-value system
    const bestResult = results.reduce((a, b) =>
      a.netBenefit > b.netBenefit ? a : b
    );
    drawSavingsDonut('savings-donut', bestResult);
  }, 100);

  // Scroll to results
  container.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function renderComparisonCards(results) {
  const grid = document.getElementById('comparison-grid');
  if (!grid) return;
  grid.innerHTML = '';

  results.forEach((result, index) => {
    const card = createBatteryCard(result, index);
    grid.appendChild(card);
  });
}

function createBatteryCard(result, index) {
  const card = document.createElement('div');
  card.className = 'battery-card';
  card.style.setProperty('--card-accent', result.battery.color);
  card.style.setProperty('--card-accent-dim', hexToRgba(result.battery.color, 0.15));
  card.style.animationDelay = `${index * 0.1}s`;
  card.classList.add('animate-fade-in-up');

  const badge = result.computedBadge || result.battery.badge;
  const isLease = result.type === 'lease';

  // Format payback display with proper units
  let paybackDisplay, paybackUnit;
  if (result.paybackYears > 20) {
    paybackDisplay = '20+';
    paybackUnit = 'years to payback';
  } else if (isLease && result.paybackYears < 1) {
    paybackDisplay = Math.max(1, Math.round(result.paybackYears * 12));
    paybackUnit = paybackDisplay === 1 ? 'month to recoup install' : 'months to recoup install';
  } else {
    paybackDisplay = result.paybackYears.toFixed(1);
    paybackUnit = 'years to payback';
  }

  const netBenefitClass = result.netBenefit >= 0 ? '' : 'battery-card__net-value--negative';
  const netBenefitSign = result.netBenefit >= 0 ? '+' : '';

  card.innerHTML = `
    ${badge ? `<div class="battery-card__badge">${badge}</div>` : ''}
    
    <div class="battery-card__header">
      <div class="battery-card__icon">${result.battery.icon}</div>
      <div>
        <div class="battery-card__name">${result.battery.shortName}</div>
        <div class="battery-card__manufacturer">${isLease ? 'Lease Model' : formatCurrency(result.systemCost) + ' installed'}</div>
      </div>
    </div>

    <div class="battery-card__payback">
      <div class="battery-card__payback-value">${paybackDisplay}</div>
      <div class="battery-card__payback-unit">${paybackUnit}</div>
      <div class="battery-card__payback-label">Payback Period</div>
    </div>

    <div class="battery-card__savings">
      <div class="savings-row">
        <span class="savings-row__label">
          <span class="savings-row__dot" style="background: #00d4aa"></span>
          TOU Arbitrage
        </span>
        <span class="savings-row__value">${formatCurrency(result.components.arbitrage.annual)}/yr</span>
      </div>
      <div class="savings-row">
        <span class="savings-row__label">
          <span class="savings-row__dot" style="background: #f59e0b"></span>
          VPP Earnings
        </span>
        <span class="savings-row__value">${formatCurrency(result.components.vpp.annual)}/yr</span>
      </div>
      <div class="savings-row">
        <span class="savings-row__label">
          <span class="savings-row__dot" style="background: #8b5cf6"></span>
          Backup Value
        </span>
        <span class="savings-row__value">${formatCurrency(result.components.backup.annual)}/yr</span>
      </div>
      ${result.components.arbitrage.nem3Bonus > 0 ? `
      <div class="savings-row">
        <span class="savings-row__label">
          <span class="savings-row__dot" style="background: #3b82f6"></span>
          NEM 3.0 Bonus
        </span>
        <span class="savings-row__value">+${formatCurrency(result.components.arbitrage.nem3Bonus)}/yr</span>
      </div>
      ` : ''}
    </div>

    <div class="battery-card__net">
      <span class="battery-card__net-label">10-Yr Net Benefit</span>
      <span class="battery-card__net-value ${netBenefitClass}">${netBenefitSign}${formatCurrency(result.netBenefit)}</span>
    </div>

    <button class="battery-card__details-toggle">
      ▼ Show Math
    </button>

    <div class="math-breakdown" id="math-${result.battery.id}">
      ${renderMathBreakdown(result)}
    </div>
  `;

  // Attach event listener programmatically to avoid inline onclick (CSP)
  const toggleBtn = card.querySelector('.battery-card__details-toggle');
  const breakdownDiv = card.querySelector('.math-breakdown');
  if (toggleBtn && breakdownDiv) {
    toggleBtn.addEventListener('click', () => {
      breakdownDiv.classList.toggle('math-breakdown--visible');
      toggleBtn.textContent = toggleBtn.textContent.includes('Show') ? '▲ Hide Math' : '▼ Show Math';
    });
  }

  return card;
}

function renderMathBreakdown(result) {
  const d = result.components.arbitrage.details;
  const isLease = result.type === 'lease';

  let rows = '';

  // Rate info
  rows += mathSection('Rate Differential');
  rows += mathRow('Summer peak rate', `$${d.summerPeakRate}/kWh`);
  rows += mathRow('Summer off-peak rate', `$${d.summerOffPeakRate}/kWh`);
  rows += mathRow('Summer differential', `$${d.differential.summer}/kWh`);
  rows += mathRow('Winter peak rate', `$${d.winterPeakRate}/kWh`);
  rows += mathRow('Winter off-peak rate', `$${d.winterOffPeakRate}/kWh`);
  rows += mathRow('Winter differential', `$${d.differential.winter}/kWh`);

  // Arbitrage
  rows += mathSection('TOU Arbitrage');
  rows += mathRow('Battery capacity', `${d.capacity} kWh`);
  rows += mathRow('Round-trip efficiency', `${(d.efficiency * 100).toFixed(0)}%`);
  rows += mathRow('Summer daily savings', `$${d.summerDailyArbitrage}`);
  rows += mathRow('Winter daily savings', `$${d.winterDailyArbitrage}`);
  rows += mathRowHighlight('Annual arbitrage', formatCurrency(result.components.arbitrage.base));

  if (result.components.arbitrage.nem3Bonus > 0) {
    rows += mathRow('NEM 3.0 bonus', `+${formatCurrency(result.components.arbitrage.nem3Bonus)}`);
    rows += mathRowHighlight('Total w/ NEM 3.0', formatCurrency(result.components.arbitrage.annual));
  }

  // VPP
  rows += mathSection('VPP Earnings');
  rows += mathRow('Program', result.components.vpp.program?.programName || 'Disabled');
  rows += mathRow('Range', `${formatCurrency(result.components.vpp.range.min)} – ${formatCurrency(result.components.vpp.range.max)}`);
  if (result.components.vpp.upfront > 0) {
    rows += mathRow('Upfront incentive', formatCurrency(result.components.vpp.upfront));
  }
  rows += mathRowHighlight('Est. annual', formatCurrency(result.components.vpp.annual));

  // Cost
  rows += mathSection('System Cost');
  if (isLease) {
    rows += mathRow('Installation fee', formatCurrency(result.systemCost));
    rows += mathRow('Monthly fee', `$${result.monthlyLeaseCost}/mo`);
    rows += mathRow('Energy rate', `$${result.energyRate}/kWh all-in`);
  } else {
    rows += mathRow('Installed cost', formatCurrency(result.systemCost));
    if (result.taxCreditAmount > 0) {
      rows += mathRow('30% ITC credit', `-${formatCurrency(result.taxCreditAmount)}`);
    }
    if (result.vppUpfrontIncentive > 0) {
      rows += mathRow('VPP upfront', `-${formatCurrency(result.vppUpfrontIncentive)}`);
    }
    rows += mathRowHighlight('Net cost', formatCurrency(result.netSystemCost));
  }

  // Payback
  rows += mathSection('Payback');
  rows += mathRow('Annual savings', formatCurrency(result.annualSavings));
  rows += mathRow('Monthly savings', `${formatCurrency(result.monthlySavings)}/mo`);
  if (!isLease) {
    rows += mathRow('Formula', `${formatCurrency(result.netSystemCost)} ÷ ${formatCurrency(result.annualSavings)}`);
  }
  rows += mathRowHighlight('Payback period', `${result.paybackYears} years`);
  rows += mathRowHighlight('10-yr return', `${result.roi}% ROI`);

  return rows;
}

function mathSection(title) {
  return `<div class="math-row" style="margin-top:8px;border-bottom:1px solid rgba(255,255,255,0.08);padding-bottom:4px;">
    <span class="math-row__label" style="color:var(--accent-teal);font-weight:600;font-size:0.7rem;text-transform:uppercase;letter-spacing:0.08em;">${title}</span>
    <span></span>
  </div>`;
}

function mathRow(label, value) {
  return `<div class="math-row">
    <span class="math-row__label">${label}</span>
    <span class="math-row__value">${value}</span>
  </div>`;
}

function mathRowHighlight(label, value) {
  return `<div class="math-row math-row--highlight">
    <span class="math-row__label">${label}</span>
    <span class="math-row__value">${value}</span>
  </div>`;
}

// ── Helpers ──

function formatCurrency(amount) {
  const abs = Math.abs(Math.round(amount));
  const formatted = abs >= 1000
    ? `$${abs.toLocaleString()}`
    : `$${abs}`;
  return amount < 0 ? `-${formatted}` : formatted;
}

function hexToRgba(hex, alpha) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}
