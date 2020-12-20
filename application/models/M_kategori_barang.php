<?php
class M_kategori_barang extends CI_Model 
{
	function get_all()
	{
		return $this->db
			->select('id_kategori_barang, kategori', 'id_varian')
			->order_by('kategori', 'asc')
			->get('pj_kategori_barang');
	}

	function fetch_data_kategori($like_value = NULL, $column_order = NULL, $column_dir = NULL, $limit_start = NULL, $limit_length = NULL)
	{
		$sql = "
			SELECT 
				(@row:=@row+1) AS nomor, 
				a.`id_kategori_barang`, 
				a.`kategori`,
				b.`nama_varian`  
			FROM 
				`pj_kategori_barang` AS a
				LEFT JOIN `pj_kategori_varian` AS b ON a.`id_varian` = b.`id_varian`, (SELECT @row := 0) r WHERE 1=1 
		";
		
		$data['totalData'] = $this->db->query($sql)->num_rows();
		
		if( ! empty($like_value))
		{
			$sql .= " AND ( ";    
			$sql .= "
				a.`kategori` LIKE '%".$this->db->escape_like_str($like_value)."%'
				OR b.`nama_varian` LIKE '%".$this->db->escape_like_str($like_value)."%' 
			";
			$sql .= " ) ";
		}
		
		$data['totalFiltered']	= $this->db->query($sql)->num_rows();
		
		$columns_order_by = array( 
			0 => 'nomor',
			1 => 'kategori',
			2 => 'nama_varian'
		);
		
		$sql .= " ORDER BY ".$columns_order_by[$column_order]." ".$column_dir.", nomor ";
		$sql .= " LIMIT ".$limit_start." ,".$limit_length." ";
		
		$data['query'] = $this->db->query($sql);
		return $data;
	}

	function tambah_kategori($kategori, $id_varian)
	{
		$dt = array(
			'id_varian' => $id_varian,
			'kategori' => $kategori
		);

		return $this->db->insert('pj_kategori_barang', $dt);
	}

	function hapus_kategori($id_kategori_barang)
	{
		return $this->db->query("DELETE from pj_kategori_barang WHERE id_kategori_barang =".$id_kategori_barang.";");
	}

	function get_baris($id_kategori_barang)
	{
		return $this->db
			->select('id_kategori_barang, kategori, id_varian')
			->where('id_kategori_barang', $id_kategori_barang)
			->limit(1)
			->get('pj_kategori_barang');
	}

	function update_kategori($id_kategori_barang, $kategori, $id_varian)
	{
		$dt = array(
			'kategori' => $kategori,
			'id_varian' => $id_varian
		);

		return $this->db
			->where('id_kategori_barang', $id_kategori_barang)
			->update('pj_kategori_barang', $dt);
	}
}