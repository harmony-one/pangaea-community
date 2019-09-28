<?php

require_once("db.php"); //connect to your database

$query = $db->prepare("SELECT * FROM dbtable WHERE id = ?");
$query->execute(array("1"));
$result = $query->fetch();

$apiToken = "you telegram bot apiToken";

$data = [
    'offset' => $result['update_id']+1
];

$response = file_get_contents("https://api.telegram.org/bot$apiToken/getUpdates?" . http_build_query($data) ); //get message from telegram

echo $response; //response

?>