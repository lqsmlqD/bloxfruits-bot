import asyncio
from datetime import datetime, timedelta, timezone
import json
import os
import re
from threading import Thread

import discord
from discord import app_commands
from discord.ext import commands
from flask import Flask

# --- سيرفر إبقاء البوت مستيقظاً على Render ---
app = Flask("")


@app.route("/")
def home():
  return "Bot is Alive!"


def run_flask():
  app.run(host="0.0.0.0", port=8080)


def keep_alive():
  t = Thread(target=run_flask)
  t.daemon = True
  t.start()


keep_alive()

TOKEN = "MTU0Mjk2NzAxOTgyODI4NTU5MA.GNN1Ui.VN1hVzgraeHhNT5zjCoZepx9reV85ncPT-Cn5U"
GUILD_ID = discord.Object(id=1540821164300046406)
SPECIAL_ROLE_ID = 1543204347049943121


# ==================== نظام الأوتومود وتنظيف النصوص ====================
def normalize_arabic_text(text: str) -> str:
  if not text:
    return ""
  text = text.lower()
  text = re.sub(r"[\u064b-\u0652\u0640]", "", text)
  text = re.sub(r"[^\u0621-\u064A\s]", "", text)
  text = re.sub(r"[إأآا]", "ا", text)
  text = re.sub(r"ى", "ي", text)
  text = re.sub(r"ة", "ه", text)
  text = re.sub(r"(.)\1+", r"\1", text)
  return text.strip()


BAD_WORDS_SET = set()


def load_bad_words_database():
  global BAD_WORDS_SET
  if os.path.exists("bad_words.json"):
    try:
      with open("bad_words.json", "r", encoding="utf-8") as f:
        words_list = json.load(f)
        for w in words_list:
          cleaned = normalize_arabic_text(w)
          if cleaned:
            BAD_WORDS_SET.add(cleaned)
      print(f"✅ تم تحميل {len(BAD_WORDS_SET)} كلمة ممنوعة في الذاكرة بنجاح!")
    except Exception as e:
      print(f"❌ خطأ في تحميل bad_words.json: {e}")


load_bad_words_database()


def is_profane(message_content: str) -> bool:
  cleaned_text = normalize_arabic_text(message_content)
  words = cleaned_text.split()
  for word in words:
    if word in BAD_WORDS_SET:
      return True
  no_space_text = cleaned_text.replace(" ", "")
  for bad_word in BAD_WORDS_SET:
    if len(bad_word) >= 3 and bad_word in no_space_text:
      return True
  return False


# ==================== إعدادات البوت والسكربتات ====================
class MyBot(commands.Bot):

  def __init__(self):
    intents = discord.Intents.default()
    intents.message_content = True
    intents.members = True
    super().__init__(command_prefix="!", intents=intents)

  async def setup_hook(self):
    self.tree.clear_commands(guild=GUILD_ID)
    self.tree.add_command(script_command, guild=GUILD_ID)
    await self.tree.sync(guild=GUILD_ID)


bot = MyBot()


def load_local_scripts():
  try:
    with open("scripts.json", "r", encoding="utf-8") as f:
      return json.load(f)
  except FileNotFoundError:
    return []


class ScriptButton(discord.ui.Button):

  def __init__(self, label, script_data):
    super().__init__(label=label, style=discord.ButtonStyle.primary)
    self.script_data = script_data

  async def callback(self, interaction: discord.Interaction):
    raw_script = self.script_data.get("script", "-- لا يوجد كود متوفر")
    title = self.script_data.get("title", "Blox Fruits Script")
    key_status = "نعم" if self.script_data.get("key", False) else "لا (بدون كي)"

    embed = discord.Embed(
        title=f"📜 {title}",
        description=(
            f"**يتطلب مفتاح (Key)؟** `{key_status}`\n\n```lua\n{raw_script}\n```"
        ),
        color=discord.Color.green(),
    )
    await interaction.response.send_message(embed=embed, ephemeral=True)


