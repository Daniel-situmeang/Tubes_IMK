<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.2/css/bootstrap.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
<?php echo form_open('barang/tambah', array('id' => 'FormTambahBarang')); ?>
<div class='table-responsive-sm'>
<table class='table table-striped mt-5 table-light text-center' id='TabelTambahBarang'>
	<thead class="thead-dark">
		<tr>
			<th>#</th>
			<th>Nama Barang</th>
			<th>Kategori</th>
			<th>Ukuran</th>
			<th>Stok</th>
			<th>Modal</th>
			<th>Harga</th>
			<th>Batal</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>
</div>
<?php echo form_close(); ?>

<button id='BarisBaru' class='btn btn-primary'>Baris Baru</button>
<div id='ResponseInput'></div>

<script>
$(document).ready(function(){
	var Tombol = "<button type='button' class='btn btn-primary' id='SimpanTambahBarang'>Simpan Data</button>";
	Tombol += "<button type='button' class='btn btn-default' data-dismiss='modal'>Tutup</button>";
	$('#ModalFooter').html(Tombol);

	BarisBaru();

	$('#BarisBaru').click(function(){
		BarisBaru();
	});

	$('#SimpanTambahBarang').click(function(e){
		e.preventDefault();

		if($(this).hasClass('disabled'))
		{
			return false;
		}
		else
		{
			if($('#FormTambahBarang').serialize() !== '')
			{
				$.ajax({
					url: $('#FormTambahBarang').attr('action'),
					type: "POST",
					cache: false,
					data: $('#FormTambahBarang').serialize(),
					dataType:'json',
					beforeSend:function(){
						$('#SimpanTambahBarang').html("Menyimpan Data, harap tunggu ...");
						location.reload();
					},
					success: function(json){
						if(json.status == 1){ 
							$('.modal-dialog').removeClass('modal-lg');
							$('.modal-dialog').addClass('modal-sm');
							$('#ModalHeader').html('Sukses !');
							$('#ModalContent').html(json.pesan);
							$('#ModalFooter').html("<button type='button' class='btn btn-primary' data-dismiss='modal'>Ok</button>");
							$('#ModalGue').modal('show');
							$('#my-grid').DataTable().ajax.reload( null, false );
						}
						else {
							$('#ResponseInput').html(json.pesan);
						}

						$('#SimpanTambahBarang').html('Simpan Data');
					}
				});
			}
			else
			{
				$('#ResponseInput').html('');
			}
		}
	});

	$("#FormTambahBarang").find('input[type=text],textarea,select').filter(':visible:first').focus();
});

$(document).on('click', '#HapusBaris', function(e){
	e.preventDefault();
	$(this).parent().parent().remove();

	var Nomor = 1;
	$('#TabelTambahBarang tbody tr').each(function(){
		$(this).find('td:nth-child(1)').html(Nomor);
		Nomor++;
	});

	$('#SimpanTambahBarang').removeClass('disabled');
});

function BarisBaru()
{
	var Nomor = $('#TabelTambahBarang tbody tr').length + 1;
	var Baris = "<tr>";
	Baris += "<td>"+Nomor+"</td>";
	Baris += "<td><input type='text' name='nama[]' class='form-control input-sm'></td>";
	Baris += "<td>";
	Baris += "<select name='id_kategori_barang[]' class='form-control input-sm' style='width:100px;'>";
	Baris += "<option value=''></option>";

	<?php 
	if($kategori->num_rows() > 0)
	{
		foreach($kategori->result() as $k) { ?>
			Baris += "<option value='<?php echo $k->id_kategori_barang; ?>'><?php echo $k->kategori; ?></option>";
		<?php }
	}
	?>

	Baris += "</select>";
	Baris += "</td>";

	Baris += "<td>";
	Baris += "<select name='id_ukuran[]' class='form-control input-sm' style='width:100px;'>";
	Baris += "<option value=''></option>";

	<?php 
	if($ukuran->num_rows() > 0)
	{
		foreach($ukuran->result() as $k) { ?>
			Baris += "<option value='<?php echo $k->id_ukuran; ?>'><?php echo $k->ukuran; ?></option>";
		<?php }
	}
	?>

	Baris += "</select>";
	Baris += "</td>";

	Baris += "<td><input type='text' name='stok[]' class='form-control input-sm' onkeypress='return check_int(event)'></td>";
	Baris += "<td><input type='text' name='modal[]' class='form-control input-sm' onkeypress='return check_int(event)'></td>";
	Baris += "<td><input type='text' name='harga[]' class='form-control input-sm' onkeypress='return check_int(event)'></td>";
	Baris += "<td align='center'><a href='#' id='HapusBaris' class='btn btn-danger'><i class='fa fa-times'></i></a></td>";
	Baris += "</tr>";

	$('#TabelTambahBarang tbody').append(Baris);
}

function check_int(evt) {
	var charCode = ( evt.which ) ? evt.which : event.keyCode;
	return ( charCode >= 48 && charCode <= 57 || charCode == 8 );
}
</script>
