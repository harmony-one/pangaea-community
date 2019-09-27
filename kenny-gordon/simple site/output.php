<?php

/** Initialize session data. */
session_start();
if (!isset($_SESSION['username'], $_SESSION['valid'])) {
  session_destroy();
  header("location:login.php");
}

/** Set Path to Node, This script should be the directory which your harmony files are installed. */
$node_path = '/root';

/** Set date formate to display */
$udate = date("Y-m-d H:i:s");

/** Set Scope of data to fetch. */
$shard_output = shell_exec('ls -d ' . $node_path . '/harmony_db_* | tail -1 | sed "s|' . $node_path . '/||g" | cut -c12- ');
$block_output = shell_exec('tac ' . $node_path . '/latest/zero*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "[0-9]+" ');
$debug_output = shell_exec('tac ' . $node_path . '/latest/*.log  | grep -m 25 "debug" ');
$error_output = shell_exec('tac ' . $node_path . '/latest/zero*.log  | grep -m 50 "error" ');
$bingo_output = shell_exec('tac ' . $node_path . '/latest/zero*.log  | grep -a "BINGO" ');
$tx_output = shell_exec('tac ' . $node_path . '/transactions.log | grep -a "Transaction Id" ');


?>

<div class="col-lg-12 mt-2">
  
  <div class="row">

    <div class="col-md mr-auto">
      <h1 class="text-left"><span class="badge badge-dark text-wrap">Shard: <?= $shard_output ?></span></h1>
    </div>
    <div class="col-md-8 mx-auto">
      <h1 class="text-center"><span class="badge badge-dark text-wrap">Page Refreshed: <?= $udate ?></span></h1>
    </div>
    <div class="col-md ml-auto">
      <h1 class="text-right"><span class="badge badge-dark text-wrap">Block: <?= $block_output ?></span></h1>
    </div>

  </div>

  <div class="row">
    <div class="col-md">

      <!-- Card Content -->
      <div class="card mt-2 ">
        <div class="card-header text-white bg-success">
          <div class="card-title my-auto">
            <div class="row">
              <div class="col-md text-left">
                <h5 class="my-auto">
                  <a class="text-white" data-toggle="collapse" href="#BingoOutput" role="button" aria-expanded="false" aria-controls="collapseExample">
                    <i class="fas fa-handshake"></i> Bingo Feed
                  </a>
                </h5>
              </div>
              <div class="col-md text-right">
                <h5 class="my-auto"></h5>
              </div>
            </div>
          </div>
        </div>
        <div class="collapse" id="BingoOutput">
          <div class="card-body text-wrap overflow-auto bg-dark">
            <!-- Card Body Content -->
            <div style="height: 250px;">
              <small>
                <code>
                  <?= $bingo_output; ?>
                </code>
              </small>
            </div>
            <!-- ./Card Body Content -->
          </div>
        </div>
      </div>
      <!-- ./Card Content -->

      <!-- Card Content -->
      <div class="card mt-2 bg-info">
        <div class="card-header text-white">
          <div class="card-title my-auto">
            <div class="row">
              <div class="col-md text-left">
                <h5 class="my-auto">
                  <a class="text-white" data-toggle="collapse" href="#TXCXOutput" role="button" aria-expanded="false" aria-controls="collapseExample">
                    <i class="fas fa-comments-dollar"></i> TX/CX Feed
                  </a>
                </h5>
              </div>
              <div class="col-md text-right">
                <h5 class="my-auto"></h5>
              </div>
            </div>
          </div>
        </div>
        <div class="collapse" id="TXCXOutput">
          <div class="card-body text-wrap overflow-auto bg-dark">
            <!-- Card Body Content -->
            <div style="height: 250px;">
              <small>
                <code>
                  <?= $tx_output; ?>
                </code>
              </small>
            </div>
            <!-- ./Card Body Content -->
          </div>
        </div>
      </div>
      <!-- ./Card Content -->

    </div>
    <div class="col-md">

      <!-- Card Content -->
      <div class="card mt-2 bg-warning">
        <div class="card-header text-white">
          <div class="card-title my-auto">
            <div class="row">
              <div class="col-md text-left">
                <h5 class="my-auto">
                  <a class="text-white" data-toggle="collapse" href="#DebugOutput" role="button" aria-expanded="false" aria-controls="collapseExample">
                    <i class="fas fa-bug"></i> Debug Feed
                  </a>
                </h5>
              </div>
              <div class="col-md text-right">
                <h5 class="my-auto"></h5>
              </div>
            </div>
          </div>
        </div>
        <div class="collapse" id="DebugOutput">
          <div class="card-body text-wrap overflow-auto bg-dark">
            <!-- Card Body Content -->
            <div style="height: 250px;">
              <small>
                <code>
                  <?= $debug_output; ?>
                </code>
              </small>
            </div>
            <!-- ./Card Body Content -->
          </div>
        </div>
      </div>
      <!-- ./Card Content -->

      <!-- Card Content -->
      <div class="card mt-2 bg-danger">
        <div class="card-header text-white">
          <div class="card-title my-auto">
            <div class="row">
              <div class="col-md text-left">
                <h5 class="my-auto">
                  <a class="text-white" data-toggle="collapse" href="#ErrorOutput" role="button" aria-expanded="false" aria-controls="collapseExample">
                    <i class="fas fa-bomb"></i> Error Feed
                  </a>
                </h5>
              </div>
              <div class="col-md text-right">
                <h5 class="my-auto"></h5>
              </div>
            </div>
          </div>
        </div>
        <div class="collapse" id="ErrorOutput">
          <div class="card-body text-wrap overflow-auto bg-dark">
            <!-- Card Body Content -->
            <div style="height: 250px;">
              <small>
                <code>
                  <?= $error_output; ?>
                </code>
              </small>
            </div>
            <!-- ./Card Body Content -->
          </div>
        </div>
      </div>
      <!-- ./Card Content -->

    </div>
  </div>

</div>
