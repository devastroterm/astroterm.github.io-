import json
import uuid

def add_b1b2():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    
    b1_extras = [
        ("fotoğrafçılık", "photography", "hobiler"),
        ("resim yapmak", "painting", "hobiler"),
        ("bahçıvanlık", "gardening", "hobiler"),
        ("kamp yapmak", "camping", "hobiler"),
        ("doğa yürüyüşü", "hiking", "hobiler"),
        ("gitar", "guitar", "müzik"),
        ("piyano", "piano", "müzik"),
        ("davul", "drums", "müzik"),
        ("satranç", "chess", "oyunlar"),
        ("bulmaca", "puzzle", "oyunlar"),
        ("çizgi roman", "comic book", "edebiyat"),
        ("dergi", "magazine", "edebiyat"),
        ("gazete", "newspaper", "medya"),
        ("internet", "internet", "teknoloji"),
        ("bilgisayar", "computer", "teknoloji"),
        ("yazılım", "software", "teknoloji"),
        ("donanım", "hardware", "teknoloji"),
        ("akıllı telefon", "smartphone", "teknoloji"),
        ("sosyal medya", "social media", "medya"),
        ("siber güvenlik", "cybersecurity", "teknoloji"),
        ("mülakat", "interview", "is"),
        ("terfi", "promotion", "is"),
        ("maaş", "salary", "ekonomi"),
        ("toplantı", "meeting", "is"),
        ("proje", "project", "is"),
        ("meslektaş", "colleague", "is"),
        ("patron", "boss", "is"),
        ("emeklilik", "retirement", "is"),
        ("beslenme", "nutrition", "sağlık"),
        ("egzersiz", "exercise", "sağlık"),
        ("meditasyon", "meditation", "sağlık"),
        ("terapi", "therapy", "sağlık"),
        ("sağlıklı yaşam", "wellness", "sağlık"),
        ("kronik", "chronic", "sağlık"),
        ("belirti", "symptom", "sağlık"),
        ("kirlilik", "pollution", "çevre"),
        ("küresel ısınma", "global warming", "çevre"),
        ("geri dönüşüm", "recycling", "çevre"),
        ("yoksulluk", "poverty", "toplum"),
        ("eşitlik", "equality", "toplum"),
        ("göç", "immigration", "toplum")
    ]
    
    b2_extras = [
        ("strateji", "strategy", "is"),
        ("analiz", "analysis", "akademik"),
        ("istatistik", "statistics", "bilim"),
        ("araştırma", "research", "akademik"),
        ("yöntem", "methodology", "akademik"),
        ("kriter", "criterion", "akademik"),
        ("değerlendirme", "evaluation", "is"),
        ("karşılaştırma", "comparison", "akademik"),
        ("çelişki", "contradiction", "soyut"),
        ("öncelik", "priority", "is"),
        ("esneklik", "flexibility", "is"),
        ("güvenilirlik", "reliability", "is"),
        ("verimlilik", "efficiency", "is"),
        ("rekabet", "competition", "ekonomi"),
        ("isbirliği", "collaboration", "is"),
        ("yenilikçi", "innovative", "is"),
        ("sürdürülebilir", "sustainable", "çevre"),
        ("etik", "ethics", "felsefe"),
        ("ahlak", "morality", "felsefe"),
        ("felsefi", "philosophical", "felsefe"),
        ("mantıksal", "logical", "felsefe"),
        ("teorik", "theoretical", "akademik"),
        ("pratik", "practical", "akademik"),
        ("somut", "concrete", "akademik"),
        ("soyut", "abstract", "akademik"),
        ("belirsizlik", "uncertainty", "soyut"),
        ("karmaşıklık", "complexity", "soyut"),
        ("etkileşim", "interaction", "teknoloji"),
        ("bağımsızlık", "independence", "siyaset"),
        ("özgürlük", "liberty", "siyaset"),
        ("adalet", "justice", "hukuk"),
        ("hukuk", "law", "hukuk"),
        ("anayasa", "constitution", "hukuk"),
        ("hakim", "judge", "hukuk"),
        ("avukat", "lawyer", "hukuk"),
        ("savcı", "prosecutor", "hukuk"),
        ("delil", "evidence", "hukuk"),
        ("suç", "crime", "hukuk"),
        ("ceza", "punishment", "hukuk")
    ]

    new_count = 0
    for tr, en, cat in b1_extras:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "B1"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    for tr, en, cat in b2_extras:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "B2"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    print(f"Added {new_count} B1/B2 words.")
    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    add_b1b2()
