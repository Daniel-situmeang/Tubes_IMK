<style>
    .lebar{
        width: 20%;
    }
</style>
<body class="bg-secondary">
    

<div class="container bg-light">
    <form action="" class="mt-5" method="POST">
        <br>
        <div class="input-group mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="inputGroup-sizing-default">Nama Barang</span>
          </div>
          <input type="text" class="form-control" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-default" name="nama_barang">
        </div>
          <div class="input-group  mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="inputGroup-sizing-default">Stok</span>
          </div>
          <input type="number" class="form-control" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-default" name="stok">
        </div>
          <div class="input-group  mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="inputGroup-sizing-default">Modal</span>
          </div>
          <input type="number" class="form-control" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-default" name="modal">
        </div>
        <div class="input-group  mb-3">
          <div class="input-group-prepend">
            <span class="input-group-text" id="inputGroup-sizing-default">Harga</span>
          </div>
          <input type="number" class="form-control" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-default" name="harga">
        </div>
        <div class="input-group mb-3">
          <div class="input-group-prepend">
            <label class="input-group-text" for="inputGroupSelect01">Kategori Barang</label>
          </div>
          <select class="custom-select" id="inputGroupSelect01" name="kategori">
            <option selected>Pilih</option>
            <option value="1">One</option>
            <option value="2">Two</option>
            <option value="3">Three</option>
          </select>
        </div>
<?php    

    $PNG_TEMP_DIR = 'C:\xampp\htdocs\Progkasir\assets'.DIRECTORY_SEPARATOR.'temp'.DIRECTORY_SEPARATOR;

    $PNG_WEB_DIR = base_url('assets/temp/');

    $this->load->view('tambah_barang/qrlib.php');    
    if (!file_exists($PNG_TEMP_DIR))
        mkdir($PNG_TEMP_DIR);
    
    
    $filename = $PNG_TEMP_DIR.'test.png';
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
        QRcode::png($_REQUEST['data'], $filename, $errorCorrectionLevel, $matrixPointSize, 2);    
        
    } else {    
    
        //default data
        echo 'You can provide data in GET parameter: <a href="?data=like_that">like that</a><hr/>';    
        QRcode::png('PHP QR Code :)', $filename, $errorCorrectionLevel, $matrixPointSize, 2);    
        
    }    
        
    //display generated file
    echo '<center><img src="'.$PNG_WEB_DIR.basename($filename).'" class="img-fluid" alt="Responsive image" /></center><hr/>';  
    ?>
    <?php
    //config form
    echo '
        <center>
            <div class="row">
                <div class="form-group col-md-3">
                    <label for="inputData">Data</label>
                    <input name="data" value="'.(isset($_REQUEST['data'])?htmlspecialchars($_REQUEST['data']):'PHP QR Code :)').'" id="inputData"  class="form-control" />
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
        </div>
        <hr/></div></center>';
        
    // benchmark
    // QRtools::timeBenchmark();

    ?> 
    <br><br>
        <div class="form-group col-md-12">
            <input type="submit" class="btn btn-primary btn-lg btn-block" value="Tambahkan Barang">
        </div>
        <br>
    </form>
    </div>
    </body>
