<template>
  <div class="min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4">
    <h1 class="text-3xl font-bold mb-4">Word Guesser</h1>

    <!-- Lives Display -->
    <div class="flex mb-4">
      <svg
        v-for="n in 5"
        :key="n"
        xmlns="http://www.w3.org/2000/svg"
        :fill="n <= lives ? 'red' : 'none'"
        viewBox="0 0 24 24"
        stroke="red"
        class="w-6 h-6 mx-1"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 
             4.42 3 7.5 3c1.74 0 3.41 0.81 4.5 2.09C13.09 3.81 
             14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 
             6.86-8.55 11.54L12 21.35z"
        />
      </svg>
    </div>

    <div class="mb-6">
      <p class="text-xl tracking-widest font-mono">
        <span
          v-for="(letter, index) in originalWord"
          :key="index"
          class="mx-1 px-2 py-1 rounded"
          :class="{
            'text-green-600': letter != null,
            'bg-red-300 text-white': wrongLetters.includes(letter),
            'border-b border-gray-500': !guessedLetters.includes(letter) && !wrongLetters.includes(letter)
          }"
        >
          {{ letter?.toUpperCase() || '_' }}
        </span>
      </p>
    </div>

    <!-- Virtual Keyboard -->
    <div class="grid grid-cols-9 gap-2 mb-4">
      <button
        v-for="letter in alphabet"
        :key="letter"
        :disabled="guessedLetters.includes(letter) || wrongLetters.includes(letter) || lives <= 0"
        @click="handleKeyboardClick(letter)"
        class="px-3 py-2 rounded text-black transition-colors duration-150"
        :class="{
          'bg-green-300': guessedLetters.includes(letter),
          'bg-red-300': wrongLetters.includes(letter),
          'bg-gray-300 hover:bg-gray-400': !guessedLetters.includes(letter) && !wrongLetters.includes(letter)
        }"
      >
        {{ letter.toUpperCase() }}
      </button>
    </div>

    <div class="mt-4 text-red-500" v-if="message">
      {{ message }}
    </div>

    <div class="mt-6">
      <button
        @click="resetGame"
        class="bg-gray-900 text-white px-6 py-2 rounded-full shadow-md hover:scale-105 hover:bg-gray-700 transition-transform duration-200"
      >
        🔄New Game
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// States
const originalWord = ref([])
const guessedLetters = ref([])
const wrongLetters = ref([])
const message = ref('')
const lives = ref(5)
const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.toLowerCase().split('')

// API request to start a new game (initial word)
async function startGame() {
  const response = await fetch(`/api/reset`)
  wrongLetters.value = []
  guessedLetters.value = []
  message.value = ''
  try {
    const response = await fetch('/api/')
    const data = await response.json()
    originalWord.value = data.guess.guesses
    lives.value = data.guess.lives
  } catch (error) {
    console.error('Error starting game:', error)
  }
}

// API request for handling letter guess
async function handleKeyboardClick(letter) {
  message.value = ''
  if (guessedLetters.value.includes(letter) || wrongLetters.value.includes(letter)) return

  try {
    const response = await fetch(`/api/guess?letter=${letter}`)
    const data = await response.json()

    // Update guesses and incorrect letters
    guessedLetters.value = data.guess.guesses.filter(g => g !== null)
    wrongLetters.value = data.guess.incorrect || []
    const isOk = lives.value == data.guess.lives
    lives.value = data.guess.lives
    originalWord.value = data.guess.guesses

    // Display message based on the outcome
    if (lives.value <= 0) {
      const word = await failed()
      message.value = `Game over! The word was: ${word}`
    } else if (data.guess.guesses.every(g => g !== null)) {
      message.value = 'Congratulations! You guessed the word!'
    } else if(!isOk) {
      message.value = `Wrong guess. You have ${lives.value} lives left.`
    }
  } catch (error) {
    console.error('Error during guess:', error)
  }
}

async function failed() {
  const response = await fetch(`/api/reset`)
  const data = await response.json()
  return data.word;
}

// Reset game
function resetGame() {
  startGame()
  window.addEventListener('keydown', (e) => {
    const key = e.key.toLowerCase()
    if (alphabet.includes(key) && !guessedLetters.value.includes(key) && !wrongLetters.value.includes(key) && lives.value > 0) {
      handleKeyboardClick(key)
    }
  })
}

// Start game when component is mounted
onMounted(() => {
  startGame()
})
</script>

<style scoped>
body {
  font-family: 'Inter', sans-serif;
}
</style>
