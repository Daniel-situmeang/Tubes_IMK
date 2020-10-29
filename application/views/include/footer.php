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
					<div class="modal-header" style="background-color: #FF8C00">
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
	</body>
</html>
