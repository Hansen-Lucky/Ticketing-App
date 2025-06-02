import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ticket_app/services/firebase.dart';

class Receipt extends StatefulWidget {
  final String idTicket;
  const Receipt({super.key, required this.idTicket});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final FirestoreService service = FirestoreService();
  bool _isDownloaded = false;

  // Format angka ke mata uang Rupiah
  String _formatPrice(dynamic price) {
    if (price == null) return '-';
    try {
      final number = price is int ? price : int.parse(price.toString());
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (_) {
      return price.toString();
    }
  }

  // Membuat dan membagikan PDF bukti pembayaran
  Future<void> generatePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text("Bukti Pembayaran Tiket",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Nama Tiket: ${data['nama_tiket']}"),
          pw.Text("Kategori: ${data['kategori']}"),
          pw.Text("Harga Tiket: ${_formatPrice(data['harga'])}"),
          pw.Divider(),
          pw.Text("Total Pembayaran: ${_formatPrice(data['harga'])}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 30),
          pw.Text("Terimakasih telah membeli tiket!"),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'bukti_pembayaran_${data['nama_tiket']}.pdf',
    );

    setState(() => _isDownloaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text("Bukti Pembayaran",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: service.getTicketById(widget.idTicket),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              if (_isDownloaded) _downloadedBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        _successIcon(),
                        const SizedBox(height: 18),
                        const Text("Pembayaran Berhasil",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          "Transaksi kamu telah selesai.\nDetail pembelian ada di bawah ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        _ticketDetail(data),
                        const SizedBox(height: 30),
                        _actionButtons(data),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget notifikasi jika PDF sudah diunduh
  Widget _downloadedBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Bukti pembayaran berhasil diunduh!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.green),
            onPressed: () => setState(() => _isDownloaded = false),
          ),
        ],
      ),
    );
  }

  // Icon berhasil bayar
  Widget _successIcon() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(color: Color(0xFFE6ECFA), shape: BoxShape.circle),
      child: const Icon(Icons.check, size: 40, color: Color(0xFF2666EC)),
    );
  }

  // Menampilkan detail tiket
  Widget _ticketDetail(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRow(data['nama_tiket'], _formatPrice(data['harga'])),
          const SizedBox(height: 4),
          Text(data['kategori'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_formatPrice(data['harga']),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF2666EC), fontSize: 16)),
            ],
          ),
          const Divider(height: 28),
        ],
      ),
    );
  }

  // Tombol Aksi: Unduh & Kembali
  Widget _actionButtons(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2666EC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Kembali", style: TextStyle(color: Color(0xFF2666EC))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async => await generatePdf(data),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2666EC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Unduh bukti"),
          ),
        ),
      ],
    );
  }

  // Baris teks: nama tiket dan harga
  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
