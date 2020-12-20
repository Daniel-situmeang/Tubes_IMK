<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>9Transaction</title>
		<link href='<?php echo config_item('assets'); ?>bg/log.png' type='image/x-icon' rel='shortcut icon'>
		<!-- <link href="<?php echo config_item('bootstrap'); ?>css/bootstrap.min.css" rel="stylesheet"> -->
		<link href="<?php echo config_item('boot4'); ?>dist/css/bootstrap.min.css" rel="stylesheet">
		<link href="<?php echo config_item('bootstrap'); ?>css/bootstrap-theme.min.css" rel="stylesheet">
		<link href="<?php echo config_item('font_awesome'); ?>css/font-awesome.min.css" rel="stylesheet">
		<link href="<?php echo config_item('css'); ?>extended.css" rel="stylesheet">
		<!-- <script src="<?php echo config_item('js'); ?>jquery.min.js"></script> -->
		<script src="<?php echo config_item('assets'); ?>jQuery/jquery-3.5.1.min.js"></script>
		
		<script>
		var habiscuy;
		$(document).on({
			ajaxStart: function() { 
				habiscuy = setTimeout(function(){
					$("#LoadingDulu").html("<div id='LoadingContent' class='spinner-grow text-primary' role='status' > <span class='visually-hidden'>Loading...</span></div>");
					$("#LoadingDulu").show();
				}, 500);
			},
			ajaxStop: function() { 
				clearTimeout(habiscuy);
				$("#LoadingDulu").hide(); 
			}
		});
		function AutoRefresh( t ) {
               setTimeout("location.reload(true);", t);
            }
		</script>
	</head>
	<body>
		<div id='LoadingDulu' class="col-sm-12"></div>
		<div class="flash-data" data-flashdata="<?=$this->session->flashdata('flash');?>"></div>
<div class="gagal-data" data-gagal="<?=$this->session->flashdata('gagal');?>"></div>
