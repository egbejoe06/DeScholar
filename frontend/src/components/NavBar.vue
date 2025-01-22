<template>
    <div>
        <!-- Main Navigation -->
        <nav class="fixed w-full bg-white/80 backdrop-blur-md shadow-sm py-4 px-6 z-40 border-b border-gray-100">
            <div class="max-w-7xl mx-auto flex justify-between items-center">
                <div class="flex items-center space-x-3">
                    <router-link :to="{ name: 'LandingPage' }" class="flex items-center space-x-3">
                        <GraduationCap class="w-10 h-10 text-indigo-600" />
                        <h1
                            class="text-2xl font-black bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                            DeScholar
                        </h1>
                    </router-link>
                </div>

                <!-- Desktop Menu -->
                <div class="hidden md:flex items-center space-x-8">
                    <router-link v-for="item in menuItems" :key="item.name" :to="item.route"
                        class="text-gray-600 hover:text-indigo-600 transition-colors">
                        {{ item.name }}
                    </router-link>
                    <button @click="connectWallet"
                        class="group bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-2.5 rounded-full font-medium transition-all duration-200 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 shadow-lg hover:shadow-xl">
                        <div class="flex items-center space-x-2">
                            <Wallet class="w-4 h-4 group-hover:rotate-12 transition-transform" />
                            <span>{{ userAccount ? 'Connected' : 'Connect Wallet' }}</span>
                        </div>
                    </button>
                </div>

                <!-- Mobile Menu Toggle -->
                <button @click="toggleMobileMenu" class="md:hidden p-2 rounded-lg hover:bg-gray-100">
                    <Menu v-if="!isMobileMenuOpen" class="w-6 h-6 text-gray-600" />
                    <X v-else class="w-6 h-6 text-gray-600" />
                </button>
            </div>
        </nav>

        <!-- Mobile Menu Overlay -->
        <div v-if="isMobileMenuOpen" class="fixed inset-0 bg-black/50 backdrop-blur-sm z-40" @click="closeMobileMenu">
        </div>

        <!-- Mobile Menu Panel -->
        <transition enter-active-class="transform transition ease-in-out duration-300"
            enter-from-class="-translate-x-full" enter-to-class="translate-x-0"
            leave-active-class="transform transition ease-in-out duration-300" leave-from-class="translate-x-0"
            leave-to-class="-translate-x-full">
            <div v-if="isMobileMenuOpen"
                class="fixed inset-y-0 left-0 w-4/5 max-w-sm bg-white shadow-xl z-50 overflow-y-auto" @click.stop>
                <!-- Mobile Menu Header -->
                <div class="p-6 border-b border-gray-100">
                    <div class="flex items-center space-x-3">
                        <GraduationCap class="w-8 h-8 text-indigo-600" />
                        <span class="text-xl font-bold text-gray-900">DeScholar</span>
                    </div>
                </div>

                <!-- Mobile Menu Items -->
                <div class="py-6 px-6">
                    <div class="flex flex-col space-y-6">
                        <router-link v-for="item in menuItems" :key="item.name" :to="item.route"
                            class="flex items-center space-x-3 text-gray-600 hover:text-indigo-600 transition-colors text-lg font-medium"
                            @click="closeMobileMenu">
                            <component :is="item.icon" class="w-5 h-5" />
                            <span>{{ item.name }}</span>
                        </router-link>
                    </div>

                    <!-- Mobile Wallet Button -->
                    <div class="mt-8">
                        <button @click="handleMobileWalletConnect"
                            class="w-full group bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-3 rounded-full font-medium transition-all duration-200 hover:shadow-lg">
                            <div class="flex items-center justify-center space-x-2">
                                <Wallet class="w-5 h-5" />
                                <span>{{ userAccount ? 'Connected' : 'Connect Wallet' }}</span>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </transition>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useWallet } from '../composable/useWallet'
import { useRouter, useRoute } from 'vue-router'
import {
    GraduationCap,
    Wallet,
    Menu,
    X,
    BookOpen,
    Users,
    MessageSquare,
    Newspaper
} from 'lucide-vue-next'

const { connectWallet, getResearchContract, userAccount } = useWallet()
const isMobileMenuOpen = ref(false)
const contract = ref(null)

// Enhanced menu items with icons
const menuItems = [
    { name: 'Research', route: { name: 'ResearchFeed' }, icon: Newspaper },
    { name: 'Question', route: { name: 'QuestionFeed' }, icon: MessageSquare },
    { name: 'Proposal', route: { name: 'Proposal' }, icon: Users },
    { name: 'Community', route: { name: 'GroupPage' }, icon: BookOpen },
]

const toggleMobileMenu = () => {
    isMobileMenuOpen.value = !isMobileMenuOpen.value
    // Prevent body scroll when menu is open
    document.body.style.overflow = isMobileMenuOpen.value ? 'hidden' : ''
}

const closeMobileMenu = () => {
    isMobileMenuOpen.value = false
    document.body.style.overflow = ''
}

const handleMobileWalletConnect = async () => {
    try {
        await connectWallet()
        closeMobileMenu()
    } catch (error) {
        console.error("Mobile wallet connection error:", error)
    }
}

onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchContract()
    } catch (error) {
        console.error("Mounted hook error:", error)
    }
})

const route = useRoute()

// Close mobile menu on route change
watch(route, () => {
    closeMobileMenu()
})

// Handle resize events
const handleResize = () => {
    if (window.innerWidth >= 768) {
        closeMobileMenu()
    }
}

// Cleanup
onMounted(() => {
    window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
    document.body.style.overflow = ''
})
</script>