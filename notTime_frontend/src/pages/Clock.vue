<script setup lang="ts">
// @ts-ignore
import Logo from './../components/Logo/Logo.vue'
// @ts-ignore
import Navbar from './../components/Navbar/Navbar.vue';
//@ts-ignore
import DateTime from './../components/Navbar/DateTime.vue';
//@ts-ignore
import LowProfile from './../components/Navbar/LowProfil.vue';
//@ts-ignore
import ClockView from './../components/ClockPannel/ClockView.vue';
</script>

<template>
    <div class="h-screen flex flex-col">
        <div class=" bg-grayDA  w-screen flex transition-bg flex-row p-5">
            <div class="bg-whiteDA shadow-best h-16 w-fit  rounded-full px-9 py-4">
                <Logo :imgSrc="'/black_logo.png'" :titleColor='"black"' :imgSize="'w-6'" :textSize="'text-lg'" />
            </div>
            <Navbar />
            <DateTime />
            <LowProfile />
        </div>
        <ClockView />
    </div>
</template>

<style lang="">
    
</style>