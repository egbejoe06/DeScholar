<template>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        <NavBar />
        <!-- Hero Section with animated gradient -->
        <header class="relative pt-32 pb-24 overflow-hidden">
            <div class="absolute inset-0 bg-gradient-to-br from-blue-600 via-blue-700 to-blue-800"></div>
            <div class="absolute inset-0 opacity-10">
            </div>
            <div class="relative max-w-7xl mx-auto px-6 text-center">
                <h2 class="text-5xl md:text-6xl font-bold text-white leading-tight">
                    Decentralized Academic
                    <span class="block mt-2">Platform for the Future</span>
                </h2>
                <p class="mt-6 text-xl text-blue-100 max-w-2xl mx-auto">
                    Empowering researchers and educators through blockchain technology. Join the revolution in academic
                    publishing and learning.
                </p>
                <div class="mt-10 flex flex-col sm:flex-row justify-center gap-4">
                    <button
                        class="px-8 py-4 bg-white text-blue-600 rounded-full font-bold shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                        <div class="flex items-center justify-center space-x-2">
                            <Rocket class="w-5 h-5" />
                            <span>Get Started</span>
                        </div>
                    </button>
                    <button
                        class="px-8 py-4 bg-transparent border-2 border-white text-white rounded-full font-bold hover:bg-white/10 transition-all duration-200">
                        <div class="flex items-center justify-center space-x-2">
                            <Info class="w-5 h-5" />
                            <router-link :to="{ name: 'ICO' }">
                                <span>ICO</span></router-link>
                        </div>
                    </button>
                </div>
            </div>
        </header>

        <!-- Features Section with hover cards -->
        <section class="py-24 px-6 bg-white">
            <div class="max-w-7xl mx-auto">
                <h3 class="text-4xl font-bold text-center text-gray-900">
                    Revolutionizing Academia
                </h3>
                <p class="mt-4 text-xl text-gray-600 text-center max-w-2xl mx-auto">
                    Experience the future of academic research and education with our innovative blockchain-powered
                    features.
                </p>

                <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-16">
                    <!-- Feature Cards with hover effects -->
                    <div
                        class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100">
                        <div
                            class="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-blue-600 transition-colors duration-300">
                            <BookCopy
                                class="w-8 h-8 text-blue-600 group-hover:text-white transition-colors duration-300" />
                        </div>
                        <h4
                            class="text-xl font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-300">
                            NFT-Based Research
                        </h4>
                        <p class="mt-4 text-gray-600 leading-relaxed">
                            Publish and monetize your research as NFTs, ensuring immutable ownership and transparent
                            citation tracking.
                        </p>
                    </div>

                    <div
                        class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100">
                        <div
                            class="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-blue-600 transition-colors duration-300">
                            <Users
                                class="w-8 h-8 text-blue-600 group-hover:text-white transition-colors duration-300" />
                        </div>
                        <h4
                            class="text-xl font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-300">
                            Peer Review System
                        </h4>
                        <p class="mt-4 text-gray-600 leading-relaxed">
                            Participate in our decentralized peer review system and earn DST tokens for quality reviews.
                        </p>
                    </div>

                    <div
                        class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100">
                        <div
                            class="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-blue-600 transition-colors duration-300">
                            <Coins
                                class="w-8 h-8 text-blue-600 group-hover:text-white transition-colors duration-300" />
                        </div>
                        <h4
                            class="text-xl font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-300">
                            Research Funding
                        </h4>
                        <p class="mt-4 text-gray-600 leading-relaxed">
                            Create funding proposals and receive support directly from the academic community.
                        </p>
                    </div>

                    <div
                        class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100">
                        <div
                            class="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-blue-600 transition-colors duration-300">
                            <GraduationCap
                                class="w-8 h-8 text-blue-600 group-hover:text-white transition-colors duration-300" />
                        </div>
                        <h4
                            class="text-xl font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-300">
                            Group Discussions
                        </h4>
                        <p class="mt-4 text-gray-600 leading-relaxed">
                            Engage in real-time discussions and Q&A sessions within your communities.
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Call to Action with gradient overlay -->
        <section class="relative py-24 bg-gray-900">
            <div class="absolute inset-0 bg-gradient-to-br from-blue-600/20 to-blue-900/20"></div>
            <div class="relative max-w-4xl mx-auto px-6 text-center">
                <h3 class="text-4xl font-bold text-white">Join DeScholar Today</h3>
                <p class="mt-6 text-xl text-gray-300 leading-relaxed">
                    Connect your wallet and become part of the fastest-growing decentralized academic community. Start
                    publishing, reviewing, and earning today.
                </p>
                <div class="mt-10 flex flex-col sm:flex-row justify-center items-center gap-6">
                    <button
                        class="w-full sm:w-auto px-8 py-4 bg-blue-600 text-white rounded-full font-bold shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105 hover:bg-blue-700">
                        <div class="flex items-center justify-center space-x-2">
                            <Wallet class="w-5 h-5" />
                            <span>Connect Wallet</span>
                        </div>
                    </button>
                    <a href="#" class="text-blue-400 hover:text-blue-300 transition-colors flex items-center space-x-2">
                        <span>Learn more about DST tokens</span>
                        <ArrowRight class="w-4 h-4" />
                    </a>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="bg-gray-800 py-12 px-6">
            <div class="max-w-7xl mx-auto grid md:grid-cols-4 gap-8 text-gray-400">
                <div>
                    <div class="flex items-center space-x-2 text-white mb-4">
                        <GraduationCap class="w-6 h-6" />
                        <h4 class="font-semibold">DeScholar</h4>
                    </div>
                    <p class="text-sm">
                        Revolutionizing academic publishing and education through blockchain technology.
                    </p>
                </div>
                <div>
                    <h5 class="text-white font-semibold mb-4">Quick Links</h5>
                    <ul class="space-y-2 text-sm">
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <ChevronRight class="w-4 h-4" />
                                <span>Research</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <ChevronRight class="w-4 h-4" />
                                <span>Courses</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <ChevronRight class="w-4 h-4" />
                                <span>Community</span>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <h5 class="text-white font-semibold mb-4">Resources</h5>
                    <ul class="space-y-2 text-sm">
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <FileText class="w-4 h-4" />
                                <span>Documentation</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <Code2 class="w-4 h-4" />
                                <span>API</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <HelpCircle class="w-4 h-4" />
                                <span>Support</span>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <h5 class="text-white font-semibold mb-4">Connect</h5>
                    <ul class="space-y-2 text-sm">
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <Twitter class="w-4 h-4" />
                                <span>Twitter</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <MessageCircle class="w-4 h-4" />
                                <span>Discord</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="hover:text-white transition-colors flex items-center space-x-2">
                                <Github class="w-4 h-4" />
                                <span>GitHub</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </footer>
    </div>
</template>

<script setup>
import {
    GraduationCap,
    Wallet,
    Menu,
    Rocket,
    Info,
    BookCopy,
    Users,
    Coins,
    ArrowRight,
    ChevronRight,
    FileText,
    Code2,
    HelpCircle,
    Twitter,
    MessageCircle,
    Github
} from 'lucide-vue-next'
import { ref, onMounted } from "vue";
import NavBar from '../components/NavBar.vue';
import { ethers } from "ethers";
import { useWallet } from '../composable/useWallet';

const {
    connectWallet,
    userAccount,
    getResearchContract,
    connected
} = useWallet();
const ResearchContract = ref(null);
const account = ref("");

const connect = async () => {
    try {
        await connectWallet();
    } catch (error) {
        console.error('Failed to connect wallet:', error);
    }
};

function truncateAddress(walletAddress) {
    if (!walletAddress || walletAddress.length < 10) {
        return walletAddress; // Return as is if it's too short
    }
    return `${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`;
}

onMounted(async () => {
    try {
        // Attempt to connect wallet first
        await connectWallet().catch(error => {
            console.warn("Wallet connection failed:", error);
        });

        ResearchContract.value = getResearchContract()

        // Set account
        account.value = userAccount.value;

        // Only proceed if contract and account are availab
    } catch (error) {
        console.error("Mounted hook error:", error);
    }
});

</script>