<template>
    <div>
        <Navbar />
        <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 pt-24 px-6">
            <div class="max-w-7xl mx-auto">
                <!-- User Profile Section -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm" v-if="userProfile">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Your Profile</h3>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="bg-blue-50 p-4 rounded-lg">
                            <p class="text-sm text-gray-600">Reputation</p>
                            <p class="text-2xl font-semibold text-blue-600">{{ userProfile.reputation }}</p>
                        </div>
                        <div class="bg-green-50 p-4 rounded-lg">
                            <p class="text-sm text-gray-600">Messages Sent</p>
                            <p class="text-2xl font-semibold text-green-600">{{ userProfile.messageCount }}</p>
                        </div>
                    </div>
                </div>

                <!-- Create Group Section -->
                <div class="mb-8 bg-white rounded-xl p-6 shadow-sm">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">Create Research Group</h3>
                    <form @submit.prevent="createGroup">
                        <div class="space-y-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Group Name</label>
                                <input v-model="newGroup.name" type="text"
                                    class="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2" required />
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Description</label>
                                <textarea v-model="newGroup.description" rows="3"
                                    class="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2" required></textarea>
                            </div>
                            <button type="submit"
                                class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                                :disabled="isSubmitting">
                                {{ isSubmitting ? 'Creating...' : 'Create Group' }}
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Available Groups -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <!-- Predefined Groups -->
                    <div class="col-span-full mb-8">
                        <h3 class="text-xl font-semibold text-gray-900 mb-4">Predefined Groups</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            <div v-for="(group, index) in predefinedGroups" :key="index"
                                class="bg-white rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow"
                                @click="navigateToChat(index)">
                                <div class="flex justify-between items-start">
                                    <h4 class="text-lg font-semibold text-gray-900">{{ group.name }}</h4>
                                    <span class="px-2 py-1 rounded-full text-xs"
                                        :class="isUserMember(index, true) ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'">
                                        {{ isUserMember(index, true) ? 'Joined' : 'Not Joined' }}
                                    </span>
                                </div>
                                <p class="mt-2 text-gray-600">{{ group.description }}</p>
                                <div class="mt-4 flex items-center justify-between">
                                    <span class="text-sm text-gray-500">{{ group.memberCount }} members</span>
                                    <button @click="joinPredefinedGroup(index)"
                                        class="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
                                        :disabled="isUserMember(index, true)">
                                        {{ isUserMember(index, true) ? 'Joined' : 'Join Group' }}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Custom Groups -->
                    <div class="col-span-full">
                        <h3 class="text-xl font-semibold text-gray-900 mb-4">Custom Groups</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            <div v-for="(group, index) in customGroups" :key="index"
                                class="bg-white rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow">
                                <div class="flex justify-between items-start">
                                    <h4 class="text-lg font-semibold text-gray-900">{{ group.name }}</h4>
                                    <div class="flex space-x-2">
                                        <span class="px-2 py-1 rounded-full text-xs"
                                            :class="isUserMember(index, false) ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'">
                                            {{ isUserMember(index, false) ? 'Joined' : 'Not Joined' }}
                                        </span>
                                        <span
                                            :class="group.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                                            class="px-2 py-1 rounded-full text-xs">
                                            {{ group.isActive ? 'Active' : 'Inactive' }}
                                        </span>
                                    </div>
                                </div>
                                <p class="mt-2 text-gray-600">{{ group.description }}</p>
                                <div class="mt-4 flex items-center justify-between">
                                    <div class="text-sm text-gray-500">
                                        <div>{{ group.memberCount }} members</div>
                                        <div class="text-xs">Created by: {{ truncateAddress(group.creator) }}</div>
                                    </div>
                                    <div class="flex space-x-2">
                                        <button v-if="isAdmin" @click="toggleGroupStatus(index)"
                                            class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
                                            {{ group.isActive ? 'Deactivate' : 'Activate' }}
                                        </button>
                                        <button @click="joinCustomGroup(index)"
                                            class="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
                                            :disabled="!group.isActive || isUserMember(index, false)">
                                            {{ isUserMember(index, false) ? 'Joined' : 'Join Group' }}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
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
const { connectWallet, getResearchGroupContract, userAccount } = useWallet()

// State
const isSubmitting = ref(false)
const predefinedGroups = ref([])
const customGroups = ref([])
const userProfile = ref(null)
const isAdmin = ref(false)
const userMemberships = ref({})
const newGroup = ref({
    name: '',
    description: ''
})

