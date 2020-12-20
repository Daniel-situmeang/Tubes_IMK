const flashData = $('.flash-data').data('flashdata');
const gagalData = $('.gagal-data').data('gagal');
const hatiData = $('.hati-data').data('hati');

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


else if(gagalData) {
	Swal.fire({
	title: 'Maaf ',
	text: 'Terjadi error saat ' + hatiData,
	icon: 'warning'
	});
}
