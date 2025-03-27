<script setup lang="ts">
import { ref } from 'vue'
// @ts-ignore
import Logo from './../components/Logo/Logo.vue'
// @ts-ignore
import Input from './../components/Input/Input.vue'
// @ts-ignore
import ButtonConnexion from './../components/Button/ButtonConnexion.vue'
// @ts-ignore
import Checkbox from './../components/Input/Checkbox.vue'
import { useAuthStore } from '../stores/auth';
import { apiRoutes } from '../config/apiRoutes';
import { useRouter } from 'vue-router';
import { jwtDecode } from "jwt-decode";

const isLogin = ref(true)
const isForgotPassword = ref(false)
const password2 = ref('')
const password2conf = ref('')
const email2 = ref('')
const errorMessage = ref('')
const password1 = ref('')
const email1 = ref('')
const emailForgot = ref('')
const CodeMail = ref('')
const newPasswordValue = ref('')
const password3conf = ref('')
const password3 = ref('')
const authStore = useAuthStore();
const router = useRouter();

const validateEmail = (email: string) => {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  return emailRegex.test(email)
}

const validatePassword = (password: string) => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
  return passwordRegex.test(password)
}

const toggleView = (view: string) => {
  if (view === 'login') {
    isLogin.value = true
    isForgotPassword.value = false
  } else if (view === 'register') {
    isLogin.value = false
    isForgotPassword.value = false
  } else if (view === 'forgotPassword') {
    isLogin.value = false
    isForgotPassword.value = true
  }
}

const backgroundImage = () => {
  return isLogin.value ? "url('/bg6.jpg')" : "url('/bg3.jpg')"
}

async function getUserById(user_id: number) {
  try {
    const response = await fetch(apiRoutes.userById(user_id), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();
    console.log('User fetched successfully:', result);
    return result;
  } catch (err) {
    console.error('Error fetching user:', err);
    return null;
  }
}

const registerRequest = async () => {
  const newUser = {
    "user": {
      "email": email2.value,
      "non_hashed_password": password2.value
    }
  }

  try {
    const response = await fetch(apiRoutes.register, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newUser),
    })

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`)
    }

    const result = await response.json()
    if (result.message === "User registered successfully") {
      console.log('Successful registration :', result)
      // Handle successful registration, e.g., redirect to login page or show a success message
      toggleView("login")
    } else {
      throw new Error('Unexpected response format')
    }
  } catch (err) {
    console.error('Registration error :', err)
  }
}

const onClickRegister = () => {
  errorMessage.value = ''

  if (!validateEmail(email2.value)) {
    errorMessage.value = "invalid Email"
    console.log(errorMessage.value);
    return
  }

  if (!password2.value || !password2conf.value) {
    errorMessage.value = "Password fields must not be empty"
    console.log(errorMessage.value);
    return
  }

  if (!validatePassword(password2.value)) {
    errorMessage.value = "The password must contain at least 8 characters, one upper case, one lower case, one number and one special character"
    console.log(errorMessage.value);
    return
  }

  if (password2.value === password2conf.value) {
    registerRequest()
  } else {
    errorMessage.value = "Passwords don't match"
    console.log(errorMessage.value);
  }
}

const loginRequest = async () => {
  const Login = {
    "user": {
      "email": email1.value,
      "non_hashed_password": password1.value
    }
  };

  try {
    const response = await fetch(apiRoutes.login, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(Login),
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const result = await response.json();

    if (result.token) {
      authStore.setToken(result.token);

      const decoded_token = jwtDecode<{ user_id: number }>(result.token);
      const userId = decoded_token.user_id;

      const userInfos = await getUserById(userId);

      if (userInfos) {
        authStore.setUserInfo(userInfos);
        await router.push('/home');
      } else {
        throw new Error('Failed to fetch user information');
      }
    } else {
      errorMessage.value = 'Login failed: invalid email or password';
    }
  } catch (err) {
    errorMessage.value = 'Login error: ' + err;
    console.error('Login error:', err);
  }
};


const onClickLogin = () => {
  errorMessage.value = ''

  if (!validateEmail(email1.value)) {
    errorMessage.value = "Invalid Email"
    console.log(errorMessage.value)
    return
  }

  if (!password1.value) {
    errorMessage.value = "Password field must not be empty"
    console.log(errorMessage.value)
    return
  }

  loginRequest()
}


const SendMail = async () => {
  try {

    const randomCode = Math.floor(100000 + Math.random() * 900000).toString(); // Génère un nombre à 6 chiffres
    const response = await fetch(apiRoutes.forgotPassword, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email: emailForgot.value, code: randomCode }),
    })

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`)
    }

    const result = await response.json()
    console.log('Password reset request successful :', result)

    return randomCode
  } catch (err) {
    console.error('Error in password reset :', err)
    return null
  }
}


