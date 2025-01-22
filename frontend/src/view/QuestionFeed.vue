<template>
    <div>
        <Navbar />
        <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
            <div class="max-w-7xl mx-auto">
                <!-- Ask Question Section -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Ask a Question</h3>
                    <form @submit.prevent="submitQuestion">
                        <textarea v-model="newQuestion" rows="3"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2"
                            placeholder="What's on your mind?" required></textarea>
                        <button type="submit"
                            class="mt-3 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                            :disabled="isSubmitting">
                            {{ isSubmitting ? 'Submitting...' : 'Ask Question' }}
                        </button>
                    </form>
                </div>

                <!-- Loading State -->
                <div v-if="loading" class="flex justify-center items-center py-12">
                    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                </div>

                <!-- Questions List -->
                <div v-else-if="questions.length" class="space-y-6">
                    <div v-for="question in questions" :key="question.questionId"
                        class="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden border border-gray-100"
                        @click="navigateToDetails(question.questionId)">
                        <div class="p-6 cursor-pointer">
                            <div class="flex items-start justify-between">
                                <div class="flex-1">
                                    <div class="flex items-center justify-between">
                                        <h3 class="text-xl font-semibold text-gray-900">{{ question.content }}</h3>
                                        <div :class="question.isResolved ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'"
                                            class="px-3 py-1 rounded-full text-xs font-medium ml-4">
                                            {{ question.isResolved ? 'Resolved' : 'Open' }}
                                        </div>
                                    </div>
                                    <div class="mt-2 flex items-center text-sm text-gray-500">
                                        <span>Asked by {{ truncateAddress(question.asker) }}</span>
                                        <span class="mx-2">•</span>
                                        <span>{{ formatDate(question.timestamp) }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Empty State -->
                <div v-else class="text-center py-12">
                    <h3 class="text-lg font-medium text-gray-900">No Questions Found</h3>
                    <p class="mt-2 text-gray-500">Be the first to ask a question!</p>
                </div>
            </div>
        </div>
        <FooterSection />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useWallet } from '../composable/useWallet'
import Navbar from "../components/NavBar.vue"
import FooterSection from '../components/FooterSection.vue'

const router = useRouter()
const {
    connectWallet,
    getQuestionContract,
    userAccount,
} = useWallet()

// State
const loading = ref(true)
const questions = ref([])
const isSubmitting = ref(false)
const newQuestion = ref('')

// Contract instance
const contract = ref(null)

onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getQuestionContract()
        await fetchQuestions()
    } catch (error) {
        console.error('Failed to initialize:', error)
    } finally {
        loading.value = false
    }
})

const fetchQuestions = async () => {
    try {
        const allQuestions = await contract.value.getAllQuestions()
        questions.value = allQuestions.filter(q => q.exists)
    } catch (error) {
        console.error('Failed to fetch questions:', error)
    }
}

async function submitQuestion() {
    if (!newQuestion.value.trim()) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.askQuestion(newQuestion.value)
        await tx.wait()
        newQuestion.value = ''
        await fetchQuestions()
    } catch (error) {
        console.error('Failed to submit question:', error)
        alert('Failed to submit question. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

function navigateToDetails(questionId) {
    router.push(`/question/${questionId}`)
}

function formatDate(timestamp) {
    return new Date(timestamp * 1000).toLocaleDateString()
}

function truncateAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}
</script>
