-- adatbázis létrehozása

CREATE DATABASE `targykor` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- adatbázisba belépés

USE targykor;

-- táblák kódja:
CREATE TABLE `users` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(320) NOT NULL,
  `phone_number` varchar(50),
  `password` varchar(255) NOT NULL,
  `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_username` (`username`)
);

CREATE TABLE `email_verifications` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `verified_at` datetime NULL DEFAULT NULL,
  UNIQUE KEY `uq_email_verif_token` (`token`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

CREATE TABLE `password_resets` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_pw_reset_token` (`token`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

CREATE TABLE `categories` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime NULL DEFAULT NULL,
  UNIQUE KEY `uq_categories_name` (`name`)
);

CREATE TABLE `products` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `category_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` int NOT NULL,
  `description` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `county` ENUM(
    'Bács-Kiskun', 'Baranya', 'Békés', 'Borsod-Abaúj-Zemplén',
    'Csongrád-Csanád', 'Fejér', 'Győr-Moson-Sopron', 'Hajdú-Bihar',
    'Heves', 'Jász-Nagykun-Szolnok', 'Komárom-Esztergom', 'Nógrád',
    'Pest', 'Somogy', 'Szabolcs-Szatmár-Bereg', 'Tolna',
    'Vas', 'Veszprém', 'Zala', 'Budapest'
  ) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`)
);

CREATE TABLE `product_images` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `url` varchar(255) NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
);

CREATE TABLE `rentals` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `product_id` int NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `price` int NOT NULL,
  `total_price` int NOT NULL,
  `status` ENUM('pending', 'approved', 'active', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_rentals_dates` CHECK (`end_date` >= `start_date`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
);

CREATE TABLE `notifications` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `type` varchar(50) NOT NULL,
  `content` varchar(255) NOT NULL,
  `rental_id` int NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`) ON DELETE SET NULL
);

CREATE TABLE `favourites` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_favourite` (`users_id`, `product_id`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
);

CREATE TABLE `reviews` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `rental_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_review_rental` (`rental_id`),
  CONSTRAINT `chk_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5),
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`)
);
