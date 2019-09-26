<?php

/** Initialize session data. */
session_start();
if (!isset($_SESSION['username'], $_SESSION['valid'])) {
  session_destroy();
  header("location:login.php");
}

/** Sets the default timezone used by all date/time functions in a script. */
date_default_timezone_set('UTC');

/** Set Site Base URL */
if (!defined('BASE_URL')) {
  /** Define BASE_URL structure  */
  define('BASE_URL', (!empty($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . '/');
}

/** Get the network status from Harmony (Reads entire file into a string) */
$network        = file_get_contents('https://harmony.one/pga/network');

/** Get the balances from Harmony (Reads entire file into a string) */
$TotalBalance   = file_get_contents('https://harmony.one/pga/balances.json');
$PerHour        = file_get_contents('https://harmony.one/pga/1h.json');
$PerFourHours   = file_get_contents('https://harmony.one/pga/4h.json');
$PerDay         = file_get_contents('https://harmony.one/pga/24h.json');

/** Decode the JSON strings into associative arrays. */
$TotalBalance   = json_decode($TotalBalance, true);
$PerHour        = json_decode($PerHour, true);
$PerFourHours   = json_decode($PerFourHours, true);
$PerDay         = json_decode($PerDay, true);

/** Combind associative arrays to a single array */
$master         = comb($TotalBalance['onlineNodes'], $PerHour['onlineNodes'], 'address', 'ONEsPerHour');
$master         = comb($master, $PerFourHours['onlineNodes'], 'address', 'ONEsPerFourHours');
$master         = comb($master, $PerDay['onlineNodes'], 'address', 'ONEsPerDay');

/** Construct a regex to get shard/block status */
$re = '/Shard \d .+!/m';
$str = $network;
preg_match_all($re, $str, $online, PREG_SET_ORDER, 0);

/** Merge associative array value where keys match */
function comb($array1, $array2, $key, $value)
{
  $result = array();
  foreach ($array1 as $data1) {
    foreach ($array2 as $data2) {
      if ($data1[$key] == $data2[$key]) {
        $tmp = array($value => $data2[$value]);
        $tmp = array_merge($data1, $tmp);
        $result[] = $tmp;
      }
    }
  }
  return $result;
};

?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
  <meta name="description" content="Harmony Pangaea Balance">
  <meta name="keywords" content="Harmony, Pangaea, Balance">
  <meta name="author" content="K Gordon">

  <title>Harmony Pangaea | Balance</title>

  <link rel="apple-touch-icon" sizes="180x180" href="assets/default/img/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="assets/default/img/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="assets/default/img/favicon/favicon-16x16.png">
  <link rel="manifest" href="assets/default/img/favicon/site.webmanifest">
  <link rel="mask-icon" href="assets/default/img/favicon/safari-pinned-tab.svg" color="#563d7c">
  <link rel="shortcut icon" href="assets/default/img/favicon/favicon.ico">
  <meta name="msapplication-TileColor" content="#563d7c">
  <meta name="msapplication-config" content="assets/default/img/favicon/browserconfig.xml">
  <meta name="theme-color" content="#ffffff">

  <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Bootstrap core CSS -->
  <link href="assets/vendor/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">
  <!-- FontAwesome core CSS -->
  <link href="assets/vendor/font-awesome/5.11.2/css/all.min.css" rel="stylesheet">
  <!-- Custom Bootstrap styles for this template -->
  <link href="assets/default/css/bootstrap.purple.min.css" rel="stylesheet">
  <!-- Datatables core CSS -->
  <link href="assets/vendor/datatables/1.10.18/css/datatables.min.css" rel="stylesheet">
  <!-- Custom CSS -->
  <link href="assets/default/css/default.css" rel="stylesheet">

</head>

<body>

  <!-- Header -->
  <header>
    <!-- Nav -->
    <nav class="navbar navbar-expand-lg fixed-top navbar-dark bg-primary">
      <a class="navbar-brand" href="https://docs.harmony.one/pangaea/welcome-to-pangaea"><i class="fas fa-coins"></i> Harmony Pangaea Helpers</a>
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ml-auto">
          <li class="nav-item">
            <a class="nav-link active" href="balance.php"><i class="fas fa-coins"></i> Balance</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="logfeed.php"><i class="fas fa-link"></i> Log Feed</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="index.php"><i class="fas fa-server"></i> Shard Status</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="logout.php"><i class="fas fa-sign-out-alt"></i> Logout</a>
          </li>
        </ul>
      </div>
    </nav>
    <!-- ./Nav -->
  </header>
  <!-- ./Header -->

  <!-- Main Content -->
  <main class="container">
    <div class="row">
      <div class="col-lg-12">
        <!-- Card Content -->
        <div class="card my-5">
          <div class="card-header text-white bg-primary">
            <div class="card-title my-auto">
              <div class="row">
                <div class="col-md text-left">
                  <h5 class="my-auto">Nodes Online: <?= count($PerHour['onlineNodes']) ?> </h5>
                </div>
                <div class="col-md text-right">
                  <h5 class="my-auto">Last updated: <?= $TotalBalance['date'] ?></h5>
                </div>
              </div>
            </div>
          </div>
          <div class="card-body">
            <!-- Card Body Content -->
            <div class="table-responsive">
              <table id="pga" class="table table-striped table-sm">
                <thead>
                  <tr>
                    <th>Address</th>
                    <th>Shard</th>
                    <th>1 hour</th>
                    <th>4 hours</th>
                    <th>24 hours</th>
                    <th>Total balance</th>
                  </tr>
                </thead>
                <tbody>
                  <?php
                  // Loop through array
                  foreach ($master as $key => $value) {
                    ?>
                    <tr>
                      <td><?= $value['address'] ?></td>
                      <td><?= $value['shard'] ?></td>
                      <td><?= $value['ONEsPerHour'] ?></td>
                      <td><?= $value['ONEsPerFourHours'] ?></td>
                      <td><?= $value['ONEsPerDay'] ?></td>
                      <td><?= $value['totalBalance'] ?></td>
                    </tr>
                  <?php } ?>
                </tbody>
                <tfoot>
                  <tr>
                    <th>Address</th>
                    <th>Shard</th>
                    <th>1 hour</th>
                    <th>4 hours</th>
                    <th>24 hours</th>
                    <th>Total balance</th>
                  </tr>
                </tfoot>
              </table>
            </div>
            <!-- ./Card Body Content -->
          </div>
        </div>
        <!-- ./Card Content -->
      </div>
    </div>
    </div>
    <!-- ./Page Content -->
  </main>
  <!-- ./Main -->
  </main>
  <!-- ./Main -->

  <!-- Footer -->
  <footer>
    <div class="container copyright">
      Copyright &#169; <?= date("Y") ?> <a class="text-muted" href="<?= BASE_URL; ?>"
      target="_blank"> <?= $_SERVER['HTTP_HOST']; ?></a> | All Rights Reserved
    </div>
  </footer>
  <!-- ./Footer -->

  <!-- Bootstrap core JavaScript (Including jQuery dependency)
         ================================================== -->
  <!-- Placed at the end of the document so the pages load faster -->
  <script src="assets/vendor/jquery/3.4.1/jquery-3.4.1.min.js"></script>
  <script src="assets/vendor/bootstrap/4.3.1/js/bootstrap.bundle.min.js"></script>
  <script src="assets/vendor/datatables/1.10.18/js/datatables.min.js"></script>
  <script src="assets/default/js/default.js"></script>

</body>

</html>