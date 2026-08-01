import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import '../../services/firestore_service.dart';
import '../../services/email_service.dart';
import '../../services/auth_service.dart';
import '../../models/report_model.dart';
import '../../utils/app_colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descCtrl = TextEditingController();
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _picker = ImagePicker();

  String _selectedCat = '';
  String _selectedPriority = 'Medium';
  double? _lat, _lon;
  bool _loadingLoc = false;
  bool _submitting = false;
  String? _locText;
  File? _selectedImage;
  WebViewController? _mapController;

  final List<Map<String, String>> _categories = [
    {'icon': '🚌', 'name': 'Transport'},
    {'icon': '🗑️', 'name': 'Garbage'},
    {'icon': '💧', 'name': 'Water Supply'},
    {'icon': '♻️', 'name': 'Waste Management'},
    {'icon': '⚡', 'name': 'Electricity'},
    {'icon': '📋', 'name': 'Other'},
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  void _initMap(double lat, double lon) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
          <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
          <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { width: 100%; height: 100%; overflow: hidden; }
            #map { width: 100%; height: 100vh; }
            .leaflet-control-attribution { font-size: 8px; }
          </style>
        </head>
        <body>
          <div id="map"></div>
          <script>
            var map = L.map("map", {
              zoomControl: true,
              attributionControl: true
            }).setView([$lat, $lon], 16);

            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
              attribution: "&copy; OpenStreetMap contributors",
              maxZoom: 19
            }).addTo(map);

            var marker = L.marker([$lat, $lon]).addTo(map);
            marker.bindPopup("<b>Your Current Location</b><br>${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}").openPopup();
          </script>
        </body>
        </html>
      ''');
    setState(() => _mapController = controller);
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Photo',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? img = await _picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (img != null) {
                        setState(() => _selectedImage = File(img.path));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt,
                              color: AppColors.accent, size: 32),
                          SizedBox(height: 8),
                          Text('Camera',
                              style: TextStyle(
                                  color: AppColors.accent, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? img = await _picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 70);
                      if (img != null) {
                        setState(() => _selectedImage = File(img.path));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.accent2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent2.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library,
                              color: AppColors.accent2, size: 32),
                          SizedBox(height: 8),
                          Text('Gallery',
                              style: TextStyle(
                                  color: AppColors.accent2, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _getLocation() async {
    setState(() => _loadingLoc = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lon = pos.longitude;
        _locText =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        _loadingLoc = false;
      });
      _initMap(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() {
        _locText = 'Could not get location';
        _loadingLoc = false;
      });
    }
  }

  void _submit() async {
    if (_selectedCat.isEmpty) {
      _showSnack('Please select a category');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _showSnack('Please describe the issue');
      return;
    }
    setState(() => _submitting = true);

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await _auth.getUserData(user.uid);
    final id = 'UV-${const Uuid().v4().substring(0, 6).toUpperCase()}';
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    final report = ReportModel(
      id: id,
      userEmail: user.email ?? '',
      userName: userData?.name ?? user.email ?? '',
      userId: user.uid,
      category: _selectedCat,
      description: _descCtrl.text.trim(),
      priority: _selectedPriority,
      latitude: _lat,
      longitude: _lon,
      status: 'Under Process',
      createdAt: now,
    );

    await _firestore.addReport(report);

    await EmailService.sendUserConfirmation(
      userName: userData?.name ?? user.email ?? '',
      userEmail: user.email ?? '',
      reportId: id,
      category: _selectedCat,
      description: _descCtrl.text.trim(),
      priority: _selectedPriority,
      date: dateStr,
    );

    await EmailService.sendAdminAlert(
      userName: userData?.name ?? user.email ?? '',
      userEmail: user.email ?? '',
      reportId: id,
      category: _selectedCat,
      description: _descCtrl.text.trim(),
      priority: _selectedPriority,
      date: dateStr,
    );

    setState(() => _submitting = false);
    if (!mounted) return;
    _showSuccessDialog(id);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  void _showSuccessDialog(String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('Report Submitted!',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Report ID: #$id',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textSecond)),
            const SizedBox(height: 4),
            const Text('A confirmation email has been sent to you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textThird)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child:
                    const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface),
                    ),
                    const SizedBox(width: 12),
                    const Text('Report Issue',
                        style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      const Text('SELECT CATEGORY',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1,
                        children: _categories.map((c) {
                          final selected = _selectedCat == c['name'];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCat = c['name']!),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.accent.withOpacity(0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.border,
                                    width: selected ? 2 : 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(c['icon']!,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(c['name']!,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: selected
                                              ? AppColors.accent
                                              : AppColors.textSecond),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('DESCRIPTION',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                            hintText: 'Describe the issue in detail...'),
                      ),
                      const SizedBox(height: 16),

                      // Priority
                      const Text('PRIORITY',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Row(
                        children: _priorities.map((p) {
                          final sel = _selectedPriority == p;
                          Color c = AppColors.success;
                          if (p == 'Medium') c = AppColors.warning;
                          if (p == 'High') c = Colors.orange;
                          if (p == 'Critical') c = AppColors.danger;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPriority = p),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: sel
                                        ? c.withOpacity(0.15)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: sel ? c : AppColors.border)),
                                child: Text(p,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? c : AppColors.textThird,
                                        fontWeight: sel
                                            ? FontWeight.w600
                                            : FontWeight.normal)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Location
                      const Text('LOCATION',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loadingLoc ? null : _getLocation,
                          icon: _loadingLoc
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.accent))
                              : const Icon(Icons.my_location,
                                  color: AppColors.accent),
                          label: Text(_locText ?? 'Detect My Location',
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),

                      // Real Map Preview
                      if (_mapController != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: WebViewWidget(controller: _mapController!),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Photo Upload
                      const Text('PHOTO (OPTIONAL)',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _selectedImage != null
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: _selectedImage != null ? 2 : 1),
                          ),
                          child: _selectedImage != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: double.infinity,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedImage = null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        color: AppColors.textThird, size: 40),
                                    SizedBox(height: 8),
                                    Text('Tap to add photo',
                                        style: TextStyle(
                                            color: AppColors.textThird,
                                            fontSize: 13)),
                                    SizedBox(height: 4),
                                    Text('Camera or Gallery',
                                        style: TextStyle(
                                            color: AppColors.textThird,
                                            fontSize: 11)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: _submitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text('Submit Report',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
