-- =====================================================
-- Database  : pinjam_in
-- Aplikasi  : pinjam.in (Penyewaan Barang Kebutuhan Berbasis Online)
-- Kelompok  : 5
-- Target    : MySQL / MariaDB (phpMyAdmin)
-- =====================================================

CREATE DATABASE IF NOT EXISTS `pinjam_in`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `pinjam_in`;

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------
-- 1. users
-- -----------------------------------------------------
CREATE TABLE `users` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `nama_lengkap` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL COMMENT 'disimpan dalam bentuk hash',
  `role` enum('penyewa','admin','mitra','kurir') NOT NULL DEFAULT 'penyewa',
  `tipe_penyewa` enum('mahasiswa','organisasi_kampus','panitia_acara','komunitas','umum') DEFAULT NULL,
  `status_verifikasi` enum('belum','menunggu','disetujui','ditolak') NOT NULL DEFAULT 'belum',
  `foto_profil` varchar(200) DEFAULT NULL,
  `status_akun` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 2. alamat
-- -----------------------------------------------------
CREATE TABLE `alamat` (
  `id_alamat` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `nama_penerima` varchar(100) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `alamat_lengkap` text NOT NULL,
  `kota` varchar(100) DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_utama` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_alamat`),
  KEY `idx_alamat_user` (`id_user`),
  CONSTRAINT `fk_alamat_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 3. verifikasi_identitas
-- -----------------------------------------------------
CREATE TABLE `verifikasi_identitas` (
  `id_verifikasi` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `jenis_identitas` enum('KTP','KTM') NOT NULL,
  `nomor_identitas` varchar(50) NOT NULL,
  `foto_identitas` varchar(200) NOT NULL,
  `foto_selfie` varchar(200) NOT NULL,
  `status` enum('menunggu','disetujui','ditolak') NOT NULL DEFAULT 'menunggu',
  `catatan` text DEFAULT NULL,
  `id_admin` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `verified_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_verifikasi`),
  KEY `idx_verif_user` (`id_user`),
  KEY `idx_verif_admin` (`id_admin`),
  CONSTRAINT `fk_verif_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_verif_admin` FOREIGN KEY (`id_admin`) REFERENCES `users` (`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 4. kategori
