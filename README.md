# Team Intro — Micro Game (Godot 4)

Micro game perkenalan tim proyek akhir. Pemain berjalan di sebuah ruangan, menemui
podium tiap anggota, dan melihat kartu berisi **Nama, NIM, peran, dan foto wajah
yang di-pixelate**. Setelah semua anggota ditemui, gerbang di atas terbuka dan
pemain bisa keluar ke layar ending.

**Kontrol:** WASD / panah = jalan · E / Spasi / Enter = interaksi · R = main lagi (di ending)

## Cara menjalankan
1. Install **Godot 4.3+** (versi standar, bukan .NET).
2. Buka Godot → **Import** → pilih `project.godot` di folder ini.
3. Tekan **F5** (Run).

## Mengganti data tim (WAJIB)
Edit `data/team.json`: ganti `team_name`, `name`, `nim`, `role`, `fact`, `color`.

Foto wajah:
```bash
pip install pillow
python tools/pixelate.py foto_asli_budi.jpg assets/photos/member1.png
```
Script ini sudah mem-pixelate foto, jadi **foto asli tidak perlu masuk ke GitHub**
(simpan di `assets/photos/raw/`, folder itu sudah di-ignore). Game juga mem-pixelate
lagi saat runtime sebagai pengaman.

## Struktur & pemilik file
| File | Isi | Pemilik |
|---|---|---|
| `scripts/player.gd` | gerak & gambar karakter | Programmer |
| `scripts/main.gd` | alur game, state, gerbang | Programmer |
| `scripts/info_popup.gd` | kartu info anggota | Programmer / Artist |
| `scripts/photo_util.gd`, `tools/pixelate.py` | efek pixel foto | Artist |
| `assets/photos/*`, warna di `team.json` | aset visual | Artist |
| `scripts/member_stand.gd`, layout di `main.gd` (`ROOM`, posisi podium) | desain level | Project + Level |
| `data/team.json`, `README.md`, Trello | data & manajemen | Project + Level |

## Alur kolaborasi GitHub
1. **Project + Level** membuat repo, push commit awal, invite 2 anggota lain sebagai collaborator.
2. Tiap anggota: `git clone <url>` → `git checkout -b <nama-fitur>`.
3. Kerja → `git add . && git commit -m "feat: ..."` → `git push -u origin <nama-fitur>`.
4. Buka **Pull Request** di GitHub → anggota lain review → **Merge**.
5. Yang lain: `git checkout main && git pull`.

Contoh branch & commit:
- Programmer: `feature/player-movement` → "feat: gerak player WASD", `feature/popup` → "feat: kartu info anggota"
- Artist: `feature/pixel-photos` → "art: foto pixel 3 anggota", "art: palet warna podium"
- Project + Level: `feature/level-layout` → "level: layout ruangan & gerbang", "docs: README"

## Board Trello
Kolom: **To Do → In Progress → Review → Done**

| Kartu | Anggota |
|---|---|
| Setup repo GitHub + project Godot | Project + Level |
| Gerak player (WASD) | Programmer |
| Sistem interaksi podium (tombol E) | Programmer |
| Popup kartu anggota | Programmer |
| Pixelate foto wajah 3 anggota | Artist |
| Palet warna & tampilan podium | Artist |
| Layout ruangan + gerbang keluar | Project + Level |
| Isi data team.json (Nama, NIM) | Project + Level |
| Testing & bug fix | Semua |
| Rekam & edit video demo | Semua |

Tempel link PR GitHub di kartu yang bersangkutan supaya Trello & GitHub terlihat terhubung.

## Naskah video demo (target ±17 menit)
| Menit | Isi | Layar |
|---|---|---|
| 0:00–1:30 | Pembukaan: nama tim, anggota, peran, ide game | Wajah/slide + title screen game |
| 1:30–3:30 | Board Trello: kolom, kartu, siapa pegang apa | Trello |
| 3:30–5:30 | Setup repo GitHub, invite collaborator, struktur folder | GitHub + Godot |
| 5:30–9:00 | **Programmer**: buka `player.gd` & `main.gd`, jelaskan, commit, push, buat PR, geser kartu Trello | Godot → terminal → GitHub → Trello |
| 9:00–12:00 | **Artist**: jalankan `pixelate.py`, ganti foto, ubah warna, commit, PR, geser kartu | Terminal → Godot → GitHub → Trello |
| 12:00–14:30 | **Project + Level**: atur posisi podium/ruangan, isi `team.json`, review & merge PR teman | Godot → GitHub → Trello |
| 14:30–16:30 | **Demo game** penuh: title → temui 3 anggota → gerbang terbuka → ending | Game (F5) |
| 16:30–17:30 | Penutup: tampilkan history commit/Insights GitHub + board Trello yang semua kartunya Done | GitHub + Trello |

Tips rekam: tiap anggota merekam layarnya sendiri (OBS / QuickTime) saat mengerjakan
bagiannya, lalu digabung. Sebut nama di awal tiap segmen ("Saya X, bagian programmer…").
