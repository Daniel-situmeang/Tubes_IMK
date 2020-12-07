<?php
defined('BASEPATH') OR exit('No direct script access allowed');


class Penjualan extends MY_Controller 
{
	function __construct()
	{
		parent::__construct();
		if($this->session->userdata('ap_level') == 'inventory'){
			redirect();
		}
	}

	public function index()
	{
		$this->transaksi();
	}

	public function transaksi()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'kasir')
		{
			if($_POST)
			{
				if( ! empty($_POST['id_barang']))
				{
					$total = 0;
					foreach($_POST['id_barang'] as $k)
					{
						if( ! empty($k)){ $total++; }
					}

					if($total > 0)
					{
						$this->load->library('form_validation');
						$this->form_validation->set_rules('nomor_nota','Nomor Nota','trim|required|max_length[40]|alpha_numeric|callback_cek_nota[nomor_nota]');
						$this->form_validation->set_rules('tanggal','Tanggal','trim|required');
						
						$no = 0;
						foreach($_POST['id_barang'] as $d)
						{
							if( ! empty($d))
							{
								$this->form_validation->set_rules('id_barang['.$no.']','Kode Barang #'.($no + 1), 'trim|required|max_length[40]|callback_cek_id_barang[id_barang['.$no.']]');
								$this->form_validation->set_rules('jumlah_beli['.$no.']','Qty #'.($no + 1), 'trim|numeric|required|callback_cek_nol[jumlah_beli['.$no.']]');
							}

							$no++;
						}
						
						$this->form_validation->set_rules('cash','Total Bayar', 'trim|numeric|required|max_length[17]');
						$this->form_validation->set_rules('catatan','Catatan', 'trim|max_length[1000]');

						$this->form_validation->set_message('required', '%s harus diisi');
						$this->form_validation->set_message('cek_id_barang', '%s tidak ditemukan');
						$this->form_validation->set_message('cek_nota', '%s sudah ada');
						$this->form_validation->set_message('cek_nol', '%s tidak boleh nol');
						$this->form_validation->set_message('alpha_numeric', '%s Harus huruf / angka !');

						if($this->form_validation->run() == TRUE)
						{
							$nomor_nota 	= $this->input->post('nomor_nota');
							$tanggal		= $this->input->post('tanggal');
							$id_kasir		= $this->input->post('id_kasir');
							$id_pelanggan	= $this->input->post('id_pelanggan');
							$bayar			= $this->input->post('cash');
							//$grand_modal	= $this->input->post('grand_modal');
							$grand_modal	= "0";
							//$grand_modal	= $this->m_penjualan_master->ambil_grand_total($id_penjualan_m)
							$grand_total	= $this->input->post('grand_total');
							$catatan		= $this->clean_tag_input($this->input->post('catatan'));

							if($bayar < $grand_total)
							{
								$this->query_error("Cash Kurang");
							}
							else
							{
								$this->load->model('m_penjualan_master');
								$master = $this->m_penjualan_master->insert_master($nomor_nota, $tanggal, $id_kasir, $id_pelanggan, $bayar, $grand_modal, $grand_total, $catatan);
								if($master)
								{
									$id_master 	= $this->m_penjualan_master->get_id($nomor_nota)->row()->id_penjualan_m;
									$inserted	= 0;

									$this->load->model('m_penjualan_detail');
									$this->load->model('m_barang');

									$no_array	= 0;
									foreach($_POST['id_barang'] as $k)
									{
										if( ! empty($k))
										{
											$id_barang 		= $_POST['id_barang'][$no_array];
											$jumlah_beli 	= $_POST['jumlah_beli'][$no_array];
											$harga_satuan 	= $_POST['harga_satuan'][$no_array];
											$sub_total 		= $_POST['sub_total'][$no_array];
											$id_barang		= $this->m_barang->get_id($id_barang)->row()->id_barang;
											
											$insert_detail	= $this->m_penjualan_detail->insert_detail($id_master, $id_barang, $jumlah_beli, $harga_satuan, $sub_total);
											if($insert_detail)
											{
												$this->m_barang->update_stok($id_barang, $jumlah_beli);
												$inserted++;
											}
										}

										$no_array++;
									}
									
									/////////////////////////////////
									$id_penjualan_m = $id_master;
									$grandmodal = $this->m_penjualan_master->ambil_grand_total($id_penjualan_m);
									
									//echo "THE GRAND MODAL IS: ".$grandmodal;
									//exit;
									
									$this->m_penjualan_master->ubah_grand_total($id_penjualan_m,$grandmodal);
									/////////////////////////////////

									if($inserted > 0)
									{
										echo json_encode(array('status' => 1, 'pesan' => "Transaksi berhasil disimpan !"));
									}
									else
									{
										$this->query_error();
									}
								}
								else
								{
									$this->query_error();
								}
							}
						}
						else
						{
							echo json_encode(array('status' => 0, 'pesan' => validation_errors("<font color='red'>- ","</font><br />")));
						}
					}
					else
					{
						$this->query_error("Harap masukan minimal 1 kode barang !");
					}
				}
				else
				{
					$this->query_error("Harap masukan minimal 1 kode barang !");
				}
			}
			else
			{
				$this->load->model('m_user');
				$this->load->model('m_pelanggan');

				$dt['kasirnya'] = $this->m_user->list_kasir();
				$dt['pelanggan']= $this->m_pelanggan->get_all();
				$this->load->view('penjualan/transaksi', $dt);
			}
		}
	}


	public function cek_nota($nota)
	{
		$this->load->model('m_penjualan_master');
		$cek = $this->m_penjualan_master->cek_nota_validasi($nota);

		if($cek->num_rows() > 0)
		{
			return FALSE;
		}
		return TRUE;
	}

	public function transaksi_cetak()
	{
		$nomor_nota 	= $this->input->get('nomor_nota');
		$tanggal		= $this->input->get('tanggal');
		$id_kasir		= $this->input->get('id_kasir');
		$id_pelanggan	= $this->input->get('id_pelanggan');
		$cash			= $this->input->get('cash');
		$catatan		= $this->input->get('catatan');
		$grand_total	= $this->input->get('grand_total');

		$this->load->model('m_user');
		$kasir = $this->m_user->get_baris($id_kasir)->row()->nama;
		
		$this->load->model('m_pelanggan');
		$pelanggan = 'umum';
		if( ! empty($id_pelanggan))
		{
			$pelanggan = $this->m_pelanggan->get_baris($id_pelanggan)->row()->nama;
		}

		$this->load->library('Cfpdf');		
		$pdf = new FPDF('P','mm','A5');
		$pdf->AddPage();
		$pdf->SetFont('Arial','',10);

		$pdf->Cell(25, 4, 'Nota', 0, 0, 'L'); 
		$pdf->Cell(85, 4, $nomor_nota, 0, 0, 'L');
		$pdf->Ln();
		$pdf->Cell(25, 4, 'Tanggal', 0, 0, 'L'); 
		$pdf->Cell(85, 4, date('d-M-Y H:i:s', strtotime($tanggal)), 0, 0, 'L');
		$pdf->Ln();
		$pdf->Cell(25, 4, 'Kasir', 0, 0, 'L'); 
		$pdf->Cell(85, 4, $kasir, 0, 0, 'L');
		$pdf->Ln();
		$pdf->Cell(25, 4, 'Pelanggan', 0, 0, 'L'); 
		$pdf->Cell(85, 4, $pelanggan, 0, 0, 'L');
		$pdf->Ln();
		$pdf->Ln();

		$pdf->Cell(130, 5, '-----------------------------------------------------------------------------------------------------------', 0, 0, 'L');
		$pdf->Ln();
		
		$pdf->Cell(25, 5, 'Kode', 0, 0, 'L');
		$pdf->Cell(40, 5, 'Item', 0, 0, 'L');
		$pdf->Cell(25, 5, 'Harga', 0, 0, 'L');
		$pdf->Cell(15, 5, 'Qty', 0, 0, 'L');
		$pdf->Cell(25, 5, 'Subtotal', 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(130, 5, '-----------------------------------------------------------------------------------------------------------', 0, 0, 'L');
		$pdf->Ln();

		$this->load->model('m_barang');
		$this->load->helper('text');

		$no = 0;
		foreach($_GET['id_barang'] as $kd)
		{
			if( ! empty($kd))
			{
				$nama_barang = $this->m_barang->get_id($kd)->row()->nama_barang;
				$nama_barang = character_limiter($nama_barang, 20, '..');

				$pdf->Cell(25, 5, $kd, 0, 0, 'L');
				$pdf->Cell(40, 5, $nama_barang, 0, 0, 'L');
				$pdf->Cell(25, 5, str_replace(',', '.', number_format($_GET['harga_satuan'][$no])), 0, 0, 'L');
				$pdf->Cell(15, 5, $_GET['jumlah_beli'][$no], 0, 0, 'L');
				$pdf->Cell(25, 5, str_replace(',', '.', number_format($_GET['sub_total'][$no])), 0, 0, 'L');
				$pdf->Ln();

				$no++;
			}
		}

		$pdf->Cell(130, 5, '-----------------------------------------------------------------------------------------------------------', 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(105, 5, 'Total Bayar', 0, 0, 'R');
		$pdf->Cell(25, 5, str_replace(',', '.', number_format($grand_total)), 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(105, 5, 'Cash', 0, 0, 'R');
		$pdf->Cell(25, 5, str_replace(',', '.', number_format($cash)), 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(105, 5, 'Kembali', 0, 0, 'R');
		$pdf->Cell(25, 5, str_replace(',', '.', number_format(($cash - $grand_total))), 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(130, 5, '-----------------------------------------------------------------------------------------------------------', 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(25, 5, 'Catatan : ', 0, 0, 'L');
		$pdf->Ln();
		$pdf->Cell(130, 5, (($catatan == '') ? 'Tidak Ada' : $catatan), 0, 0, 'L');
		$pdf->Ln();

		$pdf->Cell(130, 5, '-----------------------------------------------------------------------------------------------------------', 0, 0, 'L');
		$pdf->Ln();
		$pdf->Ln();
		$pdf->Cell(130, 5, "Terimakasih telah berbelanja dengan kami", 0, 0, 'C');

		$pdf->Output();
	}

	public function ajax_pelanggan()
	{
		if($this->input->is_ajax_request())
		{
			$id_pelanggan = $this->input->post('id_pelanggan');
			$this->load->model('m_pelanggan');

			$data = $this->m_pelanggan->get_baris($id_pelanggan)->row();
			$json['telp']			= ( ! empty($data->telp)) ? $data->telp : "<small><i>Tidak ada</i></small>";
			$json['alamat']			= ( ! empty($data->alamat)) ? preg_replace("/\r\n|\r|\n/",'<br />', $data->alamat) : "<small><i>Tidak ada</i></small>";
			$json['status_anggota']			= ( ! empty($data->status_anggota)) ? preg_replace("/\r\n|\r|\n/",'<br />', $data->status_anggota) : "<small><i>Tidak ada</i></small>";
			$json['info_tambahan']	= ( ! empty($data->info_tambahan)) ? preg_replace("/\r\n|\r|\n/",'<br />', $data->info_tambahan) : "<small><i>Tidak ada</i></small>";
			echo json_encode($json);
		}
	}

	public function ajax_kode()
	{
		if($this->input->is_ajax_request())
		{
			$keyword 	= $this->input->post('keyword');
			$registered	= $this->input->post('registered');

			$this->load->model('m_barang');

			$barang = $this->m_barang->cari_kode($keyword, $registered);

			if($barang->num_rows() > 0)
			{
				$json['status'] 	= 1;
				$json['datanya'] 	= "<ul id='daftar-autocomplete'>";
				foreach($barang->result() as $b)
				{
					$json['datanya'] .= "
						<li>
							<b>Kode</b> : 
							<span id='kodenya'>".$b->id_barang."</span> <br />
							<span id='barangnya'>".$b->nama_barang."</span>
							<span id='harganya' style='display:none;'>".$b->harga."</span>
						</li>
					";
				}
				$json['datanya'] .= "</ul>";
			}
			else
			{
				$json['status'] 	= 0;
			}

			echo json_encode($json);
		}
	}

	public function cek_id_barang($kode)
	{
		$this->load->model('m_barang');
		$cek_kode = $this->m_barang->cek_kode($kode);

		if($cek_kode->num_rows() > 0)
		{
			return TRUE;
		}
		return FALSE;
	}

	public function cek_nol($qty)
	{
		if($qty > 0){
			return TRUE;
		}
		return FALSE;
	}

	public function history()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'kasir' OR $level == 'keuangan')
		{
			$this->load->view('penjualan/transaksi_history');
		}
	}

	public function history_json()
	{
		$this->load->model('m_penjualan_master');
		$level 			= $this->session->userdata('ap_level');

		$requestData	= $_REQUEST;
		$fetch			= $this->m_penjualan_master->fetch_data_penjualan($requestData['search']['value'], $requestData['order'][0]['column'], $requestData['order'][0]['dir'], $requestData['start'], $requestData['length']);
		
		$totalData		= $fetch['totalData'];
		$totalFiltered	= $fetch['totalFiltered'];
		$query			= $fetch['query'];

		$data	= array();
		foreach($query->result_array() as $row)
		{ 
			$nestedData = array(); 

			$nestedData[]	= $row['nomor'];
			$nestedData[]	= $row['tanggal'];
			$nestedData[]	= "<a href='".site_url('penjualan/detail-transaksi/'.$row['id_penjualan_m'])."' id='LihatDetailTransaksi'><i class='fa fa-file-text-o fa-fw'></i> ".$row['nomor_nota']."</a>";
			$nestedData[]	= $row['grand_modal'];
			$nestedData[]	= $row['grand_total'];
			$nestedData[]	= $row['nama_pelanggan'];
			$nestedData[]	= preg_replace("/\r\n|\r|\n/",'<br />', $row['keterangan']);
			$nestedData[]	= $row['kasir'];
		
			if($level == 'admin' OR $level == 'keuangan')
			{
				$nestedData[]	= "<a href='".site_url('penjualan/hapus-transaksi/'.$row['id_penjualan_m'])."' id='HapusTransaksi'><font color='red'><i class='fa fa-trash-o'></i> Hapus</font></a>";
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

	public function detail_transaksi($id_penjualan)
	{
		if($this->input->is_ajax_request())
		{
			$this->load->model('m_penjualan_detail');
			$this->load->model('m_penjualan_master');

			$dt['detail'] = $this->m_penjualan_detail->get_detail($id_penjualan);
			$dt['master'] = $this->m_penjualan_master->get_baris($id_penjualan)->row();
			
			$this->load->view('penjualan/transaksi_history_detail', $dt);
		}
	}

	public function hapus_transaksi($id_penjualan)
	{
		if($this->input->is_ajax_request())
		{
			$level 	= $this->session->userdata('ap_level');
			if($level == 'admin')
			{
				$reverse_stok = $this->input->post('reverse_stok');

				$this->load->model('m_penjualan_master');

				$nota 	= $this->m_penjualan_master->get_baris($id_penjualan)->row()->nomor_nota;
				$hapus 	= $this->m_penjualan_master->hapus_transaksi($id_penjualan, $reverse_stok);
				if($hapus)
				{
					echo json_encode(array(
						"pesan" => "<font color='green'><i class='fa fa-check'></i> Transaksi <b>".$nota."</b> berhasil dihapus !</font>
					"));
				}
				else
				{
					echo json_encode(array(
						"pesan" => "<font color='red'><i class='fa fa-warning'></i> Terjadi kesalahan, coba lagi !</font>
					"));
				}
			}
		}
	}

	public function pelanggan()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'kasir' OR $level == 'keuangan')
		{
			$this->load->view('penjualan/pelanggan_data');
		}
	}

	public function pelanggan_json()
	{
		$this->load->model('m_pelanggan');
		$level 			= $this->session->userdata('ap_level');

		$requestData	= $_REQUEST;
		$fetch			= $this->m_pelanggan->fetch_data_pelanggan($requestData['search']['value'], $requestData['order'][0]['column'], $requestData['order'][0]['dir'], $requestData['start'], $requestData['length']);
		
		$totalData		= $fetch['totalData'];
		$totalFiltered	= $fetch['totalFiltered'];
		$query			= $fetch['query'];

		$data	= array();
		foreach($query->result_array() as $row)
		{ 
			$nestedData = array(); 

			$nestedData[]	= $row['nomor'];
			$nestedData[]	= $row['nama'];
			$nestedData[]	= preg_replace("/\r\n|\r|\n/",'<br />', $row['alamat']);
			$nestedData[]	= $row['telp'];
			$nestedData[]	= preg_replace("/\r\n|\r|\n/",'<br />', $row['info_tambahan']);
			$nestedData[]	= $row['waktu_input'];
			$nestedData[]	= $row['status_anggota'];
			
			if($level == 'admin' OR $level == 'kasir' OR $level == 'keuangan') 
			{
				$nestedData[]	= "<a href='".site_url('penjualan/pelanggan-edit/'.$row['id_pelanggan'])."' id='EditPelanggan'><i class='fa fa-pencil'></i> Edit</a>";
			}

			if($level == 'admin') 
			{
				$nestedData[]	= "<a href='".site_url('penjualan/pelanggan-hapus/'.$row['id_pelanggan'])."' id='HapusPelanggan'><font color='red'><i class='fa fa-trash-o'></i> Hapus</font></a>";
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

	public function tambah_pelanggan()
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin' OR $level == 'kasir' OR $level == 'keuangan')
		{
			if($_POST)
			{
				$this->load->model('m_pelanggan');
				$nama 		= $this->input->post('nama');
				$alamat 	= $this->clean_tag_input($this->input->post('alamat'));
				$telepon 	= $this->input->post('telepon');
				$info 		= $this->clean_tag_input($this->input->post('info'));

				$unique		= time().$this->session->userdata('ap_id_user');
				$insert 	= $this->m_pelanggan->tambah_pelanggan($nama, $alamat, $telepon, $info, $unique);
				if($insert)
				{
					$id_pelanggan = $this->m_pelanggan->get_dari_kode($unique)->row()->id_pelanggan;
					echo json_encode(array(
						'status' => 1,
						'pesan' => "<div class='alert alert-success'><i class='fa fa-check'></i> <b>".$nama."</b> berhasil ditambahkan sebagai pelanggan.</div>",
						'id_pelanggan' => $id_pelanggan,
						'nama' => $nama,
						'alamat' => preg_replace("/\r\n|\r|\n/",'<br />', $alamat),
						'telepon' => $telepon,
						'info' => (empty($info)) ? "<small><i>Tidak ada</i></small>" : preg_replace("/\r\n|\r|\n/",'<br />', $info)						
					));
				}
				else
				{
					$this->query_error();
				}
			}
			else
			{
				$this->load->view('penjualan/pelanggan_tambah');
			}
		}
	}

	public function pelanggan_edit($id_pelanggan = NULL)
	{
		if( ! empty($id_pelanggan))
		{
			$level = $this->session->userdata('ap_level');
			if($level == 'admin' OR $level == 'kasir' OR $level == 'keuangan')
			{
				if($this->input->is_ajax_request())
				{
					$this->load->model('m_pelanggan');
					
					if($_POST)
					{
						$nama 		= $this->input->post('nama');
						$alamat 	= $this->clean_tag_input($this->input->post('alamat'));
						$telepon 	= $this->input->post('telepon');
						$info 		= $this->clean_tag_input($this->input->post('info'));
						$status 	= $this->input->post('status');

						$update 	= $this->m_pelanggan->update_pelanggan($id_pelanggan, $nama, $alamat, $telepon, $info, $status);
						if($update)
						{
							echo json_encode(array(
								'status' => 1,
								'pesan' => "<div class='alert alert-success'><i class='fa fa-check'></i> Data berhasil diupdate.</div>"
							));
						}
						else
						{
							$this->query_error();
						}
					}
					else
					{

						$dt['pelanggan'] = $this->m_pelanggan->get_baris($id_pelanggan)->row();
						$this->load->view('penjualan/pelanggan_edit', $dt);
					}
				}
			}
		}
	}

	public function cari_ID(){
		$id = $this->input->post('id');
		$dbs = $this->db->where('id_barang', $id)->get('pj_barang');
		$row = $dbs->row();
		$nrow = $dbs->num_rows();

		if ($nrow==0) {
			$json = array('status' => "false", 'id' => $id);
		}else{
			$json = array(
				'status' => "true",
				'id' => $id,
				'nama' => $row->nama_barang,
				'harga' => $row->harga
			 );
		}
		$jsonD = json_encode($json);
		echo $jsonD;
	}

	public function pelanggan_hapus($id_pelanggan)
	{
		$level = $this->session->userdata('ap_level');
		if($level == 'admin')
		{
			if($this->input->is_ajax_request())
			{
				$this->load->model('m_pelanggan');
				$hapus = $this->m_pelanggan->hapus_pelanggan($id_pelanggan);
				if($hapus)
				{
					echo json_encode(array(
						"pesan" => "<font color='green'><i class='fa fa-check'></i> Data berhasil dihapus !</font>
					"));
				}
				else
				{
					echo json_encode(array(
						"pesan" => "<font color='red'><i class='fa fa-warning'></i> Terjadi kesalahan, coba lagi !</font>
					"));
				}
			}
		}
	}
}
