import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/dev_profile_preview.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showDevProfilePreview(BuildContext context, String imagePath, String name) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: DevProfilePreview(
              imagePath: imagePath,
              name: name,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Update status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.green.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'About ScanMySoil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode
                            ? [Colors.green.shade900, Colors.grey.shade900]
                            : [Colors.green.shade600, Colors.green.shade800],
                      ),
                    ),
                  ),
                  // App logo
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'lib/assets/images/scan_my_soil_logo.png',
                            height: 80,
                            width: 80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App info section
                _buildAppInfoSection(context),

                // University section
                _buildUniversitySection(context),

                // Team members section
                _buildTeamSection(context),

                // Version info - this is the last section
                _buildVersionSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'About the App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // App description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDarkMode ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ScanMySoil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ScanMySoil is an innovative application designed to analyze soil samples using AI technology. By simply taking a photo of your soil, the app provides detailed analysis and recommendations for optimal plant growth and soil management.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This app was developed as a capstone project by Civil Engineering students from the University of Saint Louis Tuguegarao.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitySection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'University',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // University card
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDarkMode ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // University image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'lib/assets/images/uslt_logo.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.school, size: 64, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),

                // University details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'University of Saint Louis Tuguegarao',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tuguegarao City, Cagayan, Philippines',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 18,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'www.usl.edu.ph',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Development Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Team member 1
          _buildTeamMemberCard(
            context,
            name: 'Gerald T. Bassig',
            role: 'Developer',
            university: 'University of Saint Louis Tuguegarao',
            degree: 'Bachelor of Science in Civil Engineering',
            location: 'Alibago, Enrile, Cagayan',
            email: 'geraldbassig51@gmail.com',
            imagePath: 'lib/assets/images/gerald.jpg',
          ),

          const SizedBox(height: 16),

          // Team member 2
          _buildTeamMemberCard(
            context,
            name: 'Christner Don B. Baynosa',
            role: 'Developer',
            university: 'University of Saint Louis Tuguegarao',
            degree: 'Bachelor of Science in Civil Engineering',
            location: 'Piat, Cagayan',
            email: 'christnerdonbaynosa@gmail.com',
            imagePath: 'lib/assets/images/christner.jpg',
          ),

          const SizedBox(height: 16),

          // Team member 3
          _buildTeamMemberCard(
            context,
            name: 'Shella Mae P. Baquiran',
            role: 'Developer',
            university: 'University of Saint Louis Tuguegarao',
            degree: 'Bachelor of Science in Civil Engineering',
            location: 'Tumauini, Isabela',
            email: 'shellabaquirannn@gmail.com',
            imagePath: 'lib/assets/images/shella.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(
      BuildContext context, {
        required String name,
        required String role,
        required String university,
        required String degree,
        required String location,
        required String email,
        required String imagePath,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and basic info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture with Hero animation and tap gesture
                GestureDetector(
                  onTap: () => _showDevProfilePreview(context, imagePath, name),
                  child: Hero(
                    tag: 'dev-profile-$name',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            height: 1,
          ),

          // Detailed info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Education
                _buildInfoRow(
                  context,
                  icon: Icons.school_outlined,
                  title: 'Education',
                  subtitle: '$degree\n$university',
                ),
                const SizedBox(height: 12),

                // Location
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  subtitle: location,
                ),
                const SizedBox(height: 12),

                // Email - Ensure it's fully visible
                _buildInfoRow(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: email,
                  isEmail: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        bool isEmail = false,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade700 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmail ? Colors.blue.shade700 : null,
                  height: 1.4,
                ),
                // No overflow or maxLines to ensure full visibility
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth, // Make it full width
      margin: const EdgeInsets.only(top: 24, bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800
            : Colors.green.shade50,
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'lib/assets/images/scan_my_soil_logo.png',
              height: 60,
              width: 60,
            ),
          ),
          const SizedBox(height: 20),

          // App name
          Text(
            'ScanMySoil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.green.shade700,
            ),
          ),

          // Version
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? Colors.grey.shade300
                    : Colors.grey.shade800,
              ),
            ),
          ),

          // Copyright
          const SizedBox(height: 24),
          Container(
            width: double.infinity, // Make this container full width
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.green.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '© 2025 ScanMySoil Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'All Rights Reserved',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

