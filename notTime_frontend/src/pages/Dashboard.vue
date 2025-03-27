<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { apiRoutes } from '../config/apiRoutes';

//@ts-ignore
import Logo from '../components/Logo/Logo.vue';
//@ts-ignore
import Navbar from '../components/Navbar/Navbar.vue';
//@ts-ignore
import DateTime from '../components/Navbar/DateTime.vue';
//@ts-ignore
import LowProfile from '../components/Navbar/LowProfil.vue';
//@ts-ignore
import EditUsers from '../components/EditUsers/EditUsers.vue';
//@ts-ignore
import EditTeams from '../components/EditUsers/EditTeams.vue';


interface Team {
    id: number;
    name: string;
}

interface User {
  id: number;
  name: string;
  lastname: string;
  urlpicture: string;
  team_id: string;
  team_name?: string;
}

interface Manager {
  id: number;
  user_id: number;
  name: string;
  lastname: string;
  team_id: string;
}

const currentPageUsers = ref(1);
const currentPageManagers = ref(1);
const currentPageTeams = ref(1);
const usersPerPage = 8;
const teamsPerPage = 8;

const users = ref<User[]>([]);
const managers = ref<Manager[]>([]);
const teams = ref<Team[]>([]);

const loadingUsers = ref(false);
const loadingManagers = ref(false);
const loadingTeams = ref(false);
const errorUsers = ref('');
const errorManagers = ref('');
const errorTeams = ref('');

