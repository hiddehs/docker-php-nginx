<?php
$dsn = 'pgsql:host=host.docker.internal;port=5432;dbname=vra_cloud_api';
try {
    $pdo = new PDO($dsn, 'sail', 'password');
    echo "Connected successfully";
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
