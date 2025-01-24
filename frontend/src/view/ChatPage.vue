<template>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        <Navbar class="fixed top-0 left-0 right-0 z-50" />

        <!-- Main Content -->
        <div class="flex flex-col h-screen pt-16">
            <!-- Group Header - Collapsible on mobile -->
            <div class="bg-white border-b border-gray-200 px-4 py-3">
                <div class="flex items-center justify-between">
                    <h2 class="text-xl font-bold text-gray-900 truncate">
                        {{ groupInfo.name }}
                    </h2>
                    <button @click="toggleGroupInfo" class="p-2 text-gray-500 hover:text-gray-700">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5"
                            :class="{ 'transform rotate-180': showGroupInfo }" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd"
                                d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                                clip-rule="evenodd" />
                        </svg>
                    </button>
                </div>

                <!-- Collapsible Group Info -->
                <div v-show="showGroupInfo" class="mt-3 space-y-2 text-sm">
                    <p class="text-gray-600">{{ groupInfo.description }}</p>
                    <div class="flex justify-between text-gray-500">
                        <span>{{ groupInfo.memberCount }} members</span>
                        <span>Created by: {{ truncateAddress(groupInfo.creator) }}</span>
                    </div>
                    <div v-if="userProfile" class="flex justify-between text-gray-500">
                        <span>Reputation: {{ userProfile.reputation }}</span>
                        <span>Messages: {{ userProfile.messageCount }}</span>
                    </div>
                </div>
            </div>

            <!-- Messages Section -->
            <div ref="messagesContainer" class="flex-1 overflow-y-auto px-4 py-3 bg-gray-50">
                <!-- Loading State -->
                <div v-if="isLoading" class="flex justify-center items-center h-full">
                    <div class="animate-spin rounded-full h-8 w-8 border-3 border-blue-500 border-t-transparent"></div>
                </div>

                <!-- Error State -->
                <div v-else-if="error" class="text-center p-4">
                    <p class="text-red-600">{{ error }}</p>
                    <button @click="fetchMessages" class="mt-2 text-blue-600 underline">
                        Retry
                    </button>
                </div>

                <!-- Empty State -->
                <div v-else-if="messages.length === 0" class="text-center p-4 text-gray-500">
                    No messages yet. Start the conversation!
                </div>

                <!-- Messages -->
                <div v-else class="space-y-4">
                    <div v-for="(message, index) in messages" :key="index" v-show="!message.deleted"
                        class="bg-white rounded-lg shadow-sm p-3">
                        <!-- Message Header -->
                        <div class="flex justify-between items-start">
                            <div class="flex items-center space-x-2">
                                <span class="font-medium text-blue-600 text-sm">
                                    {{ truncateAddress(message.sender) }}
                                </span>
                                <span class="text-xs text-gray-500">
                                    {{ formatTimestamp(message.timestamp) }}
                                </span>
                            </div>
                            <button v-if="canDeleteMessage(message)" @click="deleteMessage(index)"
                                class="text-red-500 p-1">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20"
                                    fill="currentColor">
                                    <path fill-rule="evenodd"
                                        d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                                        clip-rule="evenodd" />
                                </svg>
                            </button>
                        </div>

                        <!-- Message Content -->
                        <p class="mt-2 text-gray-800 text-sm break-words">
                            {{ message.content }}
                        </p>

                        <!-- Message Actions -->
                        <div class="mt-2">
                            <button @click="upvoteMessage(index)" :disabled="message.hasVoted"
                                class="flex items-center space-x-1 text-xs"
                                :class="message.hasVoted ? 'text-blue-600' : 'text-gray-500'">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20"
                                    fill="currentColor">
                                    <path fill-rule="evenodd"
                                        d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z"
                                        clip-rule="evenodd" />
                                </svg>
                                <span>{{ message.upvotes }}</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Message Input -->
            <div class="bg-white border-t border-gray-200 p-3">
                <form @submit.prevent="sendMessage" class="flex space-x-2">
                    <input v-model="newMessage" type="text"
                        class="flex-1 rounded-full border border-gray-300 px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="Type your message..." :disabled="isSubmitting" required />
                    <button type="submit"
                        class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-full disabled:opacity-50"
                        :disabled="isSubmitting || !newMessage.trim()">
                        {{ isSubmitting ? '...' : 'Send' }}
                    </button>
                </form>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useWallet } from '../composable/useWallet'
import Navbar from "../components/NavBar.vue"
import FooterSection from '../components/FooterSection.vue'

const route = useRoute()
const { connectWallet, getResearchGroupContract, userAccount } = useWallet()
const showGroupInfo = ref(false)
const toggleGroupInfo = () => {
    showGroupInfo.value = !showGroupInfo.value
}
// State
const groupId = ref(parseInt(route.params.id))
const groupInfo = ref({
    name: '',
    description: '',
    memberCount: 0,
    creator: '',
    isActive: true
})
const messages = ref([])
const newMessage = ref('')
const isSubmitting = ref(false)
const isLoading = ref(true)
const error = ref(null)
const messagesContainer = ref(null)
const userProfile = ref(null)
const userRole = ref(0) // 0: Regular, 1: Moderator, 2: Admin

