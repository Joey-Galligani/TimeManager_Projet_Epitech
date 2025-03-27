<script setup lang="ts">
import { ref, computed, onMounted, defineProps } from 'vue';
import { jwtDecode } from 'jwt-decode';
import { apiRoutes } from '../../config/apiRoutes';

const props = defineProps<{
  image: string;
}>();

// Récupérer l'heure actuelle en pourcentage pour positionner le point
const currentHourPosition = ref(0);
const isChecked = ref(false); // Pour suivre l'état de la checkbox

onMounted(() => {
  const date = new Date();
  const hours = date.getHours();
  const minutes = date.getMinutes();
  const totalMinutes = (hours * 60) + minutes;
  currentHourPosition.value = (totalMinutes / (24 * 60)) * 100;
  GetClock()
});

const time = ref('');
const buttonsEnabled = ref(true); 

const PostClock = async () => {
  if (!buttonsEnabled.value) return; 

  disableButtonsTemporarily(); 

  const token = String(localStorage.getItem('token'));
  const decoded_token = jwtDecode<{ user_id: string }>(token);
  const userID = String(parseInt(decoded_token.user_id, 10));

  const DataClock = {
    "userID": userID
  };

  try {
    const response = await fetch(apiRoutes.clock(userID), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(DataClock),
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    console.log(result.message);
    if (result.message === "Clock in successful") {
      console.log('Clock created:', result);
    } else {
      throw new Error('Unexpected response format');
    }
    GetClock();

  } catch (err) {
    console.error('Creating clock error:', err);
  }
};

const GetClock = async () => {

  const token = String(localStorage.getItem('token'));
  const decoded_token = jwtDecode<{ user_id: string }>(token);
  const userID = String(parseInt(decoded_token.user_id, 10));

  try {
    const response = await fetch(apiRoutes.clock(userID), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    const state = result.clock[0]?.status;
    const clocktime = String(result.clock[0]?.time);
    let [date, timePart] = clocktime.split('T');
    let formattedDate = date.replace(/-/g, '/');
    let finish = `${formattedDate} at ${timePart}`;
    const clockintime = 'Last Clock IN to ' + finish;
    const clockouttime = 'Last Clock OUT to ' + finish;

    if (state === true) {
      isChecked.value = true; 
      time.value = clockintime;
    } else {
      isChecked.value = false; 
      time.value = clockouttime;
    }
  } catch (err) {
    console.error('Error fetching clock state:', err);
  }
};

const disableButtonsTemporarily = () => {
  buttonsEnabled.value = false;
  setTimeout(() => {
    buttonsEnabled.value = true;
  }, 5000); 
};

</script>

<template>
    <div :class="['button', isChecked ? 'active' : '']">
      <svg xmlns="http://www.w3.org/2000/svg" height="8em" viewBox="0 0 384 512" class="svg2">
        <path d="M272 384c9.6-31.9 29.5-59.1 49.2-86.2l0 0c5.2-7.1 10.4-14.2 15.4-21.4c19.8-28.5 31.4-63 31.4-100.3C368 78.8 289.2 0 192 0S16 78.8 16 176c0 37.3 11.6 71.9 31.4 100.3c5 7.2 10.2 14.3 15.4 21.4l0 0c19.8 27.1 39.7 54.4 49.2 86.2H272zM192 512c44.2 0 80-35.8 80-80V416H112v16c0 44.2 35.8 80 80 80zM112 176c0 8.8-7.2 16-16 16s-16-7.2-16-16c0-61.9 50.1-112 112-112c8.8 0 16 7.2 16 16s-7.2 16-16 16c-44.2 0-80 35.8-80 80z"></path>
      </svg>
      <svg xmlns="http://www.w3.org/2000/svg" height="8em" viewBox="0 0 384 512" class="svg">
        <path d="M297.2 248.9C311.6 228.3 320 203.2 320 176c0-70.7-57.3-128-128-128S64 105.3 64 176c0 27.2 8.4 52.3 22.8 72.9c3.7 5.3 8.1 11.3 12.8 17.7l0 0c12.9 17.7 28.3 38.9 39.8 59.8c10.4 19 15.7 38.8 18.3 57.5H109c-2.2-12-5.9-23.7-11.8-34.5c-9.9-18-22.2-34.9-34.5-51.8l0 0 0 0c-5.2-7.1-10.4-14.2-15.4-21.4C27.6 247.9 16 213.3 16 176C16 78.8 94.8 0 192 0s176 78.8 176 176c0 37.3-11.6 71.9-31.4 100.3c-5 7.2-10.2 14.3-15.4 21.4l0 0 0 0c-12.3 16.8-24.6 33.7-34.5 51.8c-5.9 10.8-9.6 22.5-11.8 34.5H226.4c2.6-18.7 7.9-38.6 18.3-57.5c11.5-20.9 26.9-42.1 39.8-59.8l0 0 0 0 0 0c4.7-6.4 9-12.4 12.7-17.7zM192 128c-26.5 0-48 21.5-48 48c0 8.8-7.2 16-16 16s-16-7.2-16-16c0-44.2 35.8-80 80-80c8.8 0 16 7.2 16 16s-7.2 16-16 16zm0 384c-44.2 0-80-35.8-80-80V416H272v16c0 44.2-35.8 80-80 80z"></path>
      </svg>
    </div>
  
    <div class="w-9/12 mt-20 flex flex-col items-center">
      <!-- Ligne représentant les 24h avec graduations -->
      <div class="relative w-full h-3 bg-gray-300 rounded-full">
        <!-- Graduations pour chaque heure -->
        <div v-for="i in 23" :key="i" :style="{ left: (i * 100 / 24) + '%' }" class="absolute h-3 w-px bg-gray-500 top-0"></div>
        <!-- Triangle indiquant l'heure actuelle, au-dessus de la ligne -->
        <div :style="{ left: currentHourPosition + '%' }" class="absolute w-0 h-0 border-l-4 border-r-4 border-b-8 border-transparent border-b-red-500 transform -translate-x-1/2 -translate-y-6 rotate-180"></div>
      </div>
  
      <!-- Indications horaires en bas -->
      <div class="flex justify-between w-full text-gray-700 text-sm mt-2">
        <span>00:00</span>
        <span>06:00</span>
        <span>12:00</span>
        <span>18:00</span>
        <span>24:00</span>
      </div>
    </div>
  {{ time }}
    <div class="toggle-cont">
      <input class="toggle-input" :disabled="!buttonsEnabled" id="toggle" name="toggle" @click="PostClock()" type="checkbox" v-model="isChecked" />
      <label class="toggle-label" for="toggle">
        <div class="cont-label-play">
          <span class="label-play"></span>
        </div>
      </label>
    </div>
  </template>

<style scoped>
.button {
  position: relative;
  list-style: none;
  border: none;
  background-color: transparent;
  border-radius: 50%;
}

.button .svg {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  transition: all 0.3s;
}

.button .svg2 {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  fill: #f4af03;
  opacity: 0;
  transition: opacity 0.3s;
}

/* On retire l'effet hover et on le remplace par la classe active */
.button.active .svg {
  fill: #f4af03;
}

.button.active .svg2 {
  opacity: 1;
  fill: #f4af03;
}

.toggle-cont {
  margin-right: 15px;
  width: 100px;
  height: 50px;
  border-radius: 9999px;
}

.toggle-cont .toggle-input {
  display: none;
}

.toggle-cont .toggle-label {
  cursor: pointer;
  position: relative;
  display: inline-block;
  padding: 6px;
  width: 100%;
  height: 100%;
  background: #272727;
  border-radius: 9999px;
  box-sizing: content-box;
  box-shadow: 0px 0px 16px -8px #fefefe;
}

.toggle-cont .toggle-label .cont-label-play {
  position: relative;
  width: 50px;
  aspect-ratio: 1 / 1;
  background: #5e5e5e;
  border-radius: 9999px;
  transition: all 0.5s cubic-bezier(1, 0, 0, 1);
}

.toggle-cont .toggle-input:checked + .toggle-label .cont-label-play {
  background: #f43f5e;
  transform: translateX(50px);
}

.toggle-cont .toggle-label .label-play {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: inline-block;
  width: 24px;
  aspect-ratio: 1 / 1;
  background: #fefefe;
  border-radius: 4px;
  clip-path: polygon(25% 0, 75% 50%, 25% 100%, 25% 51%);
  transition: all 0.5s cubic-bezier(1, 0, 0, 1);
}

.toggle-cont .toggle-input:checked + .toggle-label .label-play {
  width: 20px;
  clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);
}


    
</style>