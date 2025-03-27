<script lang="ts">
import { defineComponent, ref } from 'vue';

export default defineComponent({
  name: 'Input',
  props: {
    placeholder: {
      type: String,
      default: ''
    },
    modelValue: {
      type: String,
      default: ''
    },
    label: {
      type: String,
      default: ''
    },
    showLabel: {
      type: Boolean,
      default: false
    },
    type: {
      type: String,
      default: 'text'
    }
  },
  emits: ['update:modelValue'],
  setup(props, { emit }) {
    const isPasswordVisible = ref(false);  

    // Met à jour la valeur de l'input et émet un événement
    const updateValue = (event: Event) => {
      const target = event.target as HTMLInputElement;
      emit('update:modelValue', target.value);
    };

    const togglePasswordVisibility = () => {
      isPasswordVisible.value = !isPasswordVisible.value;
    };

    // Vérifie si le type d'input est un mot de passe
    const isPasswordType = () => {
      return props.type === 'password';
    };

    return {
      isPasswordVisible,
      updateValue,
      togglePasswordVisibility,
      isPasswordType
    };
  }
});
</script>

<template>
  <div>
    <label v-if="showLabel" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">{{ label }}</label>
    <div class="relative"> 
      <input
        :placeholder="placeholder"
        class="outline-none bg-gray-50 border-2 border-gray-800 text-gray-900 text-sm rounded-lg focus:ring-orange-500 focus:border-orange-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-orange-500 dark:focus:border-orange-500"
        :type="isPasswordVisible ? 'text' : type" 
        :value="modelValue"   
        @input="updateValue"
        :aria-label="placeholder ? placeholder : 'Input field'"
      />
      <button
        v-if="isPasswordType()"
        type="button" 
        class="absolute inset-y-0 right-0 px-3 py-2 text-sm" 
        @click="togglePasswordVisibility"
        :aria-label="isPasswordVisible ? 'Hide password' : 'Show password'" 
      >
        {{ isPasswordVisible ? 'Hide' : 'Show' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.relative {
  position: relative;
}
.absolute {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}
</style>
