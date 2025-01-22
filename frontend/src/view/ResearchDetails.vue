<template>
    <div>
        <Navbar />
    </div>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
        <div class="max-w-4xl mx-auto">
            <!-- Loading State -->
            <div v-if="loading" class="flex justify-center items-center py-12">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>

            <template v-else-if="research">
                <!-- Paper Header -->
                <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
                    <div class="flex items-start justify-between">
                        <div>
                            <h1 class="text-3xl font-bold text-gray-900">{{ research.metadata.name }}</h1>
                            <p class="mt-2 text-gray-600">Published {{ formatDate(research.timestamp) }}</p>
                        </div>
                        <div :class="research.peerReviewed ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'"
                            class="px-4 py-2 rounded-full text-sm font-medium">
                            {{ research.peerReviewed ? 'Peer Reviewed' : 'Under Review' }}
                        </div>
                    </div>

                    <!-- Researcher Info -->
                    <div class="mt-6 flex items-center">
                        <div class="bg-blue-100 rounded-full p-3">
                            <UserCircle class="w-6 h-6 text-blue-600" />
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-900">
                                {{ truncateAddress(research.researcher) }}
                            </p>
                            <p class="text-sm text-gray-500">Researcher</p>
                        </div>
                    </div>
                </div>

                <!-- Paper Content -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Left Column: Description and File -->
                    <div class="lg:col-span-2">
                        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
                            <h2 class="text-xl font-semibold text-gray-900 mb-4">Abstract</h2>
                            <p class="text-gray-600">{{ research.metadata.description }}</p>

                            <!-- File Download -->
                            <div v-if="research.metadata.file" class="mt-6">
                                <h2 class="text-xl font-semibold text-gray-900 mb-4">Research Paper</h2>
                                <a :href="getIPFSUrl(research.metadata.file)" target="_blank"
                                    class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                                    <FileDown class="w-5 h-5 mr-2" />
                                    Download Paper
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Reviews Stats -->
                    <div class="lg:col-span-1">
                        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
                            <h2 class="text-xl font-semibold text-gray-900 mb-4">Review Statistics</h2>
                            <div class="space-y-4">
                                <div class="flex items-center justify-between">
                                    <span class="text-gray-600">Total Reviews</span>
                                    <span class="font-semibold">{{ reviews.length }}</span>
                                </div>
                                <div class="flex items-center justify-between">
                                    <span class="text-gray-600">Average Score</span>
                                    <span class="font-semibold">{{ averageScore }}/5</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Reviews Section -->
                <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
                    <div class="flex items-center justify-between mb-6">
                        <h2 class="text-xl font-semibold text-gray-900">Reviews</h2>
                        <button v-if="isReviewer(research.tokenId)" @click="openReviewModal"
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 transition-colors">
                            Submit Review
                        </button>
                    </div>

                    <!-- Reviews List -->
                    <div v-if="reviews.length" class="space-y-6">
                        <div v-for="review in reviews" :key="review.timestamp"
                            class="border-b border-gray-100 pb-6 last:border-0">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center">
                                    <div class="bg-gray-100 rounded-full p-2">
                                        <UserCircle class="w-5 h-5 text-gray-600" />
                                    </div>
                                    <span class="ml-3 text-sm font-medium text-gray-900">
                                        {{ truncateAddress(review.reviewer) }}
                                    </span>
                                </div>
                                <div class="flex items-center">
                                    <Star class="w-5 h-5 text-yellow-400" />
                                    <span class="ml-2 text-sm font-medium">{{ review.score }}/5</span>
                                </div>
                            </div>
                            <p class="text-gray-600">{{ review.comment }}</p>
                            <p class="mt-2 text-sm text-gray-500">{{ formatDate(review.timestamp) }}</p>
                        </div>
                    </div>

                    <!-- No Reviews State -->
                    <div v-else class="text-center py-12">
                        <p class="text-gray-500">No reviews yet. Be the first to review!</p>
                    </div>
                </div>
            </template>

            <!-- Review Modal -->
            <Dialog :open="isReviewModalOpen" @close="closeReviewModal" class="fixed inset-0 z-50 overflow-y-auto">
                <div class="flex min-h-screen items-center justify-center p-4">
                    <DialogOverlay class="fixed inset-0 bg-black/30" />

                    <div class="relative bg-white rounded-xl max-w-md w-full p-6">
                        <DialogTitle class="text-lg font-medium text-gray-900 mb-4">
                            Submit Review
                        </DialogTitle>

                        <form @submit.prevent="submitReview">
                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">
                                        Score (1-5)
                                    </label>
                                    <input type="number" v-model="reviewForm.score" min="1" max="10"
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" required />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">
                                        Comments
                                    </label>
                                    <textarea v-model="reviewForm.comment" rows="4"
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" required></textarea>
                                </div>

                                <button type="submit" :disabled="isSubmitting"
                                    class="w-full bg-blue-600 text-white rounded-lg px-4 py-2 hover:bg-blue-700 transition-colors disabled:bg-gray-400">
                                    {{ isSubmitting ? 'Submitting...' : 'Submit Review' }}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </Dialog>
        </div>
    </div>
    <FooterSection />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { Dialog, DialogOverlay, DialogTitle } from '@headlessui/vue'
import { UserCircle, Star, FileDown } from 'lucide-vue-next'
import { useRoute } from 'vue-router'
import { useWallet } from '../composable/useWallet'
import Navbar from "../components/NavBar.vue"
import axios from 'axios'
import FooterSection from '../components/FooterSection.vue'

const route = useRoute()
const {
    connectWallet,
    getResearchContract,
    userAccount,
} = useWallet()

// State
const loading = ref(true)
const research = ref(null)
const reviews = ref([])
const isReviewModalOpen = ref(false)
const isSubmitting = ref(false)
const reviewForm = ref({
    score: '',
    comment: ''
})

// Contract instance
const contract = ref(null)

// Computed
const averageScore = computed(() => {
    if (!reviews.value.length) return 'N/A'
    const total = reviews.value.reduce((sum, review) => sum + review.score, 0)
    return (total / reviews.value.length).toFixed(1)
})

// Initialize and fetch data
onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchContract()
        await fetchResearchData()
    } catch (error) {
        console.error('Failed to initialize:', error)
    } finally {
        loading.value = false
    }
})

// Fetch research data and metadata
async function fetchResearchData() {
    try {
        const tokenId = route.params.id
        const researchData = await contract.value.getResearch(tokenId)
        const reviewsData = await contract.value.getResearchReviews(tokenId)

        // Fetch metadata
        const tokenURI = await contract.value.tokenURI(tokenId)
        const ipfsGateway = 'https://pink-glamorous-hawk-591.mypinata.cloud/ipfs/'
        const cleanTokenURI = tokenURI.replace('ipfs://', '')
        const metadataUrl = `${ipfsGateway}${cleanTokenURI}`
        const metadataResponse = await axios.get(metadataUrl)

        research.value = {
            ...researchData,
            metadata: metadataResponse.data
        }
        reviews.value = reviewsData
    } catch (error) {
        console.error('Failed to fetch research data:', error)
    }
}

// Get IPFS URL for file download
function getIPFSUrl(uri) {
    const ipfsHash = uri.replace('ipfs://', '')
    return `https://pink-glamorous-hawk-591.mypinata.cloud/ipfs/${ipfsHash}`
}

// Check if current user has reviewed
async function isReviewer(tokenId) {
    try {
        return await contract.value.isReviewer(tokenId, userAccount.value)
    } catch (error) {
        console.error('Failed to check reviewer status:', error)
        return false
    }
}

// Modal and review functions
function openReviewModal() {
    isReviewModalOpen.value = true
}

function closeReviewModal() {
    isReviewModalOpen.value = false
    reviewForm.value = { score: '', comment: '' }
}

async function submitReview() {
    isSubmitting.value = true
    try {
        const tx = await contract.value.submitReview(
            research.value.tokenId,
            reviewForm.value.score,
            reviewForm.value.comment
        )
        await tx.wait()
        await fetchResearchData()
        closeReviewModal()
    } catch (error) {
        console.error('Failed to submit review:', error)
        alert('Failed to submit review. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Format timestamp to readable date
function formatDate(timestamp) {
    return new Date(timestamp * 1000).toLocaleDateString()
}

// Truncate ethereum address
function truncateAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}
</script>