<script setup>
import { ref, computed, onMounted } from 'vue';

// Initialisation des variables réactives
const currentDate = ref(new Date());
const daysInMonth = ref([]);
const weekDays = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
const isModalOpen = ref(false);
const selectedDay = ref(null);
const dayInfo = ref("");
const dayInfos = ref({}); // Stocke les informations par jour

// Calcul de l'entête du mois et de l'année
const monthYear = computed(() => {
  const options = { year: "numeric", month: "long" };
  return currentDate.value.toLocaleDateString("fr-FR", options);
});

// Capitalize the first letter of monthYear
const capitalizedMonthYear = computed(() => {
  return monthYear.value.charAt(0).toUpperCase() + monthYear.value.slice(1);
});

// Ouvre le modal pour un jour sélectionné
function openModal(day) {
  selectedDay.value = day;
  dayInfo.value = dayInfos.value[day] || ""; // Charger les infos précédentes, le cas échéant
  isModalOpen.value = true;
}

// Ferme le modal
function closeModal() {
  isModalOpen.value = false;
}

// Enregistre les informations du jour dans le dictionnaire
function saveDayInfo() {
  dayInfos.value[selectedDay.value] = dayInfo.value;
  closeModal();
}

// Actions de demande
function requestLeave() {
  alert("Demande de congé envoyée !");
}

function declareSickLeave() {
  alert("Jour d'arrêt maladie déclaré !");
}

// Calcul des jours dans le mois en cours
function calculateDaysInMonth() {
  const year = currentDate.value.getFullYear();
  const month = currentDate.value.getMonth();
  const days = new Date(year, month + 1, 0).getDate();
  daysInMonth.value = Array.from({ length: days }, (_, i) => i + 1);
}

// Initialisation du calendrier
onMounted(() => {
  calculateDaysInMonth();
});
</script>

<template>
  <div class="flex w-full h-full p-4 bg-gray-100">
    <!-- Partie principale du calendrier -->
    <div class="flex-1 grid grid-cols-7 gap-2 bg-white rounded-2xl p-4 shadow-best overflow-auto h-fit">
      <!-- En-tête du mois -->
      <div class="col-span-7 text-2xl font-semibold flex flex-col justify-center m-6">
        <span>{{ capitalizedMonthYear }} 📅</span>
      </div>
      
      <!-- Jours de la semaine -->
        <div v-for="(day, index) in weekDays" :key="index" class="text-center font-semibold text-gray-600 flex items-end justify-center">
            <span>{{ day }}</span>
        </div>

        <!-- Jours du mois -->
        <div
            v-for="(day, index) in daysInMonth"
            :key="index"
            class="h-[110px] flex items-center justify-center border rounded-lg cursor-pointer hover:bg-blue-100"
            @click="openModal(day)"
        >
            <span>{{ day }}</span>
            <p v-if="dayInfos[day]" class="text-xs text-gray-500 mt-2">{{ dayInfos[day] }}</p>
        </div>

    </div>
    
    <div class="flex flex-col gap-4 ">
        <div class="flex h-64 bg-white ml-4 rounded-2xl shadow-best flex-col items-center gap-4">
            <div class="w-full rounded-t-2xl h-44 bg-cover bg-center bg-no-repeat shadow-best mb-1" style="background-image: url('/stop.jpg');"></div>
            <button type="button" class="mx-7 text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 ">Déclarer un jour d'arrêt maladie</button>
        </div>

        <div class="flex h-64 bg-white ml-4 rounded-2xl shadow-best flex-col items-center gap-4">
            <div class="w-full rounded-t-2xl h-44 bg-cover bg-center bg-no-repeat shadow-best" style="background-image: url('/vac.jpg');"></div>
            <button type="button" class="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 ">Demander un congé</button>
        </div>
    </div>
    

    <!-- Modal pour les informations du jour -->
    <div v-if="isModalOpen" class="fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
      <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h3 class="text-xl font-semibold mb-4">Ajouter des informations pour le {{ selectedDay }}</h3>
        <textarea v-model="dayInfo" class="w-full h-32 p-2 border rounded-lg" placeholder="Informations..."></textarea>
        <div class="mt-4 flex justify-end space-x-2">
          <button @click="closeModal" class="p-2 bg-gray-500 text-white rounded-lg">Annuler</button>
          <button @click="saveDayInfo" class="p-2 bg-blue-500 text-white rounded-lg">Enregistrer</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Ajustement de la hauteur pour prendre tout l'espace disponible */
html, body, #app {
  height: 100%;
  margin: 0;
  overflow: hidden;
}
</style>