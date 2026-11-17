import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/repositories/venues_repository.dart';

/// Implementación en producción de [VenuesRepository] respaldada por Firebase Cloud Firestore,
/// con soporte reactivo en tiempo real (Streams), modo sin conexión y resiliencia ante errores.
class FirestoreVenuesRepository implements VenuesRepository {
  final FirebaseFirestore? _firestoreInstance;
  final List<VenueModel> _fallbackVenues;

  FirestoreVenuesRepository({
    FirebaseFirestore? firestore,
    required List<VenueModel> fallbackVenues,
  })  : _firestoreInstance = firestore,
        _fallbackVenues = List.unmodifiable(fallbackVenues);

  FirebaseFirestore? get _db {
    if (_firestoreInstance != null) return _firestoreInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Firebase no inicializado aún: $e');
    }
    return null;
  }

  @override
  Stream<List<VenueModel>> watchVenues() {
    final db = _db;
    if (db == null) {
      // Si Firebase no está disponible, emitir la lista base verificada
      return Stream.value(_fallbackVenues);
    }

    try {
      return db
          .collection('venues')
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          return _fallbackVenues;
        }

        // Mapear cada documento combinando datos del local y eventos en vivo
        final List<VenueModel> list = [];
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            // Buscar subcolección de eventos activos si existe
            List<VenueEvent> events = [];
            try {
              final eventsSnap = await doc.reference
                  .collection('events')
                  .where('expiresAt', isGreaterThan: Timestamp.now())
                  .get();

              events = eventsSnap.docs
                  .map((eDoc) => VenueEvent.fromMap(eDoc.data(), eDoc.id))
                  .where((e) => !e.isExpired)
                  .toList();
            } catch (_) {
              // Si la subcolección falla o no tiene permisos, continuar con data del documento
            }

            final venue = VenueModel.fromMap(data, doc.id).copyWith(
              upcomingEvents: events.isNotEmpty ? events : null,
            );
            list.add(venue);
          } catch (e) {
            debugPrint('[FirestoreVenuesRepo] Error parseando venue ${doc.id}: $e');
          }
        }

        return list.isNotEmpty ? list : _fallbackVenues;
      }).handleError((error) {
        debugPrint('[FirestoreVenuesRepo] Error en Stream de Firestore: $error');
        return _fallbackVenues;
      });
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Error suscribiendo a venues: $e');
      return Stream.value(_fallbackVenues);
    }
  }

  @override
  Future<List<VenueModel>> fetchVenues() async {
    final db = _db;
    if (db == null) return _fallbackVenues;

    try {
      final snapshot = await db.collection('venues').get();
      if (snapshot.docs.isEmpty) return _fallbackVenues;

      final List<VenueModel> list = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        list.add(VenueModel.fromMap(data, doc.id));
      }
      return list.isNotEmpty ? list : _fallbackVenues;
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Fallback a locales base por error: $e');
      return _fallbackVenues;
    }
  }

  @override
  Future<List<VenueEvent>> fetchEventsForVenue(String venueId) async {
    final db = _db;
    if (db == null) return [];

    try {
      final snap = await db
          .collection('venues')
          .doc(venueId)
          .collection('events')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .get();

      return snap.docs
          .map((doc) => VenueEvent.fromMap(doc.data(), doc.id))
          .where((event) => !event.isExpired)
          .toList();
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Error obteniendo eventos para $venueId: $e');
      return [];
    }
  }

  @override
  Future<void> updateVenueCapacity(String venueId, int capacity) async {
    final db = _db;
    if (db == null) return;

    try {
      await db.collection('venues').doc(venueId).update({
        'currentOccupancyPercent': capacity.clamp(0, 100),
        'liveAttendeesCount': capacity.clamp(0, 100),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Error actualizando aforo en Firestore: $e');
    }
  }

  @override
  Future<void> updateVenueLiveMusic({
    required String venueId,
    required bool hasLiveMusic,
    String? actName,
  }) async {
    final db = _db;
    if (db == null) return;

    try {
      await db.collection('venues').doc(venueId).update({
        'hasLiveMusic': hasLiveMusic,
        'liveMusicAct': actName,
        'liveMusic.hasLiveMusic': hasLiveMusic,
        'liveMusic.bandOrDjName': actName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Error actualizando música en vivo: $e');
    }
  }

  @override
  Future<void> updateVenuePromo({
    required String venueId,
    required bool hasPromo,
    String? promoHeadline,
  }) async {
    final db = _db;
    if (db == null) return;

    try {
      await db.collection('venues').doc(venueId).update({
        'hasPromo': hasPromo,
        'promoHeadline': promoHeadline,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreVenuesRepo] Error actualizando promo en Firestore: $e');
    }
  }
}