-- -----------------------------------------------------
CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL AUTO_INCREMENT,
  `nama_kategori` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `ikon` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id_kategori`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 5. produk
-- -----------------------------------------------------
CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL AUTO_INCREMENT,
  `id_kategori` int(11) NOT NULL,
  `id_pemilik` int(11) DEFAULT NULL COMMENT 'mitra pemilik; NULL = milik pusat layanan',
  `nama_produk` varchar(300) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `harga_per_hari` decimal(12,2) NOT NULL DEFAULT 0.00,
  `harga_per_jam` decimal(12,2) DEFAULT NULL,
  `nilai_deposit` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stok` int(11) NOT NULL DEFAULT 0,
  `foto_produk` varchar(200) DEFAULT NULL,
  `rating` decimal(2,1) NOT NULL DEFAULT 0.0,
  `terlaris` tinyint(4) NOT NULL DEFAULT 0,
  `status_produk` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_produk`),
  KEY `idx_produk_kategori` (`id_kategori`),
  KEY `idx_produk_pemilik` (`id_pemilik`),
  CONSTRAINT `fk_produk_kategori` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`),
  CONSTRAINT `fk_produk_pemilik` FOREIGN KEY (`id_pemilik`) REFERENCES `users` (`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 6. paket_sewa
-- -----------------------------------------------------
CREATE TABLE `paket_sewa` (
  `id_paket` int(11) NOT NULL AUTO_INCREMENT,
  `id_produk` int(11) NOT NULL,
  `nama_paket` varchar(100) NOT NULL,
  `durasi_hari` int(11) NOT NULL,
  `harga` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_paket`),
  KEY `idx_paket_produk` (`id_produk`),
  CONSTRAINT `fk_paket_produk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 7. wishlist
-- -----------------------------------------------------
CREATE TABLE `wishlist` (
  `id_wishlist` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_wishlist`),
  UNIQUE KEY `uq_wishlist` (`id_user`,`id_produk`),
  KEY `idx_wishlist_produk` (`id_produk`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_produk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 8. keranjang
-- -----------------------------------------------------
CREATE TABLE `keranjang` (
  `id_keranjang` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_keranjang`),
  UNIQUE KEY `uq_keranjang_user` (`id_user`),
  CONSTRAINT `fk_keranjang_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 9. detail_keranjang
-- -----------------------------------------------------
CREATE TABLE `detail_keranjang` (
  `id_detail_keranjang` int(11) NOT NULL AUTO_INCREMENT,
  `id_keranjang` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `id_paket` int(11) DEFAULT NULL,
  `jumlah` int(11) NOT NULL DEFAULT 1,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  PRIMARY KEY (`id_detail_keranjang`),
  KEY `idx_dk_keranjang` (`id_keranjang`),
  KEY `idx_dk_produk` (`id_produk`),
  KEY `idx_dk_paket` (`id_paket`),
  CONSTRAINT `fk_dk_keranjang` FOREIGN KEY (`id_keranjang`) REFERENCES `keranjang` (`id_keranjang`) ON DELETE CASCADE,
  CONSTRAINT `fk_dk_produk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`) ON DELETE CASCADE,
  CONSTRAINT `fk_dk_paket` FOREIGN KEY (`id_paket`) REFERENCES `paket_sewa` (`id_paket`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 10. pesanan
-- -----------------------------------------------------
CREATE TABLE `pesanan` (
  `id_pesanan` int(11) NOT NULL AUTO_INCREMENT,
  `kode_pesanan` varchar(30) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_alamat` int(11) DEFAULT NULL COMMENT 'NULL jika ambil sendiri',
  `tanggal_mulai` datetime NOT NULL,
  `tanggal_selesai` datetime NOT NULL,
  `metode_serah` enum('ambil_sendiri','diantar') NOT NULL DEFAULT 'ambil_sendiri',
  `jarak_km` decimal(6,2) DEFAULT NULL,
  `ongkir` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `deposit` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_bayar` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status_pesanan` enum('menunggu_pembayaran','dibayar','disiapkan','berlangsung','terlambat','dikembalikan','selesai','dibatalkan') NOT NULL DEFAULT 'menunggu_pembayaran',
  `batas_bayar` datetime DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pesanan`),
  UNIQUE KEY `uq_pesanan_kode` (`kode_pesanan`),
  KEY `idx_pesanan_user_status` (`id_user`,`status_pesanan`),
  KEY `idx_pesanan_tanggal` (`tanggal_mulai`,`tanggal_selesai`),
  KEY `idx_pesanan_alamat` (`id_alamat`),
  CONSTRAINT `fk_pesanan_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  CONSTRAINT `fk_pesanan_alamat` FOREIGN KEY (`id_alamat`) REFERENCES `alamat` (`id_alamat`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 11. detail_pesanan
-- -----------------------------------------------------
CREATE TABLE `detail_pesanan` (
  `id_detail_pesanan` int(11) NOT NULL AUTO_INCREMENT,
  `id_pesanan` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `id_paket` int(11) DEFAULT NULL,
  `nama_produk` varchar(300) NOT NULL COMMENT 'salinan nama saat order',
  `harga_satuan` decimal(12,2) NOT NULL COMMENT 'salinan harga saat order',
  `durasi` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL DEFAULT 1,
  `subtotal` decimal(12,2) NOT NULL,
  `foto_kondisi_serah` varchar(200) DEFAULT NULL,
  `foto_kondisi_kembali` varchar(200) DEFAULT NULL,
  `catatan_kondisi` text DEFAULT NULL,
  PRIMARY KEY (`id_detail_pesanan`),
  KEY `idx_dp_pesanan` (`id_pesanan`),
  KEY `idx_dp_produk` (`id_produk`),
  KEY `idx_dp_paket` (`id_paket`),
  CONSTRAINT `fk_dp_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE,
  CONSTRAINT `fk_dp_produk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`),
  CONSTRAINT `fk_dp_paket` FOREIGN KEY (`id_paket`) REFERENCES `paket_sewa` (`id_paket`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 12. pembayaran
-- -----------------------------------------------------
CREATE TABLE `pembayaran` (
  `id_pembayaran` int(11) NOT NULL AUTO_INCREMENT,
  `id_pesanan` int(11) NOT NULL,
  `metode` enum('transfer','e_wallet','qris') NOT NULL,
  `jumlah` decimal(12,2) NOT NULL,
  `status_pembayaran` enum('menunggu','berhasil','gagal','kedaluwarsa') NOT NULL DEFAULT 'menunggu',
  `bukti_bayar` varchar(200) DEFAULT NULL,
  `id_transaksi` varchar(100) DEFAULT NULL COMMENT 'referensi payment gateway',
  `tanggal_bayar` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pembayaran`),
  KEY `idx_bayar_pesanan` (`id_pesanan`,`status_pembayaran`),
  CONSTRAINT `fk_bayar_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 13. pengembalian
-- -----------------------------------------------------
CREATE TABLE `pengembalian` (
  `id_pengembalian` int(11) NOT NULL AUTO_INCREMENT,
  `id_pesanan` int(11) NOT NULL,
  `jatuh_tempo` datetime NOT NULL,
  `tanggal_kembali` datetime DEFAULT NULL,
  `terlambat_hari` int(11) NOT NULL DEFAULT 0,
  `denda_terlambat` decimal(12,2) NOT NULL DEFAULT 0.00,
  `denda_kerusakan` decimal(12,2) NOT NULL DEFAULT 0.00,
  `potongan_deposit` decimal(12,2) NOT NULL DEFAULT 0.00,
  `deposit_dikembalikan` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status_deposit` enum('ditahan','dikembalikan','dipotong') NOT NULL DEFAULT 'ditahan',
  `id_admin` int(11) DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  PRIMARY KEY (`id_pengembalian`),
  UNIQUE KEY `uq_kembali_pesanan` (`id_pesanan`),
  KEY `idx_kembali_admin` (`id_admin`),
  CONSTRAINT `fk_kembali_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE,
  CONSTRAINT `fk_kembali_admin` FOREIGN KEY (`id_admin`) REFERENCES `users` (`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 14. ulasan
-- -----------------------------------------------------
CREATE TABLE `ulasan` (
  `id_ulasan` int(11) NOT NULL AUTO_INCREMENT,
  `id_pesanan` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `komentar` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_ulasan`),
  UNIQUE KEY `uq_ulasan` (`id_pesanan`,`id_produk`),
  KEY `idx_ulasan_produk` (`id_produk`),
  KEY `idx_ulasan_user` (`id_user`),
  CONSTRAINT `fk_ulasan_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE,
  CONSTRAINT `fk_ulasan_produk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`) ON DELETE CASCADE,
  CONSTRAINT `fk_ulasan_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 15. notifikasi
-- -----------------------------------------------------
CREATE TABLE `notifikasi` (
  `id_notifikasi` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `id_pesanan` int(11) DEFAULT NULL,
  `judul` varchar(150) NOT NULL,
  `isi` text NOT NULL,
  `kanal` enum('push','whatsapp','in_app') NOT NULL DEFAULT 'in_app',
  `is_dibaca` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notifikasi`),
  KEY `idx_notif_user` (`id_user`,`is_dibaca`),
  KEY `idx_notif_pesanan` (`id_pesanan`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_notif_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------
-- 16. pengaturan
-- -----------------------------------------------------
CREATE TABLE `pengaturan` (
  `id_pengaturan` int(11) NOT NULL AUTO_INCREMENT,
  `nama_pengaturan` varchar(100) NOT NULL,
  `nilai` varchar(255) NOT NULL,
  `keterangan` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id_pengaturan`),
  UNIQUE KEY `uq_nama_pengaturan` (`nama_pengaturan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- DATA AWAL
-- =====================================================

INSERT INTO `kategori` (`nama_kategori`, `deskripsi`) VALUES
('Elektronik & Presentasi', 'Proyektor, layar proyektor, laptop, pointer/clicker'),
('Fotografi & Videografi', 'Kamera, tripod, lighting, gimbal'),
('Audio', 'Speaker, sound system, mikrofon, mixer'),
('Outdoor & Camping', 'Tenda camping, sleeping bag, kompor portable, carrier'),
('Perlengkapan Acara', 'Meja, kursi, tenda acara, backdrop & dekorasi');

-- Koordinat pusat layanan: GANTI sesuai lokasi sebenarnya
INSERT INTO `pengaturan` (`nama_pengaturan`, `nilai`, `keterangan`) VALUES
('pusat_latitude', '-3.3194374', 'Latitude pusat layanan (contoh, ganti sesuai lokasi)'),
('pusat_longitude', '114.5902778', 'Longitude pusat layanan (contoh, ganti sesuai lokasi)'),
('radius_gratis_km', '1', 'Antar gratis sampai jarak ini (km)'),
('ongkir_per_km', '3000', 'Ongkir per km di luar radius gratis (Rp)'),
('denda_telat_persen', '10', 'Denda per hari terlambat (% dari harga sewa harian)'),
('batas_bayar_jam', '24', 'Batas waktu pembayaran (jam)'),
('pengingat_jam_sebelum', '3', 'Pengingat pengembalian sebelum jatuh tempo (jam)');
