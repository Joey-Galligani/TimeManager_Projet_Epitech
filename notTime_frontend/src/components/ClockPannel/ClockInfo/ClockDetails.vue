<script lang="ts">
import { defineComponent, type PropType, computed } from 'vue';

interface WorkingHour {
    start: number;
    end: number;
}

interface DayWorkingHours {
    date: string;
    totalWorkedHours: number;
    workingHours: WorkingHour[];
}

// Utility function to convert decimal hours to hh:mm format
const formatTime = (decimalHour: number): string => {
    const hours = Math.floor(decimalHour);
    const minutes = Math.round((decimalHour - hours) * 60);
    return `${hours}h ${minutes < 10 ? '0' : ''}${minutes}m`;
};

// Utility function to format date into French text
const formatDateToFrench = (date: string): string => {
    const dateObj = new Date(date);
    return dateObj.toLocaleDateString('fr-FR', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
    }).charAt(0).toUpperCase() + dateObj.toLocaleDateString('fr-FR', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
    }).slice(1);
};

// Utility function to calculate total worked hours precisely
const calculateTotalWorkedHours = (workingHours: WorkingHour[]): number => {
    let totalWorkedTime = 0;

    // Iterate over each working period and calculate the time worked
    for (let i = 0; i < workingHours.length; i++) {
        const start = workingHours[i].start;
        const end = workingHours[i].end;

        // Calculate the time worked for this period
        const workedTime = end - start;

        // Add this worked time to the total
        totalWorkedTime += workedTime;
    }

    return totalWorkedTime;
};

// Utility function to calculate total break time
const calculateBreakTime = (workingHours: WorkingHour[]): number => {
    let totalBreakTime = 0;

    // Calculate the time between the end of one period and the start of the next
    for (let i = 1; i < workingHours.length; i++) {
        const previousEnd = workingHours[i - 1].end;
        const currentStart = workingHours[i].start;

        // Calculate the break between previous end and current start
        const breakTime = currentStart - previousEnd;

        // Add this break time to the total
        totalBreakTime += breakTime;
    }

    return totalBreakTime;
};

// Utility function to calculate idle time
const calculateIdleTime = (workingHours: WorkingHour[]): number => {
    let idleTime = 0;

    // Assuming standard working hours are from 9am - 5pm (9 to 17)
    const workStart = 9;
    const workEnd = 17;

    if (workingHours.length > 0) {
        const firstStart = workingHours[0].start;
        const lastEnd = workingHours[workingHours.length - 1].end;

        // Calculate idle time before first punch in and after last punch out
        if (firstStart > workStart) {
            idleTime += firstStart - workStart;
        }
        if (lastEnd < workEnd) {
            idleTime += workEnd - lastEnd;
        }
    } else {
        // If no work was logged, entire workday is idle
        idleTime = workEnd - workStart;
    }

    return idleTime;
};

export default defineComponent({
    name: 'ClockDetails',
    props: {
        day: {
            type: Object as PropType<DayWorkingHours>,
            required: true
        }
    },
    setup(props) {
        // Calculate total worked hours using computed to update automatically when 'props.day' changes
        const totalWorkedHours = computed(() => calculateTotalWorkedHours(props.day.workingHours));

        // Calculate break time using computed to update automatically when 'props.day' changes
        const breakTime = computed(() => calculateBreakTime(props.day.workingHours));

        // Calculate idle time using computed
        const idleTime = computed(() => calculateIdleTime(props.day.workingHours));

        // Find the most productive time slot
        const mostProductiveTimeSlot = computed(() => {
            if (props.day.workingHours.length === 0) {
                return "No data available";
            }

            let maxProductiveHour = props.day.workingHours[0];
            let maxDuration = maxProductiveHour.end - maxProductiveHour.start;

            props.day.workingHours.forEach(hour => {
                const duration = hour.end - hour.start;
                if (duration > maxDuration) {
                    maxProductiveHour = hour;
                    maxDuration = duration;
                }
            });

            return `${Math.floor(maxProductiveHour.start)}h - ${Math.ceil(maxProductiveHour.end)}h`;
        });

        return {
            formatTime,
            formatDateToFrench,
            totalWorkedHours,
            breakTime,
            idleTime,
            mostProductiveTimeSlot
        };
    }
});
</script>

<template>
    <div>
        <h2 class="text-2xl font-bold mb-4">{{ formatDateToFrench(day.date) }}</h2>
        <p class="text-lg">Total Worked Hours: {{ formatTime(totalWorkedHours) }}</p>
        <p class="text-lg">Break Time: {{ formatTime(breakTime) }}</p>
        <p class="text-lg">Idle Time: {{ formatTime(idleTime) }}</p>
        <p class="text-lg">Most Productive Time Slot: {{ mostProductiveTimeSlot }}</p>
        <div class="mt-4">
            <h3 class="text-xl font-semibold">Working Hours:</h3>
            <ul class="list-disc ml-5">
                <li v-for="(hour, index) in day.workingHours" :key="index">
                    Start: {{ formatTime(hour.start) }}, End: {{ formatTime(hour.end) }}
                </li>
            </ul>
        </div>
        
    </div>
</template>

<style scoped></style>
