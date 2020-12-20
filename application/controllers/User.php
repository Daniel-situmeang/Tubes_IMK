<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class User extends MY_Controller 
{
	public function index()
	{
		$level = $this->session->userdata('ap_level');
		if($level !== 'admin')
		{
			exit();
		}
		else
		{
			$this->load->view('user/user_data');
		}
	}

	public function user_json()
	{
		$this->load->model('m_user');

		$requestData	= $_REQUEST;
		$fetch			= $this->m_user->fetch_data_user($requestData['search']['value'], $requestData['order'][0]['column'], $requestData['order'][0]['dir'], $requestData['start'], $requestData['length']);
		
		$totalData		= $fetch['totalData'];
		$totalFiltered	= $fetch['totalFiltered'];
		$query			= $fetch['query'];

		$data	= array();
		foreach($query->result_array() as $row)
		{ 
			$nestedData = array(); 

			$nestedData[]	= $row['nomor'];
			$nestedData[]	= $row['username'];
			$nestedData[]	= $row['nama'];
			$nestedData[]	= $row['level_akses'];
			$nestedData[]	= $row['status_user'];
			$nestedData[]	= "<a href='".site_url('user/edit/'.$row['id_user'])."' id='EditUser'><i class='fa fa-pencil'></i> Edit</a>";
			
			if($row['label'] !== 'admin')
			{
				$nestedData[]	= "<a href='".site_url('user/hapus/'.$row['id_user'])."' id='HapusUser'><font color='red'><i class='fa fa-trash-o'></i> Hapus</font></a>";
			}

			if($row['label'] == 'admin')
			{
				$nestedData[]	= '';
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

	public function hapus($id_user)
	{
		$level = $this->session->userdata('ap_level');
		if($level !== 'admin')
		{
			exit();
		}
		else
		{
			if($this->input->is_ajax_request())
			{
				$this->load->model('m_user');
				$hapus = $this->m_user->hapus_user($id_user);
				if($hapus)
				{
					$this->session->set_flashdata('flash','menghapus data karyawan');
				}
				else
				{
					$this->session->set_flashdata('gagal','menghapus data karyawan');
				}
			}
		}
	}

	public function tambah()
	{
		$level = $this->session->userdata('ap_level');
		if($level !== 'admin')
		{
			exit();
		}
		else
		{
			if($_POST)
			{
				$this->load->model('m_user');

				$username 	= $this->input->post('username');
				$password 	= $this->input->post('password');
				$nama		= $this->input->post('nama');
				$id_akses	= $this->input->post('id_akses');
				$status		= $this->input->post('status');

				$insert = $this->m_user->tambah_baru($username, $password, $nama, $id_akses, $status);
				

				if($insert > 0)
				{
					$this->session->set_flashdata('flash','menambah data karyawan');
				}
				else
				{
					$this->session->set_flashdata('gagal','menambah data karyawan');
				}
			}
			else
			{
				$this->load->model('m_akses');
				$dt['akses'] 	= $this->m_akses->get_all();
				$this->load->view('user/user_tambah', $dt);
			}
		}
	}

	public function exist_username($username)
	{
		$this->load->model('m_user');
		$cek_user = $this->m_user->cek_username($username);

		if($cek_user->num_rows() > 0)
		{
			return FALSE;
		}
		return TRUE;
	}

	public function edit($id_user = NULL)
	{
		$level = $this->session->userdata('ap_level');
		if($level !== 'admin')
		{
			exit();
		}
		else
		{
			if( ! empty($id_user))
			{
				if($this->input->is_ajax_request())
				{
					$this->load->model('m_user');
					
					if($_POST)
					{
						$this->load->library('form_validation');

						$username 		= $this->input->post('username');
						$username_old	= $this->input->post('username_old');

						$callback			= '';
						if($username !== $username_old){
							$callback = "|callback_exist_username[username]";
						}

						$password 		= $this->input->post('password');
						$nama			= $this->input->post('nama');
						$id_akses		= $this->input->post('id_akses');
						$status_user	= $this->input->post('status');

						$update = $this->m_user->update_user($id_user, $username, $password, $nama, $id_akses, $status_user);
						if($update)
						{
							$label = $this->input->post('label');
							if($label == 'admin')
							{
								$this->session->set_userdata('ap_nama', $nama);
							}

							$this->session->set_flashdata('flash','mengedit data karyawan');
						}
						else
						{
							$this->session->set_flashdata('gagal','menambah data karyawan');
						}
					}
					else
					{
						$this->load->model('m_akses');
						$dt['user'] 	= $this->m_user->get_baris($id_user)->row();
						$dt['akses'] 	= $this->m_akses->get_all();
						$this->load->view('user/user_edit', $dt);
					}
				}
			}
		}
	}

	public function ubah_password()
	{
		if($this->input->is_ajax_request())
		{
			if($_POST)
			{
				$this->load->library('form_validation');
				$this->form_validation->set_rules('pass_old','Password Lama','trim|required|max_length[60]|callback_check_pass[pass_old]');
				$this->form_validation->set_rules('pass_new','Password Baru','trim|required|max_length[60]');
				$this->form_validation->set_rules('pass_new_confirm','Ulangi Password Baru','trim|required|max_length[60]|matches[pass_new]');
				$this->form_validation->set_message('required','%s harus diisi !');
				$this->form_validation->set_message('check_pass','%s anda salah !');

				if($this->form_validation->run() == TRUE)
				{
					$this->load->model('m_user');
					$pass_new 	= $this->input->post('pass_new');

					$update 	= $this->m_user->update_password($pass_new);
					if($update)
					{
						$this->session->set_userdata('ap_password', sha1($pass_new));

						$this->session->set_flashdata('flash','mengubah password data karyawan');
					}
					else
					{
						$this->session->set_flashdata('gagal','mengedit data karyawan');
					}
				}
				else
				{
					$this->session->set_flashdata('gagal','mengedit data karyawan');
				}
			}
			else
			{
				$this->load->view('user/change_pass');
			}
		}
	}

	public function check_pass($pass)
	{
		$this->load->model('m_user');
		$cek_user = $this->m_user->cek_password($pass);

		if($cek_user->num_rows() > 0)
		{
			return TRUE;
		}
		return FALSE;
	}
}
