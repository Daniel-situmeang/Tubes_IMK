const flashData = $('.flash-data').data('flashdata');
const gagalData = $('.gagal-data').data('gagal');
const warningData = $('.warning-data').data('warning');

if(flashData) {
	Swal.fire({
	title: 'Selamat ',
	text: 'Anda Berhasil ' + flashData,
	icon: 'success'
	});
}

else if(gagalData) {
	Swal.fire({
	title: 'Maaf ',
	text: 'Terjadi error saat ' + gagalData,
	icon: 'error'
	});
}

else if(warningData) {
	Swal.fire({
	title: 'Maaf ',
	text: 'Harap isi ' + warningData,
	icon: 'error'
	});
}
