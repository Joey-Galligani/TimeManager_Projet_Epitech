<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { jwtDecode } from 'jwt-decode';
import { apiRoutes } from '../../config/apiRoutes';
import HelloClock from './HelloClock.vue';

interface User {
  id: number;
  name: string;
  lastname: string;
  urlpicture: string;
}

const users = ref<User[]>([]); 


const listeUsers = async () => {
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
    const liste = [];
    for (let i = 0; i < result.length; i++) {
      const team = result[i].team_id;
      const idUsers = result[i].id;
      const name = result[i].name;
      const lastname = result[i].lastname;
      // const url_picture = result[i].url_picture;
      const userInfo = localStorage.getItem('userInfo');

      let teamUser: string | null = null;

      if (userInfo) {
        try {
          const parsedUserInfo = JSON.parse(userInfo); // Parse le JSON
          teamUser = parsedUserInfo.team_id; // Récupère la team_id
        } catch (error) {
          console.error('Erreur lors de la récupération des informations utilisateur:', error);
        }
      }

      console.log('Team ID:', teamUser);

      if (team === teamUser && team !== null) {
        liste.push({ "id": idUsers, "name": name, "lastname": lastname, "urlpicture": '/profile.png' });
      }
    }

    users.value = liste; 
  } catch (err) {
    console.error('Error fetching users:', err);
  }
};

const currentPage = ref(1);
const usersPerPage = 9;
const buttonsEnabled = ref(true); 

const totalPages = computed(() => Math.ceil(users.value.length / usersPerPage));

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return users.value.slice(start, end); 
});

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

onMounted(() => {
  listeUsers(); 
});
</script>

<template>
  <div class="bg-grayDA grow w-screen flex transition-bg h-max gap-6 flex-row p-5 pt-0">
    <div class="flex flex-col bg-whiteDA shadow-best w-1/2 h-full rounded-3xl px-9 py-4">
      <div class="shadow-best w-full rounded-3xl px-9 py-9 mt-4 h-1/2 bg-cover bg-center bg-no-repeat align-middle items-center justify-center flex flex-col" style="background-image: url('/bgst.png');">
        <h1 class="text-5xl font-bold">Have a Good day,<br></br> <span class="text-orangeperferct">User 👋</span></h1>
        <p class="text-gray-500">Welcome back to your NotTime panel</p>
      </div>
      
      <div class="w-full rounded-3xl px-9 py-20 h-1/2 align-middle items-center flex flex-col mt-10 gap-10">
        <HelloClock image="/profile.png"/>
      </div>
      <br>
    </div>
    <div class="bg-whiteDA shadow-best w-1/2 h-full rounded-3xl px-10 py-5">
      <h2 class="text-3xl font-bold text-gray-800 pt-4 mb-6">Teams member 🧑‍💻</h2>
      <div class="flex flex-col gap-2">
        <div class="flex flex-col gap-2">
          <div v-for="(user, index) in paginatedUsers" :key="user.id"
              :class="[ 
                'flex flex-row items-center justify-between w-full px-5 py-4 shadow-best',
                index === 0 ? 'rounded-t-2xl' : '',
                index === paginatedUsers.length - 1 ? 'rounded-b-2xl' : ''
              ]">
            <div class="flex gap-3 items-center w-1/3">
              <img :src="user.urlpicture" alt="Profile picture" class="w-10 h-fit rounded-full" />
              <p>{{ user.name }} {{ user.lastname }}</p>
            </div>
            
            <button class="w-fit text-right relative inline-flex items-center justify-center p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-red-200 via-red-300 to-yellow-200 group-hover:from-red-200 group-hover:via-red-300 group-hover:to-yellow-200 dark:text-white dark:hover:text-gray-900 focus:ring-4 focus:outline-none focus:ring-red-100 dark:focus:ring-red-400">
              <span class="relative px-5 py-2 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
                Send Message
              </span>
            </button>
          </div>
        </div>
      </div>
      <div class="flex justify-center">
        <button v-for="page in totalPages" :key="page" @click="changePage(page)"
                :class="['px-4 py-2 mx-1 rounded mt-6', currentPage === page ? 'bg-orangeperferct text-white' : 'bg-gray-200']">
          {{ page }}
        </button>
      </div>
    </div>
  </div>
</template>

