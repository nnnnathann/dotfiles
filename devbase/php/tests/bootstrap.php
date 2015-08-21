<?php
putenv('TEST=1');
$_ENV['TEST'] = true;
require_once __DIR__ . '/../vendor/autoload.php';
