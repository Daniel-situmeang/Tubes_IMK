-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 20 Des 2020 pada 18.31
-- Versi server: 10.4.11-MariaDB
-- Versi PHP: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `9transaction`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_detail_penjualan_master` (IN `id_pm` MEDIUMINT(1))  NO SQL
SELECT 
				a.`nomor_nota`, 
				a.`grand_total`,
				a.`tanggal`,
				a.`bayar`,
				a.`id_user` AS id_kasir,
				a.`id_pelanggan`,
				a.`keterangan_lain` AS catatan,
				b.`nama` AS nama_pelanggan,
				b.`alamat` AS alamat_pelanggan,
				b.`telp` AS telp_pelanggan,
				b.`info_tambahan` AS info_pelanggan 
			FROM 
				`pj_penjualan_master` AS a 
				LEFT JOIN `pj_pelanggan` AS b ON a.`id_pelanggan` = b.`id_pelanggan` 
			WHERE 
				a.`id_penjualan_m` = id_pm 
			LIMIT 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_detail_transaksi` (IN `id_pm` MEDIUMINT(1))  NO SQL
SELECT 
				b.`id_barang`,  
				b.`nama_barang`, 
				CONCAT('Rp. ', REPLACE(FORMAT(a.`harga_satuan`, 0),',','.') ) AS harga_satuan, 
				a.`harga_satuan` AS harga_satuan_asli, 
				a.`jumlah_beli`,
				CONCAT('Rp. ', REPLACE(FORMAT(a.`total`, 0),',','.') ) AS sub_total,
				a.`total` AS sub_total_asli  
			FROM 
				`pj_penjualan_detail` a 
				LEFT JOIN `pj_barang` b ON a.`id_barang` = b.`id_barang` 
			WHERE 
				a.`id_penjualan_m` = id_pm 
			ORDER BY 
				a.`id_penjualan_d` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `laporan_keuntungan` (IN `awal` DATETIME, IN `akhir` DATETIME)  NO SQL
SELECT 
				DISTINCT(SUBSTR(a.`tanggal`, 1, 10)) AS tanggal,
				(
					f_untung(a.`tanggal`)  
				) AS total_keuntungan 
			FROM 
				`pj_penjualan_master` AS a 
			WHERE 
				SUBSTR(a.`tanggal`, 1, 10) >= awal 
				AND SUBSTR(a.`tanggal`, 1, 10) <= akhir 
			ORDER BY 
				a.`tanggal` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `laporan_penjualan` (IN `awal` DATETIME, IN `akhir` DATETIME)  NO SQL
SELECT 
				DISTINCT(SUBSTR(a.`tanggal`, 1, 10)) AS tanggal,
				(
					f_total_penghasilan(a.`tanggal`)
				) AS total_penjualan 
			FROM 
				`pj_penjualan_master` AS a 
			WHERE 
				SUBSTR(a.`tanggal`, 1, 10) >= awal 
				AND SUBSTR(a.`tanggal`, 1, 10) <= akhir 
			ORDER BY 
				a.`tanggal` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_hapus_pj_barang` (IN `idb` VARCHAR(11))  NO SQL
DELETE FROM `pj_barang` WHERE id_barang = idb$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_hapus_pj_kategori` (IN `id_pkb` MEDIUMINT(1))  NO SQL
DELETE FROM `pj_kategori_barang` WHERE id_user = id_pkb$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_hapus_pj_user` (IN `idpu` MEDIUMINT(1))  NO SQL
DELETE FROM `pj_user` WHERE id_user = idpu$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_jumlah_barang` ()  BEGIN
DECLARE jumlah_barang INT;
SELECT COUNT(*) AS jumlah_barang FROM pj_barang;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_jumlah_kategori` ()  BEGIN
DECLARE jumlah_kategori INT;
SELECT COUNT(*) AS jumlah_kategori FROM pj_kategori_barang;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_jumlah_pelanggan` ()  BEGIN
DECLARE jumlah_pelanggan INT;
SELECT COUNT(*) AS jumlah_pelanggan FROM pj_pelanggan;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_tambah_pj_barang` (IN `nama` VARCHAR(60), IN `total` MEDIUMINT(1), IN `hrg` DECIMAL(10), IN `ikb` MEDIUMINT(1), IN `imb` MEDIUMINT(1), IN `mdl` DECIMAL(10))  NO SQL
INSERT INTO pj_barang(nama_barang, total_stok, harga, id_kategori_barang, id_ukuran, modal) VALUES (nama, total, hrg, ikb, imb, mdl)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_tambah_pj_kategori` (IN `cate` VARCHAR(40))  NO SQL
INSERT INTO `pj_kategori_barang`(`kategori`) VALUES (cate)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_tambah_pj_user` (IN `user` VARCHAR(40), IN `pass` VARCHAR(60), IN `name` VARCHAR(50), IN `akses` TINYINT(1), IN `state` ENUM('Aktif','Non Aktif'))  NO SQL
INSERT INTO pj_user (username, password, nama, id_akses, status) VALUES (user, pass, name, akses, state)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_update_pj_barang` (IN `idb` VARCHAR(11), IN `nama` VARCHAR(60), IN `total` MEDIUMINT(1), IN `hrg` DECIMAL(10), IN `ikb` MEDIUMINT(1), IN `imb` MEDIUMINT(1), IN `mdl` DECIMAL(10))  NO SQL
UPDATE `pj_barang` SET `nama_barang`= nama, `total_stok`= total, `harga`= hrg, `id_kategori_barang`=ikb, `id_ukuran`=imb, `modal`= mdl WHERE `id_barang` = idb$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_update_pj_user` (IN `idpu` MEDIUMINT(1), IN `user` VARCHAR(40), IN `pass` VARCHAR(60), IN `name` VARCHAR(50), IN `ida` TINYINT(1), IN `state` ENUM('Aktif','Non Aktif'))  NO SQL
UPDATE `pj_user` SET `username` = user, `password` = pass, `nama` = name, `id_akses` = ida, `status_user` = state WHERE `id_user`= idpu$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_cek_status_pelanggan` (`state` ENUM('aktif','non aktif')) RETURNS INT(11) BEGIN

