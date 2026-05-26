# -*- coding: utf-8 -*-
"""comment_text 전체 맥락 기반 긍정/부정/중립 분류"""
import ast
import re
import pandas as pd

INPUT_PATH = r"c:\Users\ccc\All_About_Data_project\Data_project_github\ampm_2U\03_MySQL\comment_형태소분석.csv"
OUTPUT_PATH = r"c:\Users\ccc\All_About_Data_project\Data_project_github\ampm_2U\03_MySQL\comment_맥락_감성분석.csv"

# 형태소 기반 사전 (참고용)
MORPH_POS = [
    "좋", "추천", "만족", "괜찮", "효과", "최고", "가성비", "재구매", "싸다", "도움",
    "강추", "꿀템", "대박", "신뢰", "득템", "저렴", "유용", "감사", "편하", "착하",
    "혜자", "행복", "반갑", "기대", "귀엽", "만나", "챙기",
]
MORPH_NEG = [
    "별로", "비추", "실망", "낭비", "비싸", "효과없", "구라", "사기", "최악", "부작용",
    "과장", "후회", "싫", "못믿", "괜히", "싸구려", "오줌", "까맣", "휘청", "아프",
    "힘들", "막히", "부족",
]

# 맥락: 강한 긍정/부정 문구 (형태소와 무관하게 전체 문장 판단)
STRONG_POS = [
    r"감사", r"고마워", r"고맙", r"최고", r"대박", r"좋[은네다요]", r"너무\s*좋",
    r"잘\s*봤", r"잘\s*보고", r"유익", r"도움", r"추천", r"만족", r"재구매",
    r"구매했", r"샀습니다", r"득템", r"꿀템", r"혜자", r"행복", r"반갑", r"기대",
    r"사랑", r"짱", r"강추", r"효과\s*있", r"효과\s*봤", r"효과\s*났",
    r"편하", r"착하", r"가성비", r"저렴", r"싸[다게]", r"괜찮",
    r"덕분", r"정보\s*감사", r"영상\s*잘", r"구독", r"👍", r"❤", r"🥰", r"⭐️", r"💚",
    r"파이팅", r"응원", r"최고네", r"좋네요", r"좋아요", r"좋은\s*정보",
    r"달려가", r"고고", r"구입해봐", r"사야겠", r"살\s*예정",
    r"정가거부", r"마아아안", r"마세",  # 채널 인사
]
STRONG_NEG = [
    r"돈\s*낭비", r"낭비", r"오줌", r"사기", r"구라", r"거짓", r"속[았음]",
    r"별로", r"비추", r"실망", r"최악", r"후회", r"아깝", r"손절",
    r"효과\s*없", r"안\s*좋", r"안좋", r"못\s*믿", r"싸구려",
    r"부작용", r"까맣", r"휘청", r"뿌옇", r"어눌", r"증상",
    r"너무\s*아프", r"아픈", r"아파요", r"아픈대", r"힘들었", r"힘들어",
    r"남겨\s*먹", r"남기", r"별\s*차이\s*없", r"차이\s*안",
    r"안\s*되", r"안되", r"막힌", r"막히", r"안\s*들어", r"적용\s*안",
    r"잔액\s*부족", r"에바", r"인간적", r"개박살", r"박살",
    r"사지\s*마", r"마세요", r"위험", r"즉시\s*중단",
    r"과장", r"거부님.*고생",  # not used
]
# 부정 맥락이지만 의료용어/인사 등 예외
FALSE_NEG_BLOCK = [
    r"부정맥", r"아프지\s*마", r"아프지마", r"건강\s*조심", r"조심하세요",
    r"정가\s*거부", r"거부님",
]
# 할인 관련: 불만 vs 만족
DISCOUNT_COMPLAINT = [
    r"할인\s*안", r"안\s*들어", r"막힌", r"막히", r"중복\s*안", r"적용\s*안",
    r"안\s*되", r"안되", r"못\s*받", r"혜택\s*안",
]
DISCOUNT_POSITIVE = [
    r"할인\s*들어", r"할인\s*받", r"할인\s*적용", r"할인\s*해서", r"할인\s*되",
    r"혜자", r"좋았", r"행복",
]

QUESTION_PATTERNS = [
    r"\?", r"인가요", r"일까요", r"되나요", r"되요", r"돼요", r"가능한가",
    r"어떻게", r"어떤", r"무엇", r"뭔가", r"맞죠", r"맞나", r"알려", r"답변",
    r"부탁", r"가능한지", r"해야하", r"해야\s*하", r"인지", r"건가요",
]


def parse_morphs(val):
    if pd.isna(val) or val == "[]" or val == "":
        return []
    if isinstance(val, list):
        return val
    try:
        return ast.literal_eval(val)
    except (ValueError, SyntaxError):
        return []


def morph_sentiment(words):
    if not words:
        return "중립"
    pos = sum(1 for w in words if any(p in w for p in MORPH_POS))
    neg = sum(1 for w in words if any(n in w for n in MORPH_NEG))
    if pos > neg:
        return "긍정"
    if neg > pos:
        return "부정"
    return "중립"


def count_patterns(text, patterns):
    return sum(1 for p in patterns if re.search(p, text))


