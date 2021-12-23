import 'package:flutter/material.dart';
import 'package:sqlite/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Tutorial SQLite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, @required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  //ambil data dari database
  List<Map<String, dynamic>> catatan = [];
  void refreshCatatan() async {
    final data = await SQLHelper.getCatatan();
    setState(() {
      catatan = data;
    });
  }

  @override
  void initState() {
    refreshCatatan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: catatan.length,
          itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(catatan[index]['judul']),
                  subtitle: Text(catatan[index]['deskripsi']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => modalForm(catatan[index]['id']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => hapusCatatan(catatan[index]['id']),
                            icon: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                ),
              )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => modalForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  //fungsi tambah
  Future<void> tambahCatatan() async {
    await SQLHelper.tambahCatatan(
        judulController.text, deskripsiController.text);
    refreshCatatan();
  }

  //fungsi ubah
  Future<void> ubahCatatan(int id) async {
    await SQLHelper.ubahCatatan(
        id, judulController.text, deskripsiController.text);
    refreshCatatan();
  }

  //fungsi hapus
  void hapusCatatan(int id) async {
    await SQLHelper.hapusCatatan(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Berhasil hapus catatan')));
    refreshCatatan();
  }

  //membuat form tambah
  void modalForm(int id) async {
    if (id != null) {
      final dataCatatan = catatan.firstWhere((element) => element['id'] == id);
      judulController.text = dataCatatan['judul'];
      deskripsiController.text = dataCatatan['deskripsi'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 800,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(hintText: 'judul'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: deskripsiController,
                      decoration: const InputDecoration(hintText: 'deskripsi'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            await tambahCatatan();
                          } else {
                            await ubahCatatan(id);
                          }
                          judulController.text = '';
                          deskripsiController.text = '';
                          Navigator.pop(context);
                        },
                        child: Text(id == null ? 'Tambah' : 'update'))
                  ],
                ),
              ),
            ));
  }
}
