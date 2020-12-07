-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 07 Des 2020 pada 16.06
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
-- Database: `penjualan_db`
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_update_pj_kategori` (IN `id_pkb` MEDIUMINT(1), IN `cate` VARCHAR(40))  NO SQL
UPDATE `pj_kategori_barang` SET `kategori`= cate WHERE `id_kategori_barang`= id_pkb$$

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

CREATE DEFINER=`root`@`localhost` FUNCTION `f_kodeotomatis_barang` (`nomor` VARCHAR(15)) RETURNS CHAR(8) CHARSET latin1 NO SQL
BEGIN
DECLARE kodebaru CHAR(8);
DECLARE urut INT;
 
SET urut = IF(nomor IS NULL, 1, nomor + 1);
SET kodebaru = LPAD(urut, 6, 0)*100000;
 
RETURN CONCAT("BG", rand(kodebaru));
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
(1, '2', 'Runme Everynight Y98', 0, 0, '120000', 3, 0, 'DELETE', '2019-06-18 07:07:23'),
(2, '3', 'My Lovely Bag 877', 0, 0, '350000', 2, 0, 'DELETE', '2019-06-18 07:08:11'),
(3, '4', 'Quick Silver Gaul', 0, 0, '35000', 3, 0, 'DELETE', '2019-06-18 07:08:11'),
(4, '5', 'My Cool Shoes', 0, 0, '550000', 1, 0, 'DELETE', '2019-06-18 07:08:11'),
(5, '6', 'Testing', 0, 0, '929992', 1, 0, 'DELETE', '2019-06-18 07:08:12'),
(6, '7', 'Tes ada', 0, 0, '600000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(7, '8', 'Yes desk', 0, 0, '999999', 1, 0, 'DELETE', '2019-06-18 07:08:12'),
(8, '9', 'Test', 0, 0, '100000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(9, '10', 'Test', 0, 0, '99', 1, 0, 'DELETE', '2019-06-18 07:08:12'),
(10, '11', 'Rinso', 0, 0, '30000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(11, '12', 'mouse', 0, 0, '20000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(12, '13', 'Soklin Lantai', 0, 0, '3000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(13, '14', 'Beras Merah', 0, 0, '2000', 3, 0, 'DELETE', '2019-06-18 07:08:12'),
(14, 'BG0.4054', 'Keripik Singkong Kari Ecer 2000', 90, 750, '1000', 10, 4, 'INSERT', '2019-06-18 20:15:21'),
(15, 'BG00002', 'Orong - orong E1/2 kg', 0, 6000, '11000', 21, 0, 'DELETE', '2019-06-18 20:36:27'),
(16, 'BRG0006', 'Keripik Jagung Pedas 1/2kg', 40, 9000, '13000', 5, 2, 'UPDATE', '2019-06-25 03:57:24'),
(17, 'BRG0007', 'Keripik Jagung Pedas 1/4kg', 80, 4000, '6000', 2, 3, 'UPDATE', '2019-06-25 03:58:33'),
(18, 'BG0.4054', 'Keripik Singkong Kari Ecer 2000', 90, 750, '1000', 10, 4, 'UPDATE', '2019-06-28 20:28:03'),
(19, 'BG0001', 'Makaroni Kari Ecer 2000', 100, 750, '2000', 4, 4, 'UPDATE', '2019-06-28 23:52:31'),
(20, 'BG0002', 'Keripik Singkong Kari Ecer 2000', 89, 750, '1000', 10, 4, 'UPDATE', '2019-06-28 23:52:49'),
(21, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 15, 0, 'UPDATE', '2019-06-28 23:52:54'),
(22, 'BG0004', 'Kuping Gajah 1/2kg', 40, 10000, '14000', 11, 2, 'UPDATE', '2019-06-28 23:53:01'),
(23, 'BG0005', 'Kuping Gajah 1kg', 20, 20000, '28000', 11, 1, 'UPDATE', '2019-06-28 23:53:07'),
(24, 'BG0006', 'Keripik Jagung Pedas Ecer 2000', 90, 1000, '2000', 5, 4, 'UPDATE', '2019-06-28 23:53:15'),
(25, 'BG0007', 'Keripik Jagung Manis Ecer 2000', 100, 1000, '2000', 1, 4, 'UPDATE', '2019-06-28 23:53:24'),
(26, 'BG0008', 'Keripik Jagung Pedas 1kg', 50, 18000, '25000', 5, 1, 'UPDATE', '2019-06-28 23:53:30'),
(28, 'BG0009', 'Keripik Jagung Pedas 1/2kg', 39, 9000, '13000', 5, 2, 'UPDATE', '2019-06-28 23:53:53'),
(29, 'BG0010', 'Keripik Jagung Pedas 1/4kg', 74, 4000, '6000', 2, 3, 'UPDATE', '2019-06-28 23:54:02'),
(30, 'BG0011', 'Keripik Apel Hijau', 20, 11000, '15000', 1, 0, 'UPDATE', '2019-06-28 23:54:11'),
(31, 'BG0012', 'Keripik Apel Merah', 20, 9000, '13000', 1, 0, 'UPDATE', '2019-06-28 23:54:17'),
(32, 'BG0013', 'Orong - orong 1/4kg', 30, 3000, '7000', 21, 0, 'UPDATE', '2019-06-28 23:54:22'),
(33, 'BG0014', 'Keripik Bayam Hijau', 15, 5000, '10000', 2, 0, 'UPDATE', '2019-06-28 23:54:28'),
(34, 'BG0015', 'Keripik Gadung', 30, 8000, '12000', 3, 0, 'UPDATE', '2019-06-28 23:54:34'),
(35, 'BG0016', 'Makaroni Pedas Ecer 2000', 90, 750, '2000', 2, 4, 'UPDATE', '2019-06-28 23:54:39'),
(36, 'BG4083', 'Charger Nokia', 1110, 2220, '3330', 4, 4, 'INSERT', '2019-06-28 23:55:16'),
(37, 'BG4083', 'Charger Nokia', 0, 2220, '3330', 4, 4, 'DELETE', '2019-06-29 00:24:47'),
(38, 'BG0002', 'Keripik Singkong Kari Ecer 2000', 89, 750, '1000', 10, 4, 'UPDATE', '2019-06-29 00:56:53'),
(39, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 15, 0, 'UPDATE', '2019-06-29 19:07:59'),
(40, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 15, 1, 'UPDATE', '2019-06-29 19:14:55'),
(41, 'BG0011', 'Keripik Apel Hijau', 20, 11000, '15000', 1, 0, 'UPDATE', '2019-06-30 11:37:15'),
(42, 'BG4083', 'Keripik Lemas', 24, 30000, '50000', 11, 1, 'INSERT', '2019-06-30 17:33:26'),
(43, 'BG4083', 'Keripik Lemas', 0, 30000, '50000', 11, 1, 'DELETE', '2019-06-30 17:34:31'),
(44, 'BG4083', 'Astor Rasa Cokelat 1kg', 20, 18000, '25000', 29, 1, 'INSERT', '2019-07-02 11:06:29'),
(45, 'BG4083', 'Astor Rasa Cokelat 1kg', 0, 18000, '25000', 29, 1, 'DELETE', '2019-07-02 11:13:49'),
(46, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 15, 2, 'UPDATE', '2019-07-02 11:14:05'),
(47, 'BG0003', 'Keripik Jamur', 25, 5000, '10000', 15, 2, 'UPDATE', '2019-07-02 11:15:35'),
(48, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 15, 2, 'UPDATE', '2019-07-02 11:15:58'),
(49, 'BG4083', 'Astor Rasa Cokelat 1kg', 50, 18000, '25000', 29, 1, 'INSERT', '2019-07-02 11:20:48'),
(50, 'BG9030', 'Astor Rasa Cokelat 1/2kg', 50, 9000, '14000', 29, 2, 'INSERT', '2019-07-02 11:22:09'),
(51, 'BG0003', 'Keripik Jamur', 20, 5000, '10000', 27, 2, 'UPDATE', '2019-07-02 11:25:57'),
(52, 'BG0007', 'Keripik Jagung Manis Ecer 2000', 100, 1000, '2000', 1, 4, 'UPDATE', '2019-07-02 11:26:10'),
(53, 'BG0010', 'Keripik Jagung Pedas 1/4kg', 74, 4000, '6000', 2, 3, 'UPDATE', '2019-07-02 11:26:22'),
(54, 'BG0016', 'Makaroni Pedas Ecer 2000', 90, 750, '2000', 2, 4, 'UPDATE', '2019-07-02 11:26:51'),
(55, 'BG0001', 'Makaroni Kari Ecer 2000', 100, 750, '2000', 4, 4, 'UPDATE', '2019-07-02 11:27:16'),
(56, 'BG0002', 'Keripik Singkong Kari Ecer ', 89, 750, '1000', 10, 4, 'UPDATE', '2019-07-02 11:29:55'),
(57, 'BG0008', 'Keripik Jagung Pedas 1kg', 50, 18000, '25000', 5, 1, 'UPDATE', '2019-07-02 11:29:55'),
(58, 'BG4083', 'Astor Rasa Cokelat 1kg', 50, 18000, '25000', 29, 1, 'UPDATE', '2019-07-03 23:48:46'),
(59, 'BG11747.', 'Keripik Nando', 32, 19000, '35000', 7, 1, 'INSERT', '2019-07-03 23:56:31'),
(60, 'BG11747.', 'Keripik Nando', 0, 19000, '35000', 7, 1, 'DELETE', '2019-07-03 23:58:43'),
(61, 'BG55887.', 'Keripik Nando', 43, 20000, '36000', 16, 1, 'INSERT', '2019-07-03 23:59:18'),
(62, 'BG55887.', 'Keripik Nando', 0, 20000, '36000', 16, 1, 'DELETE', '2019-07-04 00:06:09'),
(63, 'BG0.4068', 'Keripik Nando', 45, 23000, '40000', 31, 1, 'INSERT', '2019-07-04 00:08:38'),
(64, 'BG0.4068', 'Keripik Nando', 0, 23000, '40000', 31, 1, 'DELETE', '2019-07-04 00:08:54'),
(65, 'BG0.4068', 'contoh', 20, 3000, '4000', 30, 2, 'INSERT', '2020-10-16 23:44:30'),
(66, 'BG0.4068', 'contoh', 20, 3000, '4000', 30, 2, 'UPDATE', '2020-10-17 00:43:51'),
(67, 'BG0.4068', 'contoh', 20, 3000, '4000', 30, 2, 'UPDATE', '2020-10-17 00:46:32'),
(68, 'BG0.4068', 'contoh', 20, 3000, '4000', 30, 2, 'UPDATE', '2020-10-17 00:51:46'),
(69, 'BG0008', 'Keripik Jagung Pedas 1kg', 49, 18000, '25000', 5, 1, 'UPDATE', '2020-10-24 00:26:39'),
(70, 'BG0.4068', 'contoh', 20, 3000, '4000', 30, 2, 'UPDATE', '2020-12-07 15:16:10'),
(71, 'BG0.4068', 'Keripik Apel Lays', 60, 3000, '4000', 1, 1, 'UPDATE', '2020-12-07 15:18:07'),
(72, 'BG0.4068', 'Keripik Apel Lays', 0, 1000, '4000', 1, 1, 'DELETE', '2020-12-07 15:37:01'),
(73, 'BG5588', 'Kerupuk Anggur', 0, 9000, '14000', 11, 1, 'DELETE', '2020-12-07 15:37:03'),
(74, 'BG9030', 'Astor Rasa Cokelat 1/2kg', 0, 9000, '14000', 29, 2, 'DELETE', '2020-12-07 15:37:06'),
(75, 'BG4083', 'Astor Rasa Cokelat 1kg', 0, 18000, '25000', 29, 1, 'DELETE', '2020-12-07 15:37:08'),
(76, 'BG0003', 'Keripik Jamur', 0, 5000, '10000', 22, 2, 'DELETE', '2020-12-07 15:37:10'),
(77, 'BG0004', 'Kuping Gajah 1/2kg', 0, 10000, '14000', 11, 2, 'DELETE', '2020-12-07 15:37:12'),
(78, 'BG0005', 'Kuping Gajah 1kg', 0, 20000, '28000', 11, 1, 'DELETE', '2020-12-07 15:37:14'),
(79, 'BG0007', 'Keripik Jagung Manis Ecer 2000', 0, 1000, '2000', 4, 4, 'DELETE', '2020-12-07 15:37:19'),
(80, 'BG0006', 'Keripik Jagung Pedas Ecer 2000', 0, 1000, '2000', 5, 4, 'DELETE', '2020-12-07 15:37:21'),
(81, 'BG0010', 'Keripik Jagung Pedas 1/4kg', 0, 4000, '6000', 5, 3, 'DELETE', '2020-12-07 15:37:24'),
(82, 'BG0009', 'Keripik Jagung Pedas 1/2kg', 0, 9000, '13000', 5, 2, 'DELETE', '2020-12-07 15:37:26'),
(83, 'BG0008', 'Keripik Jagung Pedas 1kg', 0, 18000, '25000', 5, 1, 'DELETE', '2020-12-07 15:37:28'),
(84, 'BG0001', 'Makaroni Kari Ecer 2000', 0, 750, '2000', 15, 4, 'DELETE', '2020-12-07 15:37:30'),
(85, 'BG0016', 'Makaroni Pedas Ecer 2000', 0, 750, '2000', 13, 4, 'DELETE', '2020-12-07 15:37:32'),
(86, 'BG0015', 'Keripik Gadung', 0, 8000, '12000', 3, 0, 'DELETE', '2020-12-07 15:37:34'),
(87, 'BG0014', 'Keripik Bayam Hijau', 0, 5000, '10000', 2, 0, 'DELETE', '2020-12-07 15:37:37'),
(88, 'BG0012', 'Keripik Apel Merah', 0, 9000, '13000', 1, 0, 'DELETE', '2020-12-07 15:37:39'),
(89, 'BG0011', 'Keripik Apel Hijau', 0, 11000, '15000', 1, 0, 'DELETE', '2020-12-07 15:37:43'),
(90, 'BG0013', 'Orong - orong 1/4kg', 0, 3000, '7000', 21, 0, 'DELETE', '2020-12-07 15:37:45'),
(91, 'BG0002', 'Keripik Singkong Kari Ecer ', 0, 750, '1000', 10, 4, 'DELETE', '2020-12-07 15:37:48');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_pj_kategori_barang`
--

