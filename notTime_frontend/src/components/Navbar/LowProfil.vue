<script setup lang="ts">
//@ts-ignore
import ModalProfil from '../ModalProfil/ModalProfil.vue'
</script>

<template>
    <div class="flex shadow-best h-16 space-x-4 gap-2 px-2 pr-4 py-5 ml-4 bg-whiteDA rounded-full w-full font-medium items-center">
        <input type="text" class="bg-grayDA outline-none rounded-full px-8 shadow-best py-3 w-full" placeholder="Search....">
        <div>
            <ModalProfil />
            
        </div>
    </div>
</template>

<style lang="">
    
</style>