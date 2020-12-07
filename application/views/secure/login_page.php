<?php $this->load->view('include/header'); ?>
<style>
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
<style>
	body{
	background: url(<?php echo config_item('assets'); ?>bg/bgkan.png); 
    background-position: center center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    background-size: cover;

}
.login-panel{
	box-shadow: 0 0 50px black;
}

.bg-gambar{
	background-image: linear-gradient(180deg, #213754, #213754);
}
</style>	

</head>
<body>


	<div class="karusel">
		<div class="container-fluid">
			<br><br><br><br><br><br>
			<div class="row login-panel">
			<div class="col-5 bg-gambar">
			<img src="<?php echo config_item('assets'); ?>bg/landing.png" alt="Responsive image" class="">
			</div>
			<div class="col-12 col-lg-7 bg-light ">
			<div class="">
				<center>
					<br>
					<img height="85px" src="<?php echo config_item('assets'); ?>bg/9t.png" />
				</center>
				<div class='panel panel-default'>
					<div class='panel-body'>
						<br>
						<?php echo form_open('secure', array('id' => 'FormLogin')); ?>
							<div class="form-group ml-4 mr-4">
								<div class="input-group">
									<div class="input-group-prepend " id="inputGroup-sizing-default">
										<span class='input-group-text font-weight-bolder'>Username</span>
									</div>
									<?php 
									echo form_input(array(
										'name' => 'username', 
										'class' => 'form-control', 
										'autocomplete' => 'off', 
										'autofocus' => 'autofocus',
										'aria-label'=>'Sizing example input',
										'aria-describedby'=>'inputGroup-sizing-default'
									)); 
									?>
								</div>
							</div>
							<div class="form-group ml-4 mr-4">
								<div class="input-group">
									<div class="input-group-prepend " id="inputGroup-sizing-pass">
									<span class='input-group-text font-weight-bolder'>Password</span>
									</div>
									<?php 
									echo form_password(array(
										'name' => 'password', 
										'class' => 'form-control', 
										'id' => 'InputPassword',
										'aria-label'=>'Sizing example input',
										'aria-describedby'=>'inputGroup-sizing-pass'
									)); 
									?>
								</div>
							</div>

							<div class="form-group ml-4 mr-4">
								<br>
							<button type="submit" class="btn btn-success btn-md btn-block" >
								<span class='glyphicon glyphicon-log-in' aria-hidden="true"></span> Sign In
							</button>
							<br>
							<button type="reset" class="btn btn-dark btn-md btn-block" id='ResetData'>Reset</button>
							<br><br>
							</div>
						<?php echo form_close(); ?>

						<div id='ResponseInput'></div>
					</div>
				</div>
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


