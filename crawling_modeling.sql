USE cu_dataproject;

SHOW TABLES;

DESC content;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM brand;
ALTER TABLE brand AUTO_INCREMENT = 1;
SET SQL_SAFE_UPDATES = 1;

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
DELETE FROM platform;
ALTER TABLE platform AUTO_INCREMENT = 1;
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


INSERT INTO brand (brand_name)
VALUES
('CU'),
('다이소'),
('올리브영');

INSERT INTO platform(platform_name)
VALUES
('인스타그램'),
('유튜브'),
('네이버블로그');