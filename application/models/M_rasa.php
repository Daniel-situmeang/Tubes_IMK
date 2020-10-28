<?php
class M_rasa extends CI_Model 
{
	function get_all()
	{
		return $this->db
			->order_by('nama_rasa', 'asc')
			->get('pj_kategori_rasa');
	}
}