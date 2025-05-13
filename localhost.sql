-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2025-05-12 10:23:49
-- 服务器版本： 5.7.44-log
-- PHP 版本： 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `kami`
--
CREATE DATABASE IF NOT EXISTS `kami` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `kami`;

-- --------------------------------------------------------

--
-- 表的结构 `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `admins`
--

INSERT INTO `admins` (`id`, `username`, `password`, `create_time`, `last_login`) VALUES
(1, '123', '$2y$10$gxgRAiv63rkmLDQcg1WcdumpGSKoia1pt5hVYsK2cJSpcwzVRFnjq', '2025-05-06 09:13:25', NULL);

-- --------------------------------------------------------

--
-- 表的结构 `api_keys`
--

CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL,
  `key_name` varchar(50) NOT NULL COMMENT 'API密钥名称',
  `api_key` varchar(32) NOT NULL COMMENT 'API密钥',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态:0禁用,1启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_use_time` datetime DEFAULT NULL COMMENT '最后使用时间',
  `use_count` int(11) NOT NULL DEFAULT '0' COMMENT '使用次数',
  `description` varchar(255) DEFAULT NULL COMMENT '备注说明'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- 表的结构 `cards`
--

CREATE TABLE `cards` (
  `id` int(11) NOT NULL,
  `card_key` varchar(32) NOT NULL COMMENT '原始卡密',
  `encrypted_key` varchar(40) NOT NULL COMMENT '加密后的卡密',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:未使用 1:已使用 2:已停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_time` datetime DEFAULT NULL,
  `expire_time` datetime DEFAULT NULL,
  `duration` int(11) NOT NULL DEFAULT '0',
  `verify_method` enum('web','post','get') DEFAULT NULL,
  `allow_reverify` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否允许同设备重复验证(1:允许, 0:不允许)',
  `device_id` varchar(64) DEFAULT NULL,
  `encryption_type` varchar(10) NOT NULL DEFAULT 'sha1' COMMENT '加密类型 (sha1, rc4)',
  `card_type` enum('time','count') NOT NULL DEFAULT 'time' COMMENT '卡密类型：time-时间卡密，count-次数卡密',
  `total_count` int(11) NOT NULL DEFAULT '0' COMMENT '总次数（次数卡密专用）',
  `remaining_count` int(11) NOT NULL DEFAULT '0' COMMENT '剩余次数（次数卡密专用）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `cards`
--

INSERT INTO `cards` (`id`, `card_key`, `encrypted_key`, `status`, `create_time`, `use_time`, `expire_time`, `duration`, `verify_method`, `allow_reverify`, `device_id`, `encryption_type`, `card_type`, `total_count`, `remaining_count`) VALUES
(1, 'B8MXCAtTArJad85TzXhZ', '3e92269d3df5f84f3541dc11b1eb2258358b8dee', 0, '2025-05-06 09:13:34', NULL, NULL, 0, NULL, 1, NULL, 'sha1', 'count', 20, 20);

-- --------------------------------------------------------

--
-- 表的结构 `features`
--

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `features`
--

INSERT INTO `features` (`id`, `icon`, `title`, `description`, `sort_order`, `status`) VALUES
(1, 'fas fa-shield-alt', '安全可靠', '采用先进的加密技术，确保卡密数据安全\n数据加密存储\n防暴力破解\n安全性验证', 1, 1),
(2, 'fas fa-code', 'API接口', '提供完整的API接口，支持多种验证方式\nRESTful API\n多种验证方式\n详细接口文档', 2, 1),
(3, 'fas fa-tachometer-alt', '高效稳定', '系统运行稳定，响应迅速\n快速响应\n稳定运行\n性能优化', 3, 1),
(4, 'fas fa-chart-line', '数据统计', '详细的数据统计和分析功能\n实时统计\n数据分析\n图表展示', 4, 1);

-- --------------------------------------------------------

--
-- 表的结构 `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `settings`
--

INSERT INTO `settings` (`id`, `name`, `value`) VALUES
(1, 'site_title', '小小怪卡密验证系统'),
(2, 'site_subtitle', '专业的卡密验证解决方案'),
(3, 'copyright_text', '小小怪卡密系统 - All Rights Reserved'),
(4, 'contact_qq_group', '123456789'),
(5, 'contact_wechat_qr', 'assets/images/wechat-qr.jpg'),
(6, 'contact_email', 'support@example.com'),
(7, 'api_enabled', '0'),
(8, 'api_key', 'c3d01e574865a180a20f71c4a0e41c07');

-- --------------------------------------------------------

--
-- 表的结构 `slides`
--

CREATE TABLE `slides` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `slides`
--

INSERT INTO `slides` (`id`, `title`, `description`, `image_url`, `sort_order`, `status`, `create_time`) VALUES
(1, '安全可靠的验证系统', '采用先进的加密技术，确保您的数据安全', 'assets/images/slide1.jpg', 1, 1, '2025-05-06 09:13:25'),
(2, '便捷高效的验证流程', '支持多种验证方式，快速响应', 'assets/images/slide2.jpg', 2, 1, '2025-05-06 09:13:25'),
(3, '完整的API接口', '提供丰富的接口，便于集成', 'assets/images/slide3.jpg', 3, 1, '2025-05-06 09:13:25');

--
-- 转储表的索引
--

--
-- 表的索引 `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- 表的索引 `api_keys`
--
ALTER TABLE `api_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `api_key` (`api_key`);

--
-- 表的索引 `cards`
--
ALTER TABLE `cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `card_key` (`card_key`),
  ADD UNIQUE KEY `encrypted_key` (`encrypted_key`),
  ADD KEY `device_id` (`device_id`);

--
-- 表的索引 `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- 表的索引 `slides`
--
ALTER TABLE `slides`
  ADD PRIMARY KEY (`id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `api_keys`
--
ALTER TABLE `api_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `cards`
--
ALTER TABLE `cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `features`
--
ALTER TABLE `features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- 使用表AUTO_INCREMENT `slides`
--
ALTER TABLE `slides`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