DECLARE total_pelanggan integer;
SELECT COUNT(*) into total_pelanggan from pj_pelanggan where state = status_anggota;

RETURN total_pelanggan;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_jumlah_penjualan` (`awal` DATE, `akhir` DATE) RETURNS INT(11) NO SQL
BEGIN

DECLARE hasil INTEGER;

SELECT COUNT(*) INTO hasil FROM `pj_penjualan_master`WHERE tanggal >= awal and tanggal <= akhir;

RETURN hasil;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_total_penghasilan` (`tgl` DATE) RETURNS DECIMAL(11,0) NO SQL
BEGIN
DECLARE total_penghasilan integer;
					SELECT 
						SUM(b.`grand_total`) into total_penghasilan
					FROM 
						`pj_penjualan_master` AS b 
					WHERE 
						SUBSTR(b.`tanggal`, 1, 10) = SUBSTR(tgl, 1, 10) 
					LIMIT 1;
RETURN total_penghasilan;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_untung` (`tgl` DATE) RETURNS DECIMAL(10,0) NO SQL
BEGIN
DECLARE total_penghasilan integer;
					SELECT 
						SUM(b.`grand_total` - b.`grand_modal`) into total_penghasilan
					FROM 
						`pj_penjualan_master` AS b 
					WHERE 
						SUBSTR(b.`tanggal`, 1, 10) = SUBSTR(tgl, 1, 10) 
					LIMIT 1;
RETURN total_penghasilan;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_login`
--

