<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Barang extends MY_Controller 
{
	public function __construct(){

		parent::__construct();
		$this->load->library('form_validation');
	   // $this->load->database();

	}

	public function index()
	{
		$this->load->view('barang/barang_data');
	}

	public function barang_json()
	{
		$this->load->model('m_barang');
		$level 			= $this->session->userdata('ap_level');

		$requestData	= $_REQUEST;
		$fetch			= $this->m_barang->fetch_data_barang($requestData['search']['value'], $requestData['order'][0]['column'], $requestData['order'][0]['dir'], $requestData['start'], $requestData['length']);
		
		$totalData		= $fetch['totalData'];
		$totalFiltered	= $fetch['totalFiltered'];
		$query			= $fetch['query'];

		$data	= array();
		foreach($query->result_array() as $row)
		{ 
			$nestedData = array(); 

			$nestedData[]	= $row['nomor'];
			$nestedData[]	= $row['id_barang'];
			$nestedData[]	= $row['nama_barang'];
			$nestedData[]	= $row['kategori'];
			$nestedData[]	= $row['ukuran'];
			$nestedData[]	= ($row['total_stok'] == 'Kosong') ? "<font color='red'><b>".$row['total_stok']."</b></font>" : $row['total_stok'];
			$nestedData[]	= $row['modal'];
			$nestedData[]	= $row['harga'];

			if($level == 'admin' OR $level == 'inventory')
			{
				$nestedData[]	= "<a href='".site_url('barang/edit/'.$row['id_barang'])."' id='EditBarang'><i class='fa fa-pencil'></i> Edit</a>";
				$nestedData[]	= "<a href='".site_url('barang/hapus/'.$row['id_barang'])."' id='HapusBarang'><font color='red'><i class='fa fa-trash-o'></i> Hapus</a></font>";
			}

			$data[] = $nestedData;
		}

		$json_data = array(
			"draw"            => intval( $requestData['draw'] ),  
			"recordsTotal"    => intval( $totalData ),  
			"recordsFiltered" => intval( $totalFiltered ), 
			"data"            => $data
			);

		echo json_encode($json_data);
	}

	public function hapus($id_barang)
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'inventory')
		{
			if($this->input->is_ajax_request())
			{
				$this->load->model('m_barang');
				$hapus = $this->m_barang->hapus_barang($id_barang);
				if($hapus)
				{
					$this->session->set_flashdata('flash','menghapus data');
				}
				else
				{
					$this->session->set_flashdata('gagal','menghapus data');
				}
			}
		}
	}

	public function tambah()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'inventory')
		{
			if($_POST)
			{
				$this->load->library('form_validation');

				$no = 0;
				foreach($_POST['nama'] as $kode)
				{
					$this->form_validation->set_rules('nama['.$no.']','Nama Barang #'.($no + 1),'trim|required|max_length[60]|alpha_numeric_spaces');
					$this->form_validation->set_rules('id_kategori_barang['.$no.']','Kategori #'.($no + 1),'trim|required');
					$this->form_validation->set_rules('stok['.$no.']','Stok #'.($no + 1),'trim|required|numeric|max_length[10]|callback_cek_titik[stok['.$no.']]');
					$this->form_validation->set_rules('harga['.$no.']','Harga #'.($no + 1),'trim|required|numeric|min_length[4]|max_length[10]|callback_cek_titik[harga['.$no.']]');
					$no++;
				}
				
				
					$this->load->model('m_barang');

				$no_array = 0;
				$inserted = 0;
				foreach($_POST['nama'] as $k)
				{
					$nama 				= $_POST['nama'][$no_array];
					$id_kategori_barang	= $_POST['id_kategori_barang'][$no_array];
					$id_ukuran 			= $_POST['id_ukuran'][$no_array];
					$stok 				= $_POST['stok'][$no_array];
					$modal				= $_POST['modal'][$no_array];
					$harga 				= $_POST['harga'][$no_array];

					$insert = $this->m_barang->tambah_baru($nama, $id_kategori_barang, $id_ukuran, $stok, $modal, $harga);
					if($insert){
						$inserted++;
					}
					$no_array++;
				}

				if($inserted > 0)
				{
					$this->session->set_flashdata('flash','menyimpan data');
					echo json_encode(array(
						'status' => 1,
						'pesan' => "<i class='fa fa-check' style='color:green;'></i> Data barang berhasil dismpan."
					));
				}
				else
				{
					$this->session->set_flashdata('gagal','menyimpan data');
				}
			}
			else
			{
				$this->load->model('m_kategori_barang');
				$this->load->model('m_ukuran');
				$dt['ukuran'] = $this->m_ukuran->get_all();
				$dt['kategori'] = $this->m_kategori_barang->get_all();
				$this->load->view('barang/barang_tambah', $dt);
			}

		}
		else
		{
			exit();
		}
	}


	public function qrcode(){
		
		$this->load->view('barang/modqr');

	}

	public function ajax_cek_kode()
	{
		if($this->input->is_ajax_request())
		{
			$kode = $this->input->post('kodenya');
			$this->load->model('m_barang');

			$cek_kode = $this->m_barang->cek_kode($kode);
			if($cek_kode->num_rows() > 0)
			{
				echo json_encode(array(
					'status' => 0,
					'pesan' => "<font color='red'>Kode sudah ada</font>"
				));
			}
			else
			{
				echo json_encode(array(
					'status' => 1,
					'pesan' => ''
				));
			}
		}
	}

	public function exist_kode($kode)
	{
		$this->load->model('m_barang');
		$cek_kode = $this->m_barang->cek_kode($kode);

		if($cek_kode->num_rows() > 0)
		{
			return FALSE;
		}
		return TRUE;
	}

	public function cek_titik($angka)
	{
		$pecah = explode('.', $angka);
		if(count($pecah) > 1){
			return FALSE;
		}
		return TRUE;
	}

	public function edit($id_barang = NULL)
	{
		if( ! empty($id_barang))
		{
			$level = $this->session->userdata('ap_level');
			if($level == 'admin' OR $level == 'inventory')
			{
				if($this->input->is_ajax_request())
				{
					$this->load->model('m_barang');
					
					if($_POST)
					{
							$nama 				= $this->input->post('nama_barang');
							$id_kategori_barang	= $this->input->post('id_kategori_barang');
							$ukuran 			= $this->input->post('id_ukuran');
							$stok 				= $this->input->post('total_stok');
							$modal				= $this->input->post('modal');
							$harga 				= $this->input->post('harga');
							
							$update = $this->m_barang->update_barang($id_barang, $nama, $id_kategori_barang, $ukuran, $stok, $modal, $harga);
							if($update)
							{
								$this->session->set_flashdata('flash','mengedit data');
							
							}
							else
							{
								$this->session->set_flashdata('gagal','mengedit data');
							}
					}
					else
					{
						$this->load->model('m_kategori_barang');
						$this->load->model('m_ukuran');
						$dt['ukuran'] = $this->m_ukuran->get_all();
						$dt['barang'] 	= $this->m_barang->get_baris($id_barang)->row();
						$dt['kategori'] = $this->m_kategori_barang->get_all();
						$this->load->view('barang/barang_edit', $dt);
					}
				}
			}
		}
	}

	public function list_kategori()
	{
		$this->load->view('barang/kategori/kategori_data');
	}

	public function list_kategori_json()
	{
		$this->load->model('m_kategori_barang');
		$level 			= $this->session->userdata('ap_level');

		$requestData	= $_REQUEST;
		$fetch			= $this->m_kategori_barang->fetch_data_kategori($requestData['search']['value'], $requestData['order'][0]['column'], $requestData['order'][0]['dir'], $requestData['start'], $requestData['length']);
		
		$totalData		= $fetch['totalData'];
		$totalFiltered	= $fetch['totalFiltered'];
		$query			= $fetch['query'];

		$data	= array();
		foreach($query->result_array() as $row)
		{ 
			$nestedData = array(); 

			$nestedData[]	= $row['nomor'];
			$nestedData[]	= $row['kategori'];
			$nestedData[]	= $row['nama_rasa'];


			if($level == 'admin' OR $level == 'inventory')
			{
				$nestedData[]	= "<a href='".site_url('barang/edit-kategori/'.$row['id_kategori_barang'])."' id='EditKategori'><i class='fa fa-pencil'></i> Edit</a>";
				$nestedData[]	= "<a href='".site_url('barang/hapus-kategori/'.$row['id_kategori_barang'])."' id='HapusKategori'><font color='red'><i class='fa fa-trash-o'></i> Hapus</a></font>";
			}

			$data[] = $nestedData;
		}

		$json_data = array(
			"draw"            => intval( $requestData['draw'] ),  
			"recordsTotal"    => intval( $totalData ),  
			"recordsFiltered" => intval( $totalFiltered ), 
			"data"            => $data
			);

		echo json_encode($json_data);
	}

	public function tambah_kategori()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'inventory')
		{
			if($_POST)
			{
				$this->load->library('form_validation');
				$this->form_validation->set_rules('kategori','Kategori','trim|required|max_length[40]|alpha_numeric_spaces');				
				$this->form_validation->set_message('required','%s harus diisi !');
				$this->form_validation->set_message('alpha_numeric_spaces', '%s Harus huruf / angka !');

				if($this->form_validation->run() == TRUE)
				{
					$this->load->model('m_kategori_barang');
					$kategori 	= $this->input->post('kategori');
					$id_rasa 	= $this->input->post('id_rasa');
					$insert 	= $this->m_kategori_barang->tambah_kategori($kategori, $id_rasa);
					if($insert)
					{
						$this->session->set_flashdata('flash','menambah kategori');
					}
					else
					{
						$this->session->set_flashdata('gagal','menambah kategori');
					}
				}
				else
				{
					$this->input_error();
				}
			}
			else
			{
				$this->load->model('m_rasa');
				$dt['rasa'] 	= $this->m_rasa->get_all();
				$this->load->view('barang/kategori/kategori_tambah', $dt);
			}
		}
	}

	public function hapus_kategori($id_kategori_barang)
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'inventory')
		{
			if($this->input->is_ajax_request())
			{
				$this->load->model('m_kategori_barang');
				$hapus = $this->m_kategori_barang->hapus_kategori($id_kategori_barang);
				if($hapus)
				{
					$this->session->set_flashdata('flash','menghapus kategori');
				}
				else
				{
					$this->session->set_flashdata('gagal','menghapus kategori');
				}
			}
		}
	}

	public function edit_kategori($id_kategori_barang = NULL)
	{
		if( ! empty($id_kategori_barang))
		{
			$level = $this->session->userdata('ap_level');
			if($level == 'admin' OR $level == 'inventory')
			{
				if($this->input->is_ajax_request())
				{
					$this->load->model('m_kategori_barang');
					
					if($_POST)
					{
						$this->load->library('form_validation');
						$this->form_validation->set_rules('kategori','Kategori','trim|required|max_length[40]|alpha_numeric_spaces');				
						$this->form_validation->set_message('required','%s harus diisi !');
						$this->form_validation->set_message('alpha_numeric_spaces', '%s Harus huruf / angka !');

						if($this->form_validation->run() == TRUE)
						{
							$kategori 	= $this->input->post('kategori');
							$id_rasa	= $this->input->post('id_akses'); 
							$insert 	= $this->m_kategori_barang->update_kategori($id_kategori_barang, $kategori, $id_rasa);
							if($insert)
							{
								$this->session->set_flashdata('flash','mengedit kategori');
							}
							else
							{
								$this->session->set_flashdata('gagal','mengedit kategori');
							}
						}
						else
						{
							$this->input_error();
						}
					}
					else
					{
						$this->load->model('m_rasa');
						$dt['rasa'] 	= $this->m_rasa->get_all();
						$dt['kategori'] = $this->m_kategori_barang->get_baris($id_kategori_barang)->row();
						$this->load->view('barang/kategori/kategori_edit', $dt);
					}
				}
			}
		}
	}

	public function cek_stok()
	{
		if($this->input->is_ajax_request())
		{
			$this->load->model('m_barang');
			$kode = $this->input->post('id_barang');
			$stok = $this->input->post('stok');

			$get_stok = $this->m_barang->get_stok($kode);
			if($stok > $get_stok->row()->total_stok)
			{
				echo json_encode(array('status' => 0, 'pesan' => "Stok untuk <b>".$get_stok->row()->nama_barang."</b> saat ini hanya tersisa <b>".$get_stok->row()->total_stok."</b> !"));
			}
			else
			{
				echo json_encode(array('status' => 1));
			}
		}
	}
}