def is_question(text):
    t = text.strip()
    if not t:
        return False
    if count_patterns(t, QUESTION_PATTERNS) >= 1:
        if not re.search(r"(감사|좋[은네]|최고|대박|👍|❤)", t):
            if count_patterns(t, STRONG_NEG) == 0:
                return True
    return False


def contextual_sentiment(text, morphs):
    text = str(text) if pd.notna(text) else ""
    t = text.strip()

    if not t:
        return "중립"

    # 의료 부작용·불만 신고
    if re.search(r"부작용|휘청|까맣|뿌옇|어눌|즉시\s*중단|고객\s*센터.*중단", t):
        return "부정"

    # 가격·가치 불만
    if re.search(r"남겨\s*먹|오줌|돈\s*낭비|별\s*차이\s*없|차이\s*안\s*나", t):
        return "부정"

    # 제품 비추천·경고
    if re.search(r"사지\s*마세요|싸구려|비추|사기|구라", t):
        return "부정"

    # 할인/결제 문제 (불만) — 단순 질문·순서 문의는 제외
    if count_patterns(t, DISCOUNT_COMPLAINT) >= 1:
        if re.search(r"어찌|순서|어떻게\s*하|가능한가|되나요", t) and not re.search(
            r"막힌|안\s*들어|잔액\s*부족", t
        ):
            return "중립"
        elif re.search(r"넘기시면|들어\s*갑니다|참고|알려|모르겠", t) and not re.search(
            r"막힌|안\s*들어가", t
        ):
            return "중립"
        elif not re.search(r"감사|좋[은네]|괜찮|됩니다|되요|돼요|방법", t):
            return "부정"

    # CU/브랜드 불만 (에바, 박살 등)
    if re.search(r"에바|개박살|박살났", t):
        return "부정"

    # 건강 인사·응원 (아프지 마세요 등)
    if re.search(r"아프지\s*마|건강\s*조심|조심하세요|잘\s*챙기세요", t):
        if not re.search(r"너무\s*아프|아파요|아픈대|힘들었", t):
            return "긍정" if re.search(r"감사|좋은\s*정보", t) else "중립"

    # 신체 증상 호소 (부정맥 제외)
    if count_patterns(t, [r"아프", r"힘들", r"힘들었"]) >= 1:
        if not any(re.search(b, t) for b in FALSE_NEG_BLOCK):
            return "부정"

    # 강한 긍정
    pos_score = count_patterns(t, STRONG_POS)
    neg_score = count_patterns(t, STRONG_NEG)

    # '안되'는 할인 미적용 문의·팁 맥락에서는 부정 점수 제외
    if re.search(r"안\s*되", t) and re.search(
        r"넘기시면|모르겠|어찌|순서|어떻게|가능한가|되나요|맞죠|참고",
        t,
    ):
        neg_score = max(0, neg_score - 1)

    for block in FALSE_NEG_BLOCK:
        if re.search(block, t):
            neg_score = max(0, neg_score - 2)

    # 정가거부 채널 팬 댓글
    if re.search(r"정가\s*거부|거부님", t) and re.search(r"감사|고생|최고|놀라|마아아안|마세", t):
        return "긍정"

    # 아쉽 but overall positive/neutral
    if re.search(r"아쉽", t) and re.search(r"좋[은네]|감사|좋네", t):
        pos_score += 1

    if pos_score >= 2 or (pos_score >= 1 and neg_score == 0):
        return "긍정"
    if pos_score >= 1 and neg_score <= pos_score:
        return "긍정"

    if neg_score >= 2 or (neg_score >= 1 and pos_score == 0):
        return "부정"
    if neg_score >= 1 and pos_score < neg_score:
        return "부정"

    # 정보 공유·팁 (할인 안내 등) - 중립
    if re.search(r"참고|알려|넘기시면|순서|적용하니|되요|됩니다|방법입니다", t):
        if pos_score == 0 and neg_score == 0:
            return "중립"

    # 단순 질문
    if is_question(t):
        return "중립"

    # 형태소 보조 (맥락 점수 동점일 때)
    ms = morph_sentiment(morphs)
    if pos_score == neg_score == 0:
        return ms

    return "중립"


def main():
    df = pd.read_csv(INPUT_PATH, encoding="utf-8")
    df["형태소_리스트"] = df["형태소"].apply(parse_morphs)
    df["형태소기반_감정"] = df["형태소_리스트"].apply(morph_sentiment)
    df["맥락기반_감정"] = df.apply(
        lambda r: contextual_sentiment(r["comment_text"], r["형태소_리스트"]),
        axis=1,
    )

    out = df[
        ["comment_text", "content_id", "형태소", "형태소기반_감정", "맥락기반_감정"]
    ].copy()
    out.to_csv(OUTPUT_PATH, index=False, encoding="utf-8-sig")

    print("저장:", OUTPUT_PATH)
    print("\n[형태소 기반]")
    print(out["형태소기반_감정"].value_counts())
    print("\n[맥락 기반]")
    print(out["맥락기반_감정"].value_counts())
    diff = out[out["형태소기반_감정"] != out["맥락기반_감정"]]
    print(f"\n분류 변경: {len(diff)}건 / {len(out)}건")


if __name__ == "__main__":
    main()
