import { initializeApp } from "firebase-admin/app";

initializeApp();

export { aggregateRisk } from "./aggregateRisk";
export { createInsurerView } from "./createInsurerView";
export { getWeeklyStats } from "./getWeeklyStats";
export { issueCredential } from "./issueCredential";
export { verifyCredential } from "./verifyCredential";
