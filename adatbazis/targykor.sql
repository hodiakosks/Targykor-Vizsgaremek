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
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(50),
  `password` varchar(255) NOT NULL,
  `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `failed_login_attempts` int NOT NULL DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `is_banned` tinyint NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint NULL DEFAULT 0,
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_username` (`username`)
);

CREATE TABLE `email_verifications` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `uq_email_verif_token` (`token`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

CREATE TABLE `password_resets` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_pw_reset_token` (`token`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

DROP TABLE IF EXISTS `login_logs`;
CREATE TABLE `login_logs` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NULL,
  `user_agent` varchar(255) NULL,
  `logged_in_at` datetime DEFAULT CURRENT_TIMESTAMP
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
);E NGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `categories` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint NULL DEFAULT 0,
  UNIQUE KEY `uq_categories_name` (`name`)
);

CREATE TABLE `counties` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  UNIQUE KEY `uq_counties_name` (`name`)
);

INSERT INTO `counties` (`name`) VALUES
  ('Bács-Kiskun'), ('Baranya'), ('Békés'), ('Borsod-Abaúj-Zemplén'),
  ('Csongrád-Csanád'), ('Fejér'), ('Győr-Moson-Sopron'), ('Hajdú-Bihar'),
  ('Heves'), ('Jász-Nagykun-Szolnok'), ('Komárom-Esztergom'), ('Nógrád'),
  ('Pest'), ('Somogy'), ('Szabolcs-Szatmár-Bereg'), ('Tolna'),
  ('Vas'), ('Veszprém'), ('Zala'), ('Budapest');

CREATE TABLE `products` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `category_id` int NOT NULL,
  `county_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `price_per_day` int NOT NULL,
  `description` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint NULL DEFAULT 0,
  CONSTRAINT `chk_products_price` CHECK (`price` > 0),  
  FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`),
  FOREIGN KEY (`county_id`) REFERENCES `counties`(`id`)
);

CREATE TABLE `product_images` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `url` varchar(255) NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY (`product_id`, `sort_order`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
  
);

CREATE TABLE `rentals` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `product_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,   
  `price` int NOT NULL,
  `total_price` int NOT NULL,
  `status` ENUM('pending', 'approved', 'active', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_rentals_dates` CHECK (`end_date` >= `start_date`),
  CONSTRAINT `chk_rentals_price` CHECK (`price` > 0 AND `total_price` > 0),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
);

CREATE TABLE `rental_status_history` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `rental_id` int NOT NULL,
  `old_status` ENUM('pending', 'approved', 'active', 'completed', 'cancelled') NULL,
  `new_status` ENUM('pending', 'approved', 'active', 'completed', 'cancelled') NOT NULL,
  `changed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`) ON DELETE CASCADE
);

CREATE TABLE `complaints` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `rental_id` int NOT NULL,
  `users_id` int NOT NULL,
  `type` ENUM('defective', 'not_as_described', 'damaged', 'late_return', 'other') NOT NULL,
  `description` text NOT NULL,
  `status` ENUM('open', 'in_review', 'resolved', 'rejected') NOT NULL DEFAULT 'open',
  `admin_response` text NULL,
  `resolved_by` int NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_complaints_desc` CHECK (CHAR_LENGTH(TRIM(`description`)) > 0),
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
);

CREATE TABLE `notifications` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `type` varchar(50) NOT NULL,
  `content` varchar(255) NOT NULL,
  `rental_id` int NULL,
  `is_read` tinyint NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`) ON DELETE SET NULL
);

CREATE TABLE `favourites` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_favourite` (`users_id`, `product_id`),
  FOREIGN KEY (`users_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
);

CREATE TABLE `reviews` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `rental_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_review_rental` (`rental_id`),
  CONSTRAINT `chk_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5),
  FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`)
);
