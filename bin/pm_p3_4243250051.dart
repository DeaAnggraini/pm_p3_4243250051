import 'dart:io';

// Tantangan 2: record ditambah field prioritas
typedef Tugas = ({int id, String judul, bool selesai, String prioritas});

// Angka lebih kecil = lebih penting (dipakai untuk pengurutan)
const urutanPrioritas = {'Tinggi': 0, 'Sedang': 1, 'Rendah': 2};

extension Kapital on String {
  String get kapital =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

final List<Tugas> daftar = [];
int _idBerikut = 1;

void main() {
  print('=== TODO CLI ===');
  var jalan = true;
  while (jalan) {
    tampilkanMenu();
    final pilihan = baca('Pilih menu');
    try {
      switch (pilihan) {
        case '1':
          tambah(baca('Judul tugas'), prioritas: bacaPrioritas());
        case '2':
          tampilkan(daftar);
          cetakRingkasan();
        case '3':
          tandaiSelesai(bacaAngka('ID tugas'));
        case '4':
          hapus(bacaAngka('ID tugas'));
        case '5':
          tampilkan(cari(baca('Kata kunci')), judul: 'Hasil pencarian');
        case '6':
          tampilkan(
            daftar.where((t) => !t.selesai).toList(),
            judul: 'Belum selesai',
          );
        case '7':
          ubahJudul(bacaAngka('ID tugas'), baca('Judul baru'));
        case '0':
          jalan = false;
        default:
          print('Menu tidak dikenal.');
      }
    } on FormatException catch (e) {
      print('Peringatan: ${e.message}');
    }
  }
  print('Sampai jumpa!');
}

void tampilkanMenu() {
  print('''
[1] Tambah   [2] Lihat semua   [3] Tandai selesai
[4] Hapus    [5] Cari          [6] Belum selesai
[7] Ubah judul                 [0] Keluar''');
}

String baca(String label) {
  stdout.write('$label: ');
  return (stdin.readLineSync() ?? '').trim();
}

int bacaAngka(String label) {
  final teks = baca(label);
  final angka = int.tryParse(teks);
  if (angka == null) throw FormatException('"$teks" bukan angka.');
  return angka;
}

String bacaPrioritas() {
  final teks = baca('Prioritas (Tinggi/Sedang/Rendah)');
  final p = teks.toLowerCase().kapital; // "TINGGI" / "tinggi" -> "Tinggi"
  if (!urutanPrioritas.containsKey(p)) {
    throw FormatException('Prioritas harus Tinggi, Sedang, atau Rendah.');
  }
  return p;
}

void tambah(String judul, {String prioritas = 'Sedang'}) {
  if (judul.isEmpty) throw FormatException('Judul tidak boleh kosong.');
  daftar.add((
    id: _idBerikut++,
    judul: judul.kapital,
    selesai: false,
    prioritas: prioritas,
  ));
  print('Tugas ditambahkan.');
}

void tampilkan(List<Tugas> data, {String judul = 'Daftar tugas'}) {
  print('--- $judul (${data.length}) ---');
  if (data.isEmpty) {
    print('(kosong)');
    return;
  }
  // Tantangan 2: urutkan salinan list dengan sort + fungsi pembanding
  final urut = [...data]
    ..sort((a, b) {
      final c = urutanPrioritas[a.prioritas]!.compareTo(
        urutanPrioritas[b.prioritas]!,
      );
      return c != 0 ? c : a.id.compareTo(b.id); // sama -> urut ID
    });
  for (final t in urut) {
    final tanda = t.selesai ? '[x]' : '[ ]';
    print('${t.id.toString().padLeft(3)} $tanda [${t.prioritas}] ${t.judul}');
  }
}

int _indeksDari(int id) {
  final i = daftar.indexWhere((t) => t.id == id);
  if (i == -1) throw FormatException('Tugas dengan ID $id tidak ditemukan.');
  return i;
}

void tandaiSelesai(int id) {
  final i = _indeksDari(id);
  final t = daftar[i];
  daftar[i] = (
    id: t.id,
    judul: t.judul,
    selesai: true,
    prioritas: t.prioritas,
  ); // record immutable
  print('"${t.judul}" ditandai selesai.');
}

void hapus(int id) {
  final t = daftar.removeAt(_indeksDari(id));
  print('"${t.judul}" dihapus.');
}

List<Tugas> cari(String kata) {
  final kunci = kata.toLowerCase();
  return daftar.where((t) => t.judul.toLowerCase().contains(kunci)).toList();
}

// Tantangan 1: ubah judul
void ubahJudul(int id, String judulBaru) {
  if (judulBaru.isEmpty) throw FormatException('Judul tidak boleh kosong.');
  final i = _indeksDari(id);
  final t = daftar[i];
  daftar[i] = (
    id: t.id,
    judul: judulBaru.kapital,
    selesai: t.selesai,
    prioritas: t.prioritas,
  );
  print('Judul diubah.');
}

// Tantangan 3: fungsi yang mengembalikan record
({int total, int selesai, double persen}) ringkasan() {
  final total = daftar.length;
  final selesai = daftar.where((t) => t.selesai).length;
  final persen = total == 0 ? 0.0 : selesai / total * 100;
  return (total: total, selesai: selesai, persen: persen);
}

void cetakRingkasan() {
  final r = ringkasan();
  print(
    'Ringkasan: total ${r.total}, selesai ${r.selesai}, '
    '${r.persen.toStringAsFixed(0)}%',
  );
}
