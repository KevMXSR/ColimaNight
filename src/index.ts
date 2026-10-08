import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

export { reportIncident } from './functions/reportIncident';
export { submitVibe } from './functions/submitVibe';
export { verifyIncidentByStaff } from './functions/staffVerification';
export { cleanupExpiredIncidents, resetNightlyCounters } from './functions/scheduledTasks';
export { seedVenuesDatabase } from './functions/seedDatabase';
export { SEED_VENUES } from './data/seedVenues';
