USE cu_dataproject;

SHOW TABLES;

DESC content;

SELECT * FROM brand;
SELECT * FROM comment LIMIT 5;
SELECT * FROM content LIMIT 5;
SELECT * FROM platform;

ALTER DATABASE cu_dataproject
CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

ALTER TABLE content
CONVERT TO CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

ALTER TABLE comment
CONVERT TO CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM content;
ALTER TABLE content AUTO_INCREMENT = 1;
SET SQL_SAFE_UPDATES = 1;


SELECT
    C.brand_id,
    B.brand_name,
    C.platform_id,
    P.platform_name,
    C.title,
    C.caption_text,
    C.hashtags,
    C.like_count,
    C.view_count,
    C.comment_count,
    C.upload_date,
    C.content_url
FROM content C
JOIN brand B ON B.brand_id = C.brand_id
JOIN platform P ON P.platform_id = C.platform_id
ORDER BY B.brand_id ASC;