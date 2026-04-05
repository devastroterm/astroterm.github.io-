import json
import uuid

def add_more():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    
    extra_c1 = [
        ("özümsemek", "assimilate", "sosyal"),
        ("karşılaştırmak", "juxtapose", "edebiyat"),
        ("muamma", "enigma", "soyut"),
        ("yerinde", "pertinent", "akademik"),
        ("dayanıklılık", "resilience", "psikoloji"),
        ("uzlaştırmak", "reconcile", "sosyal"),
        ("keyfi", "arbitrary", "akademik"),
        ("açıklık", "clarity", "akademik"),
        ("yaygınlık", "prevalence", "bilim"),
        ("olağanüstü", "extraordinary", "sıfat"),
        ("etkileşim", "interaction", "sosyal"),
        ("dönüşüm", "transformation", "soyut"),
        ("şeffaflık", "transparency", "is"),
        ("özerklik", "autonomy", "siyaset"),
        ("egemenlik", "sovereignty", "siyaset"),
        ("meşruiyet", "legitimacy", "siyaset"),
        ("bürokrasi", "bureaucracy", "is"),
        ("hiyerarşi", "hierarchy", "sosyal"),
        ("paradoks", "paradox", "felsefe"),
        ("metafor", "metaphor", "edebiyat"),
        ("ironi", "irony", "edebiyat"),
        ("estetik", "aesthetic", "sanat"),
        ("etik", "ethics", "felsefe"),
        ("ahlak", "morality", "felsefe"),
        ("adalet", "justice", "hukuk"),
        ("özgürlük", "liberty", "sosyal"),
        ("eşitlik", "equality", "sosyal"),
        ("kardeşlik", "fraternity", "sosyal"),
        ("dayanışma", "solidarity", "sosyal"),
        ("refah", "prosperity", "ekonomi"),
        ("yoksulluk", "poverty", "ekonomi"),
        ("enflasyon", "inflation", "ekonomi"),
        ("durgunluk", "recession", "ekonomi"),
        ("yatırım", "investment", "ekonomi"),
        ("sermaye", "capital", "ekonomi"),
        ("emek", "labor", "ekonomi"),
        ("maliyet", "cost", "ekonomi"),
        ("kar", "profit", "ekonomi"),
        ("zarar", "loss", "ekonomi"),
        ("pazarlama", "marketing", "is"),
        ("reklam", "advertising", "is"),
        ("tüketim", "consumption", "ekonomi"),
        ("üretim", "production", "ekonomi"),
        ("tedarik", "supply", "ekonomi"),
        ("talep", "demand", "ekonomi"),
        ("rekabet", "competition", "ekonomi"),
        ("tekel", "monopoly", "ekonomi"),
        ("küreselleşme", "globalization", "ekonomi"),
        ("sürdürülebilirlik", "sustainability", "çevre")
    ]
    
    extra_c2 = [
        ("vazgeçilmez", "indispensable", "sıfat"),
        ("kaçınılmaz", "unavoidable", "sıfat"),
        ("önlenemez", "unstoppable", "sıfat"),
        ("inanılmaz", "incredible", "sıfat"),
        ("anlatılmaz", "ineffable", "sıfat"),
        ("ulaşılmaz", "inaccessible", "sıfat"),
        ("dayanılmaz", "unbearable", "sıfat"),
        ("tartışılmaz", "indisputable", "sıfat"),
        ("reddedilemez", "irrefutable", "sıfat"),
        ("düzeltilemez", "incorrigible", "sıfat"),
        ("tükenmez", "inexhaustible", "sıfat"),
        ("unutulmaz", "unforgettable", "sıfat"),
        ("paha biçilemez", "priceless", "sıfat"),
        ("benzersiz", "unique", "sıfat"),
        ("olağan", "ordinary", "sıfat"),
        ("olağan dışı", "exceptional", "sıfat"),
        ("şaşırtıcı", "astounding", "sıfat"),
        ("büyüleyici", "mesmerizing", "sıfat"),
        ("göz kamaştırıcı", "dazzling", "sıfat"),
        ("korkunç", "dreadful", "sıfat"),
        ("berbat", "abysmal", "sıfat"),
        ("harika", "splendid", "sıfat"),
        ("muazzam", "tremendous", "sıfat"),
        ("devasa", "gargantuan", "sıfat"),
        ("minik", "minuscule", "sıfat"),
        ("önemsiz", "insignificant", "sıfat"),
        ("hayati", "vital", "sıfat"),
        ("ölümcül", "lethal", "sıfat"),
        ("faydalı", "beneficial", "sıfat"),
        ("zararlı", "harmful", "sıfat"),
        ("tehlikeli", "perilous", "sıfat"),
        ("güvenli", "secure", "sıfat"),
        ("sağlam", "sturdy", "sıfat"),
        ("zayıf", "feeble", "sıfat"),
        ("cesur", "valiant", "kişilik"),
        ("korkak", "craven", "kişilik"),
        ("sadık", "loyal", "kişilik"),
        ("hain", "treacherous", "kişilik"),
        ("açık sözlü", "forthright", "kişilik"),
        ("sinsi", "furtive", "kişilik"),
        ("nazik", "courteous", "kişilik"),
        ("kaba", "boorish", "kişilik"),
        ("akıllı", "astute", "kişilik"),
        ("aptal", "obtuse", "kişilik"),
        ("cömert", "lavish", "kişilik"),
        ("cimri", "parsimonious", "kişilik"),
        ("sakin", "placid", "kişilik"),
        ("heyecanlı", "exuberant", "kişilik")
    ]

    new_count = 0
    for tr, en, cat in extra_c1:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "C1"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    for tr, en, cat in extra_c2:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "C2"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    print(f"Added {new_count} more words.")
    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

add_more()
