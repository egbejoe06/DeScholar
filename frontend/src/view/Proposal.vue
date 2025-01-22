<template>
    <div>
        <Navbar />
    </div>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
        <div class="max-w-7xl mx-auto">
            <!-- Header -->
            <div class="mb-8">
                <h2 class="text-3xl font-bold text-gray-900">Research Proposals</h2>
                <p class="mt-2 text-gray-600">Support groundbreaking research projects</p>
            </div>

            <!-- Create Proposal Button -->
            <div class="mb-8">
                <button @click="openCreateModal"
                    class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    Create New Proposal
                </button>
            </div>

            <!-- Loading State -->
            <div v-if="loading" class="flex justify-center items-center py-12">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>

            <!-- Proposals Grid -->
            <div v-else-if="proposals.length" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <div v-for="proposal in proposals" :key="proposal.id"
                    class="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden border border-gray-100">
                    <div class="p-6">
                        <!-- Proposal Header -->
                        <div class="flex items-start justify-between">
                            <div>
                                <h3 class="text-xl font-semibold text-gray-900 mb-2">{{ proposal.title }}</h3>
                                <p class="text-sm text-gray-500">
                                    Deadline: {{ formatDate(proposal.deadline) }}
                                </p>
                            </div>
                            <div :class="isActive(proposal) ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                                class="px-3 py-1 rounded-full text-xs font-medium">
                                {{ isActive(proposal) ? 'Active' : 'Ended' }}
                            </div>
                        </div>

                        <!-- Description -->
                        <p class="mt-3 text-gray-600 text-sm">{{ proposal.description }}</p>

                        <!-- Funding Progress -->
                        <div class="mt-4">
                            <div class="flex justify-between text-sm mb-1">
                                <span class="text-gray-600">Progress</span>
                                <span class="text-gray-900 font-medium">
                                    {{ formatEther(proposal.currentFunding) }} / {{ formatEther(proposal.fundingGoal) }}
                                    ETH
                                </span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2.5">
                                <div class="bg-blue-600 h-2.5 rounded-full"
                                    :style="{ width: calculateProgress(proposal.currentFunding, proposal.fundingGoal) + '%' }">
                                </div>
                            </div>
                        </div>

                        <!-- Researcher Info -->
                        <div class="mt-4 flex items-center">
                            <div class="bg-blue-100 rounded-full p-2">
                                <UserCircle class="w-5 h-5 text-blue-600" />
                            </div>
                            <div class="ml-3">
                                <p class="text-sm font-medium text-gray-900">
                                    {{ truncateAddress(proposal.researcher) }}
                                </p>
                                <p class="text-xs text-gray-500">Researcher</p>
                            </div>
                        </div>

                        <!-- Fund Button -->
                        <div class="mt-4 pt-4 border-t border-gray-100">
                            <button @click="openFundingModal(proposal)" :disabled="!isActive(proposal)"
                                class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:bg-gray-400">
                                Fund Project
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Empty State -->
            <div v-else class="text-center py-12">
                <h3 class="text-lg font-medium text-gray-900">No Proposals Found</h3>
                <p class="mt-2 text-gray-500">Be the first to create a research proposal!</p>
            </div>

            <!-- Create Proposal Modal -->
            <Dialog :open="isCreateModalOpen" @close="closeCreateModal" class="fixed inset-0 z-50 overflow-y-auto">
                <div class="flex min-h-screen items-center justify-center p-4">
                    <DialogOverlay class="fixed inset-0 bg-black/30" />

                    <div class="relative bg-white rounded-xl max-w-md w-full p-6">
                        <DialogTitle class="text-lg font-medium text-gray-900 mb-4">
                            Create New Proposal
                        </DialogTitle>

                        <form @submit.prevent="createProposal">
                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Title</label>
                                    <input v-model="proposalForm.title" type="text" required
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                                    <textarea v-model="proposalForm.description" rows="4" required
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2"></textarea>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Funding Goal
                                        (ETH)</label>
                                    <input v-model="proposalForm.fundingGoal" type="number" step="0.01" required
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Duration (Days)</label>
                                    <input v-model="proposalForm.durationDays" type="number" required
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" />
                                </div>

                                <button type="submit" :disabled="isSubmitting"
                                    class="w-full bg-blue-600 text-white rounded-lg px-4 py-2 hover:bg-blue-700 transition-colors disabled:bg-gray-400">
                                    {{ isSubmitting ? 'Creating...' : 'Create Proposal' }}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </Dialog>

            <!-- Fund Proposal Modal -->
            <Dialog :open="isFundingModalOpen" @close="closeFundingModal" class="fixed inset-0 z-50 overflow-y-auto">
                <div class="flex min-h-screen items-center justify-center p-4">
                    <DialogOverlay class="fixed inset-0 bg-black/30" />

                    <div class="relative bg-white rounded-xl max-w-md w-full p-6">
                        <DialogTitle class="text-lg font-medium text-gray-900 mb-4">
                            Fund Proposal
                        </DialogTitle>

                        <form @submit.prevent="fundProposal">
                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Amount (ETH)</label>
                                    <input v-model="fundingAmount" type="number" step="0.01" required
                                        class="w-full rounded-lg border border-gray-300 px-3 py-2" />
                                </div>

                                <button type="submit" :disabled="isSubmitting"
                                    class="w-full bg-blue-600 text-white rounded-lg px-4 py-2 hover:bg-blue-700 transition-colors disabled:bg-gray-400">
                                    {{ isSubmitting ? 'Processing...' : 'Fund Project' }}
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
import { UserCircle } from 'lucide-vue-next'
import { useWallet } from '../composable/useWallet'
import { ethers } from 'ethers'
import FooterSection from '../components/FooterSection.vue'
import Navbar from "../components/NavBar.vue"

