import 'package:absen/constants/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AbsenPage extends StatefulWidget {
  const AbsenPage({super.key});

  @override
  _AbsenPageState createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> absenData = [];
  List<Map<String, dynamic>> filteredData = [];

  Future<void> createAbsen(
      String nama, String nim, String program, int semester) async {
    try {
      await _firestore.collection('absen').add({
        'nama': nama,
        'nim': nim,
        'program': program,
        'semester': semester,
        'date': DateTime.now().toString().split(' ')[0],
      });
      getData();
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('absen').get();
      absenData = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nama': doc['nama'],
          'nim': doc['nim'],
          'program': doc['program'] ?? '',
          'semester': doc['semester'] ?? 1,
          'date': doc['date'],
        };
      }).toList();
      filteredData = absenData;
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<Map<String, int>> getDayOfWeekData() async {
    Map<String, int> dayOfWeekData = {
      'Senin': 0,
      'Selasa': 0,
      'Rabu': 0,
      'Kamis': 0,
      'Jumat': 0,
      'Sabtu': 0,
      'Minggu': 0,
    };

    for (var item in absenData) {
      String date = item['date'];
      DateTime parsedDate = DateTime.parse(date);
      String dayOfWeek = _getDayOfWeek(parsedDate.weekday);
      dayOfWeekData[dayOfWeek] = (dayOfWeekData[dayOfWeek] ?? 0) + 1;
    }

    return dayOfWeekData;
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  Future<void> deleteAbsen(String docId) async {
    try {
      await _firestore.collection('absen').doc(docId).delete();
      getData();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> updateAbsen(String docId, String nama, String nim,
      String program, int semester, String date) async {
    try {
      await _firestore.collection('absen').doc(docId).update({
        'nama': nama,
        'nim': nim,
        'program': program,
        'semester': semester,
        'date': date,
      });
      getData();
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      filteredData = absenData
          .where((item) =>
              item['nama'].toLowerCase().contains(query.toLowerCase()) ||
              item['nim'].contains(query) ||
              item['program'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredData = absenData;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController namaController = TextEditingController();
    TextEditingController nimController = TextEditingController();

    String selectedProgram = 'Ilmu Komputer';
    int selectedSemester = 1;

    final List<String> programs = [
      'Ilmu Komputer',
      'Farmasi',
      'Desain Komunikasi Visual',
      'Bahasa Inggris',
      'Teknologi Informasi',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Absen Baru'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Masukkan nama lengkap',
                      ),
                    ),
                    TextField(
                      controller: nimController,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        hintText: 'Masukkan NIM',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedProgram,
                      decoration: const InputDecoration(
                        labelText: 'Program Studi',
                      ),
                      items: programs.map((String program) {
                        return DropdownMenuItem<String>(
                          value: program,
                          child: Text(program),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProgram = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                      ),
                      items: List.generate(8, (index) => index + 1)
                          .map((int semester) {
                        return DropdownMenuItem<int>(
                          value: semester,
                          child: Text('Semester $semester'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedSemester = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (namaController.text.isEmpty ||
                        nimController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama dan NIM harus diisi!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    createAbsen(
                      namaController.text,
                      nimController.text,
                      selectedProgram,
                      selectedSemester,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, Map<String, dynamic> item) {
    TextEditingController namaController =
        TextEditingController(text: item['nama']);
    TextEditingController nimController =
        TextEditingController(text: item['nim']);
    TextEditingController dateController =
        TextEditingController(text: item['date']);

    String selectedProgram = item['program'] ?? 'Ilmu Komputer';
    int selectedSemester = item['semester'] ?? 1;

    final List<String> programs = [
      'Ilmu Komputer',
      'Farmasi',
      'Desain Komunikasi Visual',
      'Bahasa Inggris',
      'Teknologi Informasi',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Absen'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    TextField(
                      controller: nimController,
                      decoration: const InputDecoration(labelText: 'NIM'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedProgram,
                      decoration: const InputDecoration(
                        labelText: 'Program Studi',
                      ),
                      items: programs.map((String program) {
                        return DropdownMenuItem<String>(
                          value: program,
                          child: Text(program),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProgram = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                      ),
                      items: List.generate(8, (index) => index + 1)
                          .map((int semester) {
                        return DropdownMenuItem<int>(
                          value: semester,
                          child: Text('Semester $semester'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedSemester = newValue!;
                        });
                      },
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                          labelText: 'Tanggal (yyyy-mm-dd)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    updateAbsen(
                      item['id'],
                      namaController.text,
                      nimController.text,
                      selectedProgram,
                      selectedSemester,
                      dateController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getDayColor(String day) {
    switch (day) {
      case 'Senin':
        return Colors.blue;
      case 'Selasa':
        return Colors.green;
      case 'Rabu':
        return Colors.orange;
      case 'Kamis':
        return Colors.red;
      case 'Jumat':
        return Colors.purple;
      case 'Sabtu':
        return Colors.yellow;
      case 'Minggu':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text(
          'Data Absen',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: accentColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name, NIM, or Program',
                hintText: 'Enter name, NIM, or program...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: FutureBuilder<Map<String, int>>(
              future: getDayOfWeekData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }

                Map<String, int> dayOfWeekData = snapshot.data!;
                List<PieChartSectionData> pieChartSections =
                    dayOfWeekData.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n${entry.value}',
                    color: _getDayColor(entry.key),
                    radius: 30,
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 14),
                  );
                }).toList();

                return PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    borderData: FlBorderData(show: false),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Color.fromARGB(255, 21, 220, 227)),
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  var item = filteredData[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.person,
                          color: Colors.teal, size: 40),
                      title: Text(
                        item['nama'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'NIM: ${item['nim']}\nProgram: ${item['program']}\nSemester: ${item['semester']}\nTanggal: ${item['date']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUpdateDialog(context, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAbsen(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
