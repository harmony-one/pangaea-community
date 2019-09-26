<?php

/** Initialize session data. */
session_start();
if (!isset($_SESSION['username'], $_SESSION['valid'])) {
  session_destroy();
  header("location:login.php");
}

?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
  <meta name="description" content="Harmony Pangaea Log Feed">
  <meta name="keywords" content="Harmony, Pangaea, Log Feed">
  <meta name="author" content="K Gordon">

  <title>Harmony Pangaea | Log Feed</title>

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
  <link href="assets/vendor/font-awesome/5.11.2/css/all.css" rel="stylesheet">
  <!-- Custom Bootstrap styles for this template -->
  <link href="assets/default/css/bootstrap.purple.min.css" rel="stylesheet">
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
            <a class="nav-link" href="balance.php"><i class="fas fa-coins"></i> Balance</a>
          </li>
          <li class="nav-item">
            <a class="nav-link active" href="logfeed.php"><i class="fas fa-link"></i> Log Feed</a>
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
  <main>
    <div id="result">

    </div>
  </main>
  <!-- ./Main -->

  <!-- Info Modal -->
  <div class="modal fade" id="overlay">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h4 class="modal-title"><i class="fas fa-bell"></i> Notice</h4>
        </div>
        <div class="modal-body">
          <p>This page will automatically refresh periodically every 60 seconds to fetch the latest information.</p>
        </div>
      </div>
    </div>
  </div>
  <!-- ./Info Modal -->

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
  <script src="assets/default/js/default.js"></script>

</body>

</html>