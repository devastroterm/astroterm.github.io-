import json
import uuid
import os

def expand_words():
    base_file = "AstroTerm/Data/words.json"
    if not os.path.exists(base_file):
        print(f"Error: {base_file} not found.")
        return

    with open(base_file, "r", encoding="utf-8") as f:
        words = json.load(f)

    # 1. Deduplicate existing words
    seen = set()
    unique_words = []
    for w in words:
        # Clean potential indices if any leaked
        if "_" in w["turkish"] and any(char.isdigit() for char in w["turkish"].split("_")[-1]):
            w["turkish"] = w["turkish"].rsplit("_", 1)[0]
        
        pair = (w["turkish"].lower(), w["english"].lower())
        if pair not in seen:
            seen.add(pair)
            unique_words.append(w)

    print(f"Base unique words: {len(unique_words)}")

    # 2. Add C1-C2 expansion words
    new_entries = []
    
    # C1 level words
    c1_words = [
        ("meşru", "legitimate", "hukuk"),
        ("titiz", "meticulous", "sıfat"),
        ("öngörü", "foresight", "soyut"),
        ("tutarlı", "coherent", "akademik"),
        ("elzem", "essential", "sıfat"),
        ("çelişki", "contradiction", "soyut"),
        ("müzakere", "negotiate", "is"),
        ("ikna edici", "persuasive", "sıfat"),
        ("kapsamlı", "comprehensive", "sıfat"),
        ("tahmin edilebilir", "predictable", "sıfat"),
        ("rastlantı", "coincidence", "soyut"),
        ("itibar", "reputation", "sosyal"),
        ("hoşgörü", "tolerance", "soyut"),
        ("bağlılık", "commitment", "duygu"),
        ("kaynak", "source", "akademik"),
        ("şeffaf", "transparent", "sıfat"),
        ("yenilikçi", "innovative", "teknoloji"),
        ("verimlilik", "efficiency", "is"),
        ("vurgulamak", "emphasize", "akademik"),
        ("onaylamak", "approve", "is"),
        ("itiraz etmek", "object", "hukuk"),
        ("yansıtmak", "reflect", "soyut"),
        ("sürdürülebilir", "sustainable", "çevre"),
        ("öncelik", "priority", "is"),
        ("etkileşim", "interaction", "teknoloji"),
        ("stratejik", "strategic", "is"),
        ("gözlemlemek", "observe", "bilim"),
        ("analiz etmek", "analyze", "akademik"),
        ("yorumlamak", "interpret", "akademik"),
        ("kanıt", "evidence", "hukuk"),
        ("kuram", "theory", "akademik"),
        ("yaklaşım", "approach", "akademik"),
        ("farkındalık", "awareness", "soyut"),
        ("işbirliği", "collaboration", "is"),
        ("denge", "balance", "soyut"),
        ("kritik", "critical", "sıfat"),
        ("potansiyel", "potential", "sıfat"),
        ("değerlendirmek", "evaluate", "akademik"),
        ("yönetmek", "manage", "is"),
        ("uygulamak", "implement", "is"),
        ("geliştirmek", "develop", "teknoloji"),
        ("çeşitlilik", "diversity", "sosyal"),
        ("küresel", "global", "sosyal"),
        ("yerel", "local", "sosyal"),
        ("geleneksel", "traditional", "kültür"),
        ("modern", "modern", "kültür"),
        ("karmaşık", "complex", "akademik"),
        ("basit", "simple", "sıfat"),
        ("doğru", "accurate", "akademik"),
        ("belirsiz", "ambiguous", "akademik"),
        ("açık", "obvious", "sıfat"),
        ("gizli", "hidden", "sıfat"),
        ("somut", "concrete", "felsefe"),
        ("soyut", "abstract", "felsefe"),
        ("mantıklı", "logical", "felsefe"),
        ("duygusal", "emotional", "duygu"),
        ("objektif", "objective", "akademik"),
        ("subjektif", "subjective", "akademik"),
        ("kalıcı", "permanent", "zaman"),
        ("geçici", "temporary", "zaman"),
        ("eski", "ancient", "tarih"),
        ("çağdaş", "contemporary", "tarih"),
        ("evrensel", "universal", "felsefe"),
        ("tikel", "particular", "felsefe"),
        ("zorunlu", "mandatory", "hukuk"),
        ("isteğe bağlı", "optional", "is"),
        ("verimli", "productive", "is"),
        ("etkisiz", "ineffective", "is"),
        ("güçlü", "powerful", "sıfat"),
        ("zayıf", "vulnerable", "sıfat"),
        ("bağımsız", "independent", "sosyal"),
        ("bağımlı", "dependent", "sosyal")
    ]
    
    # C2 level words
    c2_words = [
        ("paradigma", "paradigm", "akademik"),
        ("derin", "profound", "felsefe"),
        ("eskimiş", "obsolete", "teknoloji"),
        ("geçici", "ephemeral", "felsefe"),
        ("incelikli", "nuanced", "akademik"),
        ("titiz", "scrupulous", "sıfat"),
        ("her yerde bulunan", "ubiquitous", "teknoloji"),
        ("anlaşılmaz", "enigmatic", "soyut"),
        ("kaçınılmaz", "inevitable", "soyut"),
        ("ikircikli", "ambivalent", "duygu"),
        ("eli açık", "magnanimous", "kişilik"),
        ("vurdumduymaz", "apathetic", "duygu"),
        ("geçici", "transient", "zaman"),
        ("gereksiz", "superfluous", "sıfat"),
        ("içsel", "intrinsic", "felsefe"),
        ("dışsal", "extrinsic", "felsefe"),
        ("etkili", "cogent", "akademik"),
        ("farklı", "disparate", "sıfat"),
        ("kibirli", "supercilious", "kişilik"),
        ("yaltaklanan", "obsequious", "kişilik"),
        ("çabuk değişen", "mercurial", "kişilik"),
        ("kararlı", "resolute", "kişilik"),
        ("bilge", "sagacious", "kişilik"),
        ("sessiz", "reticent", "kişilik"),
        ("geveze", "loquacious", "kişilik"),
        ("çalışkan", "assiduous", "kişilik"),
        ("dikkatli", "circumspect", "kişilik"),
        ("savruk", "improvident", "kişilik"),
        ("inatçı", "tenacious", "kişilik"),
        ("uysal", "docile", "kişilik"),
        ("kırılgan", "fragile", "sıfat"),
        ("dayanıklı", "resilient", "sıfat"),
        ("önemli", "significant", "akademik"),
        ("önemsiz", "negligible", "akademik"),
        ("zorlu", "arduous", "sıfat"),
        ("kolay", "facile", "sıfat"),
        ("açık sözlü", "candid", "kişilik"),
        ("sinsi", "insidious", "kişilik"),
        ("yaygın", "pervasive", "sıfat"),
        ("seyrek", "sporadic", "sıfat"),
        ("derinlikli", "deep-seated", "soyut"),
        ("temelsiz", "unfounded", "soyut"),
        ("güvenilir", "reliable", "sıfat"),
        ("aldatıcı", "deceptive", "sıfat"),
        ("özgün", "authentic", "sıfat"),
        ("sahte", "spurious", "sıfat"),
        ("yapıcı", "constructive", "is"),
        ("yıkıcı", "destructive", "is"),
        ("faydalı", "beneficial", "is"),
        ("zararlı", "detrimental", "is"),
        ("açık", "explicit", "akademik"),
        ("örtük", "implicit", "akademik"),
        ("doğuştan", "innate", "bilim"),
        ("edinilmiş", "acquired", "bilim"),
        ("kararlı", "steadfast", "kişilik"),
        ("kararsız", "vacillating", "kişilik"),
        ("anlayışlı", "perceptive", "kişilik"),
        ("dar görüşlü", "myopic", "kişilik"),
        ("cömert", "altruistic", "kişilik"),
        ("bencil", "egocentric", "kişilik"),
        ("uyumlu", "harmonious", "sıfat"),
        ("uyumsuz", "discordant", "sıfat"),
        ("etkileyici", "evocative", "sanat"),
        ("sıkıcı", "mundane", "sıfat"),
        ("muhteşem", "sublime", "sanat"),
        ("çirkin", "grotesque", "sanat"),
        ("canlı", "vibrant", "sıfat"),
        ("solgun", "pallid", "sıfat"),
        ("gürültülü", "clamorous", "sıfat"),
        ("sessiz", "serene", "sıfat")
    ]

    for tr, en, cat in c1_words:
        new_entries.append({
            "id": str(uuid.uuid4()),
            "turkish": tr,
            "english": en,
            "category": cat,
            "cefrLevel": "C1"
        })

    for tr, en, cat in c2_words:
        new_entries.append({
            "id": str(uuid.uuid4()),
            "turkish": tr,
            "english": en,
            "category": cat,
            "cefrLevel": "C2"
        })

    # Add to main list and deduplicate again just in case
    final_list = unique_words + new_entries
    
    seen_final = set()
    deduped_final = []
    for w in final_list:
        pair = (w["turkish"].lower(), w["english"].lower())
        if pair not in seen_final:
            seen_final.add(pair)
            deduped_final.append(w)

    print(f"Final word count: {len(deduped_final)}")

    with open(base_file, "w", encoding="utf-8") as f:
        json.dump(deduped_final, f, ensure_ascii=False, indent=2)

    print("Success: Updated words.json and removed indices.")

if __name__ == "__main__":
    expand_words()
