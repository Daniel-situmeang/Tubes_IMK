<?php
class M_varian extends CI_Model 
{
	function get_all()
	{
		return $this->db
			->order_by('nama_varian', 'asc')
			->get('pj_kategori_varian');
	}
}