const {
    connectWallet,
    getProposalContract,
    userAccount,
} = useWallet()

// State
const loading = ref(true)
const proposals = ref([])
const isCreateModalOpen = ref(false)
const isFundingModalOpen = ref(false)
const isSubmitting = ref(false)
const selectedProposal = ref(null)
const fundingAmount = ref('')

const proposalForm = ref({
    title: '',
    description: '',
    fundingGoal: '',
    durationDays: ''
})

// Contract instance
const contract = ref(null)

// Initialize contract and fetch proposals
onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getProposalContract()
        await fetchProposals()
    } catch (error) {
        console.error('Failed to initialize:', error)
    } finally {
        loading.value = false
    }
})

// Fetch all proposals
const fetchProposals = async () => {
    try {
        const allProposals = await contract.value.getAllProposals()
        proposals.value = allProposals
    } catch (error) {
        console.error('Failed to fetch proposals:', error)
    }
}

// Modal functions
function openCreateModal() {
    isCreateModalOpen.value = true
}

function closeCreateModal() {
    isCreateModalOpen.value = false
    proposalForm.value = {
        title: '',
        description: '',
        fundingGoal: '',
        durationDays: ''
    }
}

function openFundingModal(proposal) {
    selectedProposal.value = proposal
    isFundingModalOpen.value = true
}

function closeFundingModal() {
    isFundingModalOpen.value = false
    selectedProposal.value = null
    fundingAmount.value = ''
}

// Create proposal
async function createProposal() {
    if (!contract.value) return

    isSubmitting.value = true
    try {
        const fundingGoalWei = ethers.utils.parseEther(proposalForm.value.fundingGoal.toString())
        const tx = await contract.value.createProposal(
            proposalForm.value.title,
            proposalForm.value.description,
            fundingGoalWei,
            proposalForm.value.durationDays
        )
        await tx.wait()
        await fetchProposals()
        closeCreateModal()
    } catch (error) {
        console.error('Failed to create proposal:', error)
        alert('Failed to create proposal. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Fund proposal
async function fundProposal() {
    if (!contract.value || !selectedProposal.value) return

    isSubmitting.value = true
    try {
        const fundingWei = ethers.utils.parseEther(fundingAmount.value.toString())
        const tx = await contract.value.fundProposal(selectedProposal.value.id, {
            value: fundingWei
        })
        await tx.wait()
        await fetchProposals()
        closeFundingModal()
    } catch (error) {
        console.error('Failed to fund proposal:', error)
        alert('Failed to fund proposal. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Utility functions
function formatDate(timestamp) {
    return new Date(timestamp * 1000).toLocaleDateString()
}

function truncateAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}

function formatEther(wei) {
    return parseFloat(ethers.utils.formatEther(wei)).toFixed(2)
}

function calculateProgress(current, goal) {
    if (!current || !goal) return 0
    const progress = (current.mul(100).div(goal)).toNumber()
    return Math.min(progress, 100)
}

function isActive(proposal) {
    return proposal.active && proposal.deadline > Math.floor(Date.now() / 1000)
}
</script>