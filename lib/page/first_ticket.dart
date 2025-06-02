import 'package:flutter/material.dart';
import 'package:ticket_app/page/list_ticket.dart';

class PageTicket extends StatelessWidget {
  const PageTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Warna latar belakang halaman
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 40), // Jarak atas halaman

            // Ilustrasi/logo utama yang ditempatkan di tengah
            Expanded(
              child: Center(
                child: Image.asset(
                  'images/logo.png',
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Box putih berisi judul, deskripsi, dan tombol aksi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Membuat sudut membulat
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // Bayangan halus
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Ticketing App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "Membantu anda untuk managemen\npembelian Tiket agar lebih efisien",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Tombol Get Started
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListTicket()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2666EC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Get Started"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), // Jarak bawah halaman
          ],
        ),
      ),
    );
  }
}
