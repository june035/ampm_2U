USE cu_dataproject;
SHOW TABLES;
DESC comment;

/*안전모드 해제 > 테이블 내용 삭제 > id 1번부터 다시 설정 > 안전모드 설정*/
SET SQL_SAFE_UPDATES = 0;
DELETE FROM content;
ALTER TABLE content AUTO_INCREMENT = 1;
SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS content_count FROM content;
SELECT COUNT(*) AS conmment_count FROM comment;

SELECT * FROM brand;
SELECT * FROM content LIMIT 5;
SELECT * FROM comment LIMIT 5;
SELECT * FROM platform;

-- 브랜드별 콘텐츠 갯수
SELECT B.brand_name, COUNT(*) AS brand_content_counts
FROM content C
JOIN brand B ON B.brand_id=C.brand_id
GROUP BY C.brand_id
ORDER BY brand_content_counts DESC;

-- 플랫폼별 콘텐츠 갯수
SELECT P.platform_name, COUNT(*) AS platform_content_counts
FROM content C
JOIN platform P ON P.platform_id=C.platform_id
GROUP BY C.platform_id
ORDER BY platform_content_counts DESC;

-- 브랜드별 플랫폼의 콘텐츠 갯수
SELECT B.brand_name, P.platform_name, count(*) content_counts
FROM content C
JOIN brand B ON B.brand_id=C.brand_id
JOIN platform P ON P.platform_id=C.platform_id
GROUP BY C.brand_id, P.platform_id
ORDER BY C.brand_id, content_counts DESC;

-- 브랜드별 전체 콘텐츠 수 대비 콘텐츠 타입 비율 
SELECT 
    B.brand_name,
    P.platform_name,
    COUNT(*) AS content_count,
    ROUND(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER (PARTITION BY B.brand_name),
        2
    ) AS content_ratio
FROM content C
JOIN brand B ON B.brand_id=C.brand_id
JOIN platform P ON P.platform_id=C.platform_id
GROUP BY B.brand_name, P.platform_name
ORDER BY B.brand_name, content_ratio DESC;

-- 브랜드별 인스타그램 평균 like_count, comment_count
SELECT 
    P.platform_name,
	B.brand_name,
    COUNT(*) content_count,
    ROUND(AVG(C.like_count)) like_avg,
    ROUND(AVG(C.comment_count)) comment_avg
FROM content C
JOIN brand B ON B.brand_id=C.brand_id
JOIN platform P ON P.platform_id=C.platform_id
GROUP BY B.brand_name, P.platform_name
HAVING P.platform_name="인스타그램"
ORDER BY like_avg DESC;

-- 다이소 인스타그램 게시물 링크
SELECT C.content_url
FROM content C
JOIN brand B ON B.brand_id=C.brand_id
JOIN platform P ON P.platform_id=C.platform_id
WHERE B.brand_name="다이소" and P.platform_name="인스타그램";

-- 브랜드별 인스타그램 좋아요수 top 5 게시물 링크
SELECT *
FROM (
    SELECT
        P.platform_name,
        B.brand_name,
        C.like_count,
        ROUND(
            AVG(C.like_count) OVER (PARTITION BY B.brand_name)
        ) AS avg_like_count,
        C.content_url,
        ROW_NUMBER() OVER (
            PARTITION BY B.brand_name
            ORDER BY C.like_count DESC
        ) AS rn
    FROM content C
    JOIN brand B 
        ON B.brand_id = C.brand_id
    JOIN platform P 
        ON P.platform_id = C.platform_id
    WHERE P.platform_name = '인스타그램'
) t
WHERE rn <= 5
ORDER BY brand_name, like_count DESC;

-- 올리브영 인스타그램 좋아요수 
SELECT
	B.brand_name,
    P.platform_name,
    C.like_count,
    C.content_url
FROM content C
JOIN brand B ON B.brand_id = C.brand_id
JOIN platform P ON P.platform_id = C.platform_id
WHERE B.brand_name="올리브영" and P.platform_name="인스타그램"
ORDER BY like_count DESC;

-- 게시물 수 비중 대비 좋아요 비중 비교 
SELECT
    B.brand_name,
    COUNT(*) AS post_count,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS post_ratio,

    SUM(C.like_count) AS total_like_count,
    ROUND(
        SUM(C.like_count) * 100.0
        / SUM(SUM(C.like_count)) OVER (),
        2
    ) AS like_ratio

FROM content C
JOIN brand B ON B.brand_id = C.brand_id
JOIN platform P ON P.platform_id = C.platform_id
WHERE P.platform_name = '인스타그램'
GROUP BY B.brand_name
ORDER BY like_ratio DESC;