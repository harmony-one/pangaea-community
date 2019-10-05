<?php

require_once("db.php");

$query = $db->prepare("SELECT * FROM db_tables WHERE id = ?");
$query->execute(array("1"));
$result = $query->fetch();

$all = file_get_contents('https://harmony.one/pga/network'); //get data from pangaea
$response = file_get_contents('https://your domain/getupdate.php'); //get data from telegram api

$id = "1";
$now = date('Y-m-d h:i:s');
$online = "online";
$offline = "offline";
$notfound = "notfound";

$apiToken = "your telegram bot apiToken";

//echo $response;

if(preg_match('"ok"',$response)){ //if response of telegram api "OK"

    $update_id = explode('"update_id":',$response); //get update id

    if(count($update_id) > 1){
        for($id = 1; $id < count($update_id); $id++){
	        $updates = explode('"message"',$update_id[$id]);
	        $update = explode(',',$updates[0]);
        }

        $oldup = $result['update_id'];
        $updated = max($update);

        $query1 = $db->prepare("UPDATE `db_tables` SET `update_id`=:updateid WHERE `update_id`=:id");
        $query1->bindParam(":id", $oldup);
        $query1->bindParam(":updateid", $updated);
        $query1->execute()); //update telegram update id to your db

        $checktype = explode('"type":"',$response);

        for($i = 1; $i < count($checktype); $i++){
	        $type = explode('"',$checktype[$i]);
	        if($type[0] == "private"){ //if user send pm to bot
	            $checkmessage = explode('"text":"',$checktype[$i]);
	            if(count($checkmessage) > 1){
	                $checkmessage = explode('"',$checkmessage[1]);
	            }
	            if(preg_match("/address/i",$checkmessage[0])){ //get user pangaea address
		            $checkaddress = explode("/address ",$checkmessage[0]);

		            $all = file_get_contents('https://harmony.one/pga/network');
		            $node = explode("ONLINE:",$all);
                    $node = explode("OFFLINE:",$node[1]);
                    $nodeoff = explode("OFFLINE:",$all);

                    $ids = explode(',"chat":{"id":',$checktype[$i-1]);
                    $ids = explode(',',$ids[1]); //get telegram id of sender

                    if(count($checkaddress) > 1){
                        if(preg_match("/".$checkaddress[1]."/i",$node[0])){

                            $sql = "INSERT INTO telegramdata (date, tg_id, address, status)
                                        VALUES ('$now','$ids[0]','$checkaddress[1]','$online')";
                            $db->query($sql); //insert data

                            $data2 = [
                                'chat_id' => $ids[0],
                                'text' => 'Your node ('.$checkaddress[1].') now online'
                            ];

                            $response2 = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data2) ); //send reply message to sender

                            echo $response2; //response of telegram api

                        }elseif(preg_match("/".$checkaddress[1]."/i",$nodeoff[1])){

                            $sql = "INSERT INTO telegramdata (date, tg_id, address, status)
                                        VALUES ('$now','$ids[0]','$checkaddress[1]','$offline')";
                            $db->query($sql);

                            $data2 = [
                                'chat_id' => $ids[0],
                                'text' => 'Your node ('.$checkaddress[1].') now offline'
                            ];

                            $response2 = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data2) );

                            echo $response2;
                        }else{
                        	$sql = "INSERT INTO telegramdata (date, tg_id, address, status)
                                        VALUES ('$now','$ids[0]','$checkaddress[1]','$notfound')";
                            $db->query($sql);

                	        $data2 = [
                                'chat_id' => $ids[0],
                                'text' => 'Your address ('.$checkaddress[1].') not found. Please enter pangaea address.'
                            ];

                            $response2 = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data2) );

                            echo $response2;
                        }
                    }
		        }elseif(preg_match("/help/i",$checkmessage[0])){
			        $ids = explode(',"chat":{"id":',$checktype[$i-1]);
                    $ids = explode(',',$ids[1]);

                    echo $ids[0]."<br><br>";

			        $data2 = [
                        'chat_id' => $ids[0],
                        'text' => 'Hi, @pangaeastatus_bot here. You can check:
- Your pangaea node status with command /address <your pangaea address>. Example /address one1ks04vmcl4r75rxz3s4frc9rcvrtagxw86da9vf.
- Your pangaea balance. Coming soon.
- Your pangaea transaction status. Coming soon.

If any error, bug, etc please message the creator (@OkeSip).
Thank you.'
                    ];

                    $response2 = file_get_contents("https://api.telegram.org/bot$apiToken/sendMessage?" . http_build_query($data2) );

                    echo $response2;
			    }
	        }
        }
    }
}
?>