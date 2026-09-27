
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import 'bill_detail_screen.dart';
import 'add_bill_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedBill> bills = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_bills');
    if (data != null) {
      final List list = jsonDecode(data);
      bills = list.map((e) => SavedBill.fromJson(e)).toList();
    } else {
      // Demo bills for first run
      bills = [
        SavedBill(
          id: '1',
          label: 'Ghar - LESCO',
          referenceNo: '14123456789012',
          disco: 'LESCO',
          officialDomain: 'lesco.gov.pk',
          billCheckUrl: 'https://bill.pitc.com.pk/lescobill',
          amount: 'Rs. 8,420',
          dueDate: 'Due in 2 days',
          group: 'Home',
        ),
        SavedBill(
          id: '2',
          label: 'Dukan - FESCO',
          referenceNo: '14123456789013',
          disco: 'FESCO',
          officialDomain: 'fesco.com.pk',
          billCheckUrl: 'https://bill.pitc.com.pk/fescobill',
          amount: 'Rs. 12,400',
          dueDate: 'Due in 5 days',
          group: 'Shop',
        ),
      ];
    }
    setState(() => loading = false);
  }

  Future<void> _saveBills() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_bills', jsonEncode(bills.map((e) => e.toJson()).toList()));
  }

  Future<void> _refreshAll() async {
    setState(() => loading = true);
    for (var bill in bills) {
      final result = await PitcBillService.fetchBill(bill.billCheckUrl, bill.referenceNo);
      if (result['status'] == 'ok') {
        bill.amount = result['amount'] ?? bill.amount;
        bill.dueDate = result['dueDate'] ?? bill.dueDate;
        bill.lastFetched = DateTime.now().toString();
      }
    }
    await _saveBills();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFBF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B3D20),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.receipt_long, color: Color(0xFF0B3D20), size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('آسان - Asan Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Official Source Only', style: TextStyle(fontSize: 10, color: Color(0xFFD9E8D0))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _refreshAll, icon: Icon(Icons.sync)),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0B3D20)))
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: EdgeInsets.all(12),
                children: [
                  // Trust Banner
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFD9E8D0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF0B3D20).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: Color(0xFF0B3D20), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '100% Official Data from .gov.pk • No ads on bills • Offline PDF saved',
                            style: TextStyle(fontSize: 12, color: Color(0xFF0B3D20), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Total Due Widget
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF0B3D20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Due This Month', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Rs. 20,820 • 2 bills due in 2 days', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        LinearProgressIndicator(value: 0.7, color: Color(0xFFFFB000), backgroundColor: Colors.white24),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Your Bills [Ghar][Dukan]', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B3D20))),
                  SizedBox(height: 8),
                  ...bills.map((bill) => Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BillDetailScreen(bill: bill))),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Color(0xFFD9E8D0), borderRadius: BorderRadius.circular(8)),
                            child: Icon(bill.disco == 'LESCO' ? Icons.bolt : Icons.local_fire_department, color: Color(0xFF0B3D20)),
                          ),
                          title: Text(bill.label, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text('✓ Data from ${bill.officialDomain}', style: TextStyle(fontSize: 10, color: Colors.green.shade800)),
                              ),
                              SizedBox(height: 4),
                              Text('${bill.referenceNo}', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(bill.amount, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3D20))),
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: bill.dueDate.contains('2 days') ? Color(0xFFB93815) : Color(0xFFFFB000), borderRadius: BorderRadius.circular(10)),
                                child: Text(bill.dueDate, style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )),
                  SizedBox(height: 20),
                  // Official Sources Table
                  Text('Verified Official Sources', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...OfficialSources.all.take(5).map((s) => ListTile(
                        dense: true,
                        title: Text('${s.company} - ${s.domain}', style: TextStyle(fontSize: 12)),
                        subtitle: Text(s.fullUrl, style: TextStyle(fontSize: 10, color: Colors.grey)),
                      )),
                  TextButton(onPressed: () {}, child: Text('View All 15 Official Sources')),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0B3D20),
        foregroundColor: Colors.white,
        onPressed: () async {
          final newBill = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddBillScreen()));
          if (newBill != null) {
            setState(() => bills.add(newBill));
            _saveBills();
          }
        },
        icon: Icon(Icons.add_a_photo),
        label: Text('Scan Bill'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF0B3D20),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