CREATE TABLE `log_login` (
  `id` int(10) NOT NULL,
  `username` varchar(40) NOT NULL,
  `datetime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_pj_barang`
--

CREATE TABLE `log_pj_barang` (
  `id_lpb` int(11) NOT NULL,
  `id_barang` varchar(40) NOT NULL,
  `nama_barang` varchar(60) NOT NULL,
  `total_stok` int(10) NOT NULL,
  `modal` int(10) NOT NULL,
  `harga` decimal(10,0) NOT NULL,
  `id_kategori_barang` mediumint(1) NOT NULL,
  `id_ukuran` mediumint(1) NOT NULL,
  `status` varchar(6) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `log_pj_barang`
--

INSERT INTO `log_pj_barang` (`id_lpb`, `id_barang`, `nama_barang`, `total_stok`, `modal`, `harga`, `id_kategori_barang`, `id_ukuran`, `status`, `tanggal`) VALUES
(108, '1', 'anjay', 2, 3000, '4000', 33, 1, 'INSERT', '2020-12-11 23:51:43'),
(109, '1', 'anjay', 2, 3000, '4000', 33, 1, 'UPDATE', '2020-12-11 23:59:45'),
(110, '1', 'anjaykan', 2, 3000, '4000', 33, 1, 'UPDATE', '2020-12-12 00:00:15'),
(111, '1', 'anjaykan', 2, 3000, '4000', 33, 1, 'UPDATE', '2020-12-12 00:38:12'),
(112, '2', 'contoh1', 2, 3000, '4000', 34, 2, 'INSERT', '2020-12-13 11:15:17'),
(113, '3', 'contoh2', 2, 20000, '10000', 34, 2, 'INSERT', '2020-12-13 11:15:17'),
(114, '3', 'contoh2', 2, 20000, '10000', 34, 2, 'UPDATE', '2020-12-15 22:14:07'),
(115, '2', 'contoh1', 0, 3000, '4000', 34, 2, 'DELETE', '2020-12-19 01:14:09'),
(116, '4', 'coba', 2, 1000, '1000', 33, 1, 'UPDATE', '2020-12-19 12:51:56'),
(117, '4', 'coba', 2, 3000, '1000', 33, 1, 'UPDATE', '2020-12-19 12:52:29'),
(118, '4', 'coba', 2, 1000, '1000', 33, 1, 'UPDATE', '2020-12-19 12:52:50'),
(119, '3', 'contoh2', 2, 20000, '10000', 34, 2, 'UPDATE', '2020-12-20 16:56:35'),
(120, '3', 'contoh2', 1, 20000, '10000', 34, 2, 'UPDATE', '2020-12-20 16:57:34'),
(121, '3', 'contoh2', 0, 20000, '10000', 34, 2, 'DELETE', '2020-12-20 18:48:16'),
(122, '5', 'anjaykankau', 0, 3000, '4000', 35, 3, 'DELETE', '2020-12-20 18:48:28'),
(123, '6', 'coba', 0, 20000, '50000', 34, 2, 'DELETE', '2020-12-20 18:53:14'),
(124, '7', 'coba', 20, 3000, '4000', 36, 2, 'UPDATE', '2020-12-20 18:59:40'),
(125, '7', 'coba', 30, 3000, '4000', 36, 2, 'UPDATE', '2020-12-20 19:00:14'),
(126, '4', 'coba', 2, 1000, '2000', 33, 1, 'UPDATE', '2020-12-20 19:01:27'),
(127, '4', 'coba', 3, 1000, '2000', 33, 1, 'UPDATE', '2020-12-20 19:04:13'),
(128, '7', 'coba', 0, 3000, '4000', 36, 2, 'DELETE', '2020-12-20 19:04:53'),
(129, '4', 'coba', 4, 1000, '2000', 33, 1, 'UPDATE', '2020-12-20 19:05:34'),
(130, '4', 'coba', 5, 1000, '2000', 33, 1, 'UPDATE', '2020-12-20 19:08:09'),
(131, '4', 'coba', 5, 1000, '2000', 33, 2, 'UPDATE', '2020-12-20 19:08:25'),
(132, '4', 'coba', 4, 1000, '2000', 33, 2, 'UPDATE', '2020-12-20 19:10:19'),
(133, '4', 'coba', 5, 1000, '2000', 33, 2, 'UPDATE', '2020-12-20 19:10:36'),
(134, '4', 'coba', 6, 1000, '2000', 33, 2, 'UPDATE', '2020-12-20 19:11:15'),
(135, '4', 'coba', 0, 1000, '2000', 33, 2, 'DELETE', '2020-12-20 19:11:43'),
(136, '1', 'anjaykan', 1, 3000, '4000', 33, 1, 'UPDATE', '2020-12-20 19:16:07'),
(137, '1', 'anjaykan', 3, 3000, '4000', 33, 1, 'UPDATE', '2020-12-20 19:16:20');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_pj_kategori_barang`
--

CREATE TABLE `log_pj_kategori_barang` (
  `id_lpkb` int(11) NOT NULL,
  `id_kategori_barang` mediumint(1) NOT NULL,
  `kategori` varchar(40) NOT NULL,
  `id_varian` int(2) DEFAULT NULL,
  `status` varchar(6) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `log_pj_kategori_barang`
--

INSERT INTO `log_pj_kategori_barang` (`id_lpkb`, `id_kategori_barang`, `kategori`, `id_varian`, `status`, `tanggal`) VALUES
(75, 34, 'anjay', NULL, 'UPDATE', '2020-12-13 13:18:31'),
(76, 34, 'baru', NULL, 'UPDATE', '2020-12-13 13:18:38'),
(77, 34, 'baru', NULL, 'UPDATE', '2020-12-13 13:18:47'),
(78, 34, 'baru', NULL, 'UPDATE', '2020-12-13 13:19:00'),
(79, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:19:03'),
(80, 33, 'lain', NULL, 'UPDATE', '2020-12-13 13:29:16'),
(81, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:31:00'),
(82, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:33:57'),
(83, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:35:23'),
(84, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:37:59'),
(85, 34, 'bar', NULL, 'UPDATE', '2020-12-13 13:38:11'),
(86, 34, 'bara', NULL, 'UPDATE', '2020-12-13 13:48:41'),
(87, 33, 'lainnya', NULL, 'UPDATE', '2020-12-13 13:59:31'),
(88, 35, 'contoh', NULL, 'INSERT', '2020-12-19 12:54:26'),
(89, 36, 'bar', NULL, 'INSERT', '2020-12-19 12:57:00'),
(90, 37, 'baru', NULL, 'INSERT', '2020-12-19 12:59:20'),
(91, 38, 'baru', NULL, 'INSERT', '2020-12-19 12:59:21'),
(92, 39, 'baru', NULL, 'INSERT', '2020-12-19 12:59:22'),
(93, 40, 'baru', NULL, 'INSERT', '2020-12-19 12:59:22'),
(94, 41, 'baru', NULL, 'INSERT', '2020-12-19 12:59:22'),
(95, 42, 'baru', NULL, 'INSERT', '2020-12-19 13:00:48'),
(96, 43, 'baru', NULL, 'INSERT', '2020-12-19 13:00:50'),
(97, 44, 'baru', NULL, 'INSERT', '2020-12-19 13:00:50'),
(98, 45, 'baru', NULL, 'INSERT', '2020-12-19 13:00:50'),
(99, 46, 'baru', NULL, 'INSERT', '2020-12-19 13:00:51'),
(100, 47, 'baru', NULL, 'INSERT', '2020-12-19 13:00:51'),
(101, 47, 'baru', NULL, 'DELETE', '2020-12-19 13:01:08'),
(102, 46, 'baru', NULL, 'DELETE', '2020-12-19 13:01:10'),
(103, 45, 'baru', NULL, 'DELETE', '2020-12-19 13:01:14'),
(104, 44, 'baru', NULL, 'DELETE', '2020-12-19 13:01:16'),
(105, 43, 'baru', NULL, 'DELETE', '2020-12-19 13:01:18'),
(106, 42, 'baru', NULL, 'DELETE', '2020-12-19 13:01:20'),
(107, 41, 'baru', NULL, 'DELETE', '2020-12-19 13:01:21'),
(108, 40, 'baru', NULL, 'DELETE', '2020-12-19 13:01:23'),
(109, 39, 'baru', NULL, 'DELETE', '2020-12-19 13:01:25'),
(110, 38, 'baru', NULL, 'DELETE', '2020-12-19 13:01:27'),
(111, 37, 'baru', NULL, 'DELETE', '2020-12-20 18:53:05'),
(112, 36, 'bar', NULL, 'UPDATE', '2020-12-20 19:16:35'),
(113, 36, 'baru', NULL, 'UPDATE', '2020-12-20 19:19:12'),
(114, 36, 'barus', NULL, 'UPDATE', '2020-12-20 19:19:13'),
(115, 36, 'barus', NULL, 'UPDATE', '2020-12-20 19:19:53'),
(116, 48, 'lainnya', NULL, 'INSERT', '2020-12-20 19:29:21'),
(117, 49, 'lainnya', NULL, 'INSERT', '2020-12-20 19:29:37'),
(118, 50, 'coba', NULL, 'INSERT', '2020-12-20 19:30:39'),
(119, 50, 'coba', NULL, 'DELETE', '2020-12-20 19:32:58'),
(120, 49, 'lainnya', NULL, 'DELETE', '2020-12-20 19:33:02'),
(121, 48, 'lainnya', NULL, 'DELETE', '2020-12-20 19:33:38'),
(122, 36, 'barus', NULL, 'DELETE', '2020-12-20 19:34:16'),
(123, 35, 'contoh', NULL, 'DELETE', '2020-12-20 19:34:36'),
(124, 34, 'bara', NULL, 'DELETE', '2020-12-20 19:34:58'),
(125, 33, 'lainnya', NULL, 'DELETE', '2020-12-20 19:35:55'),
(126, 51, 'lainnya', NULL, 'INSERT', '2020-12-20 19:44:37'),
(127, 32, 'Pakan', NULL, 'DELETE', '2020-12-20 19:46:27'),
(128, 51, 'lainnya', NULL, 'DELETE', '2020-12-20 19:46:29'),
(129, 52, 'BatangL', NULL, 'INSERT', '2020-12-20 20:22:21'),
(130, 52, 'BatangL', NULL, 'UPDATE', '2020-12-20 21:04:15'),
(131, 52, 'BatangL', NULL, 'DELETE', '2020-12-20 21:04:19'),
(132, 53, 'BatangL', NULL, 'INSERT', '2020-12-20 21:04:40'),
(133, 53, 'BatangL', NULL, 'UPDATE', '2020-12-20 21:04:44'),
(134, 53, 'BatangL', NULL, 'DELETE', '2020-12-20 21:04:49'),
(135, 54, 'sasadasd', NULL, 'INSERT', '2020-12-20 21:11:04'),
(136, 54, 'sasadasd', NULL, 'UPDATE', '2020-12-20 21:11:08'),
(137, 54, 'sasadasd', NULL, 'UPDATE', '2020-12-20 21:11:13'),
(138, 54, 'sasadasd', NULL, 'DELETE', '2020-12-20 21:11:16'),
(139, 55, 'PackL', NULL, 'INSERT', '2020-12-21 00:20:34'),
(140, 56, 'CairL', NULL, 'INSERT', '2020-12-21 00:20:48'),
(141, 57, 'BatangL', NULL, 'INSERT', '2020-12-21 00:20:53'),
(142, 58, 'PackOrange', NULL, 'INSERT', '2020-12-21 00:21:03'),
(143, 59, 'CairOrange', NULL, 'INSERT', '2020-12-21 00:21:13'),
(144, 60, 'BatangOrange', NULL, 'INSERT', '2020-12-21 00:21:37');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_pj_pelanggan`
--

CREATE TABLE `log_pj_pelanggan` (
  `id_lpp` int(11) NOT NULL,
  `id_pelanggan` mediumint(1) NOT NULL,
  `nama` varchar(40) NOT NULL,
  `alamat` text NOT NULL,
  `telp` varchar(40) NOT NULL,
  `status_anggota` enum('Aktif','Non Aktif') NOT NULL,
  `status` varchar(6) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `log_pj_pelanggan`
--

INSERT INTO `log_pj_pelanggan` (`id_lpp`, `id_pelanggan`, `nama`, `alamat`, `telp`, `status_anggota`, `status`, `tanggal`) VALUES
(42, 6, 'daniel', 'saf', '24', 'Aktif', 'DELETE', '2020-12-20 18:14:45'),
(43, 5, 'keling3', 'dsfahbafjd', '1341353', 'Aktif', 'DELETE', '2020-12-20 18:16:02'),
(44, 4, 'gsdhsgidn', 'adfjafd', '38483923', 'Aktif', 'DELETE', '2020-12-20 18:37:42'),
(45, 3, 'geyling', 'tasbih', '2467419419', 'Aktif', 'DELETE', '2020-12-20 18:49:00'),
(46, 2, 'bayu', 'jln konoha', '1311314797', 'Aktif', 'DELETE', '2020-12-20 18:50:30'),
(47, 1, 'bayu', 'jln konoha', '1311314797', 'Aktif', 'DELETE', '2020-12-20 18:51:56'),
(48, 19, 'Daniel Situmeang', 'SDAFASD', '3424242324', 'Aktif', 'DELETE', '2020-12-20 22:59:54'),
(49, 18, 'gfgfhfghfh', 'fhfhgfhf', 'hfghfhfh', 'Aktif', 'DELETE', '2020-12-20 23:00:07'),
(50, 17, 'dsfsfsdf', 'dsfsdfsdf', 'sdfsdf', 'Aktif', 'DELETE', '2020-12-20 23:00:18'),
(51, 16, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:08'),
(52, 15, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:13'),
(53, 14, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:17'),
(54, 13, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:24'),
(55, 12, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:28'),
(56, 11, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:33'),
(57, 10, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:37'),
(58, 9, 'fvvfdvd', 'fvdfvdfvdv', 'dvdvdvfdv', 'Aktif', 'DELETE', '2020-12-20 23:11:40'),
(59, 8, 'dsdad', 'asdad', 'asadad', 'Aktif', 'DELETE', '2020-12-20 23:11:45'),
(60, 7, 'anggu', 'afdga', '082295234849', 'Aktif', 'DELETE', '2020-12-20 23:11:50');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_pj_user`
--

CREATE TABLE `log_pj_user` (
  `id_lpu` int(11) NOT NULL,
  `id_user` varchar(40) NOT NULL,
  `username` varchar(40) NOT NULL,
  `nama` varchar(50) NOT NULL,
  `id_akses` tinyint(1) NOT NULL,
  `status_user` enum('Aktif','Non Aktif') NOT NULL,
  `status` varchar(6) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `log_pj_user`
--

INSERT INTO `log_pj_user` (`id_lpu`, `id_user`, `username`, `nama`, `id_akses`, `status_user`, `status`, `tanggal`) VALUES
(9, '10', 'bayu', 'uzumaki bayu', 2, 'Aktif', 'DELETE', '2020-12-21 00:07:52');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_akses`
--

CREATE TABLE `pj_akses` (
  `id_akses` tinyint(1) UNSIGNED NOT NULL,
  `label` varchar(10) NOT NULL,
  `level_akses` varchar(15) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_akses`
--

INSERT INTO `pj_akses` (`id_akses`, `label`, `level_akses`) VALUES
(1, 'admin', 'Administrator'),
(2, 'kasir', 'Staff Kasir'),
(3, 'inventory', 'Staff Inventory'),
(4, 'keuangan', 'Staff Keuangan');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_barang`
--

CREATE TABLE `pj_barang` (
  `id_barang` int(10) NOT NULL,
  `nama_barang` varchar(60) NOT NULL,
  `total_stok` mediumint(1) UNSIGNED NOT NULL,
  `modal` decimal(10,0) NOT NULL,
  `harga` decimal(10,0) NOT NULL,
  `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL,
  `id_ukuran` mediumint(1) NOT NULL,
  `qrcode` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_barang`
--

INSERT INTO `pj_barang` (`id_barang`, `nama_barang`, `total_stok`, `modal`, `harga`, `id_kategori_barang`, `id_ukuran`, `qrcode`) VALUES
(1, 'anjaykan', 4, '3000', '4000', 33, 1, 'http://localhost/Tubes_IMK/assets/temp/testb4f97cbde0ecda8da0b2fa7c18ea329c.png');

--
-- Trigger `pj_barang`
--
DELIMITER $$
CREATE TRIGGER `t_delete_pj_barang` BEFORE DELETE ON `pj_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_barang
SET id_barang = old.id_barang,
nama_barang = old.nama_barang,
modal = old.modal,
harga = old.harga,
id_kategori_barang = old.id_kategori_barang,
id_ukuran = old.id_ukuran,
status = 'DELETE',
tanggal = NOW();

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_update_pj_barang` BEFORE UPDATE ON `pj_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_barang
SET id_barang = new.id_barang,
nama_barang = old.nama_barang,
total_stok = old.total_stok,
modal = old.modal,
harga = old.harga,
id_kategori_barang = old.id_kategori_barang,
id_ukuran = old.id_ukuran,
status = 'UPDATE',
tanggal = NOW();

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_ci_sessions`
--

CREATE TABLE `pj_ci_sessions` (
  `id` varchar(40) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `data` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_ci_sessions`
--

INSERT INTO `pj_ci_sessions` (`id`, `ip_address`, `timestamp`, `data`) VALUES
('9ob2hrc37dqfploqunh788tpndcmdntn', '::1', 1608484072, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438343037323b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b666c6173687c733a32333a226d656e6768617075732064617461206b6172796177616e223b5f5f63695f766172737c613a313a7b733a353a22666c617368223b733a333a226e6577223b7d),
('8rjt3cfon17gv3f3frfe1a6lm6k31cle', '::1', 1608484521, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438343532313b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('u5bfcjnek916didf76mqso401eabans3', '::1', 1608484823, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438343832333b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('g4qagnav12vba0a35tdekculehf42g2c', '::1', 1608485465, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438353436353b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('kr4un7o8vs0ktplmn3h3m59o6k2pa4t8', '::1', 1608485477, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438353436343b),
('m9mrd2ml4nrsfkffu1m0d7305h6cajm4', '::1', 1608485487, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630383438353436353b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b);

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_kategori_barang`
--

CREATE TABLE `pj_kategori_barang` (
  `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL,
  `kategori` varchar(40) NOT NULL,
  `id_varian` int(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_kategori_barang`
--

INSERT INTO `pj_kategori_barang` (`id_kategori_barang`, `kategori`, `id_varian`) VALUES
(55, 'PackL', 1),
(56, 'CairL', 1),
(57, 'BatangL', 1),
(58, 'PackOrange', 2),
(59, 'CairOrange', 2),
(60, 'BatangOrange', 2);

--
-- Trigger `pj_kategori_barang`
--
DELIMITER $$
CREATE TRIGGER `t_delete_pj_kategori` BEFORE DELETE ON `pj_kategori_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_kategori_barang
SET id_kategori_barang = old.id_kategori_barang,
kategori = old.kategori,
status = 'DELETE',
tanggal = NOW();

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_insert_pj_kategori` AFTER INSERT ON `pj_kategori_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_kategori_barang
SET id_kategori_barang = new.id_kategori_barang,
kategori = new.kategori,
status = 'INSERT',
tanggal = NOW();

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_update_pj_kategori` BEFORE UPDATE ON `pj_kategori_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_kategori_barang
SET id_kategori_barang = new.id_kategori_barang,
kategori = old.kategori,
status = 'UPDATE',
tanggal = NOW();

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_kategori_ukuran`
--

CREATE TABLE `pj_kategori_ukuran` (
  `id_ukuran` int(2) NOT NULL,
  `ukuran` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_kategori_ukuran`
--

INSERT INTO `pj_kategori_ukuran` (`id_ukuran`, `ukuran`) VALUES
(1, '1 kg'),
(2, '1/2 kg'),
(3, '1/4 kg'),
(4, 'Eceran 2000'),
(5, 'Eceran 1000');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_kategori_varian`
--

CREATE TABLE `pj_kategori_varian` (
  `id_varian` int(2) NOT NULL,
  `nama_varian` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_kategori_varian`
--

INSERT INTO `pj_kategori_varian` (`id_varian`, `nama_varian`) VALUES
(1, 'Lavender'),
(2, 'Orange');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_pelanggan`
--

CREATE TABLE `pj_pelanggan` (
  `id_pelanggan` int(10) NOT NULL,
  `nama` varchar(40) NOT NULL,
  `alamat` text DEFAULT NULL,
  `telp` varchar(40) DEFAULT NULL,
  `info_tambahan` text DEFAULT NULL,
  `waktu_input` datetime NOT NULL,
  `status_anggota` enum('Aktif','Non Aktif') NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_pelanggan`
--

INSERT INTO `pj_pelanggan` (`id_pelanggan`, `nama`, `alamat`, `telp`, `info_tambahan`, `waktu_input`, `status_anggota`) VALUES
(20, 'Geylfedra', 'Medan', '081375513300', 'TI19', '2020-12-20 23:14:45', 'Aktif'),
(21, 'Daniel Situmeang', 'Medan', '08134854582', 'TI19', '2020-12-20 23:15:23', 'Aktif'),
(22, 'Anggi Yohanes Pardede', 'Medan', '08284234244', 'TI19', '2020-12-20 23:21:35', 'Aktif'),
(23, 'Muhammad Zikri Ihsan', 'Medan', '08135446567', 'TI19', '2020-12-20 23:29:27', 'Aktif'),
(24, 'Brillian Jonathan ', 'Medan', '081343823432', 'TI19', '2020-12-20 23:30:03', 'Aktif');

--
-- Trigger `pj_pelanggan`
--
DELIMITER $$
CREATE TRIGGER `t_delete_pj_pelanggan` BEFORE DELETE ON `pj_pelanggan` FOR EACH ROW BEGIN 
INSERT INTO log_pj_pelanggan
SET id_pelanggan = old.id_pelanggan,
nama = old.nama,
alamat = old.alamat,
telp = old.telp,
status_anggota = old.status_anggota,
status = 'DELETE',
tanggal = NOW();

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_penjualan_detail`
--

CREATE TABLE `pj_penjualan_detail` (
  `id_penjualan_d` int(1) UNSIGNED NOT NULL,
  `id_penjualan_m` int(1) UNSIGNED NOT NULL,
  `id_barang` varchar(10) NOT NULL,
  `jumlah_beli` smallint(1) UNSIGNED NOT NULL,
  `harga_satuan` decimal(10,0) NOT NULL,
  `total` decimal(10,0) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_penjualan_detail`
--

INSERT INTO `pj_penjualan_detail` (`id_penjualan_d`, `id_penjualan_m`, `id_barang`, `jumlah_beli`, `harga_satuan`, `total`) VALUES
(35, 23, '1', 1, '4000', '4000');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_penjualan_master`
--

CREATE TABLE `pj_penjualan_master` (
  `id_penjualan_m` int(1) UNSIGNED NOT NULL,
  `nomor_nota` varchar(40) NOT NULL,
  `tanggal` datetime NOT NULL,
  `grand_modal` int(20) NOT NULL,
  `grand_total` decimal(10,0) NOT NULL,
  `bayar` decimal(10,0) NOT NULL,
  `keterangan_lain` text DEFAULT NULL,
  `id_pelanggan` mediumint(1) UNSIGNED DEFAULT NULL,
  `id_user` mediumint(1) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_penjualan_master`
--

INSERT INTO `pj_penjualan_master` (`id_penjualan_m`, `nomor_nota`, `tanggal`, `grand_modal`, `grand_total`, `bayar`, `keterangan_lain`, `id_pelanggan`, `id_user`) VALUES
(23, '5FD3AB80535461', '2020-12-11 18:25:20', 3000, '4000', '5000', '', NULL, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_user`
--

CREATE TABLE `pj_user` (
  `id_user` mediumint(1) UNSIGNED NOT NULL,
  `username` varchar(40) NOT NULL,
  `password` varchar(60) NOT NULL,
  `nama` varchar(50) NOT NULL,
  `id_akses` tinyint(1) UNSIGNED NOT NULL,
  `status_user` enum('Aktif','Non Aktif') NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_user`
--

INSERT INTO `pj_user` (`id_user`, `username`, `password`, `nama`, `id_akses`, `status_user`) VALUES
(1, 'Adm9Transaction', 'd033e22ae348aeb5660fc2140aec35850c4da997', 'Admin', 1, 'Aktif'),
(11, 'Geylfedra', '552421f32196a069a46afc210a2aa779e589b498', 'Geylfedra Matthew Panggabean', 3, 'Aktif'),
(12, 'Daniel', '93a36f4595e1800dfc4fe182982bd5985a3e74c0', 'Daniel Situmeang', 2, 'Aktif'),
(13, 'Anggi', 'aca048e62f12c644668560644400215e528f6a62', 'Anggi Yohanes Pardede', 4, 'Aktif'),
(14, 'Zikri', '9a8edcd7bf7c2a335e213874c492358c3a69674a', 'Muhammad Zikri Ihsan', 3, 'Aktif'),
(15, 'Nathan', '0a0aea4125e759c77ee05c8af9135dfa8aecece6', 'Brillian Jonathan ', 2, 'Aktif');

--
-- Trigger `pj_user`
--
DELIMITER $$
CREATE TRIGGER `t_delete_pj_user` BEFORE DELETE ON `pj_user` FOR EACH ROW BEGIN 
INSERT INTO log_pj_user
SET id_user = old.id_user,
username = old.username,
nama = old.nama,
id_akses = old.id_akses,
status_user = old.status_user,
status = 'DELETE',
tanggal = NOW();

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_akses_aplikasi`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_akses_aplikasi` (
`staff_bagian` varchar(10)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_penjualan_detail`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_penjualan_detail` (
`id_penjualan_d` int(1) unsigned
,`tanggal` datetime
,`nama_barang` varchar(60)
,`jumlah_beli` smallint(1) unsigned
,`harga_satuan` decimal(10,0)
,`total` decimal(10,0)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_transaksi`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_transaksi` (
`ID Transaksi` int(1) unsigned
,`nomor_nota` varchar(40)
,`tanggal` datetime
,`grand_modal` int(20)
,`grand_total` decimal(10,0)
,`bayar` decimal(10,0)
,`Nama Pelanggan` varchar(40)
,`Nama Pengurus` varchar(50)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `v_akses_aplikasi`
--
DROP TABLE IF EXISTS `v_akses_aplikasi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_akses_aplikasi`  AS  select `pj_akses`.`label` AS `staff_bagian` from `pj_akses` where `pj_akses`.`id_akses` <> 1 order by `pj_akses`.`label` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_penjualan_detail`
--
DROP TABLE IF EXISTS `v_penjualan_detail`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_penjualan_detail`  AS  select `a`.`id_penjualan_d` AS `id_penjualan_d`,`b`.`tanggal` AS `tanggal`,`c`.`nama_barang` AS `nama_barang`,`a`.`jumlah_beli` AS `jumlah_beli`,`a`.`harga_satuan` AS `harga_satuan`,`a`.`total` AS `total` from ((`pj_penjualan_detail` `a` left join `pj_penjualan_master` `b` on(`a`.`id_penjualan_m` = `b`.`id_penjualan_m`)) left join `pj_barang` `c` on(`a`.`id_barang` = `c`.`id_barang`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_transaksi`
--
DROP TABLE IF EXISTS `v_transaksi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_transaksi`  AS  select `a`.`id_penjualan_m` AS `ID Transaksi`,`a`.`nomor_nota` AS `nomor_nota`,`a`.`tanggal` AS `tanggal`,`a`.`grand_modal` AS `grand_modal`,`a`.`grand_total` AS `grand_total`,`a`.`bayar` AS `bayar`,`b`.`nama` AS `Nama Pelanggan`,`c`.`nama` AS `Nama Pengurus` from ((`pj_penjualan_master` `a` left join `pj_pelanggan` `b` on(`a`.`id_pelanggan` = `b`.`id_pelanggan`)) left join `pj_user` `c` on(`a`.`id_user` = `c`.`id_user`)) ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `log_pj_barang`
--
ALTER TABLE `log_pj_barang`
  ADD PRIMARY KEY (`id_lpb`);

--
-- Indeks untuk tabel `log_pj_kategori_barang`
--
ALTER TABLE `log_pj_kategori_barang`
  ADD PRIMARY KEY (`id_lpkb`);

--
-- Indeks untuk tabel `log_pj_pelanggan`
--
ALTER TABLE `log_pj_pelanggan`
  ADD PRIMARY KEY (`id_lpp`);

--
-- Indeks untuk tabel `log_pj_user`
--
ALTER TABLE `log_pj_user`
  ADD PRIMARY KEY (`id_lpu`);

--
-- Indeks untuk tabel `pj_akses`
--
ALTER TABLE `pj_akses`
  ADD PRIMARY KEY (`id_akses`);

--
-- Indeks untuk tabel `pj_barang`
--
ALTER TABLE `pj_barang`
  ADD PRIMARY KEY (`id_barang`),
  ADD KEY `id_kategori_barang` (`id_kategori_barang`),
  ADD KEY `id_ukuran` (`id_ukuran`);

--
-- Indeks untuk tabel `pj_ci_sessions`
--
ALTER TABLE `pj_ci_sessions`
  ADD KEY `ci_sessions_timestamp` (`timestamp`);

--
-- Indeks untuk tabel `pj_kategori_barang`
--
ALTER TABLE `pj_kategori_barang`
  ADD PRIMARY KEY (`id_kategori_barang`),
  ADD KEY `id_varian` (`id_varian`) USING BTREE;

--
-- Indeks untuk tabel `pj_kategori_ukuran`
--
ALTER TABLE `pj_kategori_ukuran`
  ADD PRIMARY KEY (`id_ukuran`);

--
-- Indeks untuk tabel `pj_kategori_varian`
--
ALTER TABLE `pj_kategori_varian`
  ADD PRIMARY KEY (`id_varian`);

--
-- Indeks untuk tabel `pj_pelanggan`
--
ALTER TABLE `pj_pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indeks untuk tabel `pj_penjualan_detail`
--
ALTER TABLE `pj_penjualan_detail`
  ADD PRIMARY KEY (`id_penjualan_d`),
  ADD KEY `id_penjualan_m` (`id_penjualan_m`),
  ADD KEY `id_barang` (`id_barang`);

--
-- Indeks untuk tabel `pj_penjualan_master`
--
ALTER TABLE `pj_penjualan_master`
  ADD PRIMARY KEY (`id_penjualan_m`);

--
-- Indeks untuk tabel `pj_user`
--
ALTER TABLE `pj_user`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `id_akses` (`id_akses`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `log_pj_barang`
--
ALTER TABLE `log_pj_barang`
  MODIFY `id_lpb` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT untuk tabel `log_pj_kategori_barang`
--
ALTER TABLE `log_pj_kategori_barang`
  MODIFY `id_lpkb` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=145;

--
-- AUTO_INCREMENT untuk tabel `log_pj_pelanggan`
--
ALTER TABLE `log_pj_pelanggan`
  MODIFY `id_lpp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT untuk tabel `log_pj_user`
--
ALTER TABLE `log_pj_user`
  MODIFY `id_lpu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `pj_akses`
--
ALTER TABLE `pj_akses`
  MODIFY `id_akses` tinyint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `pj_barang`
--
ALTER TABLE `pj_barang`
  MODIFY `id_barang` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `pj_kategori_barang`
--
ALTER TABLE `pj_kategori_barang`
  MODIFY `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT untuk tabel `pj_kategori_varian`
--
ALTER TABLE `pj_kategori_varian`
  MODIFY `id_varian` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `pj_pelanggan`
--
ALTER TABLE `pj_pelanggan`
  MODIFY `id_pelanggan` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT untuk tabel `pj_penjualan_detail`
--
ALTER TABLE `pj_penjualan_detail`
  MODIFY `id_penjualan_d` int(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT untuk tabel `pj_penjualan_master`
--
ALTER TABLE `pj_penjualan_master`
  MODIFY `id_penjualan_m` int(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT untuk tabel `pj_user`
--
ALTER TABLE `pj_user`
  MODIFY `id_user` mediumint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
