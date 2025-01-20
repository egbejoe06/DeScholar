# Template
<template>
    <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <!-- Enhanced Navbar with glass effect -->
        <nav class="fixed w-full bg-white/80 backdrop-blur-md shadow-sm py-4 px-6 z-50 border-b border-gray-100">
            <div class="max-w-7xl mx-auto flex justify-between items-center">
                <div class="flex items-center space-x-3">
                    <GraduationCap class="w-10 h-10 text-indigo-600" />
                    <h1
                        class="text-2xl font-black bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                        DeScholar
                    </h1>
                </div>
                <div class="hidden md:flex items-center space-x-8">
                    <a href="#" class="text-gray-600 hover:text-indigo-600 transition-colors">Research</a>
                    <a href="#" class="text-gray-600 hover:text-indigo-600 transition-colors">Courses</a>
                    <a href="#" class="text-gray-600 hover:text-indigo-600 transition-colors">Community</a>
                    <button @click="connectWallet"
                        class="group bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-2.5 rounded-full font-medium transition-all duration-200 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 shadow-lg hover:shadow-xl">
                        <div class="flex items-center space-x-2">
                            <Wallet class="w-4 h-4 group-hover:rotate-12 transition-transform" />
                            <span>{{ userAccount ? 'Connected' : 'Connect Wallet' }}</span>
                        </div>
                    </button>
                </div>
                <button class="md:hidden p-2 rounded-lg hover:bg-gray-100">
                    <Menu class="w-6 h-6 text-gray-600" />
                </button>
            </div>
        </nav>

        <!-- Main Content with enhanced animations -->
        <div class="pt-32 pb-24 px-6">
            <div class="max-w-4xl mx-auto">
                <!-- Research Submission Form with enhanced styling -->
                <div
                    class="bg-white rounded-2xl shadow-xl p-8 border border-gray-100 transition-all duration-300 hover:shadow-2xl">
                    <div class="flex items-center space-x-4 mb-8">
                        <div class="p-3 bg-indigo-100 rounded-lg">
                            <FileText class="w-6 h-6 text-indigo-600" />
                        </div>
                        <div>
                            <h2 class="text-3xl font-bold text-gray-900">Submit Research</h2>
                            <p class="text-gray-500 mt-1">Share your academic work with the community</p>
                        </div>
                    </div>

                    <div class="space-y-6">
                        <!-- Research Name with floating label -->
                        <div class="relative">
                            <input v-model="ResearchName" type="text" id="research-name"
                                class="peer w-full p-4 pt-6 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-transparent transition-all"
                                placeholder="Research Title" />
                            <label for="research-name" class="absolute left-4 top-2 text-xs font-medium text-gray-500 transition-all
                peer-placeholder-shown:text-base peer-placeholder-shown:top-4 
                peer-focus:text-xs peer-focus:top-2">
                                Research Title
                            </label>
                        </div>

                        <!-- Enhanced File Upload -->
                        <div class="space-y-2">
                            <label class="text-sm font-medium text-gray-700">Research File</label>
                            <div class="flex items-center justify-center w-full group">
                                <label
                                    class="flex flex-col items-center justify-center w-full h-64 border-2 border-indigo-200 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-indigo-50 transition-colors group-hover:border-indigo-400">
                                    <div class="flex flex-col items-center justify-center pt-5 pb-6">
                                        <Upload
                                            class="w-12 h-12 text-indigo-400 mb-3 group-hover:scale-110 transition-transform" />
                                        <p class="mb-2 text-sm text-gray-500">
                                            <span class="font-semibold text-indigo-600">Click to upload</span> or drag
                                            and drop
                                        </p>
                                        <p class="text-xs text-gray-500">
                                            {{ ResearchFile ? ResearchFile.name : 'PDF, DOCX, or ZIP (Max 10MB)' }}
                                        </p>
                                    </div>
                                    <input type="file" class="hidden" @change="handleFileUpload"
                                        accept=".pdf,.docx,.zip" />
                                </label>
                            </div>
                        </div>

                        <!-- Enhanced Description Field -->
                        <div class="space-y-2">
                            <label class="text-sm font-medium text-gray-700">Research Description</label>
                            <div class="relative">
                                <textarea v-model="ResearchDescription" rows="4"
                                    class="w-full p-4 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent resize-none"
                                    :class="{ 'border-indigo-500': ResearchDescription }"
                                    placeholder="Describe your research and its significance..."></textarea>
                                <div class="absolute bottom-2 right-2 text-xs text-gray-400">
                                    {{ ResearchDescription.length }}/500
                                </div>
                            </div>
                        </div>

                        <!-- Enhanced Submit Button -->
                        <button @click="createResearch" :disabled="isUploading || !isFormValid" class="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-4 rounded-lg transition-all duration-200 
              hover:from-indigo-700 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed font-medium
              transform hover:scale-[1.02] active:scale-[0.98]">
                            <div class="flex items-center justify-center space-x-2">
                                <Loader2 v-if="isUploading" class="w-5 h-5 animate-spin" />
                                <span>{{ isUploading ? 'Publishing...' : 'Submit Research' }}</span>
                            </div>
                        </button>
                    </div>

                    <!-- Enhanced Status Messages -->
                    <TransitionGroup name="fade">
                        <div v-if="successMessage" key="success"
                            class="mt-6 p-4 bg-green-50 border border-green-200 text-green-700 rounded-lg flex items-center space-x-2">
                            <CheckCircle class="w-5 h-5 flex-shrink-0" />
                            <span>{{ successMessage }}</span>
                        </div>
                        <div v-if="errorMessage" key="error"
                            class="mt-6 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg flex items-center space-x-2">
                            <AlertCircle class="w-5 h-5 flex-shrink-0" />
                            <span>{{ errorMessage }}</span>
                        </div>
                    </TransitionGroup>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ethers } from 'ethers'
