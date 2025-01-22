<template>
    <div>
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
    ChevronRight,
    FileText,
    Code2,
    HelpCircle,
    Twitter,
    MessageCircle,
    Github
} from 'lucide-vue-next'
</script>