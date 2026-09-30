<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
$base_url = 'http://localhost/electronic-services/';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Electronic Services - Appliance Repair Marketplace</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<?= $base_url ?>assets/css/style.css">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
        <div class="container">
            <a class="navbar-brand text-primary fw-bold" href="<?= $base_url ?>">
                <i class="fa-solid fa-plug-circle-bolt"></i> Electronic Services
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                    <li class="nav-item"><a class="nav-link" href="<?= $base_url ?>">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="<?= $base_url ?>#services">Services</a></li>
                    <li class="nav-item"><a class="nav-link" href="<?= $base_url ?>#shops">Repair Shops</a></li>
                    <?php if(isset($_SESSION['user_id'])): ?>
                        <li class="nav-item"><a class="nav-link btn btn-outline-primary ms-2" href="<?= $base_url ?>user/dashboard.php">Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-primary text-white ms-2" href="<?= $base_url ?>includes/logout.php">Logout</a></li>
                    <?php elseif(isset($_SESSION['provider_id'])): ?>
                        <li class="nav-item"><a class="nav-link btn btn-outline-primary ms-2" href="<?= $base_url ?>provider/dashboard.php">Provider Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-primary text-white ms-2" href="<?= $base_url ?>includes/logout.php">Logout</a></li>
                    <?php elseif(isset($_SESSION['admin_id'])): ?>
                        <li class="nav-item"><a class="nav-link btn btn-outline-danger ms-2" href="<?= $base_url ?>admin/dashboard.php">Admin Panel</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-danger text-white ms-2" href="<?= $base_url ?>includes/logout.php">Logout</a></li>
                    <?php else: ?>
                        <li class="nav-item"><a class="nav-link btn btn-outline-primary ms-2" href="<?= $base_url ?>user/login.php">Login</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-primary text-white ms-2" href="<?= $base_url ?>user/register.php">Register</a></li>
                    <?php endif; ?>
                </ul>
            </div>
        </div>
    </nav>
