import requests
import time
import random
import os

# ================= USER PROMPTS ===================
print("\n🟢 Facebook Auto Comment Tool")
mode = input("\n[?] Mode (single/multi): ").strip().lower()
access_type = input("[?] Access via (token/cookie): ").strip().lower()

if access_type == "token":
    fb_token = input("[+] Enter Facebook Token: ").strip()
    fb_cookie = ""
elif access_type == "cookie":
    fb_cookie = input("[+] Enter Facebook Cookie: ").strip()
    fb_token = ""
else:
    print("[!] Invalid access type.")
    exit()

fb_id = input("[+] Enter Facebook ID: ").strip()
comment_file = input("[+] Enter comment file path: ").strip()
post_ids_file = input("[+] Enter post IDs file path: ").strip()
time_delay_min = int(input("[+] Enter minimum delay between comments (in seconds): ").strip())
time_delay_max = int(input("[+] Enter maximum delay between comments (in seconds): ").strip())

if not os.path.exists(comment_file) or not os.path.exists(post_ids_file):
    print("[!] Comment file or Post IDs file not found.")
    exit()

# ================= CORE FUNCTIONS ===================
def get_headers():
    if access_type == "token":
        return {
            "Authorization": f"Bearer {fb_token}",
            "Content-Type": "application/json"
        }
    else:
        return {
            "Cookie": fb_cookie,
            "User-Agent": "Mozilla/5.0"
        }

def read_comments():
    with open(comment_file, "r", encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip()]

def read_post_ids():
    with open(post_ids_file, "r") as f:
        return [line.strip() for line in f if line.strip()]

def send_comment(post_id, message):
    if access_type == "token":
        url = f"https://graph.facebook.com/{post_id}/comments"
        data = {
            "message": message,
            "access_token": fb_token
        }
        response = requests.post(url, data=data, headers=get_headers())
    else:
        url = f"https://mbasic.facebook.com/{post_id}"
        payload = {
            "fb_dtsg": "NA",  # Placeholder if needed
            "comment_text": message
        }
        response = requests.post(url, data=payload, headers=get_headers())
    return response.status_code, response.text

# =================== MAIN FLOW =====================
def main():
    comments = read_comments()
    post_ids = read_post_ids()

    for post_id in post_ids:
        try:
            comment = random.choice(comments)
            print(f"\n[+] Commenting on {post_id}: '{comment}'")
            status, resp = send_comment(post_id, comment)
            print(f"    → Status: {status}")
            time.sleep(random.randint(time_delay_min, time_delay_max))
        except Exception as e:
            print(f"[!] Error with post {post_id}: {e}")

if __name__ == "__main__":
    main()
