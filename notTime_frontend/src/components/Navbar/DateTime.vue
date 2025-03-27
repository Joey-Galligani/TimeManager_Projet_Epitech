<!-- DateTime.vue -->
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { OhVueIcon, addIcons } from 'oh-vue-icons';
import { FaRegularClock } from 'oh-vue-icons/icons';

addIcons(FaRegularClock);

const currentTime = ref<string>('');
const showDetails = ref<boolean>(true);

const updateTime = () => {
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  const minutes = now.getMinutes().toString().padStart(2, '0');
  const date = now.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });
  currentTime.value = `Nous sommes le ${date}, il est ${hours}:${minutes}`;
};

let timer: ReturnType<typeof setInterval>;

onMounted(() => {
  updateTime();
  timer = setInterval(updateTime, 1000);
});

onUnmounted(() => {
  clearInterval(timer);
});

const toggleDetails = () => {
  showDetails.value = !showDetails.value;
};
</script>

<template>
  <div
    @click="toggleDetails"
    :class="[
      'flex shadow-best h-16 space-x-4 px-8 py-5 ml-4 bg-whiteDA rounded-full font-medium items-center transition-all duration-500 ease-in-out',
      showDetails ? 'w-fit min-w-[460px] ease-in-out' : 'ease-in-out'
    ]"
  >
    <OhVueIcon name="fa-regular-clock" class="text-xl" />
      <span v-if="showDetails" class="text-gray-700">
        {{ currentTime }}
      </span>
  </div>
</template>

<style scoped>
</style>
