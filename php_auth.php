//An Authorization example in php that get retrieves an access token
// and prints out data object for currently logged in user 

<?php
print_r($_SERVER['QUERY_STRING'].'<br><br>');
$launchcode = $_GET['code'];
$mode = $_GET['mode'];
$appInstallID = $_GET['applicationinstallid'];
$announcementID = $_GET['announcementapplicationid'];

if (isset($launchcode) && isset($mode) && isset($appInstallID) || isset($announcementID)) {
	$str_client_id = 'http://myEdTechApp.com/auth.php';
	$str_client_secret = 'Your API Key from the Chalkable Developer Portal';
	
	$obj_connection = curl_init();
	$arr_query_bits = array (
		'grant_type' => 'authorization_code',
		'client_id' => $str_client_id,
		'client_secret' => $str_client_secret,
		'code' => $launchcode,
		'redirect_uri' => $str_client_id,
		'scope' => 'https://chalkable.com'
	);
	
	$str_query = http_build_query($arr_query_bits);
	
	$str_url = 'https://chalkable-access-control.accesscontrol.windows.net/v2/OAuth2-13';
	
	curl_setopt($obj_connection, CURLOPT_URL, $str_url);
	curl_setopt($obj_connection, CURLOPT_HEADER, 0);
	curl_setopt($obj_connection, CURLOPT_FOLLOWLOCATION, 1);
	curl_setopt($obj_connection, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($obj_connection, CURLOPT_POSTFIELDS, $str_query);
	curl_setopt($obj_connection, CURLOPT_POST, TRUE);
	
	$str_result = curl_exec($obj_connection);
	$arr_curl_info = curl_getinfo($obj_connection);
	curl_close($obj_connection);
	$obj_response = json_decode($str_result);
	
	if (is_null($obj_response)){
		throw new Exception("Response wasn't valid JSON - {$str_response}");
	}
	
	if (isset($obj_response->error)){
		$obj_token_exception = new TokenException;
		$obj_token_exception ->set_error($obj_response->error);
		$obj_token_exception ->set_error_description($obj_response->error_description);
		throw new $obj_token_exception;
	} else {
		$str_token = $obj_response->access_token;
		
		//outputs
		print_r($obj_response);
		print_r('<br><br>'.$str_token.'<br><br>');
	}
	
	//Get user info
	$userobj_connection = curl_init('https://chalkable.com/User/Me.json');
	curl_setopt($userobj_connection, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($userobj_connection, CURLOPT_HTTPHEADER, array('Authorization:Bearer:'.$str_token));
	$userobj_result = curl_exec($userobj_connection);
	curl_close($obj_connection);
	
	//output
	print_r($userobj_result);
	
} else {
	die('Restricted access, please launch the resource from Chalkable');
}
?>
