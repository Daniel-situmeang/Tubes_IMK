<?php $this->load->view('elements/navbar'); ?>
<body>
<?php 
$laman = $this->uri->segment('2');
if(null!==($laman)){
	$page = $laman;
	switch ($page){
		case 'tambah';
		$this->load->view('tambah_barang/tambah');
		break;
		case 'tampil';
		$this->load->view('tampil/index');
		break;
	}
}
else{
  $this->load->view('tampil/index');
}
?>
