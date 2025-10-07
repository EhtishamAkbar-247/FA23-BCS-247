// lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = 'Ali Hassan';
  final String email = 'xtechpk1@gmail.com';
  final String phone = '+923238130030';
  final String tagline = 'MERN-Stack Developer & AI Enthusiast';

  int selectedTheme = 0;

  final List<String> _profileImages = [
    'assets/images/A1.jpeg',
    'assets/images/A2.jpeg',
    'assets/images/A3.jpeg',
  ];

  int _currentImageIndex = 0;

  void _changeProfileImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _profileImages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional CV'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: _getBackgroundDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  _buildGradientButton(
                      'Classic', const [Colors.black87, Colors.purple], 1),
                  _buildGradientButton(
                      'Modern', const [Colors.orange, Colors.red], 2),
                  _buildGradientButton(
                      'Creative', const [Colors.green, Colors.teal], 3),
                  ElevatedButton.icon(
                    onPressed: _changeProfileImage,
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('Change Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildAboutCard(),
              const SizedBox(height: 20),
              _buildSkillsCard(),
              const SizedBox(height: 20),
              _buildExperienceCard(), // Updated Section
              const SizedBox(height: 20),
              _buildContactCard(), // Updated Section
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfileCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth > 600 ? 80.0 : 60.0;
    final titleFontSize = screenWidth > 600 ? 32.0 : 26.0;

    return _buildCard(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: AssetImage(_profileImages[_currentImageIndex]),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo)),
          const SizedBox(height: 5),
          Text(tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.person, color: Colors.indigo, size: 24),
            SizedBox(width: 10),
            Text('About Me',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
          ]),
          SizedBox(height: 15),
          Text(
              'Passionate Full-Stack Developer with 2+ years of experience in creating innovative digital solutions. Specialized in MERN-Stack Development, Flutter App Development, WordPress, and Python Development. I love turning complex problems into simple, beautiful, and intuitive solutions.',
              style: TextStyle(
                  fontSize: 16, height: 1.5, color: Color(0xB3000000))),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    const skills = [
      {
        'name': 'AI Development',
        'icon': Icons.psychology,
        'color': Colors.purple
      },
      {
        'name': 'Flutter App Development',
        'icon': Icons.phone_android,
        'color': Colors.blue
      },
      {'name': 'WordPress', 'icon': Icons.web, 'color': Colors.green},
      {
        'name': 'MERN-Stack Development',
        'icon': Icons.code,
        'color': Colors.orange
      },
    ];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.star, color: Colors.indigo, size: 24),
            SizedBox(width: 10),
            Text('Core Skills',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
          ]),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350.0,
                childAspectRatio: 4 / 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skillColor = skills[index]['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: skillColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: skillColor.withOpacity(0.3))),
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: skillColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(skills[index]['icon'] as IconData,
                            color: Colors.white, size: 20)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(skills[index]['name'] as String,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xCC000000))),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ## ---- START: UPDATED EXPERIENCE SECTION ---- ##
  Widget _buildExperienceCard() {
    final experiences = [
      {
        'title': 'Senior MERN-Stack Developer',
        'company': 'XtechPK Software Solutions',
        'period': '2023 - Present'
      },
      {
        'title': 'AI Development Specialist',
        'company': 'XtechPK Software Solutions',
        'period': '2023 - Present'
      },
      {
        'title': 'WordPress Developer',
        'company': 'XtechPK Software Solutions',
        'period': '2023 - Present'
      },
    ];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.work_history,
                  color: Colors.indigo, size: 24), // Changed icon
              SizedBox(width: 10),
              Text('Work Experience',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
            ],
          ),
          const SizedBox(height: 20),
          // Build a list of timeline items from the experience data
          for (int i = 0; i < experiences.length; i++)
            _buildExperienceItem(
              experiences[i]['title']!,
              experiences[i]['company']!,
              experiences[i]['period']!,
              isLast:
                  i == experiences.length - 1, // Check if it's the last item
            ),
        ],
      ),
    );
  }

  // A new, improved widget for displaying each experience item in a timeline
  Widget _buildExperienceItem(String title, String company, String period,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This column creates the timeline's dot and vertical line
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              // The vertical line, which is not drawn for the last item
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.indigo.shade200),
                ),
            ],
          ),
          const SizedBox(width: 15),
          // This Expanded widget holds the text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 24.0), // Add spacing below each item
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  const SizedBox(height: 4),
                  Text(company,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(period,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ## ---- START: UPDATED CONTACT SECTION ---- ##
  Widget _buildContactCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_mail, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text('Contact Information',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(Icons.email, 'Email', email),
          const SizedBox(height: 10),
          _buildContactItem(Icons.phone, 'Phone', phone),
        ],
      ),
    );
  }

  // A new, improved widget for displaying each contact item
  Widget _buildContactItem(IconData icon, String label, String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon with a styled background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.indigo, size: 20),
            ),
            const SizedBox(width: 15),
            // Column for the label and the text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(text,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
  // ## ---- END: UPDATED CONTACT SECTION ---- ##

  Widget _buildGradientButton(String text, List<Color> colors, int themeIndex) {
    return GestureDetector(
      onTap: () => setState(() => selectedTheme = themeIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    const Map<int, List<Color>> themeGradients = {
      1: [Colors.purple, Colors.blue, Colors.teal],
      2: [Colors.orange, Colors.pink, Colors.red],
      3: [Colors.green, Colors.teal],
    };
    final colors = themeGradients[selectedTheme];
    if (colors == null) return BoxDecoration(color: Colors.grey[100]);
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
