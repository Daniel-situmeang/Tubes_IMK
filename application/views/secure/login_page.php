<?php $this->load->view('include/header'); ?>
<style>
$('#toggle').click(function() {
  $('.slide-in').toggleClass('show');
});
.slide-in {
  z-index: 10; /* to position it in front of the other content */
  position: absolute;
  overflow: hidden; /* to prevent scrollbar appearing */
}

.slide-in.from-left {
  left: 0;
}

.slide-in.from-right {
  right: 0;
}

.slide-in-content {
  padding: 5px 20px;
  background: #eee;
  transition: transform .5s ease; /* our nice transition */
}

.slide-in.from-left .slide-in-content {
  transform: translateX(-100%);
  -webkit-transform: translateX(-100%);
}

.slide-in.from-right .slide-in-content {
  transform: translateX(100%);
  -webkit-transform: translateX(100%);
}

.slide-in.show .slide-in-content {
  transform: translateX(0);
  -webkit-transform: translateX(0);
}	
.slide-wrapper {
    position: relative
}

.karusel {
    padding-right: 15px;
    padding-left: 15px;
    margin-right: auto;
    margin-left: auto;
}

.carousel-indicators li { visibility: hidden; }

@media (min-width: 768px) { 
    .carousel-caption {
        text-align: left;
        padding-right: 300px;
    }
    .karusel {
        width: 750px;
        position: absolute;
        left: 50%;
        top: 0;
        bottom: 0;
        padding: 20px 0;
        margin-left: -375px;
    }
}
@media (min-width: 992px) { 
    .karusel {
        width: 970px;
        margin-left: -485px;
    }
}
@media (min-width: 1200px) { 
    .karusel {
        width: 1170px;
        margin-left: -585px;
    }
}

/* MISC */
#homepage-feature .item {
    overflow: hidden;
    height: 400px;
    background-color: transparent;
    background-size: cover;
}
#homepage-feature > .carousel-control {
    width: 30px;
    font-size: 40px;
    color: #fff;
    text-shadow: none;
    filter: none;
    opacity: 1;
}
#homepage-feature > .carousel-control span {
    position: absolute;
    top: 50%;
    margin-top: -30px;
    width: 100%;
    text-align: center;
    display: block;
}
</style>	

</head>
<body>



	<div class="karusel">
		<div class="container-fluid">
			<div class="login-panel">
				<center>
					<img src="<?php echo config_item('img'); ?>logo.png" />
				</center>
				<div class='panel panel-default'>
					<div class='panel-body'>
						<?php echo form_open('secure', array('id' => 'FormLogin')); ?>
							<div class="form-group">
								<label>Username</label>
								<div class="input-group">
									<div class="input-group-addon">
										<span class='glyphicon glyphicon-user'></span>
									</div>
									<?php 
									echo form_input(array(
										'name' => 'username', 
										'class' => 'form-control', 
										'autocomplete' => 'off', 
										'autofocus' => 'autofocus'
									)); 
									?>
								</div>
							</div>
							<div class="form-group">
								<label>Password</label>
								<div class="input-group">
									<div class="input-group-addon">
										<span class='glyphicon glyphicon-lock'></span>
									</div>
									<?php 
									echo form_password(array(
										'name' => 'password', 
										'class' => 'form-control', 
										'id' => 'InputPassword'
									)); 
									?>
								</div>
							</div>

							<button type="submit" class="btn btn-warning">
								<span class='glyphicon glyphicon-log-in' aria-hidden="true"></span> Sign In
							</button>
							<button type="reset" class="btn btn-default" id='ResetData'>Reset</button>
						<?php echo form_close(); ?>

						<div id='ResponseInput'></div>
					</div>
				</div>
				
			</div>
		</div>
		     
		     
		   </div>
		          
		</div>





<script>
$(function(){
	//------------------------Proses Login Ajax-------------------------//
	$('#FormLogin').submit(function(e){
		e.preventDefault();
		$.ajax({
			url: $(this).attr('action'),
			type: "POST",
			cache: false,
			data: $(this).serialize(),
			dataType:'json',
			success: function(json){
				//response dari json_encode di controller

				if(json.status == 1){ window.location.href = json.url_home; }
				if(json.status == 0){ $('#ResponseInput').html(json.pesan); }
				if(json.status == 2){
					$('#ResponseInput').html(json.pesan);
					$('#InputPassword').val('');
				}
			}
		});
	});

	//-----------------------Ketika Tombol Reset Diklik-----------------//
	$('#ResetData').click(function(){
		$('#ResponseInput').html('');
	});
});
</script>

<?php $this->load->view('include/footer'); ?>


