# ICOPage.vue
<template>
    <div>
        <Navbar />
        <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
            <div class="max-w-7xl mx-auto">
                <!-- ICO Status Card -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="text-center">
                            <h3 class="text-lg font-medium text-gray-900">Available Tokens</h3>
                            <p class="mt-2 text-2xl font-bold text-blue-600">{{ formatNumber(availableTokens) }}</p>
                        </div>
                        <div class="text-center">
                            <h3 class="text-lg font-medium text-gray-900">Token Price</h3>
                            <p class="mt-2 text-2xl font-bold text-blue-600">{{ formatEth(tokenPrice) }} ETH</p>
                        </div>
                        <div class="text-center">
                            <h3 class="text-lg font-medium text-gray-900">Total Sold</h3>
                            <p class="mt-2 text-2xl font-bold text-blue-600">{{ formatNumber(totalTokensSold) }}</p>
                        </div>
                    </div>
                </div>

                <!-- Owner Controls Section -->
                <div v-if="isOwner" class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Owner Controls</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- ICO Control -->
                        <div class="space-y-4">
                            <h4 class="text-lg font-medium text-gray-900">ICO Status</h4>
                            <button @click="toggleICO"
                                class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                                :disabled="isSubmitting">
                                {{ icoActive ? 'Stop ICO' : 'Start ICO' }}
                            </button>
                        </div>

                        <!-- Token Price Control -->
                        <div class="space-y-4">
                            <h4 class="text-lg font-medium text-gray-900">Set Token Price</h4>
                            <div class="flex space-x-2">
                                <input v-model="newTokenPrice" type="number" step="0.000001" min="0"
                                    class="flex-1 rounded-lg border border-gray-300 px-3 py-2"
                                    placeholder="New price in ETH" />
                                <button @click="updateTokenPrice"
                                    class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                                    :disabled="isSubmitting || !newTokenPrice">
                                    Update
                                </button>
                            </div>
                        </div>

                        <!-- Withdrawal Controls -->
                        <div class="space-y-4">
                            <h4 class="text-lg font-medium text-gray-900">Withdraw</h4>
                            <div class="flex space-x-2">
                                <button @click="withdrawETH"
                                    class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                                    :disabled="isSubmitting">
                                    Withdraw ETH
                                </button>
                                <button @click="withdrawTokens"
                                    class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                                    :disabled="isSubmitting">
                                    Withdraw Tokens
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Buy Tokens Section -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Buy Tokens</h3>
                    <div v-if="!icoActive" class="text-center py-6 bg-yellow-50 rounded-lg">
                        <p class="text-yellow-800">ICO is currently not active</p>
                    </div>
                    <form v-else @submit.prevent="buyTokens" class="space-y-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                Amount in ETH
                            </label>
                            <input v-model="ethAmount" type="number" step="0.01" min="0"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2"
                                placeholder="Enter ETH amount" required />
                        </div>
                        <div class="text-sm text-gray-600">
                            You will receive: {{ calculateTokens }} tokens
                        </div>
                        <button type="submit"
                            class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                            :disabled="isSubmitting || !ethAmount">
                            {{ isSubmitting ? 'Processing...' : 'Buy Tokens' }}
                        </button>
                    </form>
                </div>

                <!-- Your Investment -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Your Investment</h3>
                    <div v-if="userAccount" class="space-y-2">
                        <p class="text-gray-600">Address: {{ truncateAddress(userAccount) }}</p>
                        <p class="text-gray-600">Investment Amount: {{ formatEth(investmentAmount) }} ETH</p>
                    </div>
                    <div v-else class="text-center py-6 bg-gray-50 rounded-lg">
                        <p class="text-gray-600">Please connect your wallet to view your investment</p>
                    </div>
                </div>
            </div>
        </div>
        <FooterSection />
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ethers } from 'ethers'
import { useWallet } from '../composable/useWallet'
import Navbar from "../components/NavBar.vue"
import FooterSection from '../components/FooterSection.vue'

const {
    connectWallet,
    userAccount,
    getICOContract,
} = useWallet()

