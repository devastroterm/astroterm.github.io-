import uuid
import json
import random

cefr = ["A1","A2","B1","B2"]
cats = [
    "aile","yiyecekler","ev","seyahat","is","saglik",
    "teknoloji","akademik","fiiller","soyut_fiiller"
]

base_words = [
    ("gitmek","to go"),("gelmek","to come"),
    ("yemek","to eat"),("çalışmak","to work"),
    ("düşünmek","to think"),("görmek","to see")
]

data = []

for i in range(10000):
    tr, en = random.choice(base_words)
    item = {
        "id": str(uuid.uuid4()),
        "turkish": tr + f"_{i}",
        "english": en,
        "category": random.choice(cats),
        "cefrLevel": random.choice(cefr)
    }
    data.append(item)

with open("words_10k.json","w",encoding="utf-8") as f:
    json.dump(data,f,ensure_ascii=False,indent=2)

print("DONE:", len(data))
