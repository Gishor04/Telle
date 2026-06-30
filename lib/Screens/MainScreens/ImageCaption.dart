import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../API/ApiService.dart';
import '../../Helpers/Constants/Loader/Loader.dart';

class ImageCaption extends StatefulWidget {
  const ImageCaption({super.key});

  @override
  State<ImageCaption> createState() => _ImageCaptionState();
}

class _ImageCaptionState extends State<ImageCaption> {
  // Bytes are stored after picking so Image.memory works on web and native.
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String caption = '';
  final ImagePicker _picker = ImagePicker();

  // Opens a custom bottom sheet so the sheet is fully dismissed before the
  // system image picker opens — prevents the context tear-down race on Android
  // that caused the picker to silently fail with adaptive_action_sheet.
  void _showPickerBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _sheetOption(
                  sheetCtx: sheetCtx,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: primaryappColor,
                  onTap: _getFromCamera,
                ),
                const SizedBox(height: 10),
                _sheetOption(
                  sheetCtx: sheetCtx,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Colors.indigo,
                  onTap: _getFromGallery,
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetOption({
    required BuildContext sheetCtx,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        // Close the sheet FIRST, then open the picker after the dismiss
        // animation completes to avoid the overlay conflict on Android.
        Navigator.of(sheetCtx).pop();
        Future.delayed(const Duration(milliseconds: 200), onTap);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final hasImage = _imageBytes != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Text(
                "Input Your Image",
                style: TextStyle(
                    fontSize: 25,
                    color: primaryappColor,
                    fontFamily: 'zyzol',
                    fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: _showPickerBottomSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: hasImage
                    ? _buildPreview(screenHeight, screenWidth)
                    : _buildEmptyBox(screenHeight, screenWidth),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: _isLoading
                  ? Center(child: loader)
                  : GestureDetector(
                      onTap: () {
                        if (hasImage) _submitOCR();
                      },
                      child: Container(
                        height: screenHeight * 1 / 10,
                        width: screenWidth * 3 / 5,
                        decoration: BoxDecoration(
                          gradient: hasImage
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.green, Colors.yellow],
                                )
                              : null,
                          color: hasImage ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(
                          child: Text(
                            "SUBMIT",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: hasImage
                                    ? Colors.white
                                    : Colors.grey[500]),
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: screenHeight * 0.06),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  caption,
                  style: const TextStyle(fontFamily: "play", fontSize: 17),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBox(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.45,
      width: screenWidth * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: HexColor("#F9FEF8"),
        border: Border.all(color: HexColor("#D4EED4"), width: 1.5),
        boxShadow: [
          BoxShadow(color: HexColor("#E7E7E7"), spreadRadius: 3),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.20,
            child: Lottie.asset(
              "assets/json/camera.json",
              errorBuilder: (_, __, ___) => Icon(
                Icons.add_photo_alternate_outlined,
                size: 72,
                color: primaryappColor.withOpacity(0.5),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            "Tap to Select The Image",
            style: TextStyle(
              fontSize: 16,
              color: primaryappColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Camera or Gallery",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(double screenHeight, double screenWidth) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            _imageBytes!,
            height: screenHeight * 0.45,
            width: screenWidth * 0.85,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: screenHeight * 0.45,
              width: screenWidth * 0.85,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined,
                      size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Could not load image',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_rounded, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  'Tap to change image',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not select image. Please check gallery permissions.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _getFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not capture image. Please check camera permissions.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _submitOCR() async {
    if (_imageBytes == null) return;
    setState(() => _isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.mlBaseUrl}/getImageLabel'),
      );
      request.headers['Content-type'] = 'multipart/form-data';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _imageBytes!,
          filename: "tellie.png",
          contentType: MediaType('image', 'png'),
        ),
      );

      final res = await request.send();
      final respStr = await res.stream.bytesToString();
      final body = json.decode(respStr) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          caption = body["images"]?.toString() ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
