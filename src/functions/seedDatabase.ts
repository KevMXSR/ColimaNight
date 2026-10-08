import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { SEED_VENUES } from '../data/seedVenues';

const db = admin.firestore();

/**
 * Cloud Function HTTPS Callable: Inicializa o actualiza la colección 'venues'
 * con las ubicaciones reales verificadas de Colima.
 */
export const seedVenuesDatabase = functions.https.onCall(
  async (data, context) => {
    // En producción se requiere rol admin
    if (context.auth && context.auth.token.role !== 'admin') {
      // Para inicialización inicial se puede permitir si la colección está vacía
      const venuesCount = (await db.collection('venues').limit(1).get()).size;
      if (venuesCount > 0) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Solo un administrador puede ejecutar el re-sembrado de la base de datos.'
        );
      }
    }

    const batch = db.batch();
    const now = admin.firestore.Timestamp.now();

    for (const venue of SEED_VENUES) {
      const docRef = db.collection('venues').doc(venue.id);
      batch.set(
        docRef,
        {
          ...venue,
          updatedAt: now,
        },
        { merge: true }
      );
    }

    await batch.commit();
    const activeCount = SEED_VENUES.filter((v) => v.active).length;
    const memorialCount = SEED_VENUES.filter((v) => v.isEasterEgg).length;
    console.log(`[seedVenuesDatabase] Se sincronizaron ${activeCount} locales comerciales activos y ${memorialCount} memoriales históricos en Firestore.`);

    return {
      success: true,
      message: `Se sincronizaron con éxito ${activeCount} locales activos vigentes y ${memorialCount} memorial histórico (Barezzito, active: false).`,
      totalCount: SEED_VENUES.length,
      activeCount,
      memorialCount,
    };
  }
);
