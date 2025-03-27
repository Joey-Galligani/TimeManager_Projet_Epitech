import type { Ref } from "vue";

const API_BASE_URL = 'http://localhost:4000/api';

export const apiRoutes = {
    login: `${API_BASE_URL}/login`,
    register: `${API_BASE_URL}/register`,
    userById: (user_id: number) => `${API_BASE_URL}/users/${user_id}`,
    emailForgot: (emailForgot: Ref) => `${API_BASE_URL}/users?email=${emailForgot}`,
    forgotPassword: `${API_BASE_URL}/forgot-password`,
    clock: (userID: string) => `${API_BASE_URL}/clocks/${userID}`,
    getusers: `${API_BASE_URL}/users`,
    clockLimit5: (userID: string) => `${API_BASE_URL}/clocks/${userID}/last_by_limit?limit=5`,
    managers: `${API_BASE_URL}/managers`,
    team: `${API_BASE_URL}/teams`,
    deleteManagers: (user_id: number) => `${API_BASE_URL}/managers/${user_id}`,
    nameTeam: (team_id: number) => `${API_BASE_URL}/teams/${team_id}`,

};
