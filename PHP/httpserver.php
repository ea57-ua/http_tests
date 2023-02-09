<?php
set_time_limit(0);

$address = '127.0.0.1';
$port = 8080;

$sock = socket_create(AF_INET, SOCK_STREAM, 0);
socket_bind($sock, $address, $port) or die('Could not bind to address');

echo "\n Listening On port $port For Connection... \n\n";

while(1)
{
    socket_listen($sock);
    $client = socket_accept($sock);

    $input = socket_read($client, 1024);

    $incoming = array();
    $incoming = explode("\r\n", $input);

    $fetchArray = array();
    $fetchArray = explode(" ", $incoming[0]);

    $file = $fetchArray[1];
    if($file == "/"){ 

        $file = "index.html"; 

    } else {

        $filearray = array();
        $filearray = explode("/", $file);
        $file = $filearray[1];
    }

    echo $fetchArray[0] . " Request " . $file . "\n"; 

    $output = "";
    $Header = "HTTP/1.1 200 OK \r\n" .
        "Date: Fri, 31 Dec 1999 23:59:59 GMT \r\n" .
        "Content-Type: text/html \r\n\r\n";

    $Content = file_get_contents($file);
    $output = $Header . $Content;

    socket_write($client,$output,strlen($output));
    socket_close($client);
}