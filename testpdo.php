<?php
$dsn = 'pgsql:host=host.docker.internal;port=5432;dbname=postgres';
try {
    $pdo = new PDO($dsn, 'postgres', 'password');
    echo "Connected successfully";
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
