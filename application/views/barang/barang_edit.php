<?php echo form_open('barang/edit/'.$barang->id_barang, array('id' => 'FormEditBarang')); ?>
<div class="form-horizontal">
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Nama Barang</label>
		<div class="col-sm-8">
			<?php 
			echo form_input(array(
				'name' => 'nama_barang',
				'class' => 'form-control',
				'value' => $barang->nama_barang
			));
			?>
		</div>
	</div>
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Kategori</label>
		<div class="col-sm-8">
			<select name='id_kategori_barang' class='form-control'>
				<option value=''></option>
				<?php
				foreach($kategori->result() as $k)
				{
					$selected = '';
					if($barang->id_kategori_barang == $k->id_kategori_barang){
						$selected = 'selected';
					}
					
					echo "<option value='".$k->id_kategori_barang."' ".$selected.">".$k->kategori."</option>";
				}
				?>
			</select>
		</div>
	</div>
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Ukuran</label>
		<div class="col-sm-8">
			<select name='id_ukuran' class='form-control'>
				<option value=''></option>
				<?php
				foreach($ukuran->result() as $m)
				{
					$selected = '';
					if($barang->id_ukuran == $m->id_ukuran){
						$selected = 'selected';
					}

					echo "<option value='".$m->id_ukuran."' ".$selected.">".$m->ukuran."</option>";
				}
				?>
			</select>
		</div>
	</div>
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Stok</label>
		<div class="col-sm-8">
			<?php 
			echo form_input(array(
				'name' => 'total_stok',
				'class' => 'form-control',
				'value' => $barang->total_stok
			));
			?>
		</div>
	</div>
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Modal</label>
		<div class="col-sm-8">
			<?php 
			echo form_input(array(
				'name' => 'modal',
				'class' => 'form-control',
				'value' => $barang->modal
			));
			?>
		</div>
	</div>
	<div class="form-group row">
		<label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Harga</label>
		<div class="col-sm-8">
			<?php 
			echo form_input(array(
				'name' => 'harga',
				'class' => 'form-control',
				'value' => $barang->harga
			));
			?>
		</div>
	</div>
</div>
<?php echo form_close(); ?>

<div id='ResponseInput'></div>

<center>
	<img src="<?=$barang->qrcode?>" class="img-fluid" alt="Responsive image" />
</center>

<center><a href="<?=site_url('barang/qrcode/')?><?=$barang->id_barang?>/<?=$barang->nama_barang?>" class="btn btn-primary">Input Barcode</a></center>

<script>
$(document).ready(function(){
	var Tombol = "<button type='button' class='btn btn-primary' id='SimpanEditBarang' onClick='window.location.reload();'>Update Data</button>";
	Tombol += "<button type='button' class='btn btn-default' data-dismiss='modal'>Tutup</button>";
	$('#ModalFooter').html(Tombol);

	$('#SimpanEditBarang').click(function(){
		$.ajax({
			url: $('#FormEditBarang').attr('action'),
			type: "POST",
			cache: false,
			data: $('#FormEditBarang').serialize(),
			dataType:'json',
			success: function(json){
				if(json.status == 1){ 
					$('#ResponseInput').html(json.pesan);
					setTimeout(function(){ 
				   		$('#ResponseInput').html('');
				    }, 3000);
					$('#my-grid').DataTable().ajax.reload( null, false );
					location.reload();
				}
				else {
					$('#ResponseInput').html(json.pesan);
				}
			}
		});
	});
});
</script>
