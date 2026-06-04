// CellSense — Charts (Canvas-based, zero dependencies)

const COLORS = {
    tesla: '#e82127',
    enphase: '#ff6600',
    pila: '#00c853',
    basepower: '#6366f1',
    teal: '#00d4aa',
    amber: '#f59e0b',
    purple: '#8b5cf6',
    red: '#ef4444',
    grid: 'rgba(255,255,255,0.06)',
    text: '#94a3b8',
    textDim: '#64748b',
};

const BATTERY_COLORS = {
    powerwall3: COLORS.tesla,
    enphase5p: COLORS.enphase,
    pila: COLORS.pila,
    basepower: COLORS.basepower,
};

/**
 * Draw a payback timeline horizontal bar chart
 */
export function drawPaybackChart(canvasId, results) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    const rect = canvas.parentElement.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = 280 * dpr;
    canvas.style.width = rect.width + 'px';
    canvas.style.height = '280px';
    ctx.scale(dpr, dpr);

    const w = rect.width;
    const h = 280;
    const padding = { top: 20, right: 30, bottom: 40, left: 130 };
    const chartW = w - padding.left - padding.right;
    const chartH = h - padding.top - padding.bottom;

    ctx.clearRect(0, 0, w, h);

    const maxYears = Math.max(...results.map(r => Math.min(r.paybackYears, 20)), 5);
    const barHeight = Math.min(40, (chartH / results.length) - 12);

    // Grid lines
    ctx.strokeStyle = COLORS.grid;
    ctx.lineWidth = 1;
    const gridSteps = Math.ceil(maxYears / 2);
    for (let i = 0; i <= gridSteps; i++) {
        const x = padding.left + (i / gridSteps) * chartW;
        ctx.beginPath();
        ctx.moveTo(x, padding.top);
        ctx.lineTo(x, h - padding.bottom);
        ctx.stroke();

        // Label
        ctx.fillStyle = COLORS.textDim;
        ctx.font = '11px Inter, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(`${Math.round((i / gridSteps) * maxYears)}yr`, x, h - padding.bottom + 20);
    }

    // Bars
    results.forEach((result, i) => {
        const y = padding.top + i * (chartH / results.length) + (chartH / results.length - barHeight) / 2;
        const barW = Math.min(result.paybackYears / maxYears, 1) * chartW;
        const color = BATTERY_COLORS[result.battery.id] || COLORS.teal;

        // Bar background
        ctx.fillStyle = 'rgba(255,255,255,0.03)';
        roundRect(ctx, padding.left, y, chartW, barHeight, 6);
        ctx.fill();

        // Bar fill with gradient
        const grad = ctx.createLinearGradient(padding.left, 0, padding.left + barW, 0);
        grad.addColorStop(0, color);
        grad.addColorStop(1, adjustAlpha(color, 0.7));
        ctx.fillStyle = grad;
        roundRect(ctx, padding.left, y, Math.max(barW, 2), barHeight, 6);
        ctx.fill();

        // Bar glow
        ctx.shadowColor = color;
        ctx.shadowBlur = 8;
        ctx.fillStyle = 'transparent';
        roundRect(ctx, padding.left, y, Math.max(barW, 2), barHeight, 6);
        ctx.fill();
        ctx.shadowBlur = 0;

        // Value on bar
        ctx.fillStyle = '#fff';
        ctx.font = 'bold 12px Inter, sans-serif';
        ctx.textAlign = 'left';
        const valueText = result.paybackYears > 20 ? '20+ yr' : `${result.paybackYears} yr`;
        ctx.fillText(valueText, padding.left + barW + 8, y + barHeight / 2 + 4);

        // Label
        ctx.fillStyle = COLORS.text;
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText(result.battery.shortName, padding.left - 12, y + barHeight / 2 + 4);
    });
}

/**
 * Draw a savings breakdown donut chart
 */
export function drawSavingsDonut(canvasId, result) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    const rect = canvas.parentElement.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = 280 * dpr;
    canvas.style.width = rect.width + 'px';
    canvas.style.height = '280px';
    ctx.scale(dpr, dpr);

    const w = rect.width;
    const h = 280;
    const cx = w / 2;
    const cy = h / 2 - 10;
    const outerR = Math.max(10, Math.min(w, h) / 2 - 40);
    const innerR = Math.max(5, outerR * 0.62);

    ctx.clearRect(0, 0, w, h);

    const segments = [
        { label: 'Arbitrage', value: result.components.arbitrage.annual, color: COLORS.teal },
        { label: 'VPP', value: result.components.vpp.annual, color: COLORS.amber },
        { label: 'Backup', value: result.components.backup.annual, color: COLORS.purple },
    ].filter(s => s.value > 0);

    const total = segments.reduce((sum, s) => sum + s.value, 0);
    if (total === 0) return;

    let startAngle = -Math.PI / 2;

    segments.forEach((seg, i) => {
        const sliceAngle = (seg.value / total) * Math.PI * 2;
        const endAngle = startAngle + sliceAngle;

        ctx.beginPath();
        ctx.arc(cx, cy, outerR, startAngle, endAngle);
        ctx.arc(cx, cy, innerR, endAngle, startAngle, true);
        ctx.closePath();

        const grad = ctx.createRadialGradient(cx, cy, innerR, cx, cy, outerR);
        grad.addColorStop(0, adjustAlpha(seg.color, 0.8));
        grad.addColorStop(1, seg.color);
        ctx.fillStyle = grad;
        ctx.fill();

        // Gap between segments
        ctx.strokeStyle = 'rgba(6,9,15,0.8)';
        ctx.lineWidth = 2;
        ctx.stroke();

        startAngle = endAngle;
    });

    // Center text
    ctx.fillStyle = '#f1f5f9';
    ctx.font = 'bold 22px Inter, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(`$${total.toLocaleString()}`, cx, cy - 6);

    ctx.fillStyle = COLORS.textDim;
    ctx.font = '11px Inter, sans-serif';
    ctx.fillText('/ year', cx, cy + 14);

    // Legend below
    const legendY = h - 20;
    const legendItemW = w / segments.length;
    segments.forEach((seg, i) => {
        const lx = legendItemW * i + legendItemW / 2;

        ctx.fillStyle = seg.color;
        ctx.fillRect(lx - 30, legendY - 4, 10, 10);

        ctx.fillStyle = COLORS.text;
        ctx.font = '11px Inter, sans-serif';
        ctx.textAlign = 'left';
        ctx.fillText(`${seg.label}: $${seg.value.toLocaleString()}`, lx - 16, legendY + 4);
    });
}

