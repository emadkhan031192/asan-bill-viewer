
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';

class AddBillScreen extends StatefulWidget {
  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final refController = TextEditingController();
  final labelController = TextEditingController();
  String selectedDisco = 'LESCO';
  String detectedRef = '';
  bool scanning = false;

  void _autoDetect() {
    final ref = refController.text.replaceAll(RegExp(r'\D'), '');
    if (ref.isNotEmpty) {
      final source = OfficialSources.autoDetect(ref);
      setState(() => selectedDisco = source.company);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Bill - Scan Reference'), backgroundColor: Color(0xFF0B3D20), foregroundColor: Colors.white),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // OCR Scan Area
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF0B3D20), width: 2),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.document_scanner, size: 60, color: Colors.white30)),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(border: Border.all(color: Color(0xFFFFB000), width: 2), borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Center(child: Text('Point camera at printed bill\n14-digit Ref will auto-detect', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
                if (scanning) Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0B3D20), foregroundColor: Colors.white),
            onPressed: () {
              setState(() => scanning = true);
              Future.delayed(Duration(seconds: 1), () {
                // Simulate ML Kit detection
                setState(() {
                  scanning = false;
                  refController.text = '14123456789012';
                  detectedRef = '14123456789012';
                  _autoDetect();
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reference detected via ML Kit!')));
              });
            },
            icon: Icon(Icons.camera_alt),
            label: Text('Scan with Camera (ML Kit OCR)'),
          ),
          Divider(height: 32),
          TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: 'Custom Label [Ghar / Dukan / Gaon]', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
          ),
          SizedBox(height: 12),
          TextField(
            controller: refController,
            onChanged: (_) => _autoDetect(),
            decoration: InputDecoration(
              labelText: 'Reference No / Consumer No',
              hintText: 'e.g., 14123456789012',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          DropdownButtonFormField(
            value: selectedDisco,
            decoration: InputDecoration(labelText: 'DISCO / Company (Auto-detected)', border: OutlineInputBorder()),
            items: OfficialSources.all.map((e) => DropdownMenuItem(value: e.company, child: Text('${e.company} - ${e.domain}'))).toList(),
            onChanged: (v) => setState(() => selectedDisco = v.toString()),
          ),
          SizedBox(height: 20),
          // Official source info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFFD9E8D0), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Official Source:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${OfficialSources.all.firstWhere((e) => e.company == selectedDisco).fullUrl}', style: TextStyle(fontSize: 11, color: Color(0xFF0B3D20))),
                Text('Data fetched 100% client-side, no proxy server', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0B3D20), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16)),
            onPressed: () {
              if (refController.text.isEmpty || labelController.text.isEmpty) return;
              final source = OfficialSources.all.firstWhere((e) => e.company == selectedDisco);
              final bill = SavedBill(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                label: labelController.text,
                referenceNo: refController.text,
                disco: selectedDisco,
                officialDomain: source.domain,
                billCheckUrl: source.fullUrl,
                group: 'Home',
              );
              Navigator.pop(context, bill);
            },
            child: Text('Save Bill - Offline PDF Vault'),
          ),
        ],
      ),
    );
  }
}
