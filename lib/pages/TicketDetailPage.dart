import 'package:airline/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailPage extends StatefulWidget {
  final String reservationId;

  const TicketDetailPage({super.key, required this.reservationId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  Map<String, dynamic>? ticketData;
  bool qrExpired = false;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }

  Future<void> _fetchTicketData() async {
    setState(() {
      isLoading = true;
    });
    try {
      ticketData = await TicketService().fetchTicketInfo(widget.reservationId);
      DateTime expiryTime = DateTime.parse(ticketData?['qrExpiryTime']);
      qrExpired = DateTime.now().isAfter(expiryTime);
    } catch (e) {
      print("탑승권 데이터 로드 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("탑승권 정보를 불러올 수 없습니다.")),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshQrCode() async {
    await _fetchTicketData();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (ticketData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('탑승권 정보'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(child: Text('탑승권 정보가 없습니다')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('탑승권 정보'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
              onPressed: _refreshQrCode,
              icon: const Icon(Icons.refresh)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            if(ticketData?['userImageUrl'] != null ) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(ticketData!['userImageUrl']),
                radius: 40,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              ticketData!['reservationCode'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  Text(ticketData!['departureAirport']),
                  const Icon(Icons.flight_takeoff, size: 32),
                ]),
                const SizedBox(width: 32),
                Column(children: [
                  Text(ticketData!['arrivalAirport']),
                  const Icon(Icons.flight_land, size: 32),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow('편명', ticketData!['flightNumber']),
                  _infoRow('탑승일', ticketData!['departureDate']),
                  _infoRow('탑승구', ticketData!['gateNumber']),
                  _infoRow('탑승시간', ticketData!['boardingTime']),
                  _infoRow('좌석번호', ticketData!['seatNumber']),
                  _infoRow('탑승순서', ticketData!['boardingZone']),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: qrExpired ? 0.3 : 1.0,
                  child: QrImageView(
                    data: widget.reservationId,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                if(qrExpired)
                  const Positioned(
                    child: Text(
                      'QR 만료됨',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareTicket,
                  icon: const Icon(Icons.share),
                  label: const Text('탑승권 공유하기'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple
                  ),
                ),
                ElevatedButton(
                  onPressed: _refreshQrCode,
                  child: const Text('새로고침'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _shareTicket() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비중입니다!')),
    );
  }
}
