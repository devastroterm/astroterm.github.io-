import json
import uuid

def add_a1a2():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    
    a1_extras = [
        ("makarna", "pasta", "yiyecekler"),
        ("pirinç", "rice", "yiyecekler"),
        ("çay", "tea", "içecekler"),
        ("kahve", "coffee", "içecekler"),
        ("meyve suyu", "juice", "içecekler"),
        ("kahvaltı", "breakfast", "yiyecekler"),
        ("öğle yemeği", "lunch", "yiyecekler"),
        ("akşam yemeği", "dinner", "yiyecekler"),
        ("yatak", "bed", "ev"),
        ("koltuk", "sofa", "ev"),
        ("televizyon", "television", "ev"),
        ("mutfak", "kitchen", "ev"),
        ("banyo", "bathroom", "ev"),
        ("pencere", "window", "ev"),
        ("kapı", "door", "ev"),
        ("masa", "table", "ev"),
        ("sandalye", "chair", "ev"),
        ("büyükanne", "grandmother", "aile"),
        ("büyükbaba", "grandfather", "aile"),
        ("kuzen", "cousin", "aile"),
        ("bebek", "baby", "aile"),
        ("arkadaş", "friend", "sosyal"),
        ("komşu", "neighbor", "sosyal"),
        ("aslan", "lion", "hayvanlar"),
        ("kaplan", "tiger", "hayvanlar"),
        ("fil", "elephant", "hayvanlar"),
        ("zürafa", "giraffe", "hayvanlar"),
        ("maymun", "monkey", "hayvanlar"),
        ("yılan", "snake", "hayvanlar"),
        ("kelebek", "butterfly", "hayvanlar"),
        ("dağ", "mountain", "doğa"),
        ("nehir", "river", "doğa"),
        ("göl", "lake", "doğa"),
        ("okyanus", "ocean", "doğa"),
        ("orman", "forest", "doğa"),
        ("ağaç", "tree", "doğa"),
        ("çiçek", "flower", "doğa"),
        ("sarı", "yellow", "renkler"),
        ("mor", "purple", "renkler"),
        ("turuncu", "orange", "renkler"),
        ("kahverengi", "brown", "renkler"),
        ("pembe", "pink", "renkler"),
        ("sıfır", "zero", "sayılar"),
        ("on", "ten", "sayılar"),
        ("yirmi", "twenty", "sayılar"),
        ("otuz", "thirty", "sayılar"),
        ("kırk", "forty", "sayılar"),
        ("elli", "fifty", "sayılar"),
        ("yüz", "hundred", "sayılar"),
        ("bin", "thousand", "sayılar"),
        ("koşmak", "run", "fiiller"),
        ("yürümek", "walk", "fiiller"),
        ("yüzmek", "swim", "fiiller"),
        ("yemek", "eat", "fiiller"),
        ("içmek", "drink", "fiiller"),
        ("uyumak", "sleep", "fiiller"),
        ("gitmek", "go", "fiiller"),
        ("gelmek", "come", "fiiller"),
        ("bakmak", "look", "fiiller"),
        ("dinlemek", "listen", "fiiller"),
        ("konuşmak", "speak", "fiiller"),
        ("okumak", "read", "fiiller"),
        ("yazmak", "write", "fiiller"),
        ("öğrenmek", "learn", "fiiller"),
        ("öğretmek", "teach", "fiiller"),
        ("çalmak", "steal", "fiiller"),
        ("yardım etmek", "help", "fiiller"),
        ("sevmek", "love", "fiiller"),
        ("nefret etmek", "hate", "fiiller"),
        ("gülmek", "laugh", "fiiller"),
        ("ağlamak", "cry", "fiiller"),
        ("beklemek", "wait", "fiiller"),
        ("durmak", "stop", "fiiller"),
        ("başlamak", "start", "fiiller"),
        ("bitirmek", "finish", "fiiller"),
        ("çalışmak", "work", "fiiller"),
        ("oynamak", "play", "fiiller"),
        ("dans etmek", "dance", "fiiller"),
        ("şarkı söylemek", "sing", "fiiller"),
        ("çizmek", "draw", "fiiller")
    ]
    
    a2_extras = [
        ("havaalanı", "airport", "seyahat"),
        ("otobüs durağı", "bus station", "ulaşım"),
        ("tren istasyonu", "train station", "ulaşım"),
        ("bilet", "ticket", "seyahat"),
        ("otel", "hotel", "seyahat"),
        ("tatil", "vacation", "seyahat"),
        ("yolculuk", "journey", "seyahat"),
        ("çanta", "bag", "eşya"),
        ("eldiven", "gloves", "giyim"),
        ("atkı", "scarf", "giyim"),
        ("şemsiye", "umbrella", "eşya"),
        ("gözlük", "glasses", "eşya"),
        ("cüzdan", "wallet", "eşya"),
        ("anahtar", "key", "eşya"),
        ("saat", "clock", "eşya"),
        ("para", "money", "ekonomi"),
        ("fiyat", "price", "alışveriş"),
        ("indirim", "discount", "alışveriş"),
        ("müşteri", "customer", "is"),
        ("market", "grocery store", "alışveriş"),
        ("hastane", "hospital", "sağlık"),
        ("ilaç", "medicine", "sağlık"),
        ("doktor", "doctor", "meslekler"),
        ("hemşire", "nurse", "meslekler"),
        ("hasta", "patient", "sağlık"),
        ("ateş", "fever", "sağlık"),
        ("baş ağrısı", "headache", "sağlık"),
        ("soğuk algınlığı", "cold", "sağlık"),
        ("yaralanma", "injury", "sağlık"),
        ("ilk yardım", "first aid", "sağlık"),
        ("spor", "sports", "aktivite"),
        ("futbol", "football", "aktivite"),
        ("basketbol", "basketball", "aktivite"),
        ("voleybol", "volleyball", "aktivite"),
        ("tenis", "tennis", "aktivite"),
        ("kaykay", "skateboard", "aktivite"),
        ("bisiklet", "bicycle", "ulaşım"),
        ("motosiklet", "motorcycle", "ulaşım"),
        ("gemi", "ship", "ulaşım"),
        ("tren", "train", "ulaşım"),
        ("otobüs", "bus", "ulaşım"),
        ("uçak", "plane", "ulaşım"),
        ("helikopter", "helicopter", "ulaşım"),
        ("bulut", "cloud", "hava_durumu"),
        ("yağmur", "rain", "hava_durumu"),
        ("kar", "snow", "hava_durumu"),
        ("rüzgar", "wind", "hava_durumu"),
        ("fırtına", "storm", "hava_durumu"),
        ("güneşli", "sunny", "hava_durumu"),
        ("bulutlu", "cloudy", "hava_durumu"),
        ("karlı", "snowy", "hava_durumu"),
        ("yağmurlu", "rainy", "hava_durumu"),
        ("rüzgarlı", "windy", "hava_durumu"),
        ("derece", "degree", "hava_durumu"),
        ("mevsim", "season", "hava_durumu"),
        ("ilkbahar", "spring", "zaman"),
        ("yaz", "summer", "zaman"),
        ("sonbahar", "autumn", "zaman"),
        ("kış", "winter", "zaman")
    ]

    new_count = 0
    for tr, en, cat in a1_extras:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "A1"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    for tr, en, cat in a2_extras:
        if (tr.lower(), en.lower()) not in seen:
            words.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "A2"
            })
            seen.add((tr.lower(), en.lower()))
            new_count += 1

    print(f"Added {new_count} A1/A2 words.")
    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    add_a1a2()
