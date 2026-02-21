// CellSense — Backup Value Calculator

/**
 * Calculate the value of backup power for a given battery and utility.
 */
export function calculateBackup(battery, utility, options = {}) {
    const {
        userBackupValue = null, // user-specified annual value ($)
        averageOutageCostPerHour = 50, // default $/hr (food, productivity, comfort)
    } = options;

    const avgOutageHours = utility.avgOutageHoursPerYear || 4.0;

    // Calculate default backup value if user hasn't specified
    const defaultValue = Math.round(avgOutageHours * averageOutageCostPerHour);
    const annualValue = userBackupValue !== null ? userBackupValue : defaultValue;

    // Hours of backup this battery can provide (at average household load of 1.5 kW)
    const avgHouseholdLoadKw = 1.5;
    const essentialLoadKw = 0.8; // essentials only: fridge, lights, wifi, phone charging

    const hoursFullLoad = battery.usableCapacityKwh / avgHouseholdLoadKw;
    const hoursEssentials = battery.usableCapacityKwh / essentialLoadKw;

    return {
        annualValue,
        defaultValue,
        isUserSpecified: userBackupValue !== null,
        hoursFullLoad: Math.round(hoursFullLoad * 10) / 10,
        hoursEssentials: Math.round(hoursEssentials * 10) / 10,
        avgOutageHoursPerYear: avgOutageHours,
        details: {
            avgHouseholdLoadKw,
            essentialLoadKw,
            averageOutageCostPerHour,
        },
    };
}
