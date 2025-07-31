import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_kodhjalp/app/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

class KaosView extends StatefulWidget {
  const KaosView({super.key});

  @override
  State<KaosView> createState() => _KaosViewState();
}

class _KaosViewState extends State<KaosView> {
  KaosStep _currentStep = KaosStep.identify;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordingPath;

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission denied");
      return;
    }
    await _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  void _setStep(KaosStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _startRecording() async {
    if (_recorder == null) return;
    await _initRecorder();
    setState(() {
      _isRecording = true;
      _currentStep = KaosStep.record;
    });
    await _recorder!.startRecorder(toFile: 'kaos_audio.aac');
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) return;
    final path = await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordingPath = path;
    });
    _setStep(KaosStep.act);
    _uploadAndSaveRecording();
  }

  Future<void> _uploadAndSaveRecording() async {
    if (_recordingPath == null || _auth.currentUser == null) return;

    final file = File(_recordingPath!);
    try {
      final fileName =
          'kaos_entries/${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.aac';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestoreService.addItem(
        collectionPath: 'kaos_entries',
        data: {
          'type': 'audio',
          'audioUrl': downloadUrl,
          'feeling': 'recorded',
        },
      );
    } catch (e) {
      print("Error uploading recording: $e");
    }
  }

  Future<void> _saveFeeling(String feeling) async {
    try {
      await _firestoreService.addItem(
        collectionPath: 'kaos_entries',
        data: {
          'type': 'feeling',
          'feeling': feeling,
        },
      );
    } catch (e) {
      print("Error saving feeling: $e");
    }
    _setStep(KaosStep.act);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.kaosBackground,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case KaosStep.identify:
        return _buildIdentifyStep();
      case KaosStep.record:
        return _buildRecordStep();
      case KaosStep.act:
        return _buildActStep();
    }
  }

  Widget _buildIdentifyStep() {
    return Padding(
      key: const ValueKey('identify'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FaIcon(FontAwesomeIcons.hand,
              size: 64, color: Colors.blueAccent),
          const SizedBox(height: 32),
          const Text(
            '''Okej, vi pausar. En sak i taget.
Vad känner du mest just nu?''',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildFeelingButton('Arg'),
              _buildFeelingButton('Ledsen'),
              _buildFeelingButton('Värdelös'),
              _buildFeelingButton('Överväldigad'),
            ],
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.microphone, size: 18),
            label: const Text('Eller spela in en tanke'),
            onPressed: _startRecording,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              /* TODO: Navigate to a breathing exercise */
            },
            child: Text('För svårt? Ta en andningspaus istället.',
                style: TextStyle(color: Colors.blue.shade200)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingButton(String feeling) {
    return OutlinedButton(
      onPressed: () => _saveFeeling(feeling),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.blue.shade300, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(feeling, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildRecordStep() {
    return Padding(
      key: const ValueKey('record'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FaIcon(FontAwesomeIcons.microphoneLines,
              size: 64, color: Colors.blue.shade200),
          const SizedBox(height: 32),
          const Text(
            '''Säg vad du vill. Ingen dömer.
Tryck för att stoppa.''',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.redAccent, blurRadius: 10, spreadRadius: 5)
                ],
              ),
              child: const Icon(Icons.stop, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () {
              if (_isRecording) _recorder?.stopRecorder();
              setState(() {
                _isRecording = false;
              });
              Navigator.of(context).pop();
            },
            child: Text('Avbryt och radera',
                style: TextStyle(color: Colors.blue.shade300)),
          ),
        ],
      ),
    );
  }

  Widget _buildActStep() {
    return Padding(
      key: const ValueKey('act'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FaIcon(FontAwesomeIcons.personWalking,
              size: 64, color: Colors.greenAccent),
          const SizedBox(height: 32),
          const Text(
            '''Bra jobbat. Nu gör vi en sak.
Res dig upp och sträck på dig i 10 sekunder.''',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600),
            child: const Text('Klar, ta mig härifrån'),
          )
        ],
      ),
    );
  }
}

enum KaosStep {
  identify,
  record,
  act,
}
