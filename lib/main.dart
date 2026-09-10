import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ZuxcynMotionApp());
}

class ZuxcynMotionApp extends StatelessWidget {
  const ZuxcynMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zuxcyn Motion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepPurple,
      ),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String selectedEffect = 'shake';
  bool isRendering = false;
  String statusMessage = 'Siap melakukan rendering';

  Future<void> sendRenderRequest() async {
    setState(() {
      isRendering = true;
      statusMessage = 'Sedang memproses render di VPS...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://157.245.195.158:3000/api/render'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'inputPath': 'input.mp4',
          'outputPath': 'output_$selectedEffect.mp4',
          'effect': selectedEffect,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = 'Render Selesai!';
        });
      } else {
        setState(() {
          statusMessage = 'Gagal: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error koneksi ke VPS';
      });
    } finally {
      setState(() {
        isRendering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zuxcyn Motion Editor'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Center(
                child: Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1F1F1F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PILIH EFEK PRESET', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildEffectButton('Shake', 'shake'),
                      _buildEffectButton('Velocity', 'velocity'),
                      _buildEffectButton('TVROOD CC', 'tvrood_cc'),
                      _buildEffectButton('Glow', 'glow'),
                      _buildEffectButton('Flash', 'flash'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isRendering ? null : sendRenderRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: isRendering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('EXPORT VIDEO'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectButton(String name, String value) {
    final isSelected = selectedEffect == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(name),
        selected: isSelected,
        selectedColor: Colors.deepPurple,
        onSelected: (bool selected) {
          setState(() {
            selectedEffect = value;
          });
        },
      ),
    );
  }
}