CREATE TABLE `log_pj_kategori_barang` (
  `id_lpkb` int(11) NOT NULL,
  `id_kategori_barang` mediumint(1) NOT NULL,
  `kategori` varchar(40) NOT NULL,
  `id_rasa` int(2) DEFAULT NULL,
  `status` varchar(6) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `log_pj_kategori_barang`
--

INSERT INTO `log_pj_kategori_barang` (`id_lpkb`, `id_kategori_barang`, `kategori`, `id_rasa`, `status`, `tanggal`) VALUES
(1, 1, 'Sepatu', NULL, 'UPDATE', '2019-06-14 12:51:26'),
(2, 2, 'Tas', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(3, 3, 'Baju', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(4, 4, 'Celana', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(5, 5, 'Topi', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(6, 6, 'Gelang', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(7, 7, 'Jam', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(8, 8, 'Topi', NULL, 'UPDATE', '2019-06-14 12:51:27'),
(9, 9, 'Keripik Singkong Original', NULL, 'INSERT', '2019-06-14 12:58:10'),
(10, 10, 'Keripik Singkong Kari', NULL, 'INSERT', '2019-06-14 12:58:10'),
(11, 11, 'Kuping Gajah', NULL, 'INSERT', '2019-06-14 12:58:10'),
(12, 12, 'Keripik Chitato Pedas', NULL, 'INSERT', '2019-06-14 12:58:10'),
(13, 13, 'Kerupuk Makaroni Pedas', NULL, 'INSERT', '2019-06-14 12:58:10'),
(14, 14, 'Kerupuk Makaroni Original', NULL, 'INSERT', '2019-06-14 12:58:10'),
(15, 15, 'Kerupuk Makaroni Kari', NULL, 'INSERT', '2019-06-14 12:58:10'),
(16, 16, 'Keripik Pisang Pedas', NULL, 'INSERT', '2019-06-14 12:58:10'),
(17, 17, 'Keripik Pisang Original', NULL, 'INSERT', '2019-06-14 13:17:50'),
(18, 18, 'Kerupuk Kentang Pedas', NULL, 'INSERT', '2019-06-14 13:17:50'),
(19, 19, 'Kerupuk Kentang Original', NULL, 'INSERT', '2019-06-14 13:17:50'),
(20, 20, 'Kerupuk Putih', NULL, 'INSERT', '2019-06-14 13:17:50'),
(21, 4, 'Keripik Jagung Manis', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(22, 5, 'Keripik Jagung Pedas', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(23, 6, 'Keripik Jagung Original', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(24, 7, 'Keripik Singkong Manis', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(25, 8, 'Keripik SIngkong Balado', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(26, 9, 'Keripik Singkong Original', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(27, 10, 'Keripik Singkong Kari', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(28, 12, 'Keripik Chitato Pedas', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(29, 13, 'Kerupuk Makaroni Pedas', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(30, 14, 'Kerupuk Makaroni Original', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(31, 15, 'Kerupuk Makaroni Kari', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(32, 16, 'Keripik Pisang Pedas', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(33, 17, 'Keripik Pisang Original', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(34, 18, 'Kerupuk Kentang Pedas', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(35, 19, 'Kerupuk Kentang Original', NULL, 'UPDATE', '2019-06-16 09:53:55'),
(36, 28, 'Charger', NULL, 'INSERT', '2019-06-28 20:19:26'),
(37, 28, 'Charger', NULL, 'UPDATE', '2019-06-28 20:19:32'),
(38, 28, 'Charger HEHE', NULL, 'DELETE', '2019-06-28 20:19:36'),
(39, 29, 'Astor Rasa Cokelat', NULL, 'INSERT', '2019-07-02 10:35:56'),
(40, 30, 'Astor Ungu Rasa Cokelat', NULL, 'INSERT', '2019-07-02 10:36:17'),
(41, 31, 'Keripik Pasta Balado', NULL, 'INSERT', '2019-07-02 10:36:56'),
(42, 27, 'Keripik Jamur', NULL, 'DELETE', '2019-07-02 11:16:09'),
(43, 26, 'Keripik Jamur', NULL, 'DELETE', '2019-07-02 11:16:13'),
(44, 25, 'Keripik Jamur', NULL, 'DELETE', '2019-07-02 11:16:17'),
(45, 23, 'Keripik Jamur', NULL, 'DELETE', '2019-07-02 11:16:21'),
(46, 24, 'Keripik Jamur', NULL, 'DELETE', '2019-07-02 11:16:24');

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
(1, 9, 'Kodok', 'Test', '0000', 'Aktif', 'DELETE', '2019-06-17 17:06:34'),
(2, 13, 'Bernard', 'Test', '0000', 'Aktif', 'UPDATE', '2019-06-17 17:09:49'),
(3, 8388607, 'Malih', 'test', '3434343', 'Aktif', 'DELETE', '2019-06-28 20:29:52'),
(4, 8388607, 'Melina', 'Jauh', '9900039', 'Non Aktif', 'UPDATE', '2019-06-29 20:10:25'),
(5, 8388607, 'Melina', 'Jauh', '9900039', 'Non Aktif', 'DELETE', '2020-12-07 20:26:03'),
(6, 8388607, 'Norman', 'Test', '0039349', 'Aktif', 'DELETE', '2020-12-07 20:26:05'),
(7, 8388607, 'Nani', 'Test\r\n\r\nAja', '0000', 'Aktif', 'DELETE', '2020-12-07 20:26:07'),
(8, 8388607, 'Bernard', 'Test', '0000', 'Aktif', 'DELETE', '2020-12-07 20:26:10'),
(9, 8388607, 'Narji', 'Test', '000', 'Aktif', 'DELETE', '2020-12-07 20:26:12'),
(10, 8388607, 'Brandon', 'Test', '99030', 'Aktif', 'DELETE', '2020-12-07 20:26:13'),
(11, 8388607, 'Broke', 'Test', '9900', 'Aktif', 'DELETE', '2020-12-07 20:26:15'),
(12, 8388607, 'Kodok', 'Test', '0000', 'Aktif', 'DELETE', '2020-12-07 20:26:17'),
(13, 8388607, 'Budi', 'Jatinegara', '8349393439', 'Aktif', 'DELETE', '2020-12-07 20:26:18'),
(14, 8388607, 'Jamil', 'Berlan', '0934934939', 'Aktif', 'DELETE', '2020-12-07 20:26:20'),
(15, 8388607, 'Deden', 'Jauh', '990393', 'Aktif', 'DELETE', '2020-12-07 20:26:22'),
(16, 8388607, 'Mira', 'Pisangan', '09938829232', 'Aktif', 'DELETE', '2020-12-07 20:26:24'),
(17, 8388607, 'Budi', 'Salemba', '089930393829', 'Aktif', 'DELETE', '2020-12-07 20:26:26'),
(18, 8388607, 'Joko', 'Kayumanis', '08773682882', 'Aktif', 'DELETE', '2020-12-07 20:26:28'),
(19, 8388607, 'Pak Jarwo', 'Kemanggisan deket binus', '4353535353', 'Aktif', 'DELETE', '2020-12-07 20:26:30'),
(20, 8388607, 'Pak Udin', 'Jalan Kayumanis 2 Baru', '08838493439', 'Non Aktif', 'DELETE', '2020-12-07 20:26:32'),
(21, 22, 'Pokemon', 'Putri Hijau', '082345234523', 'Aktif', 'DELETE', '2020-12-07 20:26:42'),
(22, 21, 'asdadadasdad', 'test', '324', 'Aktif', 'DELETE', '2020-12-07 20:26:44'),
(23, 20, 'asda', 'asda', '2342', 'Aktif', 'DELETE', '2020-12-07 20:26:46'),
(24, 19, 'makak', 'kkk', '999', 'Aktif', 'DELETE', '2020-12-07 20:26:53'),
(25, 18, 'jaka', 'jaka', '0000', 'Aktif', 'DELETE', '2020-12-07 20:26:55'),
(26, 17, 'Malih', 'test', '3434343', 'Aktif', 'DELETE', '2020-12-07 20:26:57'),
(27, 16, 'Melina', 'Jauh', '9900039', 'Aktif', 'DELETE', '2020-12-07 20:26:59'),
(28, 15, 'Norman', 'Test', '0039349', 'Aktif', 'DELETE', '2020-12-07 20:27:01'),
(29, 13, 'Bernard Situmeang', 'Jl.Menteng 7 Gg.Kestria No.11', '085673234080', 'Aktif', 'DELETE', '2020-12-07 20:27:02'),
(30, 14, 'Nani', 'Test\r\n\r\nAja', '0000', 'Aktif', 'DELETE', '2020-12-07 20:27:05'),
(31, 12, 'Narji', 'Test', '000', 'Aktif', 'DELETE', '2020-12-07 20:27:12'),
(32, 11, 'Broke', 'Test', '9900', 'Aktif', 'DELETE', '2020-12-07 20:27:14'),
(33, 10, 'Brandon', 'Mandala By Pass', '087863234321', 'Aktif', 'DELETE', '2020-12-07 20:27:17'),
(34, 8, 'Budi', 'Jatinegara', '8349393439', 'Aktif', 'DELETE', '2020-12-07 20:27:20'),
(35, 7, 'Jamil', 'Berlan', '0934934939', 'Aktif', 'DELETE', '2020-12-07 20:27:22'),
(36, 5, 'Mira', 'Pisangan', '09938829232', 'Aktif', 'DELETE', '2020-12-07 20:27:24'),
(37, 4, 'Budi', 'Salemba', '089930393829', 'Aktif', 'DELETE', '2020-12-07 20:27:28'),
(38, 3, 'Joko', 'Kayumanis', '08773682882', 'Aktif', 'DELETE', '2020-12-07 20:27:31'),
(39, 2, 'Pak Jarwo', 'Kemanggisan deket binus', '4353535353', 'Aktif', 'DELETE', '2020-12-07 20:27:33'),
(40, 1, 'Pak Udin', 'Jalan Kayumanis 2 Baru', '08838493439', 'Aktif', 'DELETE', '2020-12-07 20:27:36');

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
(1, '5', 'jaka', 'Jaka Sembung', 3, 'Aktif', 'DELETE', '2019-06-17 17:18:39'),
(2, '7', 'amir', 'Bagus TBN', 3, '', 'DELETE', '2019-06-28 20:17:56'),
(3, '6', 'jokowow', 'Love Keuangan', 4, 'Aktif', 'DELETE', '2019-07-02 11:04:40'),
(4, '9', 'julia', 'Julia Chan', 2, 'Aktif', 'DELETE', '2020-12-07 15:41:27'),
(5, '8', 'sola_joko', 'Rogate Solafide', 4, 'Aktif', 'DELETE', '2020-12-07 15:41:29'),
(6, '4', 'javic_jaka', 'Javic Rotanson', 3, 'Aktif', 'DELETE', '2020-12-07 15:41:31'),
(7, '3', 'kasir2', 'Kasir Dua', 2, 'Aktif', 'DELETE', '2020-12-07 15:41:33'),
(8, '2', 'daisy_kasir', 'Daisy Sere', 2, 'Aktif', 'DELETE', '2020-12-07 15:41:37');

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
  `id_barang` varchar(10) NOT NULL,
  `nama_barang` varchar(60) NOT NULL,
  `total_stok` mediumint(1) UNSIGNED NOT NULL,
  `modal` decimal(10,0) NOT NULL,
  `harga` decimal(10,0) NOT NULL,
  `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL,
  `id_ukuran` mediumint(1) NOT NULL,
  `qrcode` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

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
CREATE TRIGGER `t_insert_pj_barang` AFTER INSERT ON `pj_barang` FOR EACH ROW BEGIN 
INSERT INTO log_pj_barang
SET id_barang = new.id_barang,
nama_barang = new.nama_barang,
total_stok = new.total_stok,
modal = new.modal,
harga = new.harga,
id_kategori_barang = new.id_kategori_barang,
id_ukuran = new.id_ukuran,
status = 'INSERT',
tanggal = NOW();

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_kodeotomatis_barang` BEFORE INSERT ON `pj_barang` FOR EACH ROW BEGIN
DECLARE s VARCHAR(8);
DECLARE i INTEGER;
 
SET i = (SELECT SUBSTRING(id_barang,3,6) AS Nomor
FROM pj_barang ORDER BY id_barang DESC LIMIT 1);
 
SET s = (SELECT f_kodeotomatis_barang(i));
 
IF(NEW.id_barang IS NULL OR NEW.id_barang = '')
 THEN SET NEW.id_barang =s;
END IF;
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
('r8kkk7smfq1kkjo0mjn6fcf9045ad2ge', '::1', 1602866978, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836363937383b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('okimeg6i0urg24b2epgrov32ei31lfk3', '::1', 1602868069, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836383036393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('o28f9dbbgop3j5jdsvuuaqtc17hnppig', '::1', 1602868586, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836383538363b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('3ok1icihpb84knlan77g9qfiiijj5qa5', '::1', 1602868902, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836383930323b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('lv0jlh0to22f7lgjhccq9r9jk0hhj70b', '::1', 1602869230, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836393233303b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('8v2foqqomm5uj4jd2fk5vsrs1u0ae440', '::1', 1602869533, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836393533333b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('sfnbj8pkt2t4nsv72lagomovbg02e4ql', '::1', 1602869986, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323836393938363b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('5bh8uct5fc4ag336tkaosas7u61b7ped', '::1', 1602870392, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837303339323b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('9rlrj7b1hj6qqkkib8m71nardvlcji3k', '::1', 1602870696, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837303639363b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('9b9odn0iigd5d7rje8dqbdh2umd83nf0', '::1', 1602871317, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837313331373b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('98m34mdpaov9rjjl771g57qsl8e2at4f', '192.168.100.4', 1602871169, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837313035303b61705f69645f757365727c733a313a2239223b61705f70617373776f72647c733a34303a2236633239343731306361663538346438633061643935643666353339623565306632323461366639223b61705f6e616d617c733a31303a224a756c6961204368616e223b61705f6c6576656c7c733a353a226b61736972223b61705f6c6576656c5f63617074696f6e7c733a31313a225374616666204b61736972223b),
('k35m37igq1ng2thm9m5r6rn31874v122', '::1', 1602871624, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837313632343b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('1t1ff402v2j32ucmpge1fctr3ldqvgsj', '::1', 1602871939, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837313933393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('2ugit1hs3eqe2ago1eevb22c5osrqhdj', '::1', 1602871948, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323837313933393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('8efuh0kbh15bnqgregvrh73a8lgim3al', '::1', 1602900378, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630323930303331323b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('ofbed9od6o5vmjp73v7l1ob3pk68haqi', '::1', 1603111227, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333131313232373b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('qsj0oeqvngfqvqvp5n2980gu3bvdv61e', '::1', 1603111227, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333131313232373b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('1lp8spidq1r0str2c82fu0abdhbofqin', '::1', 1603473959, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333437333935393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('p391tsrrkvk62dkso6dps3votjtji4fu', '::1', 1603474005, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333437333935393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('1k8di7m277um3jl5miu6qdck1nct8h0k', '::1', 1603992700, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333939323730303b),
('petl7enkanjjam04doa8j3vtaa00ener', '::1', 1603993085, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333939333038353b),
('ppi83nq8iv75dgbsd1gv4d0apjfhsper', '::1', 1603993459, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333939333435393b),
('11ckl1i6esau3pos79r0s56rsghrs2ib', '::1', 1603993626, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630333939333435393b),
('hr7ael982ja92qkoc8k2g630tdub41ud', '::1', 1607329356, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373332393335363b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('nl7gddh4b7joptslfgcor0s3sv5s4gp7', '::1', 1607330019, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373333303031393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('nab94lc6ea9844sth96k8vo2vufctpel', '::1', 1607329486, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373332393436303b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('vh4ljo1elkqrqfh2gn4sc4omag6s2mp8', '::1', 1607330448, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373333303434383b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('417hvuvk6tkr6j6ct5jdcr52cjhumt7v', '::1', 1607340704, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373334303730343b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('593nqndjqd9oevfqm7lcfcunr5p1tdap', '::1', 1607341369, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373334313336393b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('bjiksm1faebvcfd48o641kkiblpub64v', '::1', 1607347533, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373334373533333b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b),
('ceohm3pg47ohkm4jfrfnnp2el394et7b', '::1', 1607347656, 0x5f5f63695f6c6173745f726567656e65726174657c693a313630373334373533333b61705f69645f757365727c733a313a2231223b61705f70617373776f72647c733a34303a2264303333653232616533343861656235363630666332313430616563333538353063346461393937223b61705f6e616d617c733a353a2241646d696e223b61705f6c6576656c7c733a353a2261646d696e223b61705f6c6576656c5f63617074696f6e7c733a31333a2241646d696e6973747261746f72223b);

-- --------------------------------------------------------

--
-- Struktur dari tabel `pj_kategori_barang`
--

CREATE TABLE `pj_kategori_barang` (
  `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL,
  `kategori` varchar(40) NOT NULL,
  `id_rasa` int(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_kategori_barang`
--

INSERT INTO `pj_kategori_barang` (`id_kategori_barang`, `kategori`, `id_rasa`) VALUES
(4, 'Keripik Jagung Manis', 1),
(3, 'Keripik Gadung', 0),
(2, 'Keripik Bayam', 0),
(1, 'Keripik Apel', 0),
(5, 'Keripik Jagung Pedas', 2),
(6, 'Keripik Jagung Original', 3),
(7, 'Keripik Singkong Manis', 1),
(8, 'Keripik SIngkong Balado', 2),
(9, 'Keripik Singkong Original', 3),
(10, 'Keripik Singkong Kari', 4),
(11, 'Kuping Gajah', 0),
(12, 'Keripik Chitato Pedas', 2),
(13, 'Kerupuk Makaroni Pedas', 2),
(14, 'Kerupuk Makaroni Original', 3),
(15, 'Kerupuk Makaroni Kari', 4),
(16, 'Keripik Pisang Pedas', 2),
(17, 'Keripik Pisang Original', 3),
(18, 'Kerupuk Kentang Pedas', 2),
(19, 'Kerupuk Kentang Original', 3),
(20, 'Kerupuk Putih', 0),
(21, 'Orong - orong', 0),
(22, 'Keripik Jamur', 0),
(29, 'Astor Rasa Cokelat', 1),
(30, 'Astor Ungu Rasa Cokelat', 1),
(31, 'Keripik Pasta Balado', 2);

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
-- Struktur dari tabel `pj_kategori_rasa`
--

CREATE TABLE `pj_kategori_rasa` (
  `id_rasa` int(2) NOT NULL,
  `nama_rasa` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pj_kategori_rasa`
--

INSERT INTO `pj_kategori_rasa` (`id_rasa`, `nama_rasa`) VALUES
(0, '-'),
(1, 'Manis'),
(2, 'Balado'),
(3, 'Original'),
(4, 'Kari');

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
-- Struktur dari tabel `pj_pelanggan`
--

CREATE TABLE `pj_pelanggan` (
  `id_pelanggan` varchar(10) NOT NULL,
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
('SLS66779', 'Jarwo Sungirep', 'Jalan Bahagia Penuh No.80', '082399880055', NULL, '2019-06-16 14:34:04', 'Aktif');

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
DELIMITER $$
CREATE TRIGGER `t_update_pj_pelanggan` BEFORE UPDATE ON `pj_pelanggan` FOR EACH ROW BEGIN 
INSERT INTO log_pj_pelanggan
SET id_pelanggan = old.id_pelanggan,
nama = old.nama,
alamat = old.alamat,
telp = old.telp,
status_anggota = new.status_anggota,
status = 'UPDATE',
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
(2, 2, '2', 1, '120000', '120000'),
(3, 2, '4', 1, '35000', '35000'),
(4, 3, '3', 1, '350000', '350000'),
(5, 4, '2', 1, '120000', '120000'),
(6, 4, '11', 2, '30000', '60000'),
(7, 4, '4', 2, '35000', '70000'),
(11, 6, '2', 1, '120000', '120000'),
(10, 6, '1', 1, '400000', '400000'),
(12, 7, '4', 1, '35000', '35000'),
(13, 8, '3', 1, '350000', '350000'),
(14, 9, '1', 1, '400000', '400000'),
(15, 9, '2', 1, '120000', '120000'),
(16, 9, '3', 1, '350000', '350000'),
(17, 9, '4', 1, '35000', '35000'),
(18, 10, '1', 1, '400000', '400000'),
(19, 10, '2', 1, '120000', '120000'),
(20, 10, '3', 1, '350000', '350000'),
(21, 11, '1', 1, '400000', '400000'),
(22, 11, '3', 1, '350000', '350000'),
(23, 12, '3', 2, '350000', '700000');

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
(1, 'admin', 'd033e22ae348aeb5660fc2140aec35850c4da997', 'Admin', 1, 'Aktif');

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
  ADD KEY `id_rasa` (`id_rasa`);

--
-- Indeks untuk tabel `pj_kategori_rasa`
--
ALTER TABLE `pj_kategori_rasa`
  ADD PRIMARY KEY (`id_rasa`);

--
-- Indeks untuk tabel `pj_kategori_ukuran`
--
ALTER TABLE `pj_kategori_ukuran`
  ADD PRIMARY KEY (`id_ukuran`);

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
  MODIFY `id_lpb` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT untuk tabel `log_pj_kategori_barang`
--
ALTER TABLE `log_pj_kategori_barang`
  MODIFY `id_lpkb` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT untuk tabel `log_pj_pelanggan`
--
ALTER TABLE `log_pj_pelanggan`
  MODIFY `id_lpp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT untuk tabel `log_pj_user`
--
ALTER TABLE `log_pj_user`
  MODIFY `id_lpu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `pj_akses`
--
ALTER TABLE `pj_akses`
  MODIFY `id_akses` tinyint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `pj_kategori_barang`
--
ALTER TABLE `pj_kategori_barang`
  MODIFY `id_kategori_barang` mediumint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT untuk tabel `pj_penjualan_detail`
--
ALTER TABLE `pj_penjualan_detail`
  MODIFY `id_penjualan_d` int(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT untuk tabel `pj_penjualan_master`
--
ALTER TABLE `pj_penjualan_master`
  MODIFY `id_penjualan_m` int(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT untuk tabel `pj_user`
--
ALTER TABLE `pj_user`
  MODIFY `id_user` mediumint(1) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
