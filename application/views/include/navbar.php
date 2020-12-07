<?php
$controller = $this->router->fetch_class();
$level = $this->session->userdata('ap_level');
?>
<style>
.bg-menu{
	background-image: linear-gradient(180deg, #213754, #213754);
}
</style>
<nav class="navbar navbar-expand-lg navbar-dark" style="  background-image: linear-gradient(270deg, #2839AA, #0AB6FF);">
	
			<a class="navbar-brand" href="<?php echo site_url(); ?>">
			<img height="40px" src="<?php echo config_item('assets'); ?>bg/logo.png" />
			</a>
			<button type="button" class="navbar-toggler" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
				<span class="navbar-toggler-icon"></span>
				
			</button>

		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="navbar-nav mr-auto">

				<?php if($level == 'admin' OR $level == 'keuangan' OR $level == 'kasir') { ?>
				<li class="nav-item dropdown <?php if($controller == 'penjualan') { echo 'bg-menu active'; } ?>">
					<a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" id="penjualan" ><i class='fa fa-shopping-cart fa-fw'></i> Penjualan <span class="caret"></span></a>
					<ul class="dropdown-menu">
						<?php if($level !== 'keuangan'){ ?>
						<li><a class="dropdown-item" href="<?php echo site_url('penjualan/transaksi'); ?>">Transaksi</a></li>
						<?php } ?>
						<li><a class="dropdown-item" href="<?php echo site_url('penjualan/history'); ?>">History Penjualan</a></li>
						<div class="dropdown-divider"></div>
						<li><a class="dropdown-item" href="<?php echo site_url('penjualan/pelanggan'); ?>">Data Pelanggan</a></li>
					</ul>
				</li>
				<?php } ?>

				<li class="nav-item dropdown <?php if($controller == 'barang') { echo 'bg-menu active'; } ?>">
					<a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class='fa fa-cube fa-fw'></i> Barang <span class="caret"></span></a>
					<ul class="dropdown-menu">
						<li><a class="dropdown-item" href="<?php echo site_url('barang'); ?>">Semua Barang</a></li>
						<div class="dropdown-divider"></div>
						<li><a class="dropdown-item" href="<?php echo site_url('barang/list-kategori'); ?>">List Kategori</a></li>
					</ul>
				</li>

				<?php if($level == 'admin' OR $level == 'keuangan') { ?>
				<li class="nav-item dropdown <?php if($controller == 'laporan') { echo 'bg-menu active'; } ?>">
					<a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class='fa fa-file-text-o fa-fw'></i> Laporan <span class="caret"></span></a>
					<ul class="dropdown-menu">
						<li><a class="dropdown-item" href="<?php echo site_url('laporan'); ?>">Laporan Penjualan</a></li>
						<li><a class="dropdown-item" href="<?php echo site_url('laporan/untung'); ?>">Laporan Keuntungan</a></li>
					</ul>
				</li>
				<?php } ?>

				<?php if($level == 'admin') { ?>
				<li <?php if($controller == 'user') { echo "class='nav-item bg-menu active'"; } ?>><a  class="nav-link" href="<?php echo site_url('user'); ?>"><i class='fa fa-users fa-fw'></i> List User</a></li>
				<?php } ?>
			</ul>

			<ul class="nav navbar-nav navbar-right mr-5">
				<li class="nav-item dropdown">
					<a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class='fa fa-user fa-fw'></i> <?php echo $this->session->userdata('ap_nama'); ?> <span class="caret"></span></a>
					<ul class="dropdown-menu">
						<li><a class="dropdown-item mb-2"><?php echo $this->session->userdata('ap_level_caption'); ?></a></li>
						<li><a class="dropdown-item"  href="<?php echo site_url('user/ubah-password'); ?>" id='GantiPass'>Ubah Password</a></li>
						<li role="separator" class="divider"></li>
						<li><a class="dropdown-item" href="<?php echo site_url('secure/logout'); ?>"><i class='fa fa-sign-out fa-fw'></i> Log Out</a></li>
					</ul>
				</li>
			</ul>
		</div>
</nav>
<br><br>

<script>
$(document).on('click', '#GantiPass', function(e){
	e.preventDefault();

	$('.modal-dialog').removeClass('modal-lg');
	$('.modal-dialog').addClass('modal-sm');
	$('#ModalHeader').html('Ubah Password');
	$('#ModalContent').load($(this).attr('href'));
	$('#ModalGue').modal('show');
});
</script>
<!-- <style>
	body{
	background:url(<?php echo config_item('assets'); ?>bg/ay.png); 
    background-position: center center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    background-size: cover;

}
</style> -->
<body>
	


