import { createRouter, createWebHistory } from "vue-router";
import welcomepage from "../view/LandingPage.vue";
import PublishResearch from "../view/PublishResearch.vue";
import ResearchFeed from "../view/ResearchFeed.vue";
import ResearchDetails from "../view/ResearchDetails.vue";
import QuestionFeed from "../view/QuestionFeed.vue";
import QuestionDetail from "../view/QuestionDetail.vue";
import Proposal from "../view/Proposal.vue";
import ICO from "../view/ICO.vue";

const routes = [
  {
    path: "/",
    name: "LandingPage",
    component: welcomepage,
  },
  {
    path: "/Publish",
    name: "PublishResearch",
    component: PublishResearch,
  },
  {
    path: "/Research",
    name: "ResearchFeed",
    component: ResearchFeed,
  },
  {
    path: "/research/:id",
    name: "ResearchDetail",
    component: ResearchDetails,
  },
  {
    path: "/Question",
    name: "QuestionFeed",
    component: QuestionFeed,
  },
  {
    path: "/question/:id",
    name: "QuestionDetail",
    component: QuestionDetail,
  },
  {
    path: "/Proposals",
    name: "Proposal",
    component: Proposal,
  },
  {
    path: "/ICO",
    name: "ICO",
    component: ICO,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
