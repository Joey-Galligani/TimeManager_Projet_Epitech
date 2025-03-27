<script setup lang="ts">
import { defineProps } from 'vue';
import { OhVueIcon } from 'oh-vue-icons';
import { useRouter, useRoute } from 'vue-router';

const props = defineProps<{
  icon: string;
  label: string;
  route: string;
}>();

const router = useRouter();
const route = useRoute();

const handleClick = () => {
  router.push(props.route);
};

const isActive = () => {
  return route.path === props.route;
};
</script>

<template>
    <button 
      @click="handleClick" 
      :class="['cursor-pointer flex items-center space-x-2 px-4 py-2 text-gray-600 font-medium', isActive() ? 'text-orangeperferct hover:cursor-default' : 'hover:text-black hover:underline-animation' ]"
    >
      <OhVueIcon :name="icon" />
      <span class="font-mediu">{{ label }}</span>
    </button>
  </template>
  
  <style scoped>
  .hover\:underline-animation {
    position: relative;
    overflow: hidden;
  }
  
  .hover\:underline-animation::after {
    content: '';
    position: absolute;
    width: 70%;
    height: 2px;
    border-radius: 50px;
    background-color: currentColor;
    bottom: 0;
    left: 16%;
    transform: scaleX(0);
    transform-origin: bottom right;
    transition: transform 0.35s ease-out;
  }
  
  .hover\:underline-animation:hover::after {
    transform: scaleX(1);
    transform-origin: bottom left;
  }
  </style>