const newPassword = async (IDuser: number) => {
  try {
    const response = await fetch(apiRoutes.userById(IDuser), {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ password: password3 }),  // Changer le mot de passe ici
    });

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    const data = await response.json(); // Récupérer la réponse du serveur
    console.log('Mot de passe mis à jour avec succès :', data);

  } catch (err) {
    console.error('Erreur lors de la réinitialisation du mot de passe :', err);
  }
}

const CheckCode = async () => {
  console.log("check code")

  try {
    const response = await fetch(apiRoutes.emailForgot(emailForgot), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email: emailForgot.value }),
    })

    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`)
    }

    const result = await response.json()
    console.log('Password reset request successful :', result)

    const verifcode = await SendMail();

    const IDuser = JSON.parse(result).userid

    if (verifcode === CodeMail.value) {
      newPassword(IDuser)
    }

  } catch (err) {
    console.error('Error in password reset :', err)
  }
}

</script>

<template>
  <div class="bg-cover bg-no-repeat bg-center h-screen w-screen flex justify-between font-poppins text-lg transition-bg"
    :style="{ backgroundImage: backgroundImage() }">
    <div class="w-5/12 flex flex-col items-start justify-center gap-12 m-36">
      <Logo />
      <p class="text-white">
        Optimize your productivity with NotTime, the ultimate time management tool for professionals. Whether you're an
        entrepreneur, manager or freelancer, NotTime helps you organize your days efficiently, track your tasks and meet
        your deadlines effortlessly.
      </p>
    </div>
    <div class="h-screen shadow-best bg-white w-1/2 flex items-center justify-center">
      <div class="w-96">
        <div v-if="isLogin" key="login" class="transition-bg">
          <h3 class="text-3xl font-bold text-gray-800 pt-12">Login</h3>
          <p class="text-gray-500 text-sm mb-8">Enter your email and password to login to your account.</p>
          <Input class="mb-4" placeholder="m@example.com" label="Email" :showLabel="true" v-model="email1" />
          <Input placeholder="Enter your password" type="password" label="Password" :showLabel="true"
            v-model="password1" />
          <Checkbox class="mt-2" label="Remember me" />
          <ButtonConnexion class="mt-8" label="Connexion" @click="(onClickLogin)" />
          <p class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            Don't have an account? Sign up <a @click="toggleView('register')"
              class="text-blue-600 dark:text-blue-500 hover:underline cursor-pointer">here</a>
          </p>
          <p class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            Forgot your password? <a @click="toggleView('forgotPassword')"
              class="text-blue-600 dark:text-blue-500 hover:underline cursor-pointer">Reset it here</a>
          </p>
        </div>

        <div v-else-if="isForgotPassword" key="forgot-password" class="transition-bg">
          <h3 class="text-3xl font-bold text-gray-800 pt-12">Forgot Password</h3>
          <p class="text-gray-500 text-sm mb-8">Enter your new password to login to your account.</p>
          <Input class="mb-2" type="password" placeholder="Enter your password" label="New password" :showLabel="true"
            v-model="password3" />
          <Input class="mb-2" type="password" placeholder="Confirm your password" label="Confirm New Password"
            :showLabel="true" v-model="password3conf" />
          <br>
          <p class="text-gray-500 text-sm mb-8">Enter your email to receive your verification code.</p>
          <Input placeholder="notTime@example.com" label="Email" :showLabel="true" v-model="emailForgot" class="mb-4" />
          <ButtonConnexion label="Submit" @click="SendMail" /><br>
          <Input placeholder="Enter your verification code" label="Verification code" :showLabel="true" class="mb-4"
            v-model="CodeMail" />
          <ButtonConnexion label="Check" @click="CheckCode" />
          <p class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            Remembered your password? Login
            <a @click="toggleView('login')" class="text-blue-600 dark:text-blue-500 hover:underline cursor-pointer">
              here
            </a>
          </p>
        </div>




        <div v-else key="register" class="transition-bg">
          <h3 class="text-3xl font-bold text-gray-800 pt-12">Register</h3>
          <p class="text-gray-500 text-sm mb-8">Fill in the details to create your account.</p>
          <Input class="mb-4" placeholder="m@example.com" label="Email" :showLabel="true" v-model="email2" />
          <Input class="mb-2" type="password" placeholder="Enter your password" label="Password" :showLabel="true"
            v-model="password2" />
          <Input class="mb-2" type="password" placeholder="Confirm your password" label="Confirm Password"
            :showLabel="true" v-model="password2conf" />

          <p v-if="errorMessage" class="text-red-600 text-sm mt-2">{{ errorMessage }}</p>

          <ButtonConnexion class="mt-8" label="Register" @click="onClickRegister" />
          <p class="mt-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            Already have an account? Login <a @click="toggleView('login')"
              class="text-blue-600 dark:text-blue-500 hover:underline cursor-pointer">here</a>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>



<style scoped>
.transition-bg {
  transition: background-image 0.5s ease-in-out;
}
</style>