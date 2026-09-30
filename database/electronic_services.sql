-- phpMyAdmin SQL Dump
-- Database: `electronic_services`

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `address` text,
  `city` varchar(50),
  `pincode` varchar(10),
  `profile_image` varchar(255) DEFAULT 'default.png',
  `status` enum('Pending Approval','Approved','Rejected','Suspended') DEFAULT 'Pending Approval',
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT 'Super Admin',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `service_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_name` varchar(100) NOT NULL,
  `shop_name` varchar(150) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `address` text,
  `city` varchar(50),
  `pincode` varchar(10),
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `experience` int(11) DEFAULT 0,
  `description` text,
  `image` varchar(255) DEFAULT 'shop_default.png',
  `status` enum('Pending','Approved','Rejected','Suspended') DEFAULT 'Pending',
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `technicians` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100),
  `mobile` varchar(20) NOT NULL,
  `photo` varchar(255) DEFAULT 'tech_default.png',
  `experience` int(11) DEFAULT 0,
  `skills` text,
  `availability` enum('Available','Busy','Offline') DEFAULT 'Available',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appliance_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `icon` varchar(255),
  `description` text,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appliances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `image` varchar(255),
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  FOREIGN KEY (`category_id`) REFERENCES `appliance_categories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `appliance_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `service_name` varchar(150) NOT NULL,
  `description` text,
  `starting_price` decimal(10,2) DEFAULT 0.00,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  FOREIGN KEY (`appliance_id`) REFERENCES `appliances`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_number` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `technician_id` int(11) DEFAULT NULL,
  `appliance_id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `problem` text NOT NULL,
  `description` text,
  `image` varchar(255) DEFAULT NULL,
  `address` text,
  `city` varchar(50),
  `pincode` varchar(10),
  `preferred_date` date,
  `preferred_time` varchar(50),
  `estimated_cost` decimal(10,2) DEFAULT NULL,
  `final_cost` decimal(10,2) DEFAULT NULL,
  `booking_status` enum('Booking Requested','Shop Accepted','Technician Assigned','Technician On The Way','Inspection Started','Repair In Progress','Repair Completed','Payment Pending','Payment Completed','Booking Closed','Cancelled') DEFAULT 'Booking Requested',
  `payment_status` enum('Pending','Completed','Failed') DEFAULT 'Pending',
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_number` (`booking_number`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`id`),
  FOREIGN KEY (`technician_id`) REFERENCES `technicians`(`id`),
  FOREIGN KEY (`appliance_id`) REFERENCES `appliances`(`id`),
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `booking_status_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `status` varchar(100) NOT NULL,
  `note` text,
  `updated_by` varchar(50),
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50),
  `transaction_id` varchar(100),
  `payment_status` enum('Pending','Completed','Failed') DEFAULT 'Pending',
  `paid_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `technician_id` int(11) DEFAULT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `review` text,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`technician_id`) REFERENCES `technicians`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(50) NOT NULL,
  `pincode` varchar(10) NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `provider_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50),
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Admin Sample
INSERT INTO `admins` (`name`, `email`, `password`, `role`, `status`) VALUES 
('Super Admin', 'admin@electronicservices.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Super Admin', 'Active'); 
-- password is 'password'

-- Insert Appliance Categories
INSERT INTO `appliance_categories` (`name`, `icon`, `description`) VALUES
('Refrigerator', 'fa-snowflake', 'All types of fridges'),
('Washing Machine', 'fa-jug-detergent', 'Top and front load washing machines'),
('Air Conditioner', 'fa-fan', 'Window, Split, and Central ACs'),
('Television', 'fa-tv', 'LED, LCD, OLED, Smart TVs');

-- Insert Sample User
INSERT INTO `users` (`name`, `email`, `mobile`, `password`, `address`, `city`, `pincode`, `status`) VALUES
('John Doe', 'john@example.com', '9876543210', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '123 Main St', 'Nashik', '422001', 'Approved');

-- Insert Sample Provider
INSERT INTO `service_providers` (`owner_name`, `shop_name`, `email`, `mobile`, `address`, `city`, `pincode`, `experience`, `status`) VALUES
('Ramesh Patel', 'Patel Electronics Repair', 'patel@example.com', '9988776655', '45 Market Road', 'Nashik', '422001', 10, 'Approved');

COMMIT;
