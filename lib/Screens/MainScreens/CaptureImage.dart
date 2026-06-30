// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import '../../Helpers/Constants/Texts/VoiceText.dart';
import 'Reuse/CustomAlert.dart';

class CaptureImage extends StatefulWidget {
  const CaptureImage({super.key});

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage>
    with SingleTickerProviderStateMixin {
  // ── Tab ───────────────────────────────────────────────────────────────────
  late final TabController _tabController;

  // ── Image ─────────────────────────────────────────────────────────────────
  // Bytes stored at pick-time so Image.memory works on web and native alike.
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _imageError = false;

  // ── Speech-to-text ────────────────────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedText = '';

  // ── TTS narration ─────────────────────────────────────────────────────────
  final FlutterTts _ftts = FlutterTts();
  final TextToSpeech _tts = TextToSpeech();
  bool _narrationEnabled = false;
  String _narrationLang = 'English';

  // ── Processing ────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _loadingGetAudio = false;
  bool _mergeReady = false;
  String _finalId = '';
  final List<String> _audioUrls = [];

  // ── Emotion ───────────────────────────────────────────────────────────────
  String? _emotionType;
  bool _showEmotionDropdown = false;
  String _emotionDropdown = 'happy';
  static const List<String> _emotionItems = [
    'happy', 'sad', 'angry', 'fearful', 'surprised', 'disgust',
  ];

  String? _userId;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tts.setVolume(2.0);
    _initSpeech();
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.stop();
    _ftts.speak('');
    if (_isListening) _speech.stop();
    super.dispose();
  }

  // ── Init helpers ──────────────────────────────────────────────────────────

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (e) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (mounted &&
            (status == SpeechToText.doneStatus ||
                status == SpeechToText.notListeningStatus)) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    final voiceOn = prefs.getBool('voice') ?? false;
    final lang = prefs.getString('language') ?? 'English';

