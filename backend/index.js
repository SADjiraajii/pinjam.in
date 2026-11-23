require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

// 1) GET /api/products -> daftar semua barang aktif
app.get('/api/products', async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM produk WHERE status_produk = 'aktif'");
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// 2) GET /api/cart/:idUser -> isi keranjang satu pengguna
app.get('/api/cart/:idUser', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT dk.id_detail_keranjang, dk.id_produk, dk.jumlah,
              dk.tanggal_mulai, dk.tanggal_selesai, p.nama_produk, p.harga_per_hari
       FROM detail_keranjang dk
       JOIN keranjang k ON k.id_keranjang = dk.id_keranjang
       JOIN produk p ON p.id_produk = dk.id_produk
       WHERE k.id_user = ?`, [req.params.idUser]);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// 3) POST /api/cart -> tambah barang ke keranjang
app.post('/api/cart', async (req, res) => {
  try {
    const { id_keranjang, id_produk, jumlah, tanggal_mulai, tanggal_selesai } = req.body;
    await db.query(
      `INSERT INTO detail_keranjang (id_keranjang, id_produk, jumlah, tanggal_mulai, tanggal_selesai)
       VALUES (?, ?, ?, ?, ?)`,
      [id_keranjang, id_produk, jumlah, tanggal_mulai, tanggal_selesai]);
    res.status(201).json({ message: 'Item ditambahkan ke keranjang' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// 4) DELETE /api/cart/:id -> hapus satu item keranjang
app.delete('/api/cart/:id', async (req, res) => {
  try {
    await db.query('DELETE FROM detail_keranjang WHERE id_detail_keranjang = ?', [req.params.id]);
    res.json({ message: 'Item dihapus' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.listen(process.env.PORT || 3000, () =>
  console.log('API berjalan di http://localhost:' + (process.env.PORT || 3000)));