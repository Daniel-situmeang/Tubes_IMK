	<!-- <script src="<?php echo config_item('js'); ?>vendors.min.js"></script> -->
    <!-- <script src="<?php echo config_item('js'); ?>switchery.min.js"></script> -->
	<script src="<?php echo config_item('boot4'); ?>dist/js/bootstrap.min.js"></script>
	<!-- <script src="<?php echo config_item('js'); ?>prism.min.js" type="text/javascript"></script> -->
	<script src="<?php echo config_item('js'); ?>scroll.js"></script>
	<script src="<?php echo config_item('js'); ?>height.js"></script>
	<script src="<?php echo config_item('js'); ?>fullscreen.js"></script>

	<!-- <script src="<?php echo config_item('js'); ?>pace.min.js" type="text/javascript"></script> -->
	
		<div class="modal fade" id="ModalGue" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header" style="background-image: linear-gradient(270deg, #2839AA, #0AB6FF);">
						<h4 class="modal-title" style="color:white;" id="ModalHeader"></h4>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div class="modal-body" id="ModalContent"></div>
					<div class="modal-footer bg-dark" id="ModalFooter"></div>
				</div>
			</div>
		</div>
		
		<script>
		$('#ModalGue').on('hide.bs.modal', function () {
		   setTimeout(function(){ 
		   		$('#ModalHeader, #ModalContent, #ModalFooter').html('');
		   }, 500);
		});
		</script>
	<script src="<?= config_item('sweet');?>package/dist/sweetalert2.all.min.js"></script>
	<script src="<?php echo config_item('js'); ?>skripku.js"></script>
	</body>
</html>
