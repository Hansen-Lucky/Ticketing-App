import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/services/firebase.dart';
import 'package:ticket_app/page/checkout_buy.dart';
import 'package:another_flushbar/flushbar.dart';

/// Halaman Checkout Pembayaran Tiket
class CheckoutTicket extends StatefulWidget {
  final String idTicket;
  const CheckoutTicket({super.key, required this.idTicket});

  @override
  State<CheckoutTicket> createState() => _CheckoutTicketState();
}

class _CheckoutTicketState extends State<CheckoutTicket> {
  final FirestoreService _service = FirestoreService();

  // Fungsi format tanggal dari Timestamp Firestore ke format 'dd MMMM yyyy' lokal Indonesia
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date.toDate());
    }
    return date.toString();
  }

  // Fungsi format harga ke Rupiah dengan format tanpa desimal dan simbol Rp
  String _formatPrice(dynamic price) {
    if (price == null) return '-';
    try {
      final number = price is int ? price : int.parse(price.toString());
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (_) {
      return price.toString();
    }
  }

  // Modal dialog konfirmasi metode pembayaran dengan opsional teks tambahan (misal nomor kartu)
  void _showPaymentMethodModal(
    BuildContext context,
    String title,
    String description,
    String imagePath, {
    String? extraText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan judul dan tombol tutup
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2666EC))),
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),

              // Gambar metode pembayaran
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: Image.asset(imagePath, height: 120),
              ),

              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),

              // Jika ada extraText, tampilkan dengan tombol salin ke clipboard
              if (extraText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(extraText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F9FF),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: extraText));
                          Flushbar(
                            message: "Disalin ke clipboard",
                            backgroundColor: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(12),
                            borderColor: const Color(0xFF2666EC),
                            duration: const Duration(seconds: 2),
                            flushbarPosition: FlushbarPosition.BOTTOM,
                            messageColor: const Color(0xFF2666EC),
                            icon: const Icon(Icons.copy, color: Color(0xFF2666EC)),
                            boxShadows: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                          ).show(context);
                        },
                        icon: const Icon(Icons.copy, size: 18, color: Color(0xFF2666EC)),
                        label: const Text("Salin", style: TextStyle(color: Color(0xFF2666EC), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Ambil data tiket
                    final doc = await _service.getTicketById(widget.idTicket);
                    final ticketData = doc.data();
                    if (ticketData != null) {
                      // Tambahkan ke koleksi checkout
                      await _service.addCheckout({
                        ...ticketData,
                        'idTicket': widget.idTicket,
                        'checkoutAt': FieldValue.serverTimestamp(),
                      });
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Receipt(idTicket: widget.idTicket)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2666EC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Konfirmasi Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kartu metode pembayaran untuk pilihan user
  Widget _buildPaymentCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
              radius: 20,
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text("Pembayaran", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _service.getTicketById(widget.idTicket),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Tiket tidak ditemukan"));
          }

          final data = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informasi total tagihan dan detail tiket
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Color(0xFFE0ECFF), shape: BoxShape.circle),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2666EC), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Tagihan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_formatPrice(data['harga']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Nama Pesanan", style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text("${data['nama_tiket'] ?? '-'} - ${data['kategori'] ?? ''}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Tanggal", style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text(_formatDate(data['tanggal']), style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Pilih Metode Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),

                // Daftar kartu metode pembayaran
                _buildPaymentCard(
                  icon: Icons.money,
                  title: "Tunai (Cash)",
                  color: Colors.green,
                  onTap: () => _showPaymentMethodModal(
                    context,
                    "Pembayaran Tunai",
                    "Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi",
                    'images/money.png',
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentCard(
                  icon: Icons.credit_card,
                  title: "Kartu Kredit",
                  color: Colors.purple,
                  onTap: () => _showPaymentMethodModal(
                    context,
                    "Pembayaran Kartu Kredit",
                    "Pastikan nominal dan tujuan pembayaran sudah benar sebelum melanjutkan.",
                    'images/debit.png',
                    extraText: "8810 7766 1234 9876",
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentCard(
                  icon: Icons.qr_code,
                  title: "QRIS / QR Pay",
                  color: const Color(0xFF2666EC),
                  onTap: () => _showPaymentMethodModal(
                    context,
                    "Pembayaran QRIS",
                    "Gunakan aplikasi e-wallet atau mobile banking untuk scan QR di atas dan selesaikan pembayaran",
                    'images/qris.png',
                  ),
                ),

                const SizedBox(height: 32),
                // Informasi bantuan pembayaran
                const Text("Punya pertanyaan?", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.help_outline, color: Color(0xFF2666EC), size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text("Hubungi Admin untuk bantuan pembayaran.", style: TextStyle(fontSize: 14))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
