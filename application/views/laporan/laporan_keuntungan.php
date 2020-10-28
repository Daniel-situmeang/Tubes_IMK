<?php if($penjualan->num_rows() > 0) { ?>

	<table class='table table-bordered'>
		<thead>
			<tr>
				<th>#</th>
				<th>Tanggal</th>
				<th>Total Keuntungan</th>
			</tr>
		</thead>
		<tbody>
			<?php
			$no = 1;
			$total_keuntungan = 0;
			foreach($penjualan->result() as $p)
			{
				echo "
					<tr>
						<td>".$no."</td>
						<td>".date('d F Y', strtotime($p->tanggal))."</td>
						<td>Rp. ".str_replace(",", ".", number_format($p->total_keuntungan))."</td>
					</tr>
				";

				$total_keuntungan = $total_keuntungan + $p->total_keuntungan;
				$no++;
			}

			echo "
				<tr>
					<td colspan='2'><b>Total Seluruh Keuntungan</b></td>
					<td><b>Rp. ".str_replace(",", ".", number_format($total_keuntungan))."</b></td>
				</tr>
			";
			?>
		</tbody>
	</table>

	<p>
		<?php
		$from 	= date('Y-m-d', strtotime($from));
		$to		= date('Y-m-d', strtotime($to));
		?>
		<a href="<?php echo site_url('laporan/pdfuntung/'.$from.'/'.$to); ?>" target='blank' class='btn btn-default'><img src="<?php echo config_item('img'); ?>pdf.png"> Export ke PDF</a>
		<a href="<?php echo site_url('laporan/exceluntung/'.$from.'/'.$to); ?>" target='blank' class='btn btn-default'><img src="<?php echo config_item('img'); ?>xls.png"> Export ke Excel</a>
	</p>
	<br />
<?php } ?>

<?php if($penjualan->num_rows() == 0) { ?>
<div class='alert alert-info'>
Data dari tanggal <b><?php echo $from; ?></b> sampai tanggal <b><?php echo $to; ?></b> tidak ditemukan
</div>
<br />
<?php } ?>