// Contract instance
const contract = ref(null)

onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchGroupContract()
        await Promise.all([
            fetchGroups(),
            fetchUserProfile(),
            checkAdminRole()
        ])
    } catch (error) {
        console.error('Failed to initialize:', error)
    }
})

const fetchUserProfile = async () => {
    try {
        if (!userAccount.value) return
        const profile = await contract.value.getUserProfile(userAccount.value)
        userProfile.value = {
            reputation: Number(profile.reputation),
            messageCount: Number(profile.messageCount)
        }
    } catch (error) {
        console.error('Failed to fetch user profile:', error)
    }
}

const checkAdminRole = async () => {
    try {
        if (!userAccount.value) return
        const role = await contract.value.roles(userAccount.value)
        isAdmin.value = Number(role) === 1 // Assuming 1 is admin role
    } catch (error) {
        console.error('Failed to check admin role:', error)
    }
}

const fetchGroups = async () => {
    try {
        // Fetch predefined groups
        const predefinedCount = 3 // Assuming we have 3 predefined topics
        for (let i = 0; i < predefinedCount; i++) {
            const group = await contract.value.predefinedGroups(i)
            predefinedGroups.value.push({
                name: group.name,
                description: group.description,
                memberCount: Number(group.memberCount),
                isActive: group.isActive,
                creator: group.creator
            })
            // Check membership
            if (userAccount.value) {
                const isMember = await contract.value.joined(userAccount.value, i)
                userMemberships.value[`predefined_${i}`] = isMember
            }
        }

        // Fetch custom groups
        const customGroupCount = await contract.value.customGroupCount()
        for (let i = 0; i < Number(customGroupCount); i++) {
            const group = await contract.value.customGroups(i)
            customGroups.value.push({
                name: group.name,
                description: group.description,
                memberCount: Number(group.memberCount),
                isActive: group.isActive,
                creator: group.creator
            })
            // Check membership
            if (userAccount.value) {
                const isMember = await contract.value.joined(userAccount.value, i + predefinedCount)
                userMemberships.value[`custom_${i}`] = isMember
            }
        }
    } catch (error) {
        console.error('Failed to fetch groups:', error)
    }
}

const isUserMember = (index, isPredefined) => {
    const key = isPredefined ? `predefined_${index}` : `custom_${index}`
    return userMemberships.value[key] || false
}

async function createGroup() {
    if (!newGroup.value.name.trim() || !newGroup.value.description.trim()) return

    isSubmitting.value = true
    try {
        const tx = await contract.value.createCustomGroup(
            newGroup.value.name,
            newGroup.value.description
        )
        await tx.wait()
        newGroup.value = { name: '', description: '' }
        await fetchGroups()
    } catch (error) {
        console.error('Failed to create group:', error)
        alert('Failed to create group. Please try again.')
    } finally {
        isSubmitting.value = false
    }
}

async function joinPredefinedGroup(topicIndex) {
    try {
        const tx = await contract.value.joinPredefinedGroup(topicIndex)
        await tx.wait()
        await fetchGroups()
        router.push(`/chat/${topicIndex}`)
    } catch (error) {
        console.error('Failed to join predefined group:', error)
        alert('Failed to join group. Please try again.')
    }
}

async function joinCustomGroup(groupId) {
    try {
        const tx = await contract.value.joinCustomGroup(groupId)
        await tx.wait()
        await fetchGroups()
        router.push(`/chat/${groupId}`)
    } catch (error) {
        console.error('Failed to join custom group:', error)
        alert('Failed to join group. Please try again.')
    }
}

async function toggleGroupStatus(groupId) {
    try {
        const group = customGroups.value[groupId]
        const tx = await contract.value.updateCustomGroupStatus(groupId, !group.isActive)
        await tx.wait()
        await fetchGroups()
    } catch (error) {
        console.error('Failed to update group status:', error)
        alert('Failed to update group status. Please try again.')
    }
}

function truncateAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}

function navigateToChat(index, isPredefined) {
    // if (!isUserMember(index, isPredefined)) {
    //     alert('Please join the group first')
    //     return
    // }
    // const path = `/chat/${isPredefined ? index : index + 3}`
    const path = `/chat/${index}`
    router.push(path)
}
</script>