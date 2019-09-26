<?php

/** Initialize session data. */
session_start();
if (!isset($_SESSION['username'], $_SESSION['valid'])) {
	session_destroy();
	header("location:login.php");
}

/** Sets the default timezone used by all date/time functions in a script. */
date_default_timezone_set('UTC');

/** Get the network from Harmony (Reads entire file into a string) */
$network   = file_get_contents('https://harmony.one/pga/network.json');

/** Decode the JSON strings into associative arrays. */
$master   = json_decode($network);

/** Network Status */
$Online_Total = ($master->node_count->online);
$Offline_Total = ($master->node_count->offline);

/** Split Shards data to var */
$shard0 = $master->shards->{'0'};
$shard1 = $master->shards->{'1'};
$shard2 = $master->shards->{'2'};
$shard3 = $master->shards->{'3'};

$offline = [];
array_push($offline, (implode(",", $shard0->nodes->offline) . "," . implode(",", $shard1->nodes->offline) . "," . implode(",", $shard2->nodes->offline) . "," . implode(",", $shard3->nodes->offline)));

$online = [];
array_push($online, (implode(",", $shard0->nodes->online) . "," . implode(",", $shard1->nodes->online) . "," . implode(",", $shard2->nodes->online) . "," . implode(",", $shard3->nodes->online)));

?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	<meta name="description" content="Harmony Pangaea Status">
	<meta name="keywords" content="Harmony, Pangaea, Status">
	<meta name="author" content="K Gordon">

	<title>Harmony Pangaea | Status</title>

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
						<a class="nav-link" href="logfeed.php"><i class="fas fa-link"></i> Log Feed</a>
					</li>
					<li class="nav-item">
						<a class="nav-link active" href="index.php"><i class="fas fa-server"></i> Shard Status</a>
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
		<!-- ./Page Content -->
		<div class="row">
			<div class="col-lg-12">
				<!-- Card Content -->
				<div class="card my-5">
					<div class="card-header text-white bg-primary">
						<div class="card-title my-auto">
							<div class="row">
								<div class="col-md text-left">
									<h5 class="my-auto">Nodes Online: <?= "{$Online_Total}" ?> </h5>
									<h5 class="my-auto">Nodes Offline: <?= "{$Offline_Total}" ?> </h5>
								</div>
								<div class="col-md text-right">
								</div>
							</div>
						</div>
					</div>
					<div class="card-body">
						<!-- Card Body Content -->
						<div class="row">
							<!-- Shard 0 Card -->
							<div class="col-xl-3 col-md-6 mb-4">
								<div class="card border-left-primary shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="h5 mb-0 font-weight-bold text-gray-800">Shard 0 Status:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard0->status}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Current Block:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard0->block_number}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Online:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard0->node_count->online}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Offline:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard0->node_count->offline}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Last Updated:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard0->last_updated}" ?></div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<!-- Shard 1 Card -->
							<div class="col-xl-3 col-md-6 mb-4">
								<div class="card border-left-primary shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="h5 mb-0 font-weight-bold text-gray-800">Shard 1 Status:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard1->status}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Current Block:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard1->block_number}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Online:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard1->node_count->online}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Offline:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard1->node_count->offline}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Last Updated:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard1->last_updated}" ?></div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<!-- Shard 2 Card -->
							<div class="col-xl-3 col-md-6 mb-4">
								<div class="card border-left-primary shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="h5 mb-0 font-weight-bold text-gray-800">Shard 2 Status:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard2->status}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Current Block:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard2->block_number}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Online:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard2->node_count->online}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Offline:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard2->node_count->offline}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Last Updated:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard2->last_updated}" ?></div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<!-- Shard 3 Card -->
							<div class="col-xl-3 col-md-6 mb-4">
								<div class="card border-left-primary shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="h5 mb-0 font-weight-bold text-gray-800">Shard 3 Status:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard3->status}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Current Block:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard3->block_number}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Online:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard3->node_count->online}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Nodes Offline:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard3->node_count->offline}" ?></div>
												<div class="h5 mb-0 font-weight-bold text-gray-800">Last Updated:</div>
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><?= "{$shard3->last_updated}" ?></div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<!-- ./Card Body Content -->
					</div>
				</div>
				<!-- ./Card Content -->
			</div>
		</div>
		<!-- ./Page Content -->
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

</body>

</html>