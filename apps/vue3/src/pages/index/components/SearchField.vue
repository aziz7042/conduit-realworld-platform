<script setup lang="ts">

const formStore = ref({ query: '' })
defineEmits<{ (e: 'search', query: string): void }>()
</script>

<template>
    <input v-model="formStore.query" required type="text" class="form-control form-control-lg" @keyup.enter="$emit('search',formStore.query)"/>
    <br>
    <button class="btn btn-lg btn-primary pull-xs-right" @click="$emit('search',formStore.query)" > Search Articles </button>
</template>


<style scoped>
</style>
