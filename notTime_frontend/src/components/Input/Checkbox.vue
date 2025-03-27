<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'CustomCheckbox',
  props: {
    label: {
      type: String,
      default: ''
    },
    linkText: {
      type: String,
      default: ''
    },
    linkHref: {
      type: String,
      default: '#'
    }
  }
});
</script>

<template>
  <div class="flex items-center">
    <input id="link-checkbox" type="checkbox" value="" class=" focus:outline-none w-4 h-4 accent-gray-800 text-gray-800 bg-gray-100 border-gray-300 rounded dark:ring-offset-gray-800 focus:ring-gray-300 dark:bg-gray-700 dark:border-gray-600">
    <label for="link-checkbox" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
      {{ label }} <a :href="linkHref" class="text-blue-600 dark:text-blue-500 hover:underline">{{ linkText }}</a>.
    </label>
  </div>
</template>

<style>
    
</style>