class LocalScriptPaginatorView(discord.ui.View):

  def __init__(self, scripts):
    super().__init__(timeout=120)
    self.scripts = scripts
    self.current_page = 0
    self.items_per_page = 10
    self.build_ui()

  def build_ui(self):
    self.clear_items()
    start_idx = self.current_page * self.items_per_page
    end_idx = min(start_idx + self.items_per_page, len(self.scripts))
    page_scripts = self.scripts[start_idx:end_idx]

    for idx, script in enumerate(page_scripts):
      self.add_item(ScriptButton(label=str(idx + 1), script_data=script))

    prev_btn = discord.ui.Button(
        label="◀ السابق",
        style=discord.ButtonStyle.secondary,
        disabled=(self.current_page == 0),
        row=2,
    )
    next_btn = discord.ui.Button(
        label="التالي ▶",
        style=discord.ButtonStyle.secondary,
        disabled=(end_idx >= len(self.scripts)),
        row=2,
    )

    prev_btn.callback = self.prev_page
    next_btn.callback = self.next_page

    self.add_item(prev_btn)
    self.add_item(next_btn)

  async def prev_page(self, interaction: discord.Interaction):
    self.current_page -= 1
    self.build_ui()
    embed = self.get_page_embed()
    await interaction.response.edit_message(embed=embed, view=self)

  async def next_page(self, interaction: discord.Interaction):
    self.current_page += 1
    self.build_ui()
    embed = self.get_page_embed()
    await interaction.response.edit_message(embed=embed, view=self)

  def get_page_embed(self):
    total = len(self.scripts)
    start_idx = self.current_page * self.items_per_page
    end_idx = min(start_idx + self.items_per_page, total)

    description = (
        f"⭐ **قائمة الأشهر والأكثر أماناً لـ Blox Fruits** (عدد"
        f" السكربتات: {total})\n\n"
    )
    for i, s in enumerate(self.scripts[start_idx:end_idx]):
      description += f"**{i+1}.** {s.get('title')} ✅\n"

    embed = discord.Embed(
        title=f"🏴‍☠️ السكربتات الموثوقة (صفحة {self.current_page + 1})",
        description=description,
        color=discord.Color.gold(),
    )
    embed.set_footer(text="اضغط رقم السكربت للحصول على كوده المباشر.")
    return embed


@app_commands.command(
    name="script", description="عرض السكربتات الشهيرة والمستقرة لـ Blox Fruits"
)
async def script_command(interaction: discord.Interaction):
  scripts = load_local_scripts()
  if not scripts:
    await interaction.response.send_message(
        "❌ لم يتم العثور على `scripts.json`. شغل `fetch_all.py` أولاً!",
        ephemeral=True,
    )
    return

  view = LocalScriptPaginatorView(scripts)
  embed = view.get_page_embed()
  await interaction.response.send_message(embed=embed, view=view, ephemeral=True)


def parse_duration_from_text(text):
  clean_text = re.sub(r"<@!?\d+>", "", text).strip()
  matches = re.findall(
      r"(\d+(?:\.\d+)?)\s*([s|m|h|d|ث|د|س|ي]?)", clean_text.lower()
  )
  for amount_str, unit in matches:
    if not amount_str:
      continue
    amount = float(amount_str)
    seconds = 0
    if unit in ["ث", "s"]:
      seconds = amount
    elif unit in ["د", "m", ""]:
      seconds = amount * 60
    elif unit in ["س", "h"]:
      seconds = amount * 3600
    elif unit in ["ي", "d"]:
      seconds = amount * 86400
    if seconds > 0:
      original_str = f"{amount_str}{unit if unit else 'د'}"
      if seconds < 60:
        seconds = 60
      elif seconds > 2419200:
        seconds = 2419200
      return timedelta(seconds=seconds), original_str
  return timedelta(seconds=60), "60s"


# ==================== استقبال الرسائل والأوامر ====================
user_violations = {}


