<?php

require_once("db.php"); //connect to your database

$query = $db->prepare("SELECT * FROM db_tables WHERE id = ?");
$query->execute(array("1"));
$result = $query->fetch();

$all = file_get_contents('https://harmony.one/pga/network'); //get data from pangaea

$online = "Online";
$offline = "Offline";
$id = "1";

//Checking shard 0

$shard0 = explode("Shard 0",$all);
$shard0 = explode("(Last updated",$shard0[1]);

if(preg_match("/ONLINE/i", $shard0[0])){ //if shard online
	if($result['shard_0'] == "Online"){ //if shard (from db) status not change
		echo "shard 0 still online";
	}else{ //checking if shard status changed
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_0`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $online);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Yeah, now shard 0 is Online!'
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) ); //send message to group ith telegram api

            echo $response; //response of telegram api
        }
	}
}elseif(preg_match("/OFFLINE/i", $shard0[0])){ //if shard offline
	if($result['shard_0'] == "Offline"){ //if shard (from db) status not change
		echo "shard 0 still offline";
	}else{ //if shard status changed
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_0`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $offline);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Oh no, now shard 0 is offline :('
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) ); //send message to group with telegram api

            echo $response; //response of telegram api
        }
	}
}

//Checking Shard 1

$shard1 = explode("Shard 1",$all);
$shard1 = explode("(Last updated",$shard1[1]);

if(preg_match("/ONLINE/i", $shard1[0])){
	if($result['shard_1'] == "Online"){
		echo "tetap online 1";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_1`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $online);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Yeah, now shard 1 is Online!'
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}elseif(preg_match("/OFFLINE/i", $shard1[0])){
	if($result['shard_1'] == "Offline"){
		echo "tetap offline 1";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_1`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $offline);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Oh no, now shard 1 is offline :('
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}

//Checking Shard 2

$shard2 = explode("Shard 2",$all);
$shard2 = explode("(Last updated",$shard2[1]);

if(preg_match("/ONLINE/i", $shard2[0])){
	if($result['shard_2'] == "Online"){
		echo "tetap online 2";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_2`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $online);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Yeah, now shard 2 is Online!'
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}elseif(preg_match("/OFFLINE/i", $shard2[0])){
	if($result['shard_2'] == "Offline"){
		echo "tetap offline 2";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_2`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $offline);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Oh no, now shard 2 is offline :('
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}

//Checking Shard 3

$shard3 = explode("Shard 3",$all);
$shard3 = explode("(Last updated",$shard3[1]);

if(preg_match("/ONLINE/i", $shard3[0])){
	if($result['shard_3'] == "Online"){
		echo "tetap online 3";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_3`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $online);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Yeah, now shard 3 is Online!'
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}elseif(preg_match("/OFFLINE/i", $shard3[0])){
	if($result['shard_3'] == "Offline"){
		echo "tetap offline 3";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `shard_3`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $offline);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Oh no, now shard 3 is offline :('
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}


$node = explode("ONLINE:",$all);
$node = explode("OFFLINE:",$node[1]);
$nodeoff = explode("OFFLINE:",$all);

if(preg_match("/your pangaea address/i", $node[0])){
	if($result['owner_node'] == "Online"){
		echo "tetap online node";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `owner_node`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $online);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Yeah, now creator s node on shard 1 Online!'
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}elseif(preg_match("/your pangaea address/i", $nodeoff[1])){
	if($result['owner_node'] == "Offline"){
		echo "creator node still offline";
	}else{
		$query1 = $db->prepare("UPDATE `db_tables` SET `owner_node`=:shard_0 WHERE id=:id");
        $query1->bindParam(":id", $id);
        $query1->bindParam(":shard_0", $offline);
        if($query1->execute()){
        	$apiToken = "your telegram bot apiToken";

            $data = [
                'chat_id' => '@harmonypangaea',
                'text' => 'Oh no, now creator s node on shard 1 offline :('
            ];

            $response = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data) );

            echo $response;
        }
	}
}

?>