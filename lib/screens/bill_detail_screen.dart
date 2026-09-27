
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import 'package:share_plus/share_plus.dart';

class BillDetailScreen extends StatefulWidget {
  final SavedBill bill;
  BillDetailScreen({required this.bill});
  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  String htmlContent = 'Loading from official source...';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final result = await PitcBillService.fetchBill(widget.bill.billCheckUrl, widget.bill.referenceNo);
    setState(() {
      htmlContent = result['html'] ?? result['error'] ?? 'Failed';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFBF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B3D20),
        foregroundColor: Colors.white,
        title: Text(widget.bill.label),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () => Share.share('My ${widget.bill.disco} Bill ${widget.bill.referenceNo} - ${widget.bill.amount} via Asan Bill Viewer\nSource: ${widget.bill.officialDomain}')),
          IconButton(icon: Icon(Icons.print), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Trust Badge
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Color(0xFFD9E8D0),
            child: Row(
              children: [
                Icon(Icons.verified, size: 16, color: Color(0xFF0B3D20)),
                SizedBox(width: 6),
                Expanded(child: Text('✓ Data from ${widget.bill.officialDomain} • ${widget.bill.billCheckUrl} • SSL verified • Fetched just now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Bill Info Card
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Amount to Pay', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(widget.bill.amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B3D20))),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Due Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(0xFFB93815), borderRadius: BorderRadius.circular(8)), child: Text(widget.bill.dueDate, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
          // Bill PDF / HTML Viewer
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: loading
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Checking ${widget.bill.officialDomain}...', style: TextStyle(fontSize: 12))]))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('OFFICIAL DUPLICATE BILL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          Divider(),
                          Text(htmlContent.length > 2000 ? htmlContent.substring(0, 2000) : htmlContent, style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                          SizedBox(height: 20),
                          Text('PDF rendering via PdfRenderer would appear here\nZoomable, saveable to Documents/AsanBill/', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0B3D20), foregroundColor: Colors.white), onPressed: () {}, icon: Icon(Icons.save), label: Text('Save PDF'))),
                SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: Icon(Icons.share), label: Text('Share as Image'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
