<script setup lang="ts">
import { apiRoutes } from '@/config/apiRoutes';
import { ref, defineProps, defineEmits, onMounted } from 'vue';

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['updateUser']);

// Variables réactives
const localLastname = ref(props.user.lastname);
const localName = ref(props.user.name);
const localTeam = ref(props.user.team); // Référence pour l'équipe
const showModal = ref(false);
const teamOptions = ref<{ id: number; name: string }[]>([]); // Modifié pour stocker les ids et noms

const toggleModal = () => {
  localLastname.value = props.user.lastname;
  localName.value = props.user.name;
  localTeam.value = props.user.team; // Remplissage du champ d'équipe
  showModal.value = !showModal.value;
};

const saveChanges = () => {
  emit('updateUser', { ...props.user, name: localName.value, lastname: localLastname.value, team: localTeam.value });
  showModal.value = false;
};

// Fonction pour récupérer les noms des équipes
const getTeamNames = async () => {
  try {
    const response = await fetch(apiRoutes.team, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    teamOptions.value = result.map((team: any) => ({ id: team.id, name: team.name_team })); // Récupère les ids et noms des équipes

  } catch (err) {
    console.error('Error fetching team names:', err);
  } 
};

// Appeler getTeamNames au montage du composant pour obtenir les options d'équipe
onMounted(() => {
  getTeamNames();
  console.log(props.user); // Vérifiez la structure de l'objet user
});

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
          <img :src="props.user.urlpicture || '/profile.png'" alt="Profile Image" class="w-20 h-fit rounded-full" />
          
          <!-- Affiche seulement le prénom -->
          <h2 class="text-2xl font-bold text-gray-800 pt-4 mb-2">{{ props.user.name }} {{ props.user.lastname }}</h2>
          
          <!-- Affiche le nom de l'équipe -->
          <div>
            <p>Team name : {{ props.user.team_name }}</p>
          </div>
        </div>

        <div class="flex gap-32 mt-4 border-y-2 p-4 justify-between mr-14 ml-14">
          <button class="text-white bg-orange-800 hover:bg-orange-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Demote</button>
        </div>

        <div class="flex justify-between mt-6">
          <button @click="showModal = false" type="button" class="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Cancel</button>
          <button @click="saveChanges" type="button" class="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
