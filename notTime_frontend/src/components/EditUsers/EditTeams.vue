<script setup lang="ts">
import { apiRoutes } from '@/config/apiRoutes';
import { ref, watch, defineProps, defineEmits } from 'vue';

const props = defineProps({
  team: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['updateTeam']); // Événement pour mettre à jour l'équipe

const localTeamName = ref(props.team.name); // Référence pour le nom de l'équipe
const showModal = ref(false); // État pour afficher/masquer le modal

const toggleModal = () => {
  localTeamName.value = props.team.name; // Remplissage du champ d'équipe
  showModal.value = !showModal.value; // Alterne l'affichage du modal
};

const saveChanges = () => {
  postTeam();
  emit('updateTeam', { ...props.team, name: localTeamName.value }); // Émet les changements de l'équipe
  showModal.value = false;
  location.reload();

};

// Synchronisation du modèle avec les nouvelles props
watch(
  () => props.team,
  (newTeam) => {
    localTeamName.value = newTeam.name; // Met à jour le nom local lors d'un changement de prop
  }
);

const postTeam = async () => {
    const data = {
        "team" : {
            "name_team": localTeamName.value
        }
    }
    try {
        const response = await fetch(apiRoutes.nameTeam(props.team.id), {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
        });

        if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
        }

        const result = await response.json();
        

    } catch (err) {
        console.error('Error fetching team names:', err);
    } 
};

</script>

<template>
  <div>
    <button @click="toggleModal" type="button" class="w-fit text-right relative inline-flex items-center justify-center p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-red-200 via-red-300 to-yellow-200 group-hover:from-red-200 group-hover:via-red-300 group-hover:to-yellow-200 dark:text-white dark:hover:text-gray-900 focus:ring-4 focus:outline-none focus:ring-red-100 dark:focus:ring-red-400">
      <span class="relative px-5 py-2 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">Edit</span>
    </button>

    <div v-if="showModal" class="fixed inset-0 z-20 bg-black bg-opacity-50 flex justify-center items-center backdrop-blur-sm">
      <div class="bg-white p-8 rounded-2xl shadow-lg max-w-fit w-full" @click.stop>
        <div class="flex flex-col">
          <div class="relative h-2 bg-orangeperferct" style="top:-32px;"></div>
          <h2 class="text-2xl font-bold text-gray-800 pt-4 mb-2">{{props.team.name}}</h2>
        </div>

        <div class="flex gap-32 mt-4 border-y-2 p-4 justify-between">
          <p class="text-sm font-bold">Team Name</p>
          <div class="flex gap-3 w-80">
            <input v-model="localTeamName" type="text" placeholder="Team Name" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-black focus:border-black block w-full p-2.5" />
          </div>
        </div>

        <div class="flex justify-between mt-6">
          <button @click="showModal = false" type="button" class="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Cancel</button>
          <button @click="saveChanges" type="button" class="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
