CREATE DATABASE IF NOT EXISTS cu_dataproject_youtube
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

USE cu_dataproject_youtube;

CREATE TABLE IF NOT EXISTS content (
	id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(20) NOT NULL,
    platform_name VARCHAR(20) NOT NULL,
    title VARCHAR(255),
    caption_text TEXT,
    hashtags TEXT,
    like_count INT,
    view_count INT,
    comment_count INT,
    duration_seconds INT,
    content_type VARCHAR(20),
    upload_date DATETIME,
    content_url VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS insta_content (
	id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(20) NOT NULL,
    platform_name VARCHAR(20) NOT NULL,
    caption_text TEXT,
    hashtags TEXT,
    like_count INT,
    comment_count INT,
    content_url VARCHAR(500)
);

DESC insta_content;
SELECT * FROM insta_content LIMIT 5;
SELECT COUNT(*) FROM content;

-- 브랜드별 콘텐츠 타입의 개수 비교
SELECT brand_name, content_type, COUNT(content_type) content_count
FROM content
GROUP BY brand_name, content_type;

-- 브랜드별 전체 콘텐츠 수 대비 콘텐츠 타입 비율 
SELECT 
    brand_name,
    content_type,
    COUNT(*) AS content_count,
    ROUND(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER (PARTITION BY brand_name),
        2
    ) AS content_ratio
FROM content
GROUP BY brand_name, content_type
ORDER BY brand_name, content_ratio DESC;

-- 브랜드별 콘텐츠 타입의 평균 view_count, like_count, comment_count
SELECT
	platform_name,
	brand_name,
    content_type,
    ROUND(AVG(view_count)) view_avg,
    ROUND(AVG(like_count)) like_avg,
    ROUND(AVG(comment_count)) comment_avg
FROM content
GROUP BY brand_name, platform_name, content_type
ORDER BY brand_name, view_avg DESC;

-- 브랜드별 평균 like_count, comment_count
SELECT 
    platform_name,
	brand_name,
    ROUND(AVG(like_count)) like_avg,
    ROUND(AVG(comment_count)) comment_avg
FROM insta_content
GROUP BY brand_name, platform_name
ORDER BY like_avg DESC;