import { firestore } from 'firebase-admin';
import { CONFIG } from '../config';
import { SocialEventDocument } from '../types';

export class SocialIngestService {
  private db: firestore.Firestore;

  constructor(db: firestore.Firestore) {
    this.db = db;
  }

  /**
   * Sincroniza y procesa los eventos e historias oficiales de los canales de Colima.
   * En el pipeline híbrido:
   * 1. Limpia eventos caducados en la colección global y subcolecciones.
   * 2. Procesa eventos aprobados pendientes de publicación (pending_social_events).
   * 3. Nunca inyecta eventos ficticios si no hay publicaciones verificadas.
   */
  async syncOfficialInstagramEvents(): Promise<{ syncedCount: number; events: SocialEventDocument[] }> {
    const now = firestore.Timestamp.now();
    const batch = this.db.batch();
    const syncedEvents: SocialEventDocument[] = [];

    // 1. Limpieza de eventos caducados
    try {
      const expiredSnap = await this.db
        .collection('events')
        .where('expiresAt', '<=', now)
        .limit(50)
        .get();

      for (const doc of expiredSnap.docs) {
        batch.delete(doc.ref);
      }
    } catch (e) {
      console.warn('[SocialIngestService] Error en barrido de caducidad:', e);
    }

    // 2. Consulta de eventos validados listos para publicación (Pipeline Híbrido)
    try {
      const pendingSnap = await this.db
        .collection('pending_social_events')
        .where('status', '==', 'approved')
        .where('published', '==', false)
        .limit(20)
        .get();

      for (const doc of pendingSnap.docs) {
        const item = doc.data() as Partial<SocialEventDocument> & {
          secondaryHandle?: string;
        };

        const channelInfo = CONFIG.OFFICIAL_INSTAGRAM_HANDLES.find(
          (c) => c.handle === item.instagramHandle || c.venueId === item.venueId
        );

        if (!channelInfo) continue;

        const eventId = `${channelInfo.venueId}_${now.seconds}`;
        const expiresAt = item.expiresAt || new firestore.Timestamp(now.seconds + 72 * 3600, 0);

        const eventDoc: SocialEventDocument = {
          id: eventId,
          venueId: channelInfo.venueId,
          venueName: channelInfo.name,
          instagramHandle: item.instagramHandle || channelInfo.handle,
          eventTitle: item.eventTitle || 'Evento Oficial',
          description: item.description || '',
          eventDate: item.eventDate || now,
          djOrBand: item.djOrBand,
          musicGenre: item.musicGenre,
          coverPriceMxn: item.coverPriceMxn,
          promo: item.promo,
          mediaUrl: item.mediaUrl || '',
          postUrl: item.postUrl || `https://instagram.com/${channelInfo.handle.replace('@', '')}`,
          source: (item.source as any) || 'official_feed',
          createdAt: now,
          expiresAt,
        };

        const globalEventRef = this.db.collection('events').doc(eventId);
        const venueEventRef = this.db
          .collection('venues')
          .doc(channelInfo.venueId)
          .collection('events')
          .doc(eventId);

        batch.set(globalEventRef, eventDoc, { merge: true });
        batch.set(venueEventRef, eventDoc, { merge: true });

        // Marcar como publicado en la bandeja de revisión
        batch.update(doc.ref, { published: true, publishedAt: now });

        // Actualizar datos del bar si incluye música en vivo o promoción
        const venueRef = this.db.collection('venues').doc(channelInfo.venueId);
        const venueUpdate: any = { updatedAt: now };

        if (item.djOrBand || item.musicGenre) {
          venueUpdate['hasLiveMusic'] = true;
          venueUpdate['liveMusicAct'] = item.djOrBand;
          venueUpdate['liveMusic.hasLiveMusic'] = true;
          venueUpdate['liveMusic.bandOrDjName'] = item.djOrBand;
          venueUpdate['liveMusic.genre'] = item.musicGenre;
        }

        if (item.promo) {
          venueUpdate['hasPromo'] = true;
          venueUpdate['promoHeadline'] = item.promo;
        }

        batch.update(venueRef, venueUpdate);
        syncedEvents.push(eventDoc);
      }

      await batch.commit();
    } catch (err) {
      console.error('[SocialIngestService] Error publicando eventos del pipeline:', err);
    }

    console.log(
      `[SocialIngestService] Proceso completado. ${syncedEvents.length} eventos oficiales publicados/actualizados.`
    );

    return {
      syncedCount: syncedEvents.length,
      events: syncedEvents,
    };
  }

  /**
   * Permite a un administrador o miembro del staff registrar o activar directamente
   * una promoción o evento oficial para su establecimiento.
   */
  async publishDirectEvent(params: {
    venueId: string;
    title: string;
    description?: string;
    promo?: string;
    djOrBand?: string;
    genre?: string;
    hoursValid?: number;
    source: 'staff_verified' | 'manual_approval';
  }): Promise<SocialEventDocument> {
    const now = firestore.Timestamp.now();
    const hours = params.hoursValid || 24;
    const expiresAt = new firestore.Timestamp(now.seconds + hours * 3600, 0);
    const eventId = `${params.venueId}_${now.seconds}`;

    const channelInfo = CONFIG.OFFICIAL_INSTAGRAM_HANDLES.find((c) => c.venueId === params.venueId);
    const venueName = channelInfo ? channelInfo.name : params.venueId;
    const handle = channelInfo ? channelInfo.handle : '@colimanight';

    const eventDoc: SocialEventDocument = {
      id: eventId,
      venueId: params.venueId,
      venueName,
      instagramHandle: handle,
      eventTitle: params.title,
      description: params.description || '',
      eventDate: now,
      djOrBand: params.djOrBand,
      musicGenre: params.genre,
      promo: params.promo,
      mediaUrl: '',
      postUrl: `https://instagram.com/${handle.replace('@', '')}`,
      source: params.source,
      createdAt: now,
      expiresAt,
    };

    const batch = this.db.batch();
    batch.set(this.db.collection('events').doc(eventId), eventDoc);
    batch.set(
      this.db.collection('venues').doc(params.venueId).collection('events').doc(eventId),
      eventDoc
    );

    const venueUpdate: any = { updatedAt: now };
    if (params.promo) {
      venueUpdate['hasPromo'] = true;
      venueUpdate['promoHeadline'] = params.promo;
    }
    if (params.djOrBand) {
      venueUpdate['hasLiveMusic'] = true;
      venueUpdate['liveMusicAct'] = params.djOrBand;
    }
    batch.update(this.db.collection('venues').doc(params.venueId), venueUpdate);

    await batch.commit();
    return eventDoc;
  }
}
