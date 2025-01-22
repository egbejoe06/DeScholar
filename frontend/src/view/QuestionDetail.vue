<template>
    <div>
        <Navbar />
        <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
            <div class="max-w-7xl mx-auto">
                <!-- Loading State -->
                <div v-if="loading" class="flex justify-center items-center py-12">
                    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                </div>

                <!-- Question Details -->
                <div v-else-if="question" class="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-100">
                    <div class="p-6">
                        <!-- Question Header -->
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

                        <!-- Answers Section -->
                        <div class="mt-6 space-y-4">
                            <div v-if="answers.length">
                                <h4 class="font-medium text-gray-900 mb-3">Answers</h4>
                                <div class="space-y-4">
                                    <div v-for="answer in answers" :key="answer.answerId"
                                        class="bg-gray-50 rounded-lg p-4">
                                        <p class="text-gray-700">{{ answer.content }}</p>
                                        <div class="mt-2 flex items-center text-sm text-gray-500">
                                            <span>Answered by {{ truncateAddress(answer.responder) }}</span>
                                            <span class="mx-2">•</span>
                                            <span>{{ formatDate(answer.timestamp) }}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Submit Answer Form -->
                            <div v-if="!question.isResolved" class="mt-4">
                                <form @submit.prevent="submitAnswer">
                                    <textarea v-model="newAnswer" rows="2"
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2"
                                        placeholder="Write your answer..." required></textarea>
                                    <div class="mt-2 flex justify-between items-center">
                                        <button type="submit"
                                            class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 transition-colors"
                                            :disabled="isSubmitting">
                                            {{ isSubmitting ? 'Submitting...' : 'Submit Answer' }}
                                        </button>
                                        <button v-if="question.asker === userAccount" @click="resolveQuestion"
                                            class="px-4 py-2 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700 transition-colors">
                                            Mark as Resolved
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Question Not Found -->
                <div v-else class="text-center py-12">
                    <h3 class="text-lg font-medium text-gray-900">Question Not Found</h3>
                    <button @click="router.push('/')"
                        class="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                        Back to Questions
                    </button>
                </div>
            </div>
        </div>
        <FooterSection />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useWallet } from '../composable/useWallet'
import Navbar from "../components/NavBar.vue"
import FooterSection from '../components/FooterSection.vue'

const route = useRoute()
const router = useRouter()
const {
    connectWallet,
    getQuestionContract,
    userAccount,
} = useWallet()

// State
const loading = ref(true)
const question = ref(null)
const answers = ref([])
const isSubmitting = ref(false)
const newAnswer = ref('')

// Contract instance
const contract = ref(null)

onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getQuestionContract()
        await fetchQuestionDetails()
    } catch (error) {
        console.error('Failed to initialize:', error)
    } finally {
        loading.value = false
    }
})

async function fetchQuestionDetails() {
    try {
        const questionId = route.params.id
        const allQuestions = await contract.value.getAllQuestions()
        question.value = allQuestions.find(q => q.questionId.toString() === questionId && q.exists)

        if (question.value) {
            const questionAnswers = await contract.value.getAnswers(questionId)
            answers.value = questionAnswers.filter(a => a.exists)
        }
    } catch (error) {
        console.error('Failed to fetch question details:', error)
    }
}

async function submitAnswer() {
    if (!newAnswer.value.trim()) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.submitAnswer(route.params.id, newAnswer.value)
        await tx.wait()
        newAnswer.value = ''
        await fetchQuestionDetails()
    } catch (error) {
        console.error('Failed to submit answer:', error)
        alert('Failed to submit answer. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

async function resolveQuestion() {
    try {
        const tx = await contract.value.resolveQuestion(route.params.id)
        await tx.wait()
        await fetchQuestionDetails()
    } catch (error) {
        console.error('Failed to resolve question:', error)
        alert('Failed to resolve question. Please try again.')
    }
}

function formatDate(timestamp) {
    return new Date(timestamp * 1000).toLocaleDateString()
}

function truncateAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}
</script>