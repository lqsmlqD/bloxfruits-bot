import requests
import json
import re

def fetch_top_safe_bloxfruits_scripts():
    print("🔄 جاري سحب أحدث وأشهر سكربتات Blox Fruits...")
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    
    unique_scripts = []
    seen_titles = set()

    # سحب أول 5 صفحات للحصول على حوالي 50 إلى 100 سكربت ممتاز
    for page in range(1, 6):
        url = f"https://scriptblox.com/api/script/search?q=Blox%20Fruits&mode=free&page={page}"
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code == 200:
                data = response.json()
                scripts = data.get('result', {}).get('scripts', [])

                if not scripts:
                    break

                for s in scripts:
                    title = s.get('title', '').strip()
                    # تنظيف اسم السكربت للتحقق من المكرر
                    clean_title = re.sub(r'[^a-zA-Z0-9]', '', title).lower()
                    
                    if clean_title and clean_title not in seen_titles:
                        seen_titles.add(clean_title)
                        unique_scripts.append(s)

            else:
                print(f"❌ فشل السحب من الصفحة {page} (كود Response: {response.status_code})")
        except Exception as e:
            print(f"❌ خطأ في الصفحة {page}: {e}")

    with open("scripts.json", "w", encoding="utf-8") as f:
        json.dump(unique_scripts, f, ensure_ascii=False, indent=4)
        
    print(f"🎉 تم حفظ {len(unique_scripts)} سكربت بنجاح في scripts.json.")

if __name__ == "__main__":
    fetch_top_safe_bloxfruits_scripts()