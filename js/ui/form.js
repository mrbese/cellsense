// CellSense — Form Logic & Validation

import { utilities, getUtilitiesByState } from '../data/utilities.js';
import { getRatePlansForUtility } from '../data/ratePlans.js';

/**
 * Initialize the 3-step wizard form
 */
export function initForm(onCalculate) {
    const state = {
        currentStep: 1,
        utilityId: '',
        ratePlanId: '',
        hasSolar: false,
        monthlyBill: 200,
        homeSize: 2000,
        occupants: 3,
        hasEv: false,
        hasPool: false,
        hvacType: 'gas',
        dailyKwh: 0,
        backupValue: null,
        participateInVpp: true,
        useFederalTaxCredit: true,
    };

    setupUtilityDropdown(state);
    setupRatePlanDropdown(state);
    setupSolarToggle(state);
    setupFormInputs(state);
    setupBackupSlider(state);
    setupToggles(state);
    setupNavigation(state, onCalculate);
    updateStepDisplay(state);

    return state;
}

function setupUtilityDropdown(state) {
    const select = document.getElementById('utility-select');
    if (!select) return;

    const grouped = getUtilitiesByState();
    select.innerHTML = '<option value="">Select your utility...</option>';

    // Sort states
    const states = Object.keys(grouped).sort();
    for (const st of states) {
        const optgroup = document.createElement('optgroup');
        optgroup.label = st;
        for (const u of grouped[st]) {
            const opt = document.createElement('option');
            opt.value = u.id;
            opt.textContent = u.name;
            optgroup.appendChild(opt);
        }
        select.appendChild(optgroup);
    }

    select.addEventListener('change', () => {
        state.utilityId = select.value;
        populateRatePlans(state);
        autoEstimateKwh(state);
    });
}

function setupRatePlanDropdown(state) {
    // Initial empty state — populated when utility is selected
    const select = document.getElementById('rateplan-select');
    if (!select) return;
    select.innerHTML = '<option value="">Select a rate plan...</option>';
}

function populateRatePlans(state) {
    const select = document.getElementById('rateplan-select');
    if (!select) return;

    const plans = getRatePlansForUtility(state.utilityId);
    select.innerHTML = '<option value="">Select a rate plan...</option>';

    for (const plan of plans) {
        const opt = document.createElement('option');
        opt.value = plan.id;
        opt.textContent = plan.name;
        select.appendChild(opt);
    }

    select.addEventListener('change', () => {
        state.ratePlanId = select.value;
    });

    // Auto-select first plan
    if (plans.length > 0) {
        select.value = plans[0].id;
        state.ratePlanId = plans[0].id;
    }
}

function setupSolarToggle(state) {
    const toggle = document.getElementById('solar-toggle');
    const callout = document.getElementById('nem3-callout');
    if (!toggle) return;

    toggle.addEventListener('change', () => {
        state.hasSolar = toggle.checked;
        if (callout) {
            const utility = utilities.find(u => u.id === state.utilityId);
            if (toggle.checked && utility?.hasNem3) {
                callout.classList.add('nem3-callout--visible');
            } else {
                callout.classList.remove('nem3-callout--visible');
            }
        }
    });
}

function setupFormInputs(state) {
    // Monthly bill
    const billInput = document.getElementById('monthly-bill');
    if (billInput) {
        billInput.value = state.monthlyBill;
        billInput.addEventListener('input', () => {
            state.monthlyBill = parseFloat(billInput.value) || 0;
            autoEstimateKwh(state);
        });
    }

    // Home size
    const sizeInput = document.getElementById('home-size');
    if (sizeInput) {
        sizeInput.value = state.homeSize;
        sizeInput.addEventListener('input', () => {
            state.homeSize = parseInt(sizeInput.value) || 0;
        });
    }

    // Occupants
    const occInput = document.getElementById('occupants');
    if (occInput) {
        occInput.value = state.occupants;
        occInput.addEventListener('input', () => {
            state.occupants = parseInt(occInput.value) || 1;
        });
    }

    // EV checkbox
    const evCheck = document.getElementById('has-ev');
    if (evCheck) {
        evCheck.addEventListener('change', () => {
            state.hasEv = evCheck.checked;
            autoEstimateKwh(state);
        });
    }

    // Pool checkbox
    const poolCheck = document.getElementById('has-pool');
    if (poolCheck) {
        poolCheck.addEventListener('change', () => {
            state.hasPool = poolCheck.checked;
            autoEstimateKwh(state);
        });
    }

    // HVAC type
    const hvacSelect = document.getElementById('hvac-type');
    if (hvacSelect) {
        hvacSelect.addEventListener('change', () => {
            state.hvacType = hvacSelect.value;
        });
    }

    // Daily kWh (editable estimate)
    const kwhInput = document.getElementById('daily-kwh');
    if (kwhInput) {
        kwhInput.addEventListener('input', () => {
            state.dailyKwh = parseFloat(kwhInput.value) || 0;
        });
    }
}

