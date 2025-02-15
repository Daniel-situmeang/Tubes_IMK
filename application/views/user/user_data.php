<?php $this->load->view('include/header'); ?>
<?php $this->load->view('include/navbar'); ?>

<?php
$level = $this->session->userdata('ap_level');
?>

<div class="container bg-light">
	<br>
	<div class="panel panel-default">
		<div class="panel-body">
			<h3><i class='fa fa-users fa-fw'></i> Daftar Karyawan</h3>
			<hr />
			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.2/css/bootstrap.css">
    		<link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
			<div class='table-responsive-sm'>
				<table id="my-grid" class="table table-striped table-bordered mt-5 table-dark text-center">
					<thead style="background-image: linear-gradient(270deg, #2839AA, #0AB6FF);">
						<tr class="warning">
							<th>#</th>
							<th>Username</th>
							<th>Nama Lengkap</th>
							<th>Akses</th>
							<th>Status</th>
							<th class='no-sort'>Edit</th>
							<th class='no-sort'>Hapus</th>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</div>
	<br>
</div>

<?php
$tambahan = nbs(2)."<a href='".site_url('user/tambah')."' class='btn btn-primary' id='TambahUser'><i class='fa fa-user-plus fa-fw'></i> Tambah Karyawan</a>";
$tambahan .= nbs(2)."<span id='Notifikasi' style='display: none;'></span>";
?>

<script type="text/javascript" language="javascript" >
	$(document).ready(function() {
		var dataTable = $('#my-grid').DataTable( {
			"serverSide": true,
			"stateSave" : false,
			"bAutoWidth": true,
			"oLanguage": {
				"sSearch": "<i class='fa fa-search fa-fw'></i> Pencarian : ",
				"sLengthMenu": "_MENU_ &nbsp;&nbsp;Data Per Halaman <?php echo $tambahan; ?>",
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
				url :"<?php echo site_url('user/user-json'); ?>",
				type: "post",
				error: function(){ 
					$(".my-grid-error").html("");
					$("#my-grid").append('<tbody class="my-grid-error"><tr><th colspan="3">No data found in the server</th></tr></tbody>');
					$("#my-grid_processing").css("display","none");
				}
			}
		} );
	});
	
	$(document).on('click', '#HapusUser', function(e){
		e.preventDefault();
		var Link = $(this).attr('href');

		$('.modal-dialog').removeClass('modal-lg');
		$('.modal-dialog').addClass('modal-sm');
		$('#ModalHeader').html('Konfirmasi');
		$('#ModalContent').html('Apakah anda yakin ingin menghapus <br /><b>'+$(this).parent().parent().find('td:nth-child(3)').html()+'</b> ?');
		$('#ModalFooter').html("<button type='button' class='btn btn-primary' id='YesDelete' data-url='"+Link+"' onClick='window.location.reload();'>Ya, saya yakin</button><button type='button' class='btn btn-default' data-dismiss='modal'>Batal</button>");
		$('#ModalGue').modal('show');
	});

	$(document).on('click', '#YesDelete', function(e){
		e.preventDefault();
		$('#ModalGue').modal('hide');

		$.ajax({
			url: $(this).data('url'),
			type: "POST",
			cache: false,
			dataType:'json',
			success: function(data){
				$('#Notifikasi').html(data.pesan);
				$("#Notifikasi").fadeIn('fast').show().delay(3000).fadeOut('fast');
				$('#my-grid').DataTable().ajax.reload( null, false );
			}
		});
	});

	$(document).on('click', '#TambahUser, #EditUser', function(e){
		e.preventDefault();
		if($(this).attr('id') == 'TambahUser')
		{
			$('.modal-dialog').removeClass('modal-lg');
			$('.modal-dialog').removeClass('modal-sm');
			$('#ModalHeader').html('Tambah User');
		}
		if($(this).attr('id') == 'EditUser')
		{
			$('.modal-dialog').removeClass('modal-lg');
			$('.modal-dialog').removeClass('modal-sm');
			$('#ModalHeader').html('Edit User');
		}
		$('#ModalContent').load($(this).attr('href'));
		$('#ModalGue').modal('show');
	});
</script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js"></script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
<?php $this->load->view('include/footer'); ?>
