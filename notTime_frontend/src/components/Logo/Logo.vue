<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
    name: 'Logo',
    props: {
        imgSrc: {
            type: String,
            default: '/white_logo.png'
        },
        titleColor: {
            type: String,
            default: 'white'
        },
        imgSize: {
            type: String,
            default: 'w-11'
        },
        textSize: {
            type: String,
            default: 'text-4xl'
        }
    }
});
</script>

<template>
    <div class="flex justify-center items-end gap-4">
        <img :src="imgSrc" :class="imgSize" alt="logo" />
        <h2 :style="{ color: titleColor }" :class="`${textSize} font-bold`">NotTime.</h2>
    </div>
</template>

<style>
    
</style>