<head>
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
  <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css" integrity="sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2" crossorigin="anonymous">
  <title>Kasir</title>
<nav class="navbar navbar-expand-lg navbar-secondary bg-secondary">
  <a class="navbar-brand" href="<?=base_url();?>"><img alt="<?php echo config_item('web_title'); ?>" src="<?php echo config_item('img'); ?>logo_small.png"></a>
</nav>
</head>

<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js" integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.min.js" integrity="sha384-w1Q4orYjBQndcko6MimVbzY0tgp4pWB4lZ7lr30WKz0vr/aWKhXdBNmNb5D92v7s" crossorigin="anonymous"></script>
<br>
<div class="container bg-light">
<?php    
$nama_barang = $this->uri->segment(4);
$this->load->model('M_barang');
/*
 * PHP QR Code encoder
 *
 * Exemplatory usage
 *
 * PHP QR Code is distributed under LGPL 3
 * Copyright (C) 2010 Dominik Dzienia <deltalab at poczta dot fm>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */
    echo '<h1>Nama Barang : '.$nama_barang.'</h1>';
 
    $PNG_TEMP_DIR = 'C:\xampp\htdocs\Tubes_IMK\assets'.DIRECTORY_SEPARATOR.'temp'.DIRECTORY_SEPARATOR;

    $PNG_WEB_DIR = base_url('assets/temp/');

    $this->load->view('barang/qrlib.php');    
    
    //ofcourse we need rights to create temp dir
    if (!file_exists($PNG_TEMP_DIR))
        mkdir($PNG_TEMP_DIR);
    
    
    $filename = $PNG_TEMP_DIR.'test.png';
    
    //processing form input
    //remember to sanitize user input in real-life solution !!!
    $errorCorrectionLevel = 'L';
    if (isset($_REQUEST['level']) && in_array($_REQUEST['level'], array('L','M','Q','H')))
        $errorCorrectionLevel = $_REQUEST['level'];    

    $matrixPointSize = 4;
    if (isset($_REQUEST['size']))
        $matrixPointSize = min(max((int)$_REQUEST['size'], 1), 10);


    if (isset($_REQUEST['data'])) { 
    
        //it's very important!
        if (trim($_REQUEST['data']) == '')
            die('data cannot be empty! <a href="?">back</a>');
            
        // user data
        $filename = $PNG_TEMP_DIR.'test'.md5($_REQUEST['data'].'|'.$errorCorrectionLevel.'|'.$matrixPointSize).'.png';
        $gbr = $PNG_WEB_DIR.'test'.md5($_REQUEST['data'].'|'.$errorCorrectionLevel.'|'.$matrixPointSize).'.png';
        $id = $this->uri->segment(3);
        QRcode::png($_REQUEST['data'], $filename, $errorCorrectionLevel, $matrixPointSize, 2);
        $this->M_barang->tambahqrcode($id,$gbr);    
        
    } else {    
    
        //default data
        echo '<br><br>You can provide data in GET parameter: <a href="?data=like_that">like that</a><hr/>';    
        QRcode::png('PHP QR Code :)', $filename, $errorCorrectionLevel, $matrixPointSize, 2);    
        
    }    
        
    //display generated file
    echo '<br><center><img src="'.$PNG_WEB_DIR.basename($filename).'" class="img-fluid" alt="Responsive image" /></center><hr/>';  
    
    //config form
    echo '<form action="" method="post">
        <center>
            <div class="row mt-5">
                <div class="form-group col-md-3">
                    <label for="inputData">Data</label>
                    <input name="data" value="'.(isset($_REQUEST['data'])?htmlspecialchars($_REQUEST['data']):'Input sesuai nama barang').'" id="inputData"  class="form-control" placeholder="Input sesuai nama barang"/>
                </div>
                <div class="form-group col-md-3">
                    <label for="inputEcc">ECC</label>
                    <select name="level" id="inputEcc"  class="form-control">
                        <option value="L"'.(($errorCorrectionLevel=='L')?' selected':'').'>L - smallest</option>
                        <option value="M"'.(($errorCorrectionLevel=='M')?' selected':'').'>M</option>
                        <option value="Q"'.(($errorCorrectionLevel=='Q')?' selected':'').'>Q</option>
                        <option value="H"'.(($errorCorrectionLevel=='H')?' selected':'').'>H - best</option>
                    </select>
                </div>
                <div class="form-group col-md-3">
                    <label for="inputSize">Size</label>
                    <select name="size" id="inputSize" class="form-control">
                ';
        
    for($i=1;$i<=10;$i++)
        echo '<option value="'.$i.'"'.(($matrixPointSize==$i)?' selected':'').'>'.$i.'</option>';
        
    echo '</select></div>
        <div class="form-group col-md-3">
        <br>
        <input type="submit" class="btn btn-success mt-2" value="Buat QRcode">
        </div></center></form><hr/>';
        ?>
</div>
