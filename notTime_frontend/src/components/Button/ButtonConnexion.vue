
<script>
import { defineComponent, ref } from 'vue';

export default defineComponent({
  name: 'ButtonConnexion',
  props: {
    label: {
      type: String,
      default: ''
    }
  },
  setup() {
    const loading = ref(false);

    const handleClick = () => {
      loading.value = true;
      // Simulate an async operation
      setTimeout(() => {
        loading.value = false;
      }, 2000);
    };

    return {
      loading,
      handleClick
    };
  }
});
</script>

<template>
    <button 
      @click="handleClick"
      class="flex justify-center text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700 w-full"
    >
      <span>{{ label }}</span>
      <svg v-if="loading" class="animate-spin h-5 w-5 ml-3" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
      </svg>
    </button>
  </template>

<style lang="">
/* Ajoutez vos styles ici si nécessaire */
</style>