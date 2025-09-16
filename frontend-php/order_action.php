<?php
require __DIR__.'/env.php';

$id     = (int)($_POST['id'] ?? 0);
$action = $_POST['action'] ?? '';

if ($id <= 0 || $action === '') {
  header('Location: orders.php?msg=Invalid');
  exit;
}

$opts = ['http' => ['ignore_errors' => true, 'timeout' => 6, 'method' => 'POST']];
$url  = "$API_ORDERS/$id/$action";

if ($action === 'delete') {
  $opts['http']['method'] = 'DELETE';
  $url = "$API_ORDERS/$id";
}

$ctx = stream_context_create($opts);
$res = @file_get_contents($url, false, $ctx);
$msg = ($res === false) ? ("Failed $action") : (strtoupper($action) . " OK");

header('Location: orders.php?msg=' . urlencode($msg));
