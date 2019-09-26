<?php
session_start();

if (
  isset($_POST['login']) && !empty($_POST['username'])
  && !empty($_POST['password'])
) {

  if (
    $_POST['username'] == 'pangaea' &&
    $_POST['password'] == 'pangaea'
  ) {
    $_SESSION['valid'] = true;
    $_SESSION['timeout'] = time();
    $_SESSION['username'] = 'user';

    header("Location: index.php");
  } else {
    header("Location: login.php");
  }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
  <meta name="description" content="Harmony Pangaea Login">
  <meta name="keywords" content="Harmony, Pangaea, Login">
  <meta name="author" content="K Gordon">

  <title>Login</title>

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
  <!-- Custom styles for this template -->
  <link href="assets/default/css/login.css" rel="stylesheet">

</head>

<body>

  <form class="form-signin text-center" method="post" action="<?php echo htmlentities($_SERVER['PHP_SELF']); ?>" autocomplete="off">
    <h1 class="mb-4">Pangaea Node <?= $_SERVER['SERVER_ADDR']; ?></h1>
    <h2 class="h3 mb-3 font-weight-normal">Please sign in</h2>
    <label for="inputUser" class="sr-only">Username</label>
    <input type="test" id="inputuser" class="form-control mb-2" placeholder="Username" name="username" required autofocus>
    <label for="inputPassword" class="sr-only">Password</label>
    <input type="password" id="inputPassword" class="form-control mb-2" placeholder="Password" name="password" required>
    <button class="btn btn-lg btn-primary btn-block" type="submit" name="login">Sign in</button>
  </form>

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