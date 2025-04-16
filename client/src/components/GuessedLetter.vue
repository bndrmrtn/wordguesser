<template>
    <div class="w-14 h-14 bg-blue-400 rounded flex items-center justify-center">
        {{ letter || '' }}
    </div>
</template>

<script setup>
defineProps({
    letter: String,
})
</script>