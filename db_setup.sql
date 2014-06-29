-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 29, 2014 at 01:21 PM
-- Server version: 5.5.37
-- PHP Version: 5.3.10-1ubuntu3.12

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `Visor`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `trending_hashtags`
--
DROP VIEW IF EXISTS `trending_hashtags`;
CREATE TABLE IF NOT EXISTS `trending_hashtags` (
`hashtag` varchar(256)
,`count` bigint(21)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `trending_user_mentions`
--
DROP VIEW IF EXISTS `trending_user_mentions`;
CREATE TABLE IF NOT EXISTS `trending_user_mentions` (
`user` varchar(64)
,`mentions` bigint(21)
);
-- --------------------------------------------------------

--
-- Table structure for table `tweets`
--

DROP TABLE IF EXISTS `tweets`;
CREATE TABLE IF NOT EXISTS `tweets` (
  `tweet_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `text` varchar(256) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `retweet_count` int(11) NOT NULL,
  `favorite_count` int(11) NOT NULL,
  `source` varchar(256) DEFAULT NULL,
  `coordinates` geometry DEFAULT NULL,
  PRIMARY KEY (`tweet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_area`
--

DROP TABLE IF EXISTS `tweet_area`;
CREATE TABLE IF NOT EXISTS `tweet_area` (
  `tweet_id` bigint(20) NOT NULL,
  `area` varchar(64) NOT NULL,
  PRIMARY KEY (`tweet_id`,`area`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_hashtags`
--

DROP TABLE IF EXISTS `tweet_hashtags`;
CREATE TABLE IF NOT EXISTS `tweet_hashtags` (
  `tweet_id` bigint(20) NOT NULL,
  `hashtag` varchar(256) NOT NULL,
  PRIMARY KEY (`tweet_id`,`hashtag`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_media`
--

DROP TABLE IF EXISTS `tweet_media`;
CREATE TABLE IF NOT EXISTS `tweet_media` (
  `media_id` bigint(20) NOT NULL,
  `tweet_id` bigint(20) NOT NULL,
  `url` varchar(512) NOT NULL,
  `type` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`media_id`,`tweet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_symbols`
--

DROP TABLE IF EXISTS `tweet_symbols`;
CREATE TABLE IF NOT EXISTS `tweet_symbols` (
  `tweet_id` bigint(20) NOT NULL,
  `symbol` varchar(256) NOT NULL,
  PRIMARY KEY (`tweet_id`,`symbol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_urls`
--

DROP TABLE IF EXISTS `tweet_urls`;
CREATE TABLE IF NOT EXISTS `tweet_urls` (
  `tweet_id` bigint(20) NOT NULL,
  `url` varchar(256) NOT NULL,
  PRIMARY KEY (`tweet_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_user_mentions`
--

DROP TABLE IF EXISTS `tweet_user_mentions`;
CREATE TABLE IF NOT EXISTS `tweet_user_mentions` (
  `tweet_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `screen_name` varchar(64) NOT NULL,
  PRIMARY KEY (`tweet_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `twitter_users`
--

DROP TABLE IF EXISTS `twitter_users`;
CREATE TABLE IF NOT EXISTS `twitter_users` (
  `user_id` bigint(20) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `screen_name` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `location` varchar(64) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `url` varchar(256) DEFAULT NULL,
  `followers_count` int(11) NOT NULL,
  `friends_count` int(11) NOT NULL,
  `listed_count` int(11) NOT NULL,
  `favourites_count` int(11) NOT NULL,
  `statuses_count` int(11) NOT NULL,
  `utc_offset` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure for view `trending_hashtags`
--
DROP TABLE IF EXISTS `trending_hashtags`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `trending_hashtags` AS select `tweet_hashtags`.`hashtag` AS `hashtag`,count(0) AS `count` from `tweet_hashtags` group by `tweet_hashtags`.`hashtag` order by count(0) desc limit 20;

-- --------------------------------------------------------

--
-- Structure for view `trending_user_mentions`
--
DROP TABLE IF EXISTS `trending_user_mentions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `trending_user_mentions` AS select `tweet_user_mentions`.`screen_name` AS `user`,count(0) AS `mentions` from `tweet_user_mentions` group by `tweet_user_mentions`.`screen_name` order by count(0) desc limit 20;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
