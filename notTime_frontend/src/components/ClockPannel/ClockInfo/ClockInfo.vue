<script lang="ts">
import { defineComponent, type PropType } from 'vue';

interface WorkingHour {
  start: number;
  end: number;
}

export default defineComponent({
  name: 'ClockInfo',
  props: {
    workingHours: {
      type: Array as PropType<WorkingHour[]>,
      required: true
    },
    date: {
      type: String,
      required: true
    },
    totalWorkedHours: {
      type: Number,
      required: true
    }
  },
  setup(props) {
    const getHourClass = (hour: number) => {
      for (const period of props.workingHours) {
        if (hour >= Math.floor(period.start) && hour < Math.ceil(period.end)) {
          return 'bg-orangeperferct';
        }
      }
      return 'bg-gray-300';
    };

    const getHourWidth = (hour: number) => {
      let width = '100%';
      for (const period of props.workingHours) {
        if (hour === Math.floor(period.start)) {
          width = `${(1 - (period.start % 1)) * 100}%`;
        } else if (hour === Math.floor(period.end)) {
          width = `${(period.end % 1) * 100}%`;
        } else if (hour > Math.floor(period.start) && hour < Math.floor(period.end)) {
          width = '100%';
        }
      }
      return width;
    };

    return {
      getHourClass,
      getHourWidth
    };
  }
});
</script>

<template>
  <div class="flex w-full shadow-best rounded-2xl bg-whiteDA h-28 px-7 justify-between">
    <div class="flex flex-col justify-center gap-3">
      <h3 class="text-xl font-bold text-gray-800">{{ date }}</h3>
      <p class="text-gray-500">{{ totalWorkedHours }} heures</p>
    </div>
    <div class="flex items-center gap-1 z-10">
      <div v-for="hour in 24" :key="hour" class="relative w-4 h-9 rounded-sm bg-gray-300">
        <div 
          :class="getHourClass(hour - 1)" 
          :style="{ height: getHourWidth(hour - 1), width: '100%' }" 
          class="absolute rounded-sm left-0 bottom-0 h-full"
        ></div>
        <span v-if="[2, 6, 10, 14, 18, 22].includes(hour - 1)" 
              style='bottom:-21px; left: -4px;' 
              class="absolute text-xs text-gray-700">
          {{ (hour - 1) % 12 === 0 ? 12 : (hour - 1) % 12 }}{{ (hour - 1) < 12 ? 'am' : 'pm' }}
        </span>
      </div>
    </div>
  </div>
</template>

<style lang="css">
</style>