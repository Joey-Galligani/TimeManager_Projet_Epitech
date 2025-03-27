<script setup lang="ts">
import { ref, computed } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { apiRoutes } from '../../config/apiRoutes';
//@ts-ignore
import Bouton from '../Bouton/Bouton.vue';

const showModal = ref(false);
const showPasswordPrompt = ref(false);
const password = ref("");

const authStore = useAuthStore();

// Access user info
const userInfo = computed(() => authStore.userInfo);

const toggleModal = () => {
    showModal.value = !showModal.value;
    if (showModal.value) {
        // Reset values to user info on close
        lastname.value = userInfo.value?.lastname || '';
        name.value = userInfo.value?.name || '';
        phone.value = userInfo.value?.phone || '';
        username.value = userInfo.value?.username || '';
        email.value = userInfo.value?.email || '';
    }
};

// Define reactive fields
const lastname = ref('');
const name = ref('');
const phone = ref('');
const username = ref('');
const email = ref('');

// Function to save user info
const saveUserInfo = async () => {
    // Show the password prompt to the user
    showPasswordPrompt.value = true;
};

const isModified = computed(() => {
    return (
        lastname.value !== userInfo.value?.lastname ||
        name.value !== userInfo.value?.name ||
        phone.value !== userInfo.value?.phone ||
        username.value !== userInfo.value?.username ||
        email.value !== userInfo.value?.email
    );
});


const submitUserInfo = async () => {
    // Construct JSON with user's new information
    const userPayload = {
        user: {
            name: name.value,
            username: username.value,
            email: email.value,
            lastname: lastname.value,
            phone: phone.value,
            non_hashed_password: password.value, // Add the password
        },
    };

    // Get the user ID (assuming it's in userInfo)
    const userId = userInfo.value?.id;
    console.log(userId, "userId");

    if (userId) {
        try {
            // Send PUT request to update user info
            const response = await fetch(apiRoutes.userById(userId), {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(userPayload),
            });

            if (!response.ok) {
                throw new Error('Failed to update user information');
            }

            const data = await response.json();
            console.log('User information updated successfully', data);

            // Optionally reload or update the data locally
            authStore.setUserInfo(data); // assuming setUserInfo exists to update state
            toggleModal(); // Close the modal
        } catch (error) {
            console.error('Error updating user information:', error);
        }
    }

    // Hide the password prompt
    showPasswordPrompt.value = false;
    password.value = ''; // Clear password after submission
};

const logout = () => {
    authStore.clearAuthData();
    window.location.reload();
};

</script>

<template>
    <div class="">
        <img :src="userInfo?.url_picture || '/profile.png'" alt="Profile Image" @click="toggleModal" class="w-10 h-fit rounded-full" />

        <div v-if="showModal"
            class="fixed inset-0 z-20 bg-black bg-opacity-50 flex justify-center items-center backdrop-blur-sm"
            @click="toggleModal">
            <div class="bg-white p-8 rounded-2xl shadow-lg max-w-fit w-full" @click.stop>
                <div class="flex flex-col">
                    <div class="relative h-2 bg-orangeperferct" style="top:-32px;"></div>
                    <img :src="userInfo?.url_picture || '/profile.png'" alt="Profile Image" class="w-20 h-fit rounded-full" />
                    <h2 class="text-2xl font-bold text-gray-800 pt-4 mb-2">{{ name }} {{ lastname }}</h2>
                    <p>@{{ username }}</p>
                </div>
                <div class="flex gap-32 mt-16 border-y-2 p-4 justify-between">
                    <p class="text-sm font-bold">First name / Last name</p>
                    <div class="flex gap-3 w-80">
                        <input v-model="name" type="text"
                        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-black focus:border-black block w-full p-2.5 ">
                        <input v-model="lastname" type="text"
                            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-black focus:border-black block w-full p-2.5 ">
                    </div>
                </div>
                <div class="flex gap-32 border-b-2 p-4 justify-between">
                    <p class="text-sm font-bold">Phone Number</p>
                    <div class="flex gap-5 w-80">
                        <input v-model="phone" type="text"
                            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-black focus:border-black block w-full p-2.5">
                    </div>
                </div>
                <div class="flex gap-32 border-b-2 p-4 justify-between">
                    <p class="text-sm font-bold">Username</p>
                    <div class="flex gap-5 w-80">
                        <div class="flex w-full">
                            <span
                                class="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border rounded-e-0 border-gray-300 border-e-0 rounded-s-md dark:bg-gray-600 dark:text-gray-400 dark:border-gray-600">
                                <svg class="w-4 h-4 text-gray-500 dark:text-gray-400" aria-hidden="true"
                                    xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                                    <path
                                        d="M10 0a10 10 0 1 0 10 10A10.011 10.011 0 0 0 10 0Zm0 5a3 3 0 1 1 0 6 3 3 0 0 1 0-6Zm0 13a8.949 8.949 0 0 1-4.951-1.488A3.987 3.987 0 0 1 9 13h2a3.987 3.987 0 0 1 3.951 3.512A8.949 8.949 0 0 1 10 18Z" />
                                </svg>
                            </span>
                            <input v-model="username" type="text"
                                class="rounded-none rounded-e-lg bg-gray-50 border text-gray-900 block flex-1 min-w-0 w-full text-sm border-gray-300 p-2.5">
                        </div>
                    </div>
                </div>
                <div class="flex gap-32 border-b-2 p-4 justify-between">
                    <p class="text-sm font-bold">Profile Picture</p>
                    <div class="flex gap-5 w-80 items-center">
                        <img :src="userInfo?.url_picture || '/profile.png'" alt="Profile Image" class="w-10 h-fit rounded-full" />
                        <button type="button"
                            class="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 ">Change
                            Picture</button>
                    </div>
                </div>
                <div class="flex justify-between mt-6">
                    <button type="button" @click="logout"
                        class="text-red-500 bg-white border-red-300 border hover:bg-red-100 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 ">Logout</button>
                    <div>
                        <button type="button" @click="toggleModal"
                            class="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 ">Cancel</button>
                        <button type="button" @click="saveUserInfo" :disabled="!isModified"
                            class="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2"
                            :class="{ 'opacity-50 cursor-not-allowed': !isModified }">Save</button>
                    </div>
                </div>

            </div>
        </div>

        <div v-if="showPasswordPrompt"
            class="fixed inset-0 z-30 bg-black bg-opacity-50 flex justify-center items-center">
            <div class="bg-white p-8 rounded-2xl shadow-lg max-w-fit w-full">
                <h3 class="text-xl font-bold mb-4">Enter Password to Save Changes</h3>
                <input v-model="password" type="password"
                    class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-black focus:border-black block w-full p-2.5 mb-4">
                <button type="button" @click="submitUserInfo"
                    class="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2">Submit</button>
            </div>
        </div>
    </div>
</template>

<style scoped></style>