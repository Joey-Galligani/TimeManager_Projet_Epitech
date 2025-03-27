<script setup lang="ts">
//@ts-ignore
import ClockInfo from './ClockInfo/ClockInfo.vue';
//@ts-ignore
import ClockDetails from './ClockInfo/ClockDetails.vue';
import ProductivityCharts from '../ProductivityCharts/ProductivityCharts.vue';
import { apiRoutes } from '../../config/apiRoutes';
import { ref, onMounted } from 'vue';

const user = localStorage.getItem('userInfo');
let userId = null;

if (user) {
  const userObj = JSON.parse(user);
  userId = userObj.id;
}

interface Punch {
  id: number;
  status: boolean;
  time: string;
  user_id: number;
}

interface WorkingHours {
  start: number;
  end: number;
}

interface DayWorkingHours {
  date: string;
  totalWorkedHours: number;
  workingHours: WorkingHours[];
}

const daysWorked = ref<DayWorkingHours[]>([]);
const selectedDay = ref<DayWorkingHours | null>(null);
const hoveredDay = ref<string | null>(null); // Track the hovered day by date string

const processPunches = (punches: Punch[]): DayWorkingHours[] => {
  const groupedByDate: { [key: string]: Punch[] } = punches.reduce((acc, punch) => {
    const date = new Date(punch.time).toISOString().split('T')[0];
    if (!acc[date]) {
      acc[date] = [];
    }
    acc[date].push(punch);
    return acc;
  }, {} as { [key: string]: Punch[] });

  const result: DayWorkingHours[] = Object.keys(groupedByDate).map(date => {
    const dayPunches = groupedByDate[date].sort((a, b) => new Date(a.time).getTime() - new Date(b.time).getTime());

    let totalWorkedHours = 0;
    const workingHours: WorkingHours[] = [];
    
    for (let i = 0; i < dayPunches.length; i += 2) {
      if (i + 1 < dayPunches.length) {
        const startTime = new Date(dayPunches[i].time).getTime();
        const endTime = new Date(dayPunches[i + 1].time).getTime();
        const hoursWorked = (endTime - startTime) / (1000 * 60 * 60); 
        totalWorkedHours += hoursWorked;

        const startHour = new Date(dayPunches[i].time).getHours() + new Date(dayPunches[i].time).getMinutes() / 60;
        const endHour = new Date(dayPunches[i + 1].time).getHours() + new Date(dayPunches[i + 1].time).getMinutes() / 60;

        workingHours.push({ start: startHour, end: endHour });
      }
    }

    return {
      date,
      totalWorkedHours: Math.round(totalWorkedHours), 
      workingHours
    };
  });

  return result;
};

const GetClock = async () => {
  try {
    const response = await fetch(apiRoutes.clock(userId), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const result = await response.json();

    if (!Array.isArray(result.clock)) {
      console.error("Le résultat n'est pas un tableau:", result);
      return;
    }

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const processedData = processPunches(result.clock);
    daysWorked.value = processedData;

  } catch (err) {
    console.error('Erreur lors de la récupération des pointages:', err);
  }
};

onMounted(() => {
  GetClock();
});

function formatDate(date: string): string {
  const dateObj = new Date(date);
  const formattedDate = dateObj.toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  });

  return formattedDate.charAt(0).toUpperCase() + formattedDate.slice(1);
}

const selectDay = (day: DayWorkingHours) => {
  selectedDay.value = day;
};

const setHoveredDay = (date: string | null) => {
  hoveredDay.value = date;
};
</script>

<template>
  <div class="bg-grayDA grow w-screen flex transition-bg h-max gap-6 flex-row p-5 pt-0">
    <div class="flex flex-col w-1/2 h-full rounded-3xl gap-3">

        <!-- Loop over worked days to display the ClockInfo component -->
        <div 
          v-for="day in daysWorked" 
          :key="day.date" 
          @click="selectDay(day)"
          @mouseover="setHoveredDay(day.date)"
          @mouseleave="setHoveredDay(null)"
          :class="[
            'cursor-pointer p-2 transition-colors duration-300 rounded-2xl',
            hoveredDay === day.date && selectedDay?.date !== day.date ? 'bg-blue-100' : '', // Hover effect
            selectedDay?.date === day.date ? 'bg-blue-200' : 'bg-whiteDA' // Selected effect
          ]"
        >
          <ClockInfo 
            :workingHours="day.workingHours"
            :totalWorkedHours="day.totalWorkedHours"
            :date="formatDate(day.date)"
          />
        </div>
        
    </div>
    <div class="bg-whiteDA shadow-best w-1/2 h-full rounded-2xl px-10 py-5">
      <!-- Display the selected day's details -->
      <ClockDetails v-if="selectedDay" :day="selectedDay" />
      <ProductivityCharts v-if="selectedDay" :day="selectedDay" />
    </div>
  </div>
</template>

<style lang="">
</style>