// Calcul des pages pour les utilisateurs
const totalPagesUsers = computed(() => Math.ceil(users.value.length / usersPerPage));
const paginatedUsers = computed(() => {
  const start = (currentPageUsers.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return users.value.slice(start, end);
});

// Calcul des pages pour les managers
const totalPagesManagers = computed(() => Math.ceil(managers.value.length / usersPerPage));
const paginatedManagers = computed(() => {
  const start = (currentPageManagers.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return managers.value.slice(start, end);
});

// Calcul des pages pour les équipes
const totalPagesTeams = computed(() => Math.ceil(teams.value.length / teamsPerPage));
const paginatedTeams = computed(() => {
  const start = (currentPageTeams.value - 1) * teamsPerPage;
  const end = start + teamsPerPage;
  return teams.value.slice(start, end);
});

// Changement de page
const changePageUsers = (page: number) => {
  if (page >= 1 && page <= totalPagesUsers.value) {
    currentPageUsers.value = page;
  }
};

const changePageManagers = (page: number) => {
  if (page >= 1 && page <= totalPagesManagers.value) {
    currentPageManagers.value = page;
  }
};

const changePageTeams = (page: number) => {
  if (page >= 1 && page <= totalPagesTeams.value) {
    currentPageTeams.value = page;
  }
};

// Récupération des équipes
const fetchTeams = async () => {
  loadingTeams.value = true;
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
    teams.value = result.map((team: any) => ({
      id: team.id,
      name: team.name_team,
    }));

  } catch (err) {
    errorTeams.value = 'Erreur lors de la récupération des équipes';
    console.error('Error fetching teams:', err);
  } finally {
    loadingTeams.value = false;
  }
};

// Récupération des utilisateurs et association aux équipes
const listeUsers = async () => {
  loadingUsers.value = true;
  try {
    const response = await fetch(apiRoutes.getusers, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    users.value = result.map((user: any) => {
      const team = teams.value.find((team) => team.id === parseInt(user.team_id));
      return {
        id: user.id,
        name: user.name,
        lastname: user.lastname,
        urlpicture: user.urlpicture || '/profile.png',
        team_id: user.team_id,
        team_name: team ? team.name : 'null'
      };
    });
  } catch (err) {
    console.error('Error fetching users:', err);
    errorUsers.value = 'Erreur lors de la récupération des utilisateurs';
  } finally {
    loadingUsers.value = false;
  }
};

// Récupération des managers
const fetchManager = async () => {
  loadingManagers.value = true;
  try {
    const response = await fetch(apiRoutes.managers, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    managers.value = result.map((manager: any) => {
      const user = users.value.find((u) => u.id === manager.user_id);
      return {
        id: manager.id,
        user_id: manager.user_id,
        name: user ? user.name : '',
        lastname: user ? user.lastname : '',
        team_id: user ? user.team_id : '',
        team_name: teams ? user?.team_name : '',
      };
    });
  } catch (err) {
    console.error('Error fetching managers:', err);
    errorManagers.value = 'Erreur lors de la récupération des managers';
  } finally {
    loadingManagers.value = false;
  }
};

const handleTeamUpdate = (updatedTeam: Team) => {
    const index = teams.value.findIndex(team => team.id === updatedTeam.id);
    if (index !== -1) {
        teams.value[index] = { ...teams.value[index], ...updatedTeam };
    }
};

const DemoteManager = async (manager : Manager) => {
    try {
    const response = await fetch(apiRoutes.deleteManagers(manager.id), {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    fetchManager();
    
  } catch (err) {
    console.error('Error fetching managers:', err);
  } 
};





// Chargement des données au montage
onMounted(async () => {
  await fetchTeams();
  await listeUsers();
  await fetchManager();
});
</script>


<template>
  <div class="h-screen flex flex-col">
    <div class="bg-grayDA w-screen flex transition-bg flex-row p-5">
      <div class="bg-whiteDA shadow-best h-16 w-fit rounded-full px-9 py-4">
        <Logo :imgSrc="'/black_logo.png'" :titleColor="'black'" :imgSize="'w-6'" :textSize="'text-lg'" />
      </div>
      <Navbar />
      <DateTime />
      <LowProfile />
    </div>

    <div class="bg-grayDA grow w-screen flex transition-bg h-max gap-6 flex-row p-5 pt-0">
      <!-- Section des managers -->
      <div class="bg-whiteDA shadow-best w-1/2 h-full rounded-3xl px-10 py-5">
        <h2 class="text-3xl font-bold text-gray-800 pt-4 mb-6">Manage Managers 🧑‍💻</h2>
        <div v-if="loadingManagers" class="text-center">Loading managers...</div>
        <div v-if="errorManagers" class="text-red-500 text-center">{{ errorManagers }}</div>
        <div v-if="!loadingManagers && !errorManagers">
          <div class="flex flex-col gap-2">
            <div v-for="(manager, index) in paginatedManagers" :key="manager.id"
              :class="[
                'flex flex-row items-center justify-between w-full px-5 py-4 shadow-best',
                index === 0 ? 'rounded-t-2xl' : '',
                index === paginatedManagers.length - 1 ? 'rounded-b-2xl' : ''
              ]">
              <div class="flex gap-3 items-center w-1/3">
                <img src="/manager.png" alt="Profile picture" class="w-10 h-fit rounded-full" />
                <div>
                  <p class="font-bold">{{ manager.name }} {{ manager.lastname }}</p>

                </div>
              </div>
              <button class="text-white bg-orange-800 hover:bg-orange-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2" @click="DemoteManager(manager)">Demote</button>
            </div>
          </div>
          <div class="flex justify-center">
            <button v-for="page in totalPagesManagers" :key="page" @click="changePageManagers(page)"
              :class="['px-4 py-2 mx-1 rounded mt-6', currentPageManagers === page ? 'bg-orangeperferct text-white' : 'bg-gray-200']">
              {{ page }}
            </button>
          </div>
        </div>
        <!-- Section des Teams -->
        <div>
          <h2 class="text-3xl font-bold text-gray-800 pt-4 mb-6">Manage Teams 🧑‍💻</h2>
          <div v-if="loadingTeams" class="text-center">Loading Teams...</div>
          <div v-if="errorTeams" class="text-red-500 text-center">{{ errorTeams }}</div>
          <div v-if="!loadingTeams && !errorTeams">
            <div class="flex flex-col gap-2">
              <div v-for="(team, index) in paginatedTeams" :key="team.id"
                :class="[ 
                  'flex flex-row items-center justify-between w-full px-5 py-4 shadow-best',
                  index === 0 ? 'rounded-t-2xl' : '',
                  index === paginatedTeams.length - 1 ? 'rounded-b-2xl' : ''
                ]">
                <div class="flex gap-3 items-center w-1/3">
                    <img src="/team.png" alt="Profile picture" class="w-10 h-fit rounded-full" />

                  <div>
                    <p class="font-bold">{{ team.name }}</p>
                    <p class="font-normal">Team number {{ team.id }}</p>
                  </div>
                </div>
                <EditTeams :team="team" @updateTeam="handleTeamUpdate" />
              </div>
            </div>
            <div class="flex justify-center">
              <button v-for="page in totalPagesTeams" :key="page" @click="changePageTeams(page)"
                :class="['px-4 py-2 mx-1 rounded mt-6', currentPageTeams === page ? 'bg-orangeperferct text-white' : 'bg-gray-200']">
                {{ page }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-whiteDA shadow-best w-1/2 h-full rounded-3xl px-10 py-5">
        <h2 class="text-3xl font-bold text-gray-800 pt-4 mb-6">Manage Users 🧑‍💻</h2>
        <div v-if="loadingUsers" class="text-center">Loading Users...</div>
        <div v-if="errorUsers" class="text-red-500 text-center">{{ errorUsers }}</div>
        <div v-if="!loadingUsers && !errorUsers">
          <div class="flex flex-col gap-2">
            <div v-for="(user, index) in paginatedUsers" :key="user.id"
              :class="[
                'flex flex-row items-center justify-between w-full px-5 py-4 shadow-best',
                index === 0 ? 'rounded-t-2xl' : '',
                index === paginatedUsers.length - 1 ? 'rounded-b-2xl' : ''
              ]">
              <div class="flex gap-3 items-center w-1/3">
                <img :src="user.urlpicture" alt="Profile picture" class="w-10 h-fit rounded-full" />
                <div>
                  <p class="font-bold">{{ user.name }} {{ user.lastname }}</p>
                  <p>Team name : {{ user.team_name }}</p> <!-- Affichage de l'ID de l'équipe -->
                </div>
              </div>
              <EditUsers :user="user" />
            </div>
          </div>
          <div class="flex justify-center">
            <button v-for="page in totalPagesUsers" :key="page" @click="changePageUsers(page)"
              :class="['px-4 py-2 mx-1 rounded mt-6', currentPageUsers === page ? 'bg-orangeperferct text-white' : 'bg-gray-200']">
              {{ page }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
