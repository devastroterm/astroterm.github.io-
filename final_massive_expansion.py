import json
import uuid

def final_expand():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    new_entries = []

    # Final massive list
    final_list = [
        # A1-A2 (Objects, Actions)
        ("elma", "apple", "meyve"), ("armut", "pear", "meyve"), ("çöp kutusu", "bin", "eşya"),
        ("tabak", "plate", "eşya"), ("kaşık", "spoon", "eşya"), ("çatal", "fork", "eşya"),
        ("bıçak", "knife", "eşya"), ("bardak", "glass", "eşya"), ("fincan", "cup", "eşya"),
        ("anahtar", "key", "eşya"), ("kilit", "lock", "eşya"), ("çekiç", "hammer", "eşya"),
        ("tornavida", "screwdriver", "eşya"), ("makas", "scissors", "eşya"), ("fırça", "brush", "eşya"),
        # B1-B2 (Professions)
        ("mimar", "architect", "meslek"), ("ressam", "artist", "meslek"), ("berber", "barber", "meslek"),
        ("marangoz", "carpenter", "meslek"), ("aşçı", "chef", "meslek"), ("diş hekimi", "dentist", "meslek"),
        ("editör", "editor", "meslek"), ("itfaiyeci", "firefighter", "meslek"), ("gazeteci", "journalist", "meslek"),
        ("kütüphaneci", "librarian", "meslek"), ("müzisyen", "musician", "meslek"), ("hemşire", "nurse", "meslek"),
        ("optisyen", "optician", "meslek"), ("eczacı", "pharmacist", "meslek"), ("pilot", "pilot", "meslek"),
        ("tesisatçı", "plumber", "meslek"), ("bilim insanı", "scientist", "meslek"), ("sekreter", "secretary", "meslek"),
        ("terzi", "tailor", "meslek"), ("veteriner", "vet", "meslek"), ("garson", "waiter", "meslek"),
        # B1-B2 (Instruments)
        ("akordeon", "accordion", "enstrüman"), ("çello", "cello", "enstrüman"), ("klarinet", "clarinet", "enstrüman"),
        ("flüt", "flute", "enstrüman"), ("arp", "harp", "enstrüman"), ("obua", "oboe", "enstrüman"),
        ("org", "organ", "enstrüman"), ("saksafon", "saxophone", "enstrüman"), ("trombon", "trombone", "enstrüman"),
        ("trompet", "trumpet", "enstrüman"), ("tuba", "tuba", "enstrüman"), ("viyola", "viola", "enstrüman"),
        ("keman", "violin", "enstrüman"), ("ksilofon", "xylophone", "enstrüman"),
        # C1-C2 (Advanced)
        ("hükümet", "government", "siyaset"), ("belediye", "municipality", "siyaset"), ("seçim", "election", "siyaset"),
        ("aday", "candidate", "siyaset"), ("parti", "party", "siyaset"), ("demokrasi", "democracy", "siyaset"),
        ("cumhuriyet", "republic", "siyaset"), ("başkan", "president", "siyaset"), ("bakan", "minister", "siyaset"),
        ("milletvekili", "deputy", "siyaset"), ("yasa", "law", "siyaset"), ("anayasa", "constitution", "siyaset"),
        ("vergi", "tax", "ekonomi"), ("enflasyon", "inflation", "ekonomi"), ("ihracat", "export", "ekonomi"),
        ("ithalat", "import", "ekonomi"), ("borç", "debt", "ekonomi"), ("faiz", "interest", "ekonomi"),
        ("döviz", "exchange", "ekonomi"), ("borsa", "stock market", "ekonomi"), ("yatırım", "investment", "ekonomi"),
        ("tüketici", "consumer", "ekonomi"), ("üretici", "producer", "ekonomi"), ("verimlilik", "productivity", "ekonomi"),
        ("istihdam", "employment", "is")
    ]

    new_count = 0
    for tr, en, cat in final_list:
        if (tr.lower(), en.lower()) not in seen:
            # Randomly assign level to avoid skewing
            level = "A1" if "eşya" in cat or "meyve" in cat else "B1" if "meslek" in cat or "enstrüman" in cat else "C1"
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": level
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    print(f"Added {new_count} more words.")
    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

final_expand()