// State
const contract = ref(null)
const icoActive = ref(false)
const availableTokens = ref('0')
const tokenPrice = ref('0')
const totalTokensSold = ref('0')
const investmentAmount = ref('0')
const ethAmount = ref('')
const isSubmitting = ref(false)
const isOwner = ref(false)
const contractOwner = ref('')
const newTokenPrice = ref('')

// Initialize contract
const initializeContract = async () => {
    try {
        await connectWallet()
        contract.value = getICOContract()
        await fetchContractData()
        await checkOwnership()
    } catch (error) {
        console.error('Failed to initialize contract:', error)
    }
}

// Check if current user is the owner
const checkOwnership = async () => {
    try {
        contractOwner.value = await contract.value.owner()
        isOwner.value = userAccount.value.toLowerCase() === contractOwner.value.toLowerCase()
    } catch (error) {
        console.error('Failed to check ownership:', error)
    }
}

// Fetch all contract data
const fetchContractData = async () => {
    try {
        const [active, available, price, sold, investment] = await Promise.all([
            contract.value.icoActive(),
            contract.value.getAvailableTokens(),
            contract.value.tokenPrice(),
            contract.value.getTotalTokensSold(),
            contract.value.getInvestmentAmount(userAccount.value)
        ])

        icoActive.value = active
        availableTokens.value = available.toString()
        tokenPrice.value = price.toString()
        totalTokensSold.value = sold.toString()
        investmentAmount.value = investment.toString()
    } catch (error) {
        console.error('Failed to fetch contract data:', error)
    }
}

// Owner functions
const toggleICO = async () => {
    if (!isOwner.value) return
    isSubmitting.value = true
    try {
        const tx = await contract.value[icoActive.value ? 'stopICO' : 'startICO']()
        await tx.wait()
        await fetchContractData()
    } catch (error) {
        console.error('Failed to toggle ICO:', error)
        alert('Failed to toggle ICO status. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

const updateTokenPrice = async () => {
    if (!isOwner.value || !newTokenPrice.value) return
    isSubmitting.value = true
    try {
        const priceInWei = ethers.utils.parseEther(newTokenPrice.value)
        const tx = await contract.value.setTokenPrice(priceInWei)
        await tx.wait()
        await fetchContractData()
        newTokenPrice.value = ''
    } catch (error) {
        console.error('Failed to update token price:', error)
        alert('Failed to update token price. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

const withdrawETH = async () => {
    if (!isOwner.value) return
    isSubmitting.value = true
    try {
        const tx = await contract.value.withdrawETH()
        await tx.wait()
        alert('ETH withdrawn successfully')
    } catch (error) {
        console.error('Failed to withdraw ETH:', error)
        alert('Failed to withdraw ETH. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

const withdrawTokens = async () => {
    if (!isOwner.value) return
    isSubmitting.value = true
    try {
        const tx = await contract.value.withdrawUnsoldTokens()
        await tx.wait()
        await fetchContractData()
        alert('Tokens withdrawn successfully')
    } catch (error) {
        console.error('Failed to withdraw tokens:', error)
        alert('Failed to withdraw tokens. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Computed property to calculate tokens based on ETH amount
const calculateTokens = computed(() => {
    if (!ethAmount.value || !tokenPrice.value) return 0
    try {
        const tokens = (parseFloat(ethAmount.value) * ethers.constants.WeiPerEther) /
            parseFloat(tokenPrice.value)
        return Math.floor(tokens)
    } catch (error) {
        return 0
    }
})

// Buy tokens function
const buyTokens = async () => {
    if (!ethAmount.value || !contract.value) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.buyTokens({
            value: ethers.utils.parseEther(ethAmount.value)
        })
        await tx.wait()
        await fetchContractData()
        ethAmount.value = ''
    } catch (error) {
        console.error('Failed to buy tokens:', error)
        alert('Failed to buy tokens. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Utility functions
const formatNumber = (value) => {
    return new Intl.NumberFormat().format(value)
}

const formatEth = (wei) => {
    return parseFloat(ethers.utils.formatEther(wei)).toFixed(6)
}

const truncateAddress = (address) => {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}

// Initialize on mount
onMounted(async () => {
    await connectWallet()
    await initializeContract()
})
</script>