import json
import uuid

def add_c1c2():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    
    c1_extras = [
        ("nihilizm", "nihilism", "felsefe"),
        ("stoacılık", "stoicism", "felsefe"),
        ("epistemoloji", "epistemology", "felsefe"),
        ("solipsizm", "solipsism", "felsefe"),
        ("düalizm", "dualism", "felsefe"),
        ("entropi", "entropy", "bilim"),
        ("görelilik", "relativity", "bilim"),
        ("genom", "genome", "bilim"),
        ("fotosentez", "photosynthesis", "bilim"),
        ("kuantum", "quantum", "bilim"),
        ("hastalık", "disease", "tıp"),
        ("teşhis", "diagnosis", "tıp"),
        ("tedavi", "treatment", "tıp"),
        ("semptom", "symptom", "tıp"),
        ("bağışıklık", "immunity", "tıp"),
        ("genetik", "genetics", "bilim"),
        ("evrim", "evolution", "bilim"),
        ("ekoloji", "ecology", "bilim"),
        ("antropoloji", "anthropology", "bilim"),
        ("sosyoloji", "sociology", "bilim"),
        ("psikoloji", "psychology", "bilim"),
        ("ekonomi", "economics", "bilim"),
        ("istatistik", "statistics", "bilim"),
        ("matematik", "mathematics", "bilim"),
        ("biyoloji", "biology", "bilim"),
        ("kimya", "chemistry", "bilim"),
        ("fizik", "physics", "bilim"),
        ("astronomi", "astronomy", "bilim"),
        ("arkeoloji", "archaeology", "bilim"),
        ("jeoloji", "geology", "bilim"),
        ("meteoroloji", "meteorology", "bilim"),
        ("teknoloji", "technology", "bilim"),
        ("mühendislik", "engineering", "bilim"),
        ("mimarlık", "architecture", "sanat"),
        ("edebiyat", "literature", "sanat"),
        ("felsefe", "philosophy", "bilim"),
        ("tarih", "history", "bilim"),
        ("coğrafya", "geography", "bilim"),
        ("siyaset", "politics", "bilim"),
        ("hukuk", "law", "bilim"),
        ("eğitim", "education", "bilim"),
        ("iletişim", "communication", "bilim"),
        ("gazetecilik", "journalism", "bilim")
    ]
    
    c2_extras = [
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
    for tr, en, cat in c1_extras:
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

    for tr, en, cat in c2_extras:
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

    print(f"Added {new_count} C1/C2 words.")
    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    add_c1c2()
