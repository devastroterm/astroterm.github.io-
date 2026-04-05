import json
import uuid

def massive_expand():
    with open("AstroTerm/Data/words.json", "r", encoding="utf-8") as f:
        words = json.load(f)

    seen = set((w["turkish"].lower(), w["english"].lower()) for w in words)
    new_entries = []

    # A1-A2 Words (General)
    a1_a2_words = [
        ("elma", "apple", "meyve"), ("armut", "pear", "meyve"), ("muz", "banana", "meyve"),
        ("çilek", "strawberry", "meyve"), ("üzüm", "grape", "meyve"), ("portakal", "orange", "meyve"),
        ("limon", "lemon", "meyve"), ("karpuz", "watermelon", "meyve"), ("kavun", "melon", "meyve"),
        ("kiraz", "cherry", "meyve"), ("kayısı", "apricot", "meyve"), ("şeftali", "peach", "meyve"),
        ("erik", "plum", "meyve"), ("nar", "pomegranate", "meyve"), ("incir", "fig", "meyve"),
        ("domates", "tomato", "sebze"), ("salatalık", "cucumber", "sebze"), ("patates", "potato", "sebze"),
        ("soğan", "onion", "sebze"), ("sarımsak", "garlic", "sebze"), ("havuç", "carrot", "sebze"),
        ("biber", "pepper", "sebze"), ("patlıcan", "eggplant", "sebze"), ("kabak", "zucchini", "sebze"),
        ("ıspanak", "spinach", "sebze"), ("marul", "lettuce", "sebze"), ("lahana", "cabbage", "sebze"),
        ("bezelye", "peas", "sebze"), ("fasulye", "beans", "sebze"), ("mısır", "corn", "sebze"),
        ("ekmek", "bread", "temel"), ("su", "water", "temel"), ("süt", "milk", "temel"),
        ("yumurta", "egg", "temel"), ("peynir", "cheese", "temel"), ("zeytin", "olive", "temel"),
        ("bal", "honey", "temel"), ("reçel", "jam", "temel"), ("tereyağı", "butter", "temel"),
        ("tuz", "salt", "temel"), ("şeker", "sugar", "temel"), ("baharat", "spice", "temel"),
        ("et", "meat", "temel"), ("tavuk", "chicken", "temel"), ("balık", "fish", "temel"),
        ("kırmızı", "red", "renk"), ("mavi", "blue", "renk"), ("yeşil", "green", "renk"),
        ("sarı", "yellow", "renk"), ("siyah", "black", "renk"), ("beyaz", "white", "renk"),
        ("turuncu", "orange", "renk"), ("mor", "purple", "renk"), ("pembe", "pink", "renk"),
        ("kahverengi", "brown", "renk"), ("gri", "gray", "renk"), ("lacivert", "dark blue", "renk"),
        ("açık mavi", "light blue", "renk"), ("altın", "gold", "renk"), ("gümüş", "silver", "renk"),
        ("bir", "one", "sayı"), ("iki", "two", "sayı"), ("üç", "three", "sayı"),
        ("dört", "four", "sayı"), ("beş", "five", "sayı"), ("altı", "six", "sayı"),
        ("yedi", "seven", "sayı"), ("sekiz", "eight", "sayı"), ("dokuz", "nine", "sayı"),
        ("on", "ten", "sayı"), ("yirmi", "twenty", "sayı"), ("otuz", "thirty", "sayı"),
        ("kırk", "forty", "sayı"), ("elli", "fifty", "sayı"), ("altmış", "sixty", "sayı"),
        ("yetmiş", "seventy", "sayı"), ("seksen", "eighty", "sayı"), ("doksan", "ninety", "sayı"),
        ("yüz", "hundred", "sayı"), ("bin", "thousand", "sayı"), ("milyon", "million", "sayı"),
        ("milyar", "billion", "sayı"), ("ilk", "first", "sıra"), ("ikinci", "second", "sıra"),
        ("üçüncü", "third", "sıra"), ("son", "last", "sıra"), ("tek", "single", "sıra"),
        ("çift", "double", "sıra"), ("yarım", "half", "sayı"), ("çeyrek", "quarter", "sayı"),
        ("anne", "mother", "aile"), ("baba", "father", "aile"), ("oğul", "son", "aile"),
        ("kız", "daughter", "aile"), ("kardeş", "sibling", "aile"), ("abi", "older brother", "aile"),
        ("abla", "older sister", "aile"), ("amca", "uncle", "aile"), ("hala", "aunt", "aile"),
        ("dayı", "uncle", "aile"), ("teyze", "aunt", "aile"), ("yeğen", "nephew/niece", "aile"),
        ("torun", "grandchild", "aile"), ("eş", "spouse", "aile"), ("koca", "husband", "aile"),
        ("karı", "wife", "aile"), ("akraba", "relative", "aile"), ("bebek", "baby", "aile"),
        ("çocuk", "child", "aile"), ("genç", "young", "insan"), ("yaşlı", "elderly", "insan"),
        ("erkek", "man", "insan"), ("kadın", "woman", "insan"), ("insan", "human", "insan"),
        ("kişi", "person", "insan"), ("halk", "people", "insan"), ("arkadaş", "friend", "sosyal"),
        ("dost", "close friend", "sosyal"), ("düşman", "enemy", "sosyal"), ("komşu", "neighbor", "sosyal"),
        ("misafir", "guest", "sosyal"), ("yabancı", "stranger", "sosyal"), ("sevgili", "lover", "sosyal"),
        ("ev", "house", "yer"), ("apartman", "apartment", "yer"), ("oda", "room", "yer"),
        ("salon", "living room", "yer"), ("mutfak", "kitchen", "yer"), ("banyo", "bathroom", "yer"),
        ("yatak odası", "bedroom", "yer"), ("bahçe", "garden", "yer"), ("balkon", "balcony", "yer"),
        ("çatı", "roof", "yer"), ("pencere", "window", "yer"), ("kapı", "door", "yer"),
        ("duvar", "wall", "yer"), ("yer", "floor", "yer"), ("tavan", "ceiling", "yer"),
        ("merdiven", "stairs", "yer"), ("asansör", "elevator", "yer"), ("masa", "table", "eşya"),
        ("sandalye", "chair", "eşya"), ("koltuk", "armchair", "eşya"), ("yatak", "bed", "eşya"),
        ("dolap", "cupboard", "eşya"), ("raf", "shelf", "eşya"), ("halı", "carpet", "eşya"),
        ("perde", "curtain", "eşya"), ("lamba", "lamp", "eşya"), ("ayna", "mirror", "eşya"),
        ("saat", "clock", "eşya"), ("radyo", "radio", "eşya"), ("televizyon", "television", "eşya"),
        ("telefon", "phone", "eşya"), ("bilgisayar", "computer", "eşya"), ("kitap", "book", "eşya"),
        ("defter", "notebook", "eşya"), ("kalem", "pen/pencil", "eşya"), ("kağıt", "paper", "eşya"),
        ("çanta", "bag", "eşya"), ("ayakkabı", "shoe", "giyim"), ("elbise", "dress", "giyim"),
        ("pantolon", "pants", "giyim"), ("gömlek", "shirt", "giyim"), ("ceket", "jacket", "giyim"),
        ("kazak", "sweater", "giyim"), ("çorap", "socks", "giyim"), ("şapka", "hat", "giyim"),
        ("gözlük", "glasses", "giyim"), ("saat", "watch", "giyim"), ("yüzük", "ring", "takı"),
        ("kolye", "necklace", "takı"), ("küpe", "earring", "takı"), ("bilezik", "bracelet", "takı")
    ]

    for tr, en, cat in a1_a2_words:
        if (tr.lower(), en.lower()) not in seen:
            new_entries.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "A1"
            })
            seen.add((tr.lower(), en.lower()))

    # B1-B2 Words
    b1_b2_words = [
        ("deneyim", "experience", "soyut"), ("başarı", "success", "soyut"), ("fırsat", "opportunity", "soyut"),
        ("zorluk", "difficulty", "soyut"), ("çözüm", "solution", "soyut"), ("karar", "decision", "soyut"),
        ("seçim", "choice", "soyut"), ("fikir", "idea", "soyut"), ("düşünce", "thought", "soyut"),
        ("hayal", "dream", "soyut"), ("umut", "hope", "soyut"), ("korku", "fear", "soyut"),
        ("güven", "trust", "soyut"), ("saygı", "respect", "soyut"), ("sevgi", "love", "soyut"),
        ("nefret", "hate", "soyut"), ("öfke", "anger", "soyut"), ("mutluluk", "happiness", "soyut"),
        ("üzüntü", "sadness", "soyut"), ("heyecan", "excitement", "soyut"), ("merak", "curiosity", "soyut"),
        ("sabır", "patience", "soyut"), ("cesaret", "courage", "soyut"), ("zeka", "intelligence", "soyut"),
        ("yetenek", "talent", "soyut"), ("beceri", "skill", "soyut"), ("bilgi", "knowledge", "soyut"),
        ("eğitim", "education", "sosyal"), ("okul", "school", "yer"), ("üniversite", "university", "yer"),
        ("kurs", "course", "eğitim"), ("ders", "lesson", "eğitim"), ("sınav", "exam", "eğitim"),
        ("ödev", "homework", "eğitim"), ("not", "grade", "eğitim"), ("diploma", "diploma", "eğitim"),
        ("kütüphane", "library", "yer"), ("laboratuvar", "laboratory", "yer"), ("sınıf", "classroom", "yer"),
        ("öğrenci", "student", "insan"), ("öğretmen", "teacher", "insan"), ("profesör", "professor", "insan"),
        ("müdür", "director", "is"), ("memur", "officer", "is"), ("işçi", "worker", "is"),
        ("doktor", "doctor", "sağlık"), ("hemşire", "nurse", "sağlık"), ("mühendis", "engineer", "is"),
        ("avukat", "lawyer", "hukuk"), ("polis", "police", "sosyal"), ("asker", "soldier", "sosyal"),
        ("yazar", "writer", "sanat"), ("şair", "poet", "sanat"), ("ressam", "painter", "sanat"),
        ("müzisyen", "musician", "sanat"), ("oyuncu", "actor", "sanat"), ("yönetmen", "director", "sanat"),
        ("çiftçi", "farmer", "tarım"), ("balıkçı", "fisherman", "tarım"), ("esnaf", "tradesman", "is"),
        ("tüccar", "merchant", "is"), ("girişimci", "entrepreneur", "is"), ("teknoloji", "technology", "bilim"),
        ("bilim", "science", "bilim"), ("araştırma", "research", "akademik"), ("keşif", "discovery", "bilim"),
        ("icat", "invention", "bilim"), ("deney", "experiment", "bilim"), ("teori", "theory", "akademik"),
        ("kanıt", "proof", "akademik"), ("veri", "data", "teknoloji"), ("sistem", "system", "teknoloji"),
        ("yazılım", "software", "teknoloji"), ("donanım", "hardware", "teknoloji"), ("internet", "internet", "teknoloji"),
        ("web sitesi", "website", "teknoloji"), ("uygulama", "application", "teknoloji"), ("ağ", "network", "teknoloji"),
        ("güvenlik", "security", "soyut"), ("şifre", "password", "teknoloji"), ("hesap", "account", "is"),
        ("fatura", "bill", "ekonomi"), ("vergi", "tax", "ekonomi"), ("banka", "bank", "yer"),
        ("para", "money", "ekonomi"), ("kredi kartı", "credit card", "ekonomi"), ("borç", "debt", "ekonomi")
    ]

    for tr, en, cat in b1_b2_words:
        if (tr.lower(), en.lower()) not in seen:
            new_entries.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "B1"
            })
            seen.add((tr.lower(), en.lower()))

    # C1-C2 Words
    c1_c2_words = [
        ("bağlam", "context", "akademik"), ("soyut", "abstract", "akademik"), ("somut", "concrete", "akademik"),
        ("kavram", "concept", "akademik"), ("kuram", "theory", "akademik"), ("ilkeler", "principles", "akademik"),
        ("yöntem", "method", "akademik"), ("süreç", "process", "soyut"), ("analiz", "analysis", "akademik"),
        ("sentez", "synthesis", "akademik"), ("değerlendirme", "evaluation", "akademik"), ("eleştiri", "criticism", "akademik"),
        ("yorumlama", "interpretation", "akademik"), ("tahmin", "prediction", "soyut"), ("varsayım", "assumption", "akademik"),
        ("hipotez", "hypothesis", "akademik"), ("değişken", "variable", "akademik"), ("denge", "balance", "soyut"),
        ("etki", "impact", "soyut"), ("sonuç", "consequence", "soyut"), ("neden", "cause", "soyut"),
        ("ilişki", "relationship", "soyut"), ("etkileşim", "interaction", "soyut"), ("yapı", "structure", "soyut"),
        ("işlev", "function", "soyut"), ("kaynak", "resource", "soyut"), ("kapasite", "capacity", "soyut"),
        ("potansiyel", "potential", "soyut"), ("strateji", "strategy", "is"), ("politika", "policy", "sosyal"),
        ("yönetim", "management", "is"), ("liderlik", "leadership", "is"), ("vizyon", "vision", "soyut"),
        ("misyon", "mission", "soyut"), ("hedef", "goal", "soyut"), ("amaç", "purpose", "soyut"),
        ("değer", "value", "soyut"), ("etik", "ethics", "felsefe"), ("ahlak", "morality", "felsefe"),
        ("felsefe", "philosophy", "bilim"), ("mantık", "logic", "felsefe"), ("estetik", "aesthetics", "sanat"),
        ("kültür", "culture", "sosyal"), ("toplum", "society", "sosyal"), ("kimlik", "identity", "sosyal"),
        ("gelenek", "tradition", "kültür"), ("modernlik", "modernity", "sosyal"), ("değişim", "change", "soyut"),
        ("gelişim", "development", "soyut"), ("ilerleme", "progress", "soyut"), ("evrim", "evolution", "bilim"),
        ("devrim", "revolution", "sosyal"), ("demokrasi", "democracy", "siyaset"), ("adalet", "justice", "hukuk"),
        ("özgürlük", "freedom", "soyut"), ("haklar", "rights", "hukuk")
    ]

    for tr, en, cat in c1_c2_words:
        if (tr.lower(), en.lower()) not in seen:
            new_entries.append({
                "id": str(uuid.uuid4()),
                "turkish": tr,
                "english": en,
                "category": cat,
                "cefrLevel": "C1"
            })
            seen.add((tr.lower(), en.lower()))

    final_words = words + new_entries
    print(f"Added {len(new_entries)} total new words.")
    print(f"Final total count: {len(final_words)}")

    with open("AstroTerm/Data/words.json", "w", encoding="utf-8") as f:
        json.dump(final_words, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    massive_expand()
