# Team Intro — Micro Game Platformer (Godot 4)

Micro game perkenalan tim proyek akhir bergaya **platformer side-scrolling**.
Di awal, pemain **memilih karakter**: tiap karakter berkepala **foto wajah anggota
yang di-pixelate**, lengkap dengan Nama, NIM, dan peran. Setelah itu pemain berlari
dan melompat melewati level bergaya pastel (pelangi, awan, tanah kue, balok permen),
mengumpulkan bintang, menginjak musuh blob, dan menemui
**papan tiap anggota** (sekaligus checkpoint) yang menampilkan kartu perkenalan.
Bendera finish hanya bisa disentuh setelah semua anggota ditemui.

**Kontrol**
| Tombol | Fungsi |
|---|---|
| A / D atau Kiri / Kanan | jalan, pilih karakter |
| Spasi / W / Atas | lompat (tahan = lebih tinggi) |
| E / Spasi / Enter | mulai, tutup kartu |
| R | main lagi (di layar akhir) |

Jatuh ke jurang atau tersentuh musuh dari samping → muncul lagi di papan anggota terakhir.

## Cara menjalankan
1. Install **Godot 4.3+** (versi standar, bukan .NET).
2. Godot → **Import** → pilih `project.godot` → **Import & Edit**.
3. Tekan **F5**.

## Mengganti data tim (WAJIB)
Edit `data/team.json`: `team_name`, lalu `name`, `nim`, `role`, `fact`, `color` tiap anggota.
`color` = warna baju karakter dan bingkai fotonya.

Foto wajah:
```bash
pip install pillow
python tools/pixelate.py foto_asli.jpg assets/photos/member1.png
```
Foto asli simpan di `assets/photos/raw/` (sudah di-ignore, tidak ikut ke GitHub).

## Mengedit level (`data/level1.txt`)
Level digambar dengan karakter teks, 1 karakter = 1 tile 16×16 px.

| Karakter | Arti |
|---|---|
| `#` | tanah kue berumput (padat) |
| `B` | balok permen (padat) |
| `-` | platform awan (bisa dilompati dari bawah) |
| `o` | bintang |
| `e` | musuh |
| `1` `2` `3` | papan anggota ke-1/2/3 (sesuai urutan di team.json) |
| `P` | posisi awal pemain |
| `F` | bendera finish |
| spasi | kosong / jurang |

Tinggi lompatan maksimal ±4 tile, jarak lompat ±6 tile — jaga supaya rintangan masih bisa dilewati.

## Struktur & pemilik file
| File | Isi | Pemilik |
|---|---|---|
| `scripts/player.gd` | fisika lari, lompat, karakter berkepala foto | Programmer |
| `scripts/enemy.gd` | musuh & logika injak | Programmer |
| `scripts/main.gd` | alur game, pembaca level, kamera, HUD | Programmer |
| `scripts/select_screen.gd`, `scripts/info_popup.gd` | layar pilih karakter & kartu anggota | Programmer / Artist |
| `scripts/level_art.gd`, `scripts/sky.gd` | gambar tile & latar parallax | Artist |
| `scripts/ui.gd`, `scripts/fx.gd`, `assets/fonts/*` | palet warna, font, efek partikel | Artist |
| `scripts/photo_util.gd`, `tools/pixelate.py`, `assets/photos/*` | foto pixel | Artist |
| `scripts/pickups.gd` | bintang, papan anggota, bendera | Project + Level |
| `data/level1.txt`, `data/team.json` | desain level & data tim | Project + Level |

## Alur kolaborasi GitHub
1. Clone: `git clone https://github.com/iola-sava/ThePowerpuffgirl.git`
2. Buat branch: `git checkout -b <nama-fitur>`
3. Kerja → `git add .` → `git commit -m "feat: ..."` → `git push -u origin <nama-fitur>`
4. Buka **Pull Request** di GitHub → anggota lain review → **Merge**.
5. Yang lain: `git checkout main && git pull`.

Contoh branch:
- Programmer: `feature/player-jump` ("feat: tinggi lompat & coyote time"), `feature/enemy`
- Artist: `feature/pixel-photos` ("art: foto pixel 3 anggota"), `feature/tile-art`
- Project + Level: `feature/level-1` ("level: tambah jurang & platform"), `feature/team-data`

## Board Trello
Kolom: **To Do → In Progress → Review → Done**

| Kartu | Anggota |
|---|---|
| Setup repo GitHub + project Godot | Project + Level |
| Fisika player: lari & lompat | Programmer |
| Musuh + mekanik injak | Programmer |
| Layar pilih karakter & kartu anggota | Programmer |
| Pixelate foto wajah 3 anggota | Artist |
| Gambar tile, latar pastel, efek partikel | Artist |
| Desain level 1 (`level1.txt`) | Project + Level |
| Isi data tim (Nama, NIM, peran) | Project + Level |
| Playtest & bug fix | Semua |
| Rekam & edit video demo | Semua |

Tempel link PR GitHub di kartu terkait supaya Trello & GitHub terlihat terhubung.

## Naskah video demo (target ±17 menit)
| Menit | Isi | Layar |
|---|---|---|
| 0:00–1:30 | Pembukaan: nama tim, anggota, peran, konsep platformer | Wajah/slide + layar pilih karakter |
| 1:30–3:30 | Board Trello: kolom, kartu, pembagian tugas | Trello |
| 3:30–5:30 | Setup repo, invite collaborator, struktur folder | GitHub + Godot |
| 5:30–9:00 | **Programmer**: ubah `player.gd` (misal tinggi lompat), tes F5, commit, PR, geser kartu | Godot → terminal → GitHub → Trello |
| 9:00–12:00 | **Artist**: `pixelate.py` foto asli, ganti warna tile, commit, PR, geser kartu | Terminal → Godot → GitHub → Trello |
| 12:00–14:30 | **Project + Level**: edit `level1.txt`, isi `team.json`, review & merge PR teman | Godot → GitHub → Trello |
| 14:30–16:30 | **Demo game** penuh: pilih karakter → temui 3 anggota → finish | Game (F5) |
| 16:30–17:30 | Penutup: history commit / Insights GitHub + Trello semua Done | GitHub + Trello |

Tips: tiap anggota merekam layarnya sendiri (OBS / QuickTime) saat mengerjakan bagiannya,
lalu digabung. Sebut nama di awal tiap segmen.
