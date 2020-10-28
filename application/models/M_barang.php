<?php
class M_barang extends CI_Model 
{
	function fetch_data_barang($like_value = NULL, $column_order = NULL, $column_dir = NULL, $limit_start = NULL, $limit_length = NULL)
	{
		$sql = "
			SELECT 
				(@row:=@row+1) AS nomor, 
				a.`id_barang`, 
				-- a.`id_barang`, 
				a.`nama_barang`,
				CONCAT('Rp. ', REPLACE(FORMAT(a.`modal`, 0),',','.') ) AS modal,
				IF(a.`total_stok` = 0, 'Kosong', a.`total_stok`) AS total_stok,
				CONCAT('Rp. ', REPLACE(FORMAT(a.`harga`, 0),',','.') ) AS harga,
				b.`kategori`,
				c.`ukuran` 
			FROM 
				`pj_barang` AS a 
				LEFT JOIN `pj_kategori_barang` AS b ON a.`id_kategori_barang` = b.`id_kategori_barang`
				LEFT JOIN `pj_kategori_ukuran` AS c ON a.`id_ukuran` = c.`id_ukuran` 
				, (SELECT @row := 0) r WHERE 1=1

		";
		
		$data['totalData'] = $this->db->query($sql)->num_rows();
		//OR a.`size` LIKE '%".$this->db->escape_like_str($like_value)."%'
		if( ! empty($like_value))
		{
			$sql .= " AND ( ";    
			$sql .= "
				a.`nama_barang` LIKE '%".$this->db->escape_like_str($like_value)."%'
				 
				OR IF(a.`total_stok` = 0, 'Kosong', a.`total_stok`) LIKE '%".$this->db->escape_like_str($like_value)."%' 
				OR CONCAT('Rp. ', REPLACE(FORMAT(a.`modal`, 0),',','.') ) LIKE '%".$this->db->escape_like_str($like_value)."%' 
				OR CONCAT('Rp. ', REPLACE(FORMAT(a.`harga`, 0),',','.') ) LIKE '%".$this->db->escape_like_str($like_value)."%'  
				OR b.`kategori` LIKE '%".$this->db->escape_like_str($like_value)."%'
				OR c.`ukuran` LIKE '%".$this->db->escape_like_str($like_value)."%' 
			";
			$sql .= " ) ";
		}
		
		$data['totalFiltered']	= $this->db->query($sql)->num_rows();
		
		$columns_order_by = array( 
			0 => 'nomor',
			1 => 'a.`id_barang`',
			2 => 'a.`nama_barang`',
			3 => 'b.`kategori`',
			4 => 'c.ukuran`',
			5 => 'a.`total_stok`',
			6 => '`harga`'
		);
		
		$sql .= " ORDER BY ".$columns_order_by[$column_order]." ".$column_dir.", nomor ";
		$sql .= " LIMIT ".$limit_start." ,".$limit_length." ";
		
		$data['query'] = $this->db->query($sql);
		return $data;
	}

	function hapus_barang($id_barang)
	{
		$sql = "
			CALL p_hapus_pj_barang('$id_barang');
		";

		$result = $this->db->query($sql);
		mysqli_next_result( $this->db->conn_id );
  		return $result;
	}

	function tambah_baru($nama, $id_kategori_barang, $id_ukuran, $stok, $modal, $harga,$qr)
	{
		$data = [
		"nama_barang" => $nama,
		"total_stok" => $stok,
		"id_ukuran" => $id_ukuran,
		"modal" => $modal,
		"harga" => $harga,
		"id_kategori_barang" => $id_kategori_barang,
		"qrcode" => $qr ];

		$sql = "
			CALL p_tambah_pj_barang('$nama', '$stok', '$harga', '$id_kategori_barang', '$id_ukuran', '$modal','$qr');
		";

		// $result = $this->db->query($sql);
		// mysqli_next_result( $this->db->conn_id );
  // 		return $result;
		$this->db->insert('pj_barang',$data);
	}

	function cek_kode($kode)
	{
		return $this->db
			->select('id_barang')
			->where('id_barang', $kode)
			->limit(1)
			->get('pj_barang');
	}

	function tambahqrcode($id,$filename){
		$data = array(
        'qrcode' => $filename,
		);
		$this->db->where('id_barang',$id);
		$this->db->update('pj_barang', $data);
	}

	function get_baris($id_barang)
	{
		return $this->db
			->select('id_barang, nama_barang, total_stok, modal, id_ukuran, harga, id_kategori_barang,qrcode')
			->where('id_barang', $id_barang)
			->limit(1)
			->get('pj_barang');
	}

	function update_barang($id_barang, $nama, $id_kategori_barang, $ukuran, $stok, $modal, $harga)
	{
		$sql = "
			CALL p_update_pj_barang('$id_barang', '$nama', '$stok', '$harga', '$id_kategori_barang', '$ukuran', '$modal');
		";

		$result = $this->db->query($sql);
		// mysqli_next_result( $this->db->conn_id );
  		return $result;
	}

	function cari_kode($keyword, $registered)
	{
		$not_in = '';

		$koma = explode(',', $registered);
		if(count($koma) > 1)
		{
			$not_in .= " AND `id_barang` NOT IN (";
			foreach($koma as $k)
			{
				$not_in .= " '".$k."', ";
			}
			$not_in = rtrim(trim($not_in), ',');
			$not_in = $not_in.")";
		}
		if(count($koma) == 1)
		{
			$not_in .= " AND `id_barang` != '".$registered."' ";
		}

		$sql = "
			SELECT 
				`id_barang`, `nama_barang`, `harga` 
			FROM 
				`pj_barang` 
			WHERE 
				`total_stok` > 0 
				AND ( 
					`id_barang` LIKE '%".$this->db->escape_like_str($keyword)."%' 
					OR `nama_barang` LIKE '%".$this->db->escape_like_str($keyword)."%' 
				) 
				".$not_in." 
		";

		return $this->db->query($sql);
	}

	function get_stok($kode)
	{
		return $this->db
			->select('nama_barang, total_stok, modal')
			->where('id_barang', $kode)
			->limit(1)
			->get('pj_barang');
	}

	function get_id($kode_barang)
	{
		return $this->db
			->select('id_barang, nama_barang')
			->where('id_barang', $kode_barang)
			->limit(1)
			->get('pj_barang');
	}

	function update_stok($id_barang, $jumlah_beli)
	{
		$sql = "
			UPDATE `pj_barang` SET `total_stok` = `total_stok` - ".$jumlah_beli." WHERE `id_barang` = '".$id_barang."'
		";

		return $this->db->query($sql);
	}
}