// Contract instance
const contract = ref(null)

// Initialize on mount
onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchGroupContract()
        await Promise.all([
            fetchGroupInfo(),
            fetchMessages(),
            fetchUserProfile(),
            fetchUserRole()
        ])
        setupEventListeners()
    } catch (error) {
        console.error('Failed to initialize:', error)
        error.value = 'Failed to connect to the network. Please check your wallet connection.'
    } finally {
        isLoading.value = false
    }
})

// Watch messages array for changes and scroll to bottom
watch(messages, async () => {
    await nextTick()
    if (messagesContainer.value) {
        messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
}, { deep: true })

// Fetch group information
const fetchGroupInfo = async () => {
    try {
        if (groupId.value < 3) { // Predefined group
            groupInfo.value = await contract.value.predefinedGroups(groupId.value)
        } else { // Custom group
            groupInfo.value = await contract.value.customGroups(groupId.value - 3)
        }
    } catch (error) {
        console.error('Failed to fetch group info:', error)
        throw new Error('Failed to load group information')
    }
}

// Fetch all messages for the group
const fetchMessages = async () => {
    try {
        error.value = null
        isLoading.value = true

        const fetchedMessages = []
        let index = 0

        while (true) {
            try {
                const message = await contract.value.groupMessages(groupId.value, index)
                fetchedMessages.push({
                    sender: message.sender,
                    content: message.content,
                    timestamp: Number(message.timestamp) * 1000,
                    upvotes: Number(message.upvotes),
                    deleted: message.deleted,
                    hasVoted: false
                })
                index++
            } catch (innerError) {
                console.warn(`No more messages at index ${index}:`, innerError)
                break
            }
        }

        messages.value = fetchedMessages
    } catch (error) {
        console.error('Failed to fetch messages:', error)
        error.value = 'Failed to load messages. Please try again.'
    } finally {
        isLoading.value = false
    }
}

// Fetch user profile
const fetchUserProfile = async () => {
    try {
        if (userAccount.value) {
            userProfile.value = await contract.value.getUserProfile(userAccount.value)
        }
    } catch (error) {
        console.error('Failed to fetch user profile:', error)
    }
}

// Fetch user role
const fetchUserRole = async () => {
    try {
        if (userAccount.value) {
            userRole.value = await contract.value.roles(userAccount.value)
        }
    } catch (error) {
        console.error('Failed to fetch user role:', error)
    }
}

// Send a new message
const sendMessage = async () => {
    if (!newMessage.value.trim() || isSubmitting.value) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.sendMessage(groupId.value, newMessage.value.trim())
        await tx.wait()
        newMessage.value = ''
    } catch (error) {
        console.error('Failed to send message:', error)
        alert('Failed to send message. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

// Upvote a message
const upvoteMessage = async (messageIndex) => {
    if (messages.value[messageIndex].hasVoted) return

    try {
        const tx = await contract.value.upvoteMessage(groupId.value, messageIndex)
        await tx.wait()
        messages.value[messageIndex].upvotes++
        messages.value[messageIndex].hasVoted = true
    } catch (error) {
        console.error('Failed to upvote message:', error)
        alert('Failed to upvote message. Please try again.')
    }
}

// Check if user can delete message
const canDeleteMessage = (message) => {
    return userRole.value > 0 || message.sender.toLowerCase() === userAccount.value.toLowerCase()
}

// Delete message
const deleteMessage = async (messageIndex) => {
    try {
        const tx = await contract.value.deleteMessage(groupId.value, messageIndex)
        await tx.wait()
        messages.value[messageIndex].deleted = true
    } catch (error) {
        console.error('Failed to delete message:', error)
        alert('Failed to delete message. Please try again.')
    }
}

// Setup blockchain event listeners
const setupEventListeners = () => {
    if (!contract.value) return

    contract.value.on('MessageSent', (gId, sender, content, event) => {
        if (gId.toString() === groupId.value.toString()) {
            messages.value.push({
                sender,
                content,
                timestamp: Date.now(),
                upvotes: 0,
                hasVoted: false,
                deleted: false
            })
        }
    })

    contract.value.on('MessageUpvoted', (gId, messageIndex, voter) => {
        if (gId.toString() === groupId.value.toString() &&
            messages.value[messageIndex] &&
            voter.toLowerCase() !== userAccount.value.toLowerCase()) {
            messages.value[messageIndex].upvotes++
        }
    })

    contract.value.on('MessageDeleted', (gId, messageIndex) => {
        if (gId.toString() === groupId.value.toString() && messages.value[messageIndex]) {
            messages.value[messageIndex].deleted = true
        }
    })

    contract.value.on('GroupStatusUpdated', (gId, isActive) => {
        if (gId.toString() === groupId.value.toString()) {
            groupInfo.value.isActive = isActive
        }
    })
}

// Utility functions
const truncateAddress = (address) => {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}

const formatTimestamp = (timestamp) => {
    return new Date(timestamp).toLocaleString()
}

// Cleanup on component unmount
onUnmounted(() => {
    if (contract.value) {
        contract.value.removeAllListeners()
    }
})
</script>