/**
 * Draw cumulative savings line chart
 */
export function drawCumulativeChart(canvasId, results) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    const rect = canvas.parentElement.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = 280 * dpr;
    canvas.style.width = rect.width + 'px';
    canvas.style.height = '280px';
    ctx.scale(dpr, dpr);

    const w = rect.width;
    const h = 280;
    const padding = { top: 30, right: 20, bottom: 40, left: 65 };
    const chartW = w - padding.left - padding.right;
    const chartH = h - padding.top - padding.bottom;

    ctx.clearRect(0, 0, w, h);

    // Find value range
    let minVal = 0, maxVal = 0;
    results.forEach(r => {
        r.yearlyProjection.forEach(p => {
            minVal = Math.min(minVal, p.cumulative);
            maxVal = Math.max(maxVal, p.cumulative);
        });
    });

    const range = maxVal - minVal || 1;
    const years = results[0]?.yearlyProjection.length || 10;

    // Grid
    ctx.strokeStyle = COLORS.grid;
    ctx.lineWidth = 1;

    // Horizontal grid + labels
    const ySteps = 5;
    for (let i = 0; i <= ySteps; i++) {
        const val = minVal + (range * i / ySteps);
        const y = padding.top + chartH - (chartH * (val - minVal) / range);

        ctx.beginPath();
        ctx.moveTo(padding.left, y);
        ctx.lineTo(w - padding.right, y);
        ctx.stroke();

        ctx.fillStyle = COLORS.textDim;
        ctx.font = '10px Inter, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText(formatDollars(val), padding.left - 8, y + 4);
    }

    // Zero line
    if (minVal < 0 && maxVal > 0) {
        const zeroY = padding.top + chartH - (chartH * (0 - minVal) / range);
        ctx.strokeStyle = 'rgba(255,255,255,0.15)';
        ctx.lineWidth = 1;
        ctx.setLineDash([4, 4]);
        ctx.beginPath();
        ctx.moveTo(padding.left, zeroY);
        ctx.lineTo(w - padding.right, zeroY);
        ctx.stroke();
        ctx.setLineDash([]);
    }

    // X-axis labels
    for (let yr = 0; yr <= years; yr += 2) {
        const x = padding.left + (yr / years) * chartW;
        ctx.fillStyle = COLORS.textDim;
        ctx.font = '10px Inter, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(`Y${yr}`, x, h - padding.bottom + 18);
    }

    // Lines
    results.forEach(result => {
        const color = BATTERY_COLORS[result.battery.id] || COLORS.teal;
        const points = result.yearlyProjection;

        // Area fill
        ctx.beginPath();
        ctx.moveTo(padding.left, padding.top + chartH - (chartH * (points[0].cumulative - minVal) / range));
        points.forEach((p, i) => {
            const x = padding.left + ((i + 1) / years) * chartW;
            const y = padding.top + chartH - (chartH * (p.cumulative - minVal) / range);
            ctx.lineTo(x, y);
        });
        ctx.lineTo(padding.left + chartW, padding.top + chartH);
        ctx.lineTo(padding.left, padding.top + chartH);
        ctx.closePath();
        ctx.fillStyle = adjustAlpha(color, 0.06);
        ctx.fill();

        // Line
        ctx.beginPath();
        points.forEach((p, i) => {
            const x = padding.left + ((i + 1) / years) * chartW;
            const y = padding.top + chartH - (chartH * (p.cumulative - minVal) / range);
            if (i === 0) {
                // Start from year 0 (initial cost)
                const y0 = padding.top + chartH - (chartH * (-result.netSystemCost - minVal) / range);
                ctx.moveTo(padding.left, y0);
                ctx.lineTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });
        ctx.strokeStyle = color;
        ctx.lineWidth = 2.5;
        ctx.stroke();

        // End dot
        const lastP = points[points.length - 1];
        const lastX = padding.left + chartW;
        const lastY = padding.top + chartH - (chartH * (lastP.cumulative - minVal) / range);
        ctx.beginPath();
        ctx.arc(lastX, lastY, 4, 0, Math.PI * 2);
        ctx.fillStyle = color;
        ctx.fill();
    });
}

// ── Helpers ──

function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.arcTo(x + w, y, x + w, y + r, r);
    ctx.lineTo(x + w, y + h - r);
    ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
    ctx.lineTo(x + r, y + h);
    ctx.arcTo(x, y + h, x, y + h - r, r);
    ctx.lineTo(x, y + r);
    ctx.arcTo(x, y, x + r, y, r);
    ctx.closePath();
}

function adjustAlpha(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r},${g},${b},${alpha})`;
}

function formatDollars(val) {
    if (Math.abs(val) >= 1000) {
        return `$${(val / 1000).toFixed(1)}k`;
    }
    return `$${Math.round(val)}`;
}