@bot.event
async def on_message(message: discord.Message):
  if message.author.bot or not message.guild:
    return

  # 1. فحص الأوتومود والعقوبات المتصاعدة (لغير الأدمن)
  if not message.author.guild_permissions.administrator:
    if is_profane(message.content):
      try:
        await message.delete()

        user_id = message.author.id
        now = datetime.now(timezone.utc)

        if user_id in user_violations:
          last_time = user_violations[user_id]["last_violation"]
          if (now - last_time).total_seconds() > 86400:
            user_violations[user_id] = {"count": 1, "last_violation": now}
          else:
            user_violations[user_id]["count"] += 1
            user_violations[user_id]["last_violation"] = now
        else:
          user_violations[user_id] = {"count": 1, "last_violation": now}

        current_count = user_violations[user_id]["count"]
        timeout_minutes = current_count * 5
        next_timeout = (current_count + 1) * 5

        await message.author.timeout(
            timedelta(minutes=timeout_minutes),
            reason=f"مخالفة الألفاظ رقم {current_count} خلال 24 ساعة",
        )

        warn_msg = await message.channel.send(
            f"🚫 {message.author.mention} **تم حذف رسالتك ومعاقبتك بتايم أوت"
            f" لمدة `{timeout_minutes}` دقائق (المخالفة رقم"
            f" {current_count}).**\n⚠️ **المرة القادمة ستكون العقوبة"
            f" `{next_timeout}` دقائق!**"
        )
        await asyncio.sleep(6)
        await warn_msg.delete()
        return
      except Exception as e:
        print(f"خطأ في تطبيق العقوبة: {e}")

  # 2. الأوامر الإدارية السابقة
  content = message.content.strip()
  admin_commands = [
      "#قفل",
      "#غلق",
      "#فتح",
      "نضف",
      "نظف",
      "مسح",
      "اص",
      "تكلم",
      "تكلموا",
      "بنعالي",
      "ارجاع",
      "تفضل",
      "شيل",
  ]
  is_admin_cmd = any(content.startswith(cmd) for cmd in admin_commands)

  if is_admin_cmd:
    if (
        not isinstance(message.author, discord.Member)
        or not message.author.guild_permissions.administrator
    ):
      await message.reply("يرجال دز ههههههههههههههه")
      return

  if content in ["#قفل", "#غلق"]:
    await asyncio.gather(
        message.channel.set_permissions(
            message.guild.default_role, send_messages=False
        ),
        message.reply("🔒 تم قفل الشات بنجاح"),
    )
    return

  if content == "#فتح":
    await asyncio.gather(
        message.channel.set_permissions(
            message.guild.default_role, send_messages=True
        ),
        message.reply("🔓 تم فتح الشات بنجاح"),
    )
    return

  if content in ["نضف", "نظف", "مسح"]:
    prompt_msg = await message.reply("🗑️ كم عدد الرسائل التي تريد حذفها؟")

    def check(m):
      return (
          m.author == message.author
          and m.channel == message.channel
          and m.content.isdigit()
      )

    try:
      response = await bot.wait_for("message", check=check, timeout=15.0)
      amount = int(response.content)
      await message.channel.purge(limit=amount + 3)
      confirm_msg = await message.channel.send(
          f"🧹 **تم حذف `{amount}` رسالة.**"
      )
      await asyncio.sleep(3)
      await confirm_msg.delete()
    except asyncio.TimeoutError:
      await prompt_msg.delete()
      fail_msg = await message.reply("⏰ تم إلغاء الأمر (لم يتم تحديد العدد).")
      await asyncio.sleep(3)
      await fail_msg.delete()
    return

  if content.startswith("اص"):
    if not message.mentions:
      await message.reply("تم اعطاء العضو تايم")
      return
    target = message.mentions[0]
    duration, duration_str = parse_duration_from_text(content)
    try:
      await target.timeout(duration, reason=f"بواسطة {message.author}")
      await message.reply(f"تم اعطاء {target.mention} تايم لمدة {duration_str}")
    except discord.Forbidden:
      await message.reply("❌ **فشل:** رتبة البوت أقل من العضو!")
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("تكلم") or content.startswith("تكلموا"):
    if not message.mentions:
      await message.reply("تم فك التايم عن العضو")
      return
    target = message.mentions[0]
    try:
      await target.timeout(None, reason=f"فك الإسكات بواسطة {message.author}")
      await message.reply(f"تم فك التايم عن {target.mention}")
    except discord.Forbidden:
      await message.reply("❌ **فشل:** رتبة البوت أقل من العضو!")
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("بنعالي"):
    if not message.mentions:
      await message.reply("تم اعطاء العضو باند نهائي")
      return
    target = message.mentions[0]
    try:
      await target.ban(reason=f"بواسطة {message.author}")
      await message.reply(f"تم اعطاء {target.mention} باند نهائي")
    except discord.Forbidden:
      await message.reply(
          "❌ **فشل:** رتبة البوت أقل من العضو أو ينقصه صلاحية Ban!"
      )
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("ارجاع"):
    if not message.mentions:
      await message.reply("تم فك الباند عن العضو")
      return
    target = message.mentions[0]
    try:
      await message.guild.unban(target, reason=f"فك الحظر بواسطة {message.author}")
      await message.reply(f"تم فك الباند عن {target.mention}")
    except discord.NotFound:
      await message.reply("❌ **خطأ:** هذا العضو غير محظور أساساً!")
    except discord.Forbidden:
      await message.reply("❌ **فشل:** ينقص البوت صلاحية Ban Members!")
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("تفضل"):
    if not message.mentions:
      await message.reply("تم اعطاء الرتبة للعضو بنجاح")
      return
    target = message.mentions[0]
    role = message.guild.get_role(SPECIAL_ROLE_ID)
    if not role:
      await message.reply("❌ **خطأ:** لم يتم العثور على الرتبة بالـ ID المحدد!")
      return
    try:
      await target.add_roles(role)
      await message.reply(f"تم اعطاء الرتبة لـ {target.mention} بنجاح ✅")
    except discord.Forbidden:
      await message.reply("❌ **فشل:** رتبة البوت أقل من الرتبة المراد إعطاؤها!")
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content == "شيل":
    role = message.guild.get_role(SPECIAL_ROLE_ID)
    if not role:
      await message.reply("❌ **خطأ:** لم يتم العثور على الرتبة بالـ ID المحدد!")
      return

    status_msg = await message.reply("⚙️ جاري نزع الرتبة من الجميع...")
    count = 0
    try:
      for member in role.members:
        await member.remove_roles(role)
        count += 1
      await status_msg.edit(
          content=f"🧹 تم نزع الرتبة بنجاح من جميع الأعضاء (العدد: {count})"
      )
    except discord.Forbidden:
      await status_msg.edit(
          content="❌ **فشل:** رتبة البوت أقل من الرتبة المراد إزالتها!"
      )
    except Exception as e:
      await status_msg.edit(content=f"❌ **خطأ:** `{e}`")
    return

  await bot.process_commands(message)


@bot.event
async def on_ready():
  print(f"🚀 البوت شغال باسم: {bot.user}")


bot.run(TOKEN)
