<?php
class M_penjualan_detail extends CI_Model
{
	function insert_detail($id_master, $id_barang, $jumlah_beli, $harga_satuan, $sub_total)
	{
		$dt = array(
			'id_penjualan_m' => $id_master,
			'id_barang	' => $id_barang,
			'jumlah_beli' => $jumlah_beli,
			'harga_satuan' => $harga_satuan,
			'total' => $sub_total
		);

		return $this->db->insert('pj_penjualan_detail', $dt);
	}

	function get_detail($id_penjualan)
	{
		$sql = "
			CALL get_detail_transaksi('$id_penjualan');
		";

		$result = $this->db->query($sql);
		mysqli_next_result( $this->db->conn_id );
  		return $result;
	}
}