    if (_userId != null) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await ApiService.ensureAudioDateExists(_userId!, date);
    }

    if (voiceOn && mounted) {
      setState(() {
        _narrationEnabled = true;
        _narrationLang = lang;
      });
      _narrate(captureImageInitVoice, captureImageInitSinhalaVoice,
          captureImageInitTamilVoice);
    }
  }

  void _narrate(String? en, String? si, String? ta) {
    if (!_narrationEnabled) return;
    if (_narrationLang == 'English' && en != null) _ftts.speak(en);
    else if (_narrationLang == 'Sinhala' && si != null) _tts.speak(si);
    else if (ta != null) _tts.speak(ta);
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  /// Opens a custom bottom sheet for source selection. Using showModalBottomSheet
  /// directly (instead of adaptive_action_sheet) to avoid the sheet-context
  /// tear-down race that prevents the ImagePicker from opening on Android.
  void _showImageSourceSheet() {
    _narrate(voiceTapToSelectImage, voiceSinhalaTapToSelectImage,
        voiceTamilTapToSelectImage);

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
                // drag handle
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
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primarygreyDark,
                    fontFamily: 'play',
                  ),
                ),
                const SizedBox(height: 14),
                _sourceOption(
                  sheetCtx: sheetCtx,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: primaryappColor,
                  source: ImageSource.camera,
                  narrEn: voiceImageFromCamera,
                  narrSi: voiceSinhalaImageFromCamera,
                  narrTa: voiceTamilImageFromCamera,
                ),
                const SizedBox(height: 10),
                _sourceOption(
                  sheetCtx: sheetCtx,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Colors.indigo,
                  source: ImageSource.gallery,
                  narrEn: voiceImageFromGallery,
                  narrSi: voiceSinhalaImageFromGallery,
                  narrTa: voiceTamilImageFromGallery,
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

  Widget _sourceOption({
    required BuildContext sheetCtx,
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
    String? narrEn,
    String? narrSi,
    String? narrTa,
  }) {
    return InkWell(
      onTap: () {
        // Pop the sheet FIRST so its context is gone before ImagePicker opens.
        Navigator.of(sheetCtx).pop();
        _narrate(narrEn, narrSi, narrTa);
        // Small delay ensures the sheet animation finishes before the system
        // picker dialog opens, preventing overlay conflicts on Android.
        Future.delayed(const Duration(milliseconds: 200), () {
          _pickImage(source);
        });
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
                fontFamily: 'play',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() {
          _imageBytes = bytes;
          _imageError = false;
          _mergeReady = false;
          _finalId = '';
          _audioUrls.clear();
        });
        _narrate(voiceSubmitButton, voiceSinhalaSubmitButton,
            voiceTamilSubmitButton);
      }
    } catch (e) {
      if (mounted) _showError('Could not open image picker. Check permissions and try again.');
    }
  }

  // ── Speech-to-text ────────────────────────────────────────────────────────

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      final ok = await _speech.initialize();
      if (!ok) {
        _showError('Speech recognition is not available on this device.');
        return;
      }
      if (mounted) setState(() => _speechAvailable = true);
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) _isListening = false;
          });
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isListening = false);
        _showError('Could not start recording. Please try again.');
      }
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  bool get _imageTabReady => _imageBytes != null;
  bool get _voiceTabReady => _recognizedText.trim().isNotEmpty;

  Future<void> _submit(bool imageMode) async {
    if (imageMode) {
      await _processImageOCR();
    } else {
      await _processText(_recognizedText.trim());
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> _processImageOCR() async {
    if (_imageBytes == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final req = http.MultipartRequest(
        'POST', Uri.parse('${ApiService.mlBaseUrl}/getData'));
      req.headers['Content-type'] = 'multipart/form-data';
      req.files.add(http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: 'tellie.png',
        contentType: MediaType('image', 'png'),
      ));
      final streamed = await req.send();
      final body =
          json.decode(await streamed.stream.bytesToString()) as Map<String, dynamic>;
      final text = body['audioText'] as String? ?? '';
      final fileId = body['fileName'] as String? ?? '';
      await _processText(text, sentenceFileId: fileId);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error processing image: $e');
      }
    }
  }

  Future<void> _processText(String text, {String? sentenceFileId}) async {
    if (text.isEmpty) {
      _showError('No text available to process.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) setState(() => _isLoading = true);

    if (_emotionType == 'paragraphemotion') {
      await _getSingleEmotionAudio(text);
    } else {
      final id = sentenceFileId ??
          'voice_${DateTime.now().millisecondsSinceEpoch}';
      await _getEmotionSentences(text, id);
    }
  }

  Future<void> _getEmotionSentences(String paragraph, String id) async {
    _audioUrls.clear();
    final sentences =
        paragraph.split(RegExp(r'\.\s+')).map((s) => s.trim()).where((s) => s.isNotEmpty);

    for (final sentence in sentences) {
      try {
        final r1 = await http.post(
          Uri.parse('${ApiService.mlBaseUrl}/getEmotion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'sentence': sentence}),
        );
        if (r1.statusCode == 200) {
          final d1 = jsonDecode(r1.body) as Map<String, dynamic>;
          if (d1.containsKey('Emotion')) {
            final rawEmo = d1['Emotion'] as String;
            final emo = const {
              'joy': 'happy',
              'sadness': 'sad',
              'anger': 'angry',
              'fear': 'fearful',
              'surprise': 'surprised',
            }[rawEmo] ?? rawEmo;

            final r2 = await http.post(
              Uri.parse('${ApiService.mlBaseUrl}/getEmotionAudio'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'sentence': sentence, 'emotion': emo}),
            );
            if (r2.statusCode == 200) {
              final d2 = jsonDecode(r2.body) as Map<String, dynamic>;
              if (d2['url'] != null) _audioUrls.add(d2['url'] as String);
            }
          } else {
            final r3 = await http.post(
              Uri.parse('${ApiService.mlBaseUrl}/getAudioWithOutEmotion'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'sentence': sentence}),
            );
            if (r3.statusCode == 200) {
              final d3 = jsonDecode(r3.body) as Map<String, dynamic>;
              if (d3['url'] != null) _audioUrls.add(d3['url'] as String);
            }
          }
        }
      } catch (_) {}
    }

    if (_audioUrls.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final r4 = await http.post(
        Uri.parse('${ApiService.mlBaseUrl}/createMultiAudio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'url': _audioUrls.join(', ')}),
      );
      if (r4.statusCode == 200) {
        final d4 = jsonDecode(r4.body) as Map<String, dynamic>;
        if (d4['Message'] == 'Successfully Created') {
          _audioUrls.clear();
          await _triggerMerge(id);
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _triggerMerge(String id) async {
    try {
      final r = await http.post(
        Uri.parse('${ApiService.mlBaseUrl}/mergingAudioFiles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        final newId = d['response']['id'].toString();
        if (mounted) {
          setState(() {
            _isLoading = false;
            _finalId = newId;
            _mergeReady = true;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchFinalAudio() async {
    try {
      final r = await http.post(
        Uri.parse('${ApiService.mlBaseUrl}/finalOutputVideo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': _finalId}),
      );
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        final audioUrl = d['url'] as String;
        if (mounted) {
          AudioAlert.showAlertDialog(context, audioUrl);
          setState(() => _loadingGetAudio = false);
        }
        if (_userId != null) {
          final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
          await ApiService.addAudioUrl(_userId!, date, audioUrl);
        }
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loadingGetAudio = false);
      _showError('Failed to retrieve audio. Please try again.');
    }
  }

  Future<void> _getSingleEmotionAudio(String text) async {
    try {
      final r = await http.post(
        Uri.parse('${ApiService.mlBaseUrl}/getEmotionAudio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sentence': text, 'emotion': _emotionDropdown}),
      );
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        final audioUrl = d['url'] as String;
        if (mounted) {
          setState(() {
            _isLoading = false;
            _mergeReady = false;
          });
          AudioAlert.showAlertDialog(context, audioUrl);
        }
        if (_userId != null) {
          final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
          await ApiService.addAudioUrl(_userId!, date, audioUrl);
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildImageTab(),
                  _buildVoiceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header & tabs ─────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'Input Your Image & Voice',
        style: TextStyle(
          fontSize: 22,
          color: primaryappColor,
          fontFamily: 'zyzol',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: primaryappColor,
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: primarygreyDark,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'play'),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontFamily: 'play'),
          tabs: const [
            Tab(text: 'Image'),
            Tab(text: 'Voice'),
          ],
        ),
      ),
    );
  }

  // ── Image tab ─────────────────────────────────────────────────────────────

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePickerArea(),
          const SizedBox(height: 20),
          _buildEmotionSection(),
          const SizedBox(height: 24),
          _buildButtons(imageMode: true),
        ],
      ),
    );
  }

  Widget _buildImagePickerArea() {
    final double height = MediaQuery.of(context).size.height * 0.36;

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: _imageBytes == null
          ? _buildEmptyImageBox(height)
          : _buildImagePreview(height),
    );
  }

  Widget _buildEmptyImageBox(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: HexColor('#F9FEF8'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HexColor('#D4EED4'), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: height * 0.45,
            child: Lottie.asset(
              'assets/json/camera.json',
              errorBuilder: (_, __, ___) => Icon(
                Icons.add_photo_alternate_outlined,
                size: 72,
                color: primaryappColor.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tap to Select The Image',
            style: TextStyle(
              fontSize: 16,
              color: primaryappColor,
              fontFamily: 'play',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Camera or Gallery',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(double height) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            _imageBytes!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => setState(() => _imageError = true));
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
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
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16)),
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

  // ── Voice tab ─────────────────────────────────────────────────────────────

  Widget _buildVoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMicSection(),
          const SizedBox(height: 24),
          _buildRecognizedTextBox(),
          const SizedBox(height: 24),
          _buildEmotionSection(),
          const SizedBox(height: 24),
          _buildButtons(imageMode: false),
        ],
      ),
    );
  }

  Widget _buildMicSection() {
    return Column(
      children: [
        // Mic button
        GestureDetector(
          onTap: _toggleListening,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.red : primaryappColor,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : primaryappColor)
                      .withOpacity(0.38),
                  blurRadius: _isListening ? 22 : 12,
                  spreadRadius: _isListening ? 6 : 2,
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Status text
        Text(
          _isListening
              ? '● Listening — tap to stop'
              : _speechAvailable
                  ? 'Tap mic to start recording'
                  : 'Initializing speech recognition…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _isListening ? Colors.red : Colors.grey[600],
            fontWeight:
                _isListening ? FontWeight.w700 : FontWeight.normal,
            fontFamily: 'play',
          ),
        ),

        // Recording wave bar
        if (_isListening) ...[
          const SizedBox(height: 12),
          _buildWaveBar(),
        ],
      ],
    );
  }

  Widget _buildWaveBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final heights = [14.0, 22.0, 30.0, 22.0, 14.0];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 5,
            height: heights[i],
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecognizedTextBox() {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isListening
              ? Colors.red.withOpacity(0.45)
              : HexColor('#C8EEC8'),
          width: _isListening ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 6,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recognized Text',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              if (_recognizedText.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _recognizedText = ''),
                  child: Icon(Icons.clear_rounded,
                      size: 18, color: Colors.grey[400]),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _recognizedText.isEmpty
              ? Text(
                  _isListening ? 'Speak now…' : 'Recognized text will appear here.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(
                  _recognizedText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
        ],
      ),
    );
  }

  // ── Shared: emotion + buttons ─────────────────────────────────────────────

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioRow(
          label: 'Sentence Level Emotion',
          value: 'sentenceemotion',
          onTap: () => setState(() {
            _emotionType = 'sentenceemotion';
            _showEmotionDropdown = false;
          }),
        ),
        const SizedBox(height: 6),
        _buildRadioRow(
          label: 'Paragraph Level Emotion',
          value: 'paragraphemotion',
          onTap: () => setState(() {
            _emotionType = 'paragraphemotion';
            _showEmotionDropdown = true;
          }),
        ),
        if (_showEmotionDropdown) ...[
          const SizedBox(height: 12),
          _buildEmotionDropdown(),
        ],
      ],
    );
  }

  Widget _buildRadioRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final selected = _emotionType == value;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? primaryappColor : Colors.transparent,
              border: Border.all(
                color: selected ? primaryappColor : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'play',
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? primaryappColor : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HexColor('#C8EEC8')),
        boxShadow: [
          BoxShadow(
              color: HexColor('#E8F8E8'), spreadRadius: 1, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Emotion',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'play',
              fontWeight: FontWeight.bold,
              color: primarygreyDark,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _emotionDropdown,
            isExpanded: true,
            onChanged: (v) {
              if (v != null) setState(() => _emotionDropdown = v);
            },
            items: _emotionItems
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item[0].toUpperCase() + item.substring(1),
                        style: const TextStyle(fontFamily: 'play'),
                      ),
                    ))
                .toList(),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: HexColor('#B8DEB8')),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: HexColor('#B8DEB8')),
              ),
              focusedBorder: OutlineBottomInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: primaryappColor, width: 1.5),
              ),
              filled: true,
              fillColor: HexColor('#F6FFF6'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons({required bool imageMode}) {
    final bool ready = imageMode ? _imageTabReady : _voiceTabReady;

    if (_isLoading || _loadingGetAudio) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        if (!_mergeReady)
          _buildGradientButton(
            label: 'SUBMIT',
            enabled: ready,
            onTap: () => _submit(imageMode),
          ),
        if (_mergeReady) ...[
          const SizedBox(height: 8),
          _buildGradientButton(
            label: 'GET AUDIO',
            enabled: true,
            onTap: () {
              setState(() => _loadingGetAudio = true);
              Future.delayed(const Duration(seconds: 10), _fetchFinalAudio);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGradientButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green, Colors.yellow],
                )
              : null,
          color: enabled ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: enabled ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper needed because OutlineInputBorder is the only concrete
// InputBorder that works with focusedBorder + borderRadius together.
typedef OutlineBottomInputBorder = OutlineInputBorder;
