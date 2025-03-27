<script setup lang="ts">
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { HiSolidHome, BiCalendarWeekFill, GiIsland ,MdLockclockRound, IoSettingsSharp  } from "oh-vue-icons/icons";
// @ts-ignore
import ButtonNav from '../Button/ButtonNav.vue';

addIcons(HiSolidHome, BiCalendarWeekFill, GiIsland ,MdLockclockRound, IoSettingsSharp);

// Retrieve user information from localStorage
let userInfo = null;

try {
  // Parse the JSON string from localStorage
  const userString = localStorage.getItem('userInfo');
  if (userString) {
    userInfo = JSON.parse(userString);
  }
} catch (error) {
  console.error("Failed to parse user info from localStorage:", error);
}

const navItems = [
  { icon: 'hi-solid-home', label: 'Home', route: '/home' },
  { icon: 'md-lockclock-round', label: 'Clock', route: '/clock' },
  { icon: 'bi-calendar-week-fill', label: 'Calendar', route: '/calendar' },
  // { icon: 'gi-island', label: 'Holiday', route: '/holiday' },
];

// Check if the user is an admin
if (userInfo?.is_admin) {
  navItems.push({ icon: 'io-settings-sharp', label: 'Dashboard', route: '/dashboard' });
}
</script>

<template>
  <div class="flex shadow-best h-16 space-x-4 px-8 py-3 ml-4 bg-whiteDA rounded-full">
    <ButtonNav 
      v-for="(item, index) in navItems" 
      :key="index" 
      :icon="item.icon" 
      :label="item.label" 
      :route="item.route" 
    />
  </div>
</template>

<style scoped>
</style>