function setupBackupSlider(state) {
    const slider = document.getElementById('backup-slider');
    const valueDisplay = document.getElementById('backup-value-display');
    if (!slider) return;

    slider.addEventListener('input', () => {
        const val = parseInt(slider.value);
        state.backupValue = val;
        if (valueDisplay) {
            valueDisplay.textContent = `$${val.toLocaleString()}/yr`;
        }
    });

    // Set initial
    const defaultVal = 200;
    slider.value = defaultVal;
    state.backupValue = defaultVal;
    if (valueDisplay) valueDisplay.textContent = `$${defaultVal}/yr`;
}

function setupToggles(state) {
    const vppToggle = document.getElementById('vpp-toggle');
    if (vppToggle) {
        vppToggle.checked = state.participateInVpp;
        vppToggle.addEventListener('change', () => {
            state.participateInVpp = vppToggle.checked;
        });
    }

    const itcToggle = document.getElementById('itc-toggle');
    if (itcToggle) {
        itcToggle.checked = state.useFederalTaxCredit;
        itcToggle.addEventListener('change', () => {
            state.useFederalTaxCredit = itcToggle.checked;
        });
    }
}

function setupNavigation(state, onCalculate) {
    // Next buttons
    document.querySelectorAll('[data-action="next"]').forEach(btn => {
        btn.addEventListener('click', () => {
            if (validateStep(state)) {
                state.currentStep = Math.min(state.currentStep + 1, 3);
                updateStepDisplay(state);
            }
        });
    });

    // Back buttons
    document.querySelectorAll('[data-action="back"]').forEach(btn => {
        btn.addEventListener('click', () => {
            state.currentStep = Math.max(state.currentStep - 1, 1);
            updateStepDisplay(state);
        });
    });

    // Calculate button
    const calcBtn = document.getElementById('calculate-btn');
    if (calcBtn) {
        calcBtn.addEventListener('click', () => {
            if (validateStep(state)) {
                onCalculate(state);
            }
        });
    }
}

function validateStep(state) {
    if (state.currentStep === 1) {
        if (!state.utilityId) {
            shakeElement('utility-select');
            return false;
        }
        if (!state.ratePlanId) {
            shakeElement('rateplan-select');
            return false;
        }
        if (state.monthlyBill <= 0) {
            shakeElement('monthly-bill');
            return false;
        }
    }
    return true;
}

function updateStepDisplay(state) {
    // Update step content visibility
    document.querySelectorAll('.step').forEach(el => {
        el.classList.remove('step--active');
    });
    const activeStep = document.getElementById(`step-${state.currentStep}`);
    if (activeStep) activeStep.classList.add('step--active');

    // Update progress dots
    for (let i = 1; i <= 3; i++) {
        const dot = document.getElementById(`dot-${i}`);
        const connector = document.getElementById(`connector-${i}`);
        if (dot) {
            dot.classList.remove('wizard__dot--active', 'wizard__dot--completed');
            if (i === state.currentStep) dot.classList.add('wizard__dot--active');
            if (i < state.currentStep) dot.classList.add('wizard__dot--completed');
        }
        if (connector) {
            connector.classList.toggle('wizard__connector--active', i < state.currentStep);
        }
    }

    // Update step labels
    document.querySelectorAll('.wizard__step-label').forEach((label, i) => {
        label.classList.toggle('wizard__step-label--active', i + 1 === state.currentStep);
    });
}

function autoEstimateKwh(state) {
    if (!state.utilityId || state.monthlyBill <= 0) return;

    const utility = utilities.find(u => u.id === state.utilityId);
    if (!utility) return;

    let monthlyKwh = state.monthlyBill / utility.avgBlendedRate;
    if (state.hasEv) monthlyKwh += 400; // ~400 kWh/month for EV (~30 mi/day)
    if (state.hasPool) monthlyKwh += 200; // pool pump estimate

    const dailyKwh = Math.round(monthlyKwh / 30);
    state.dailyKwh = dailyKwh;

    const kwhInput = document.getElementById('daily-kwh');
    if (kwhInput) kwhInput.value = dailyKwh;
}

function shakeElement(id) {
    const el = document.getElementById(id);
    if (!el) return;
    el.style.borderColor = 'var(--accent-red)';
    el.style.animation = 'none';
    el.offsetHeight; // reflow
    el.style.animation = 'shake 0.4s ease';
    setTimeout(() => {
        el.style.borderColor = '';
        el.style.animation = '';
    }, 600);
}

// Add shake animation
const style = document.createElement('style');
style.textContent = `
  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-6px); }
    50% { transform: translateX(6px); }
    75% { transform: translateX(-4px); }
  }
`;
document.head.appendChild(style);
