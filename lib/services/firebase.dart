import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk mengakses data koleksi 'ticket' di Firestore
class FirestoreService {
  /// Referensi koleksi 'ticket' dengan konversi otomatis ke Map<String, dynamic>
  final CollectionReference<Map<String, dynamic>> ticket =
      FirebaseFirestore.instance.collection('ticket').withConverter(
            fromFirestore: (snapshot, _) => snapshot.data()!,
            toFirestore: (data, _) => data,
          );

  /// Ambil semua data tiket secara realtime
  Stream<QuerySnapshot<Map<String, dynamic>>> getTicket() {
    return ticket.snapshots();
  }

  /// Ambil detail tiket berdasarkan ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getTicketById(String id) {
    return ticket.doc(id).get();
  }
}
