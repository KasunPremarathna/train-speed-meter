import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'ABOUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('SRI LANKA RAILWAY NETWORK'),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Main Line',
            'Colombo Fort to Badulla',
            '28 stations • 290 km',
            'The iconic Main Line traverses through the hill country, passing tea plantations and offering breathtaking mountain views. This is one of the most scenic train journeys in the world.',
            [
              'Colombo Fort',
              'Maradana',
              'Dematagoda',
              'Kelaniya',
              'Wanawasala',
              'Hunupitiya',
              'Enderamulla',
              'Horape',
              'Ragama Junction',
              'Walpola',
              'Batuwaththa',
              'Bulugahagoda',
              'Ganemulla',
              'Yagoda',
              'Gampaha',
              'Daraluwa',
              'Bemmulla',
              'Magalegoda',
              'Heendeniya Pattiyagoda',
              'Veyangoda',
              'Polgahawela Junction',
              'Ihala Kotte',
              'Kadugannawa',
              'Peradeniya Junction',
              'Nanu Oya',
              'Pattipola',
              'Ella',
              'Badulla',
            ],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Coastal Line',
            'Colombo to Beliatta',
            '18 stations • 160 km',
            'Running along the southwestern coast, this line offers stunning ocean views and connects major coastal cities and beach towns.',
            [
              'Secretariat Halt',
              'Kompannavidiya',
              'Kollupitiya',
              'Bambalapitiya',
              'Wellawatta',
              'Angulana',
              'Lunawa',
              'Moratuwa',
              'Koralawella',
              'Egoda Uyana',
              'Panadura',
              'Pinwatta',
              'Wadduwa',
              'Kalutara North',
              'Kalutara South',
              'Katukurunda',
              'Galle',
              'Beliatta',
            ],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Northern Line',
            'Polgahawela to Kankesanthurai',
            '10 stations • 400 km',
            'Connecting the north to the rest of the country, this line passes through ancient cities and cultural landmarks.',
            [
              'Potuhera',
              'Kurunegala',
              'Wellawa',
              'Ganewatte',
              'Yapahuwa',
              'Maho Junction',
              'Anuradhapura',
              'Medawachchiya',
              'Jaffna',
              'Kankesanthurai',
            ],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Kelani Valley Line',
            'Colombo to Avissawella',
            '6 stations • 30 km',
            'A suburban line serving the Colombo metropolitan area and connecting to the hill country foothills.',
            [
              'Baseline Road',
              'Cotta Road',
              'Narahenpita',
              'Nugegoda',
              'Homagama',
              'Avissawella',
            ],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Puttalam Line',
            'Ragama to Puttalam',
            '5 stations • 110 km',
            'Serving the western coastal region and connecting to the airport area.',
            ['Kandana', 'Ja-Ela', 'Katunayake', 'Negombo', 'Puttalam'],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Eastern Lines',
            'Batticaloa & Trincomalee',
            '4 stations',
            'Connecting the eastern province with scenic routes through rural landscapes.',
            ['Gal Oya Junction', 'Polonnaruwa', 'Batticaloa', 'Trincomalee'],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Mannar Line',
            'Medawachchiya to Talaimannar Pier',
            '3 stations • 100 km',
            'The historic line to the northwestern tip, once connected to India via ferry.',
            ['Madhu Road', 'Mannar', 'Talaimannar Pier'],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Matale Line',
            'Kandy to Matale',
            '2 stations • 27 km',
            'A short branch line connecting Kandy to the spice-growing region of Matale.',
            ['Kandy', 'Matale'],
          ),
          const SizedBox(height: 12),
          _buildRailwayLine(
            'Mihintale Line',
            'Anuradhapura to Mihintale',
            '2 stations • 12 km',
            'A pilgrimage line connecting to the sacred Mihintale mountain.',
            ['Mihintale Junction', 'Mihintale'],
          ),
          const SizedBox(height: 32),
          _buildDeveloperInfo(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.train, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text(
            'Train Speed Monitor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time railway monitoring for Sri Lanka',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip('81', 'Stations'),
              _buildStatChip('9', 'Lines'),
              _buildStatChip('2026', 'Updated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildRailwayLine(
    String name,
    String route,
    String info,
    String description,
    List<String> stations,
  ) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      backgroundColor: const Color(0xFF1E1E1E),
      collapsedBackgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            route,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(info, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'STATIONS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stations.map((station) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      station,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kasun Premarathna',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Developer & Creator',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _launchUrl('mailto:htckasun@gmail.com'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, color: Colors.blueAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'htckasun@gmail.com',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
