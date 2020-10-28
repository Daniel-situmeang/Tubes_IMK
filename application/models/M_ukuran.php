<?php
class M_ukuran extends CI_Model 
{
	function get_all()
	{
		return $this->db
			->select('id_ukuran, ukuran')
			->order_by('id_ukuran', 'asc')
			->get('pj_kategori_ukuran');
	}
}

?>