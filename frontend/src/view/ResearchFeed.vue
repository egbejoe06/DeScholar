<template>
    <div>
        <Navbar />
    </div>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
        <div class="max-w-7xl mx-auto">
            <!-- Header with Publish Button -->
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h2 class="text-3xl font-bold text-gray-900">Research Feed</h2>
                    <p class="mt-2 text-gray-600">Discover the latest research papers from our community</p>
                </div>
                <router-link to="/publish"
                    class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
                    <PlusCircle class="w-5 h-5" />
                    Publish Research
                </router-link>
            </div>

            <!-- Loading State -->
            <div v-if="loading" class="flex justify-center items-center py-12">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>

            <!-- Rest of the template code remains the same -->
            <!-- Research Papers Grid -->
            <div v-else-if="researchPapers.length" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <!-- Existing research papers grid content -->
                <div v-for="paper in researchPapers" :key="paper.tokenId"
                    class="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden border border-gray-100">
                    <router-link :to="{ name: 'ResearchDetail', params: { id: paper.tokenId } }">
                        <div class="p-6">
                            <!-- Paper Header -->
                            <div class="flex items-start justify-between">
                                <div>
                                    <h3 class="text-xl font-semibold text-gray-900 mb-2">{{ paper.metadata.name }}</h3>
                                    <p class="text-sm text-gray-500">
                                        Published {{ formatDate(paper.timestamp) }}
                                    </p>
                                </div>
                                <div :class="paper.peerReviewed ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'"
                                    class="px-3 py-1 rounded-full text-xs font-medium">
                                    {{ paper.peerReviewed ? 'Peer Reviewed' : 'Under Review' }}
                                </div>
                            </div>

                            <!-- Description -->
                            <p class="mt-3 text-gray-600 text-sm">{{ paper.metadata.description }}</p>

                            <!-- IPFS Link -->
                            <div v-if="paper.metadata.file" class="mt-4">
                                <a :href="getIPFSUrl(paper.metadata.file)" target="_blank"
                                    class="inline-flex items-center text-blue-600 hover:text-blue-700">
                                    <FileDown class="w-4 h-4 mr-2" />
                                    View Research Paper
                                </a>
                            </div>

                            <!-- Researcher Info -->
                            <div class="mt-4 flex items-center">
                                <div class="bg-blue-100 rounded-full p-2">
                                    <UserCircle class="w-5 h-5 text-blue-600" />
                                </div>
                                <div class="ml-3">
                                    <p class="text-sm font-medium text-gray-900">
                                        {{ truncateAddress(paper.researcher) }}
                                    </p>
                                    <p class="text-xs text-gray-500">Researcher</p>
                                </div>
                            </div>

                            <!-- Review Stats -->
                            <div class="mt-4 flex items-center justify-between border-t border-gray-100 pt-4">
                                <div class="flex items-center space-x-2">
                                    <Star class="w-5 h-5 text-yellow-400" />
                                    <span class="text-sm text-gray-600">{{ paper.reviewCount || 0 }} Reviews</span>
                                </div>

                                <!-- Review Button -->
                                <button v-if="!isReviewer(paper.tokenId)" @click="openReviewModal(paper)"
                                    class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 transition-colors">
                                    Submit Review
                                </button>
                                <span v-else class="text-sm text-gray-500">Already Reviewed</span>
                            </div>
                        </div>
                    </router-link>
                </div>
            </div>

            <!-- Empty State -->
            <div v-else class="text-center py-12">
                <h3 class="text-lg font-medium text-gray-900">No Research Papers Found</h3>
                <p class="mt-2 text-gray-500">Be the first to publish your research!</p>
                <router-link to="/publish"
                    class="mt-4 inline-flex items-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors gap-2">
                    <PlusCircle class="w-5 h-5" />
                    Publish Research
                </router-link>
            </div>

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
                                <!-- Score Input -->
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">
                                        Score (1-10)
                                    </label>
                                    <input type="number" v-model="reviewForm.score" min="1" max="10"
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" required />
                                </div>

                                <!-- Comment Input -->
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">
                                        Comments
                                    </label>
                                    <textarea v-model="reviewForm.comment" rows="4"
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" required></textarea>
                                </div>

                                <!-- Submit Button -->
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
import { ref, onMounted } from 'vue'
import { Dialog, DialogOverlay, DialogTitle } from '@headlessui/vue'
import { UserCircle, Star, FileDown, PlusCircle } from 'lucide-vue-next'
import { useWallet } from '../composable/useWallet'
import axios from 'axios'
import { ethers } from 'ethers'
import Navbar from "../components/NavBar.vue"
import FooterSection from '../components/FooterSection.vue'

const {
    connectWallet,
    getResearchContract,
    userAccount,
} = useWallet()

// State
const loading = ref(true)
const researchPapers = ref([])
const isReviewModalOpen = ref(false)
const selectedPaper = ref(null)
const isSubmitting = ref(false)
const reviewForm = ref({
    score: '',
    comment: ''
})

// Contract instance
const contract = ref(null)

// Initialize contract and fetch research papers
onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchContract()
        await fetchResearchPapers()
    } catch (error) {
        console.error('Failed to initialize:', error)
    } finally {
        loading.value = false
    }
})

// Fetch IPFS metadata
const fetchNFTMetadata = async (tokenId) => {
    try {
        const tokenURI = await contract.value.tokenURI(tokenId)
        const ipfsGateway = 'https://pink-glamorous-hawk-591.mypinata.cloud/ipfs/'
        const cleanTokenURI = tokenURI.replace('ipfs://', '')
        const metadataUrl = `${ipfsGateway}${cleanTokenURI}`
        const response = await axios.get(metadataUrl)
        const imageUrl = response.data.file ? response.data.file.replace('ipfs://', ipfsGateway) : null;

        return {
            name: response.data.name || `NFT #${tokenId}`,
            description: response.data.description || 'No description available',
            image: imageUrl || `https://via.placeholder.com/350x350?text=NFT+${tokenId}`,
        }
    } catch (error) {
        console.error(`Failed to fetch metadata for NFT #${tokenId}:`, error)
        return {
            name: `NFT #${tokenId}`,
            description: 'Metadata unavailable',
            image: `https://via.placeholder.com/350x350?text=NFT+${tokenId}`
        }
    }
}

function getIPFSUrl(uri) {
    const ipfsHash = uri.replace('ipfs://', '')
    return `https://pink-glamorous-hawk-591.mypinata.cloud/ipfs/${ipfsHash}`
}

const fetchResearchPapers = async () => {
    try {
        const tokenIds = await contract.value.getAllAvailableResearch()
        const papers = await Promise.all(
            tokenIds.map(async (tokenId) => {
                const research = await contract.value.getResearch(tokenId)
                const reviews = await contract.value.getResearchReviews(tokenId)
                const metadata = await fetchNFTMetadata(tokenId)
                return {
                    ...research,
                    metadata,
                    reviewCount: reviews.length,
                }
            })
        )
        researchPapers.value = papers.filter(paper => paper && !paper.isDeleted && paper.metadata)
    } catch (error) {
        console.error('Failed to fetch research papers:', error)
    }
}

async function isReviewer(tokenId) {
    try {
        return await contract.value.isReviewer(tokenId, userAccount.value)
    } catch (error) {
        console.error('Failed to check reviewer status:', error)
        return false
    }
}

function openReviewModal(paper) {
    selectedPaper.value = paper
    isReviewModalOpen.value = true
}

function closeReviewModal() {
    isReviewModalOpen.value = false
    selectedPaper.value = null
    reviewForm.value = { score: '', comment: '' }
}

async function submitReview() {
    if (!selectedPaper.value) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.submitReview(
            selectedPaper.value.tokenId,
            reviewForm.value.score,
            reviewForm.value.comment
        )
        await tx.wait()
        await fetchResearchPapers()
        closeReviewModal()
    } catch (error) {
        console.error('Failed to submit review:', error)
        alert('Failed to submit review. Please try again.')
    } finally {
        isSubmitting.value = false
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