import axios from 'axios'
import { useWallet } from '../composable/useWallet'
import {
    GraduationCap,
    Wallet,
    Menu,
    Upload,
    Loader2,
    CheckCircle,
    AlertCircle,
    FileText
} from 'lucide-vue-next'

const {
    connectWallet,
    getResearchContract,
    userAccount,
} = useWallet()

// State variables
const contract = ref(null)
const successMessage = ref('')
const errorMessage = ref('')
const ResearchName = ref('')
const ResearchDescription = ref('')
const ResearchFile = ref(null)
const isUploading = ref(false)

// Computed property for form validation
const isFormValid = computed(() => {
    return ResearchName.value.trim() !== '' &&
        ResearchFile.value !== null &&
        ResearchDescription.value.trim() !== ''
})

// File upload handler with enhanced validation
const handleFileUpload = (event) => {
    const file = event.target.files[0]
    if (file) {
        // Validate file size (10MB max)
        if (file.size > 10 * 1024 * 1024) {
            errorMessage.value = 'File size exceeds 10MB limit'
            return
        }
        // Validate file type
        const allowedTypes = ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/zip']
        if (!allowedTypes.includes(file.type)) {
            errorMessage.value = 'Invalid file type. Please upload PDF, DOCX, or ZIP'
            return
        }
        ResearchFile.value = file
        errorMessage.value = ''
    }
}

// Upload to IPFS via Pinata
const uploadToIPFS = async () => {
    if (!ResearchFile.value) {
        throw new Error('No file selected')
    }

    const formData = new FormData()
    formData.append('file', ResearchFile.value)

    const pinataMetadata = JSON.stringify({
        name: ResearchName.value,
    })
    formData.append('pinataMetadata', pinataMetadata)

    try {
        // Upload file to Pinata
        const fileResponse = await axios.post(
            'https://api.pinata.cloud/pinning/pinFileToIPFS',
            formData,
            {
                headers: {
                    'Content-Type': 'multipart/form-data',
                    'Authorization': `Bearer ${import.meta.env.VITE_PINATA_JWT}`
                }
            }
        )

        // Create metadata JSON
        const metadata = {
            name: ResearchName.value,
            description: ResearchDescription.value,
            file: `ipfs://${fileResponse.data.IpfsHash}`
        }

        // Upload metadata to Pinata
        const metadataResponse = await axios.post(
            'https://api.pinata.cloud/pinning/pinJSONToIPFS',
            metadata,
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${import.meta.env.VITE_PINATA_JWT}`
                }
            }
        )

        return `ipfs://${metadataResponse.data.IpfsHash}`
    } catch (error) {
        throw error
    }
}

// Create Research with enhanced error handling
const createResearch = async () => {
    if (!isFormValid.value) {
        errorMessage.value = 'Please fill in all required fields'
        return
    }

    try {
        isUploading.value = true
        errorMessage.value = ''

        // Upload to IPFS
        const tokenURI = await uploadToIPFS()

        // Create Research via contract
        const tx = await contract.value.publishResearch(
            ResearchName.value,
            tokenURI
        )
        await tx.wait()

        // Reset form
        ResearchName.value = ''
        ResearchDescription.value = ''
        ResearchFile.value = null

        successMessage.value = 'Research published successfully! 🎉'

        // Clear success message after 5 seconds
        setTimeout(() => {
            successMessage.value = ''
        }, 5000)
    } catch (error) {
        console.error(error)
        errorMessage.value = error.message || 'Failed to publish research'
    } finally {
        isUploading.value = false
    }
}

// Initial setup
onMounted(async () => {
    try {
        await connectWallet()
        contract.value = getResearchContract()
    } catch (error) {
        console.error("Mounted hook error:", error)
        errorMessage.value = 'Failed to connect wallet'
    }
})
</script>

<style>
.fade-enter-active,
.fade-leave-active {
    transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
    transform: translateY(-10px);
}
</style>