<?php echo form_open('barang/edit-kategori/'.$kategori->id_kategori_barang, array('id' => 'FormEditkategori')); ?>
<div class='form-group'>
	<?php
	echo form_input(array(
		'name' => 'kategori', 
		'class' => 'form-control',
		'value' => $kategori->kategori
	));
	?>
</div>
<div class='form-group'>
	<label>Varian</label>
	<select name='id_akses' class='form-control'>
	<?php
	foreach($rasa->result() as $a)
	{
		$selected = '';
		if($a->id_rasa == $kategori->id_rasa){
			$selected = 'selected';
		}
		echo "<option value='".$a->id_rasa."'".$selected.">".$a->nama_rasa."</option>";
	}
	?>
	</select>
</div>
<?php echo form_close(); ?>

<div id='ResponseInput'></div>

<script>
function EditKategori()
{
	$.ajax({
		url: $('#FormEditkategori').attr('action'),
		type: "POST",
		cache: false,
		data: $('#FormEditkategori').serialize(),
		dataType:'json',
		success: function(json){
			if(json.status == 1){ 
				$('#ResponseInput').html(json.pesan);
				setTimeout(function(){ 
			   		$('#ResponseInput').html('');
			    }, 3000);
				$('#my-grid').DataTable().ajax.reload( null, false );
			}
			else {
				$('#ResponseInput').html(json.pesan);
			}
		}
	});
}

$(document).ready(function(){
	var Tombol = "<button type='button' class='btn btn-primary' id='SimpanEditKategori' onClick='window.location.reload();'>Update Data</button>";
	Tombol += "<button type='button' class='btn btn-default' data-dismiss='modal'>Tutup</button>";
	$('#ModalFooter').html(Tombol);

	$("#FormEditkategori").find('input[type=text],textarea,select').filter(':visible:first').focus();

	$('#SimpanEditKategori').click(function(e){
		e.preventDefault();
		EditKategori();
	});

	$('#FormEditkategori').submit(function(e){
		e.preventDefault();
		EditKategori();
	});
});
</script>
