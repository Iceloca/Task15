<?php

require 'red.php';
$ip = $_SERVER['REMOTE_ADDR'] ?? 'неизвестно';
$forwarded = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null;
$real_ip = $_SERVER['HTTP_X_REAL_IP'] ?? null;

$stdout = fopen('php://stdout', 'w');
fwrite($stdout, "Запрос от IP: $ip\n");
if ($forwarded) {
    fwrite($stdout, "Проксированный IP (X-Forwarded-For): $forwarded\n");
}
if ($real_ip) {
    fwrite($stdout, "Реальный IP : $real_ip\n");
}
