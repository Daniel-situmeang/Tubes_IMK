<?php $this->load->view('include/header'); ?>
<?php $this->load->view('include/navbar'); ?>

<?php
$level = $this->session->userdata('ap_level');
?>

<div class="container">
	<div class="panel panel-default">
		<div class="panel-body">
			<h3><i class='fa fa-shopping-cart fa-fw'></i> Penjualan <i class='fa fa-angle-right fa-fw'></i> History Penjualan</h3>
			<hr />

			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.2/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
			<div class='table-responsive-sm'>
				<table id="my-grid" class="table table-striped mt-5 table-dark text-center">
				<thead style="background-color: #FF8C00">
						<tr>
							<th scope="col" style="width: 5%">#</th>
							<th scope="col" style="width: 20%">Tanggal</th>
							<th scope="col" style="width: 15%">Nomor Nota</th>
							<th scope="col" style="width: 10%">Grand Modal</th>
							<th scope="col" style="width: 10%">Grand Total</th>
							<th scope="col" style="width: 10%">Pelanggan</th>
							<th scope="col" style="width: 10%">Keterangan</th>
							<th scope="col" style="width: 15%">Kasir</th>
							<?php if($level == 'admin') { ?>
							<th class='no-sort' scope="col" style="width: 15%">Hapus</th>
							<?php } ?>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</div>
</div>


<?php
$tambahan = nbs(2)."<span id='Notifikasi' style='display: none;'></span>";
?>

<script type="text/javascript" language="javascript" >
	$(document).ready(function() {
		var dataTable = $('#my-grid').DataTable( {
			"serverSide": true,
			"stateSave" : false,
			"bAutoWidth": true,
			"oLanguage": {
				"sSearch": "&nbsp<i class='fa fa-search fa-fw'></i> Pencarian : ",
				"sLengthMenu": "Data Per Halaman <?php echo $tambahan; ?>_MENU_ &nbsp;&nbsp;",
				"sInfo": "Menampilkan _START_ s/d _END_ dari <b>_TOTAL_ data</b>",
				"sInfoFiltered": "(difilter dari _MAX_ total data)", 
				"sZeroRecords": "Pencarian tidak ditemukan", 
				"sEmptyTable": "Data kosong", 
				"sLoadingRecords": "Harap Tunggu...", 
				"oPaginate": {
					"sPrevious": "Prev",
					"sNext": "Next"
				}
			},
			"aaSorting": [[ 0, "desc" ]],
			"columnDefs": [ 
				{
					"targets": 'no-sort',
					"orderable": false,
				}
	        ],
			"sPaginationType": "simple_numbers", 
			"iDisplayLength": 10,
			"aLengthMenu": [[10, 20, 50, 100, 150], [10, 20, 50, 100, 150]],
			"ajax":{
				url :"<?php echo site_url('penjualan/history-json'); ?>",
				type: "post",
				error: function(){ 
					$(".my-grid-error").html("");
					$("#my-grid").append('<tbody class="my-grid-error"><tr><th colspan="3">No data found in the server</th></tr></tbody>');
					$("#my-grid_processing").css("display","none");
				}
			}
		} );
	});
	
	$(document).on('click', '#HapusTransaksi', function(e){
		e.preventDefault();
		var Link = $(this).attr('href');
		var Check = "<br /><hr style='margin:10px 0px 8px 0px;' /><div class='checkbox'><label><input type='checkbox' name='reverse_stok' value='yes' id='reverse_stok'> Kembalikan stok barang</label></div>";
		$('.modal-dialog').removeClass('modal-lg');
		$('.modal-dialog').addClass('modal-sm');
		$('#ModalHeader').html('Konfirmasi');
		$('#ModalContent').html('Apakah anda yakin ingin menghapus transaksi <b>'+$(this).parent().parent().find('td:nth-child(3)').text()+'</b> ?' + Check);
		$('#ModalFooter').html("<button type='button' class='btn btn-primary' id='YesDelete' data-url='"+Link+"' autofocus>Ya, saya yakin</button><button type='button' class='btn btn-default' data-dismiss='modal'>Batal</button>");
		$('#ModalGue').modal('show');
	});

	$(document).on('click', '#YesDelete', function(e){
		e.preventDefault();
		$('#ModalGue').modal('hide');

		var reverse_stok = 'no';
		if($('#reverse_stok').prop('checked')){
			var reverse_stok = 'yes';
		}

		$.ajax({
			url: $(this).data('url'),
			type: "POST",
			cache: false,
			data: "reverse_stok="+reverse_stok,
			dataType:'json',
			success: function(data){
				$('#Notifikasi').html(data.pesan);
				$("#Notifikasi").fadeIn('fast').show().delay(3000).fadeOut('fast');
				$('#my-grid').DataTable().ajax.reload( null, false );
			}
		});
	});

	$(document).on('click', '#LihatDetailTransaksi', function(e){
		e.preventDefault();
		var CaptionHeader = 'Transaksi Nomor Nota ' + $(this).text();
		$('.modal-dialog').removeClass('modal-sm');
		$('.modal-dialog').addClass('modal-lg');
		$('#ModalHeader').html(CaptionHeader);
		$('#ModalContent').load($(this).attr('href'));
		$('#ModalFooter').html("<button type='button' class='btn btn-primary' data-dismiss='modal'>Tutup</button>");
		$('#ModalGue').modal('show');
	});
</script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js"></script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
<?php $this->load->view('include/footer'); ?>
