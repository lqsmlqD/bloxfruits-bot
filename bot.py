import asyncio
from datetime import datetime, timedelta, timezone
import json
import os
import re
from threading import Thread

import aiohttp
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

# قائمة بأشهر 10 مابات في روبلوكس للبحث عن سكربتاتها
TOP_10_GAMES = [
    "Blox Fruits",
    "King Legacy",
    "Pet Simulator 99",
    "Adopt Me",
    "Blade Ball",
    "Brookhaven",
    "Da Hood",
    "Arsenal",
    "BedWars",
    "Anime Adventures",
]


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


# ==================== إعدادات البوت والسكربتات التلقائية ====================
class MyBot(commands.Bot):

  def __init__(self):
    intents = discord.Intents.default()
    intents.message_content = True
    intents.members = True
    super().__init__(command_prefix="!", intents=intents)

  async def setup_hook(self):
    self.tree.clear_commands(guild=GUILD_ID)
    self.tree.add_command(script_command, guild=GUILD_ID)
    self.tree.add_command(clear_group, guild=GUILD_ID)
    await self.tree.sync(guild=GUILD_ID)


bot = MyBot()


# دالة جلب السكربتات المباشرة من ScriptBlox API
async def fetch_scripts_from_api(game_name: str):
  url = f"https://scriptblox.com/api/script/search?q={game_name}&max=10&mode=free"
  async with aiohttp.ClientSession() as session:
    try:
      async with session.get(url, timeout=5) as resp:
        if resp.status == 200:
          data = await resp.json()
          return data.get("result", {}).get("scripts", [])
    except Exception as e:
      print(f"خطأ في جلب سكربتات {game_name}: {e}")
  return []


class ScriptDetailButton(discord.ui.Button):

  def __init__(self, label, script_data):
    super().__init__(label=label, style=discord.ButtonStyle.primary)
    self.script_data = script_data

  async def callback(self, interaction: discord.Interaction):
    raw_script = self.script_data.get("script", "-- لا يوجد كود متوفر")
    title = self.script_data.get("title", "Roblox Script")
    key_status = "نعم" if self.script_data.get("key", False) else "لا (بدون كي)"
    views = self.script_data.get("views", 0)

    embed = discord.Embed(
        title=f"📜 {title}",
        description=(
            f"**المشاهدات:** `{views}` | **يتطلب مفتاح (Key)؟**"
            f" `{key_status}`\n\n```lua\n{raw_script}\n```"
        ),
        color=discord.Color.green(),
    )
    await interaction.response.send_message(embed=embed, ephemeral=False)


class ScriptsView(discord.ui.View):

  def __init__(self, scripts):
    super().__init__(timeout=120)
    for idx, s in enumerate(scripts[:10]):
      self.add_item(ScriptDetailButton(label=f"كود السكربت {idx + 1}", script_data=s))


class GameSelect(discord.ui.Select):

  def __init__(self):
    options = [
        discord.SelectOption(
            label=game, value=game, description=f"عرض أشهر 10 سكربتات لـ {game}"
        )
        for game in TOP_10_GAMES
    ]
    super().__init__(
        placeholder="🎮 اختر الماب لعرض أحدث وأشهر سكربتاته...",
        min_values=1,
        max_values=1,
        options=options,
    )

  async def callback(self, interaction: discord.Interaction):
    game_selected = self.values[0]
    await interaction.response.defer(ephemeral=False)

    scripts = await fetch_scripts_from_api(game_selected)

    if not scripts:
      await interaction.followup.send(
          f"❌ لم يتم العثور على سكربتات حديثة لماب **{game_selected}** حالياً."
      )
      return

    embed = discord.Embed(
        title=f"🏴‍☠️ أشهر 10 سكربتات لماب: {game_selected}",
        description=(
            "تم جلب السكربتات تلقائياً ومباشرةً من الإنترنت. اضغط على أزرار"
            " الأكواد بالأسفل لنسخ السكربت:\n\n"
        ),
        color=discord.Color.gold(),
    )

    for idx, s in enumerate(scripts[:10]):
      key_text = "🔑 بـ Key" if s.get("key") else "✅ بدون Key"
      embed.description += (
          f"**{idx + 1}.** {s.get('title')} (`{key_text}`)\n"
      )

    view = ScriptsView(scripts[:10])
    await interaction.followup.send(embed=embed, view=view)


class GameSelectView(discord.ui.View):

  def __init__(self):
    super().__init__(timeout=120)
    self.add_item(GameSelect())


@app_commands.command(
    name="script", description="عرض أشهر 10 مابات روبلوكس وجلب سكربتاتها فورياً"
)
async def script_command(interaction: discord.Interaction):
  view = GameSelectView()
  embed = discord.Embed(
      title="🎮 قائمة أشهر 10 مابات في Roblox",
      description=(
          "اختر الماب المطلوبة من القائمة المنسدلة بالأسفل ليقوم البوت بجلب"
          " أحدث وأشهر 10 سكربتات للماب مباشرة بدون توقف:"
      ),
      color=discord.Color.blue(),
  )
  await interaction.response.send_message(embed=embed, view=view, ephemeral=False)


# ==================== نظام القوائم المنسدلة الشامل لكافة الرتب ====================
class RoleSelect(discord.ui.Select):

  def __init__(self, roles, placeholder):
    options = [
        discord.SelectOption(
            label=role.name, value=str(role.id), description=f"ID: {role.id}"
        )
        for role in roles
    ]
    super().__init__(
        placeholder=placeholder,
        min_values=1,
        max_values=1,
        options=options,
    )

  async def callback(self, interaction: discord.Interaction):
    if not interaction.user.guild_permissions.administrator:
      await interaction.response.send_message(
          "يرجال دز ههههههههههههههه", ephemeral=False
      )
      return

    role_id = int(self.values[0])
    target_role = interaction.guild.get_role(role_id)

    if not target_role:
      await interaction.response.send_message(
          "❌ لم يتم العثور على الرتبة!", ephemeral=False
      )
      return

    await interaction.response.defer(ephemeral=False)

    count = 0
    for member in target_role.members:
      try:
        await member.remove_roles(target_role)
        count += 1
      except Exception:
        pass

    embed = discord.Embed(
        description=(
            f"🧹 **تم إزالة رتبة {target_role.mention} بنجاح من `{count}`"
            " عضو.**"
        ),
        color=discord.Color.green(),
    )
    await interaction.followup.send(embed=embed)


class MultiRoleSelectView(discord.ui.View):

  def __init__(self, guild: discord.Guild):
    super().__init__(timeout=120)
    all_roles = [
        r for r in guild.roles if r != guild.default_role and not r.managed
    ]
    chunk_size = 25
    chunks = [
        all_roles[i : i + chunk_size]
        for i in range(0, len(all_roles), chunk_size)
    ]

    for index, role_chunk in enumerate(chunks):
      start_num = (index * chunk_size) + 1
      end_num = start_num + len(role_chunk) - 1
      placeholder_text = f"📋 اختر رتبة (من {start_num} إلى {end_num})"
      self.add_item(RoleSelect(roles=role_chunk, placeholder=placeholder_text))


# ==================== أوامر السلاش ====================
clear_group = app_commands.Group(
    name="clear", description="أوامر التنظيف للمسح وإزالة الرتب"
)


@clear_group.command(
    name="message", description="حذف عدد معين من الرسائل من الروم"
)
@app_commands.describe(count="عدد الرسائل المراد حذفها")
async def clear_message_cmd(interaction: discord.Interaction, count: int):
  if not interaction.user.guild_permissions.administrator:
    await interaction.response.send_message(
        "يرجال دز ههههههههههههههه", ephemeral=False
    )
    return

  if count <= 0:
    await interaction.response.send_message(
        "⚠️ يرجى إدخال رقم أعلى من 0", ephemeral=False
    )
    return

  await interaction.response.defer(ephemeral=False)
  deleted = await interaction.channel.purge(limit=count)

  embed = discord.Embed(
      description=f"🗑️ **تم مسح `{len(deleted)}` من الرسائل بنجاح.**",
      color=discord.Color.blue(),
  )
  await interaction.followup.send(embed=embed)


@clear_group.command(
    name="role",
    description="عرض جميع رتب السيرفر في قوائم منسدلة واختيار رتبة لسحبها من الجميع",
)
async def clear_role_cmd(interaction: discord.Interaction):
  if not interaction.user.guild_permissions.administrator:
    await interaction.response.send_message(
        "يرجال دز ههههههههههههههه", ephemeral=False
    )
    return

  view = MultiRoleSelectView(interaction.guild)
  if not view.children:
    await interaction.response.send_message(
        "❌ لا توجد رتب متاحة للسحب في هذا السيرفر.", ephemeral=False
    )
    return

  await interaction.response.send_message(
      "👇 **اختر الرتبة المراد سحبها من جميع الأعضاء (تشمل كافة رتب"
      " السيرفر):**",
      view=view,
      ephemeral=False,
  )


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

        await message.author.timeout(
            timedelta(minutes=timeout_minutes),
            reason=f"مخالفة الألفاظ رقم {current_count} خلال 24 ساعة",
        )

        warn_msg = await message.channel.send(
            f"🚫 **تم معاقبة {message.author.mention} بإعطائه `{timeout_minutes}`"
            " دقائق تايم بسبب الشتم.**\n⚠️ **المرة القادمة ستكون العقوبة"
            " أكبر!**"
        )
        await asyncio.sleep(6)
        await warn_msg.delete()
        return
      except Exception as e:
        print(f"خطأ في تطبيق العقوبة: {e}")

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
      "مسح_رتب",
      "سحب_رتبة",
  ]
  is_admin_cmd = any(content.startswith(cmd) for cmd in admin_commands)

  if is_admin_cmd:
    if (
        not isinstance(message.author, discord.Member)
        or not message.author.guild_permissions.administrator
    ):
      await message.reply("يرجال دز ههههههههههههههه")
      return

  if content in ["مسح_رتب", "سحب_رتبة"]:
    view = MultiRoleSelectView(message.guild)
    if not view.children:
      await message.reply("❌ لا توجد رتب متاحة للسحب في هذا السيرفر.")
      return

    await message.reply(
        "👇 **اختر الرتبة المراد سحبها من الجميع من القوائم أدناه (تضم كافة"
        " الرتب):**",
        view=view,
    )
    return

  if content in ["#قفل", "#غلق"]:
    await message.channel.set_permissions(
        message.guild.default_role, send_messages=False
    )
    embed = discord.Embed(
        description="🔒 **تم قفل الشات بنجاح.**", color=discord.Color.red()
    )
    await message.reply(embed=embed)
    return

  if content == "#فتح":
    await message.channel.set_permissions(
        message.guild.default_role, send_messages=True
    )
    embed = discord.Embed(
        description="🔓 **تم فتح الشات بنجاح.**", color=discord.Color.green()
    )
    await message.reply(embed=embed)
    return

  if content in ["نضف", "نظف", "مسح"]:
    prompt_msg = await message.reply("🗑️ **كم عدد الرسائل التي تريد حذفها؟**")

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
      embed = discord.Embed(
          description=f"🗑️ **تم مسح `{amount}` من الرسائل بنجاح.**",
          color=discord.Color.blue(),
      )
      confirm_msg = await message.channel.send(embed=embed)
      await asyncio.sleep(3)
      await confirm_msg.delete()
    except asyncio.TimeoutError:
      await prompt_msg.delete()
    return

  if content.startswith("اص"):
    if not message.mentions:
      embed = discord.Embed(
          description="⚠️ **يرجى تحديد العضو المطلوبة معاقبته!**",
          color=discord.Color.gold(),
      )
      await message.reply(embed=embed)
      return
    target = message.mentions[0]
    duration, duration_str = parse_duration_from_text(content)
    try:
      await target.timeout(duration, reason=f"بواسطة {message.author}")
      embed = discord.Embed(
          description=(
              f"🤐 **تم إعطاء {target.mention} تايم أوت لمدة `{duration_str}`.**"
          ),
          color=discord.Color.orange(),
      )
      await message.reply(embed=embed)
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("تكلم") or content.startswith("تكلموا"):
    if not message.mentions:
      embed = discord.Embed(
          description="⚠️ **يرجى تحديد العضو لفك الميوت عنه!**",
          color=discord.Color.gold(),
      )
      await message.reply(embed=embed)
      return
    target = message.mentions[0]
    try:
      await target.timeout(None, reason=f"فك الإسكات بواسطة {message.author}")
      embed = discord.Embed(
          description=f"🔊 **تم فك الميوت عن {target.mention}.**",
          color=discord.Color.green(),
      )
      await message.reply(embed=embed)
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("بنعالي"):
    if not message.mentions:
      embed = discord.Embed(
          description="⚠️ **يرجى تحديد العضو لطرده بنهائي!**",
          color=discord.Color.gold(),
      )
      await message.reply(embed=embed)
      return
    target = message.mentions[0]
    try:
      await target.ban(reason=f"بواسطة {message.author}")
      embed = discord.Embed(
          description=f"🔨 **تم حظر {target.mention} بنجاح من السيرفر.**",
          color=discord.Color.red(),
      )
      await message.reply(embed=embed)
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("ارجاع"):
    if not message.mentions:
      embed = discord.Embed(
          description="⚠️ **يرجى منشن العضو لفك الحظر عنه!**",
          color=discord.Color.gold(),
      )
      await message.reply(embed=embed)
      return
    target = message.mentions[0]
    try:
      await message.guild.unban(target, reason=f"فك الحظر بواسطة {message.author}")
      embed = discord.Embed(
          description=f"🔓 **تم إلغاء حظر {target.mention} بنجاح.**",
          color=discord.Color.green(),
      )
      await message.reply(embed=embed)
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content.startswith("تفضل"):
    if not message.mentions:
      embed = discord.Embed(
          description="⚠️ **يرجى منشن العضو لإعطائه الرتبة!**",
          color=discord.Color.gold(),
      )
      await message.reply(embed=embed)
      return
    target = message.mentions[0]
    role = message.guild.get_role(SPECIAL_ROLE_ID)
    if not role:
      await message.reply("❌ **خطأ:** لم يتم العثور على الرتبة بالـ ID المحدد!")
      return
    try:
      await target.add_roles(role)
      embed = discord.Embed(
          description=f"🎭 **تم إعطاء {target.mention} رتبة {role.mention} بنجاح.**",
          color=discord.Color.blue(),
      )
      await message.reply(embed=embed)
    except Exception as e:
      await message.reply(f"❌ **خطأ:** `{e}`")
    return

  if content == "شيل":
    role = message.guild.get_role(SPECIAL_ROLE_ID)
    if not role:
      await message.reply("❌ **خطأ:** لم يتم العثور على الرتبة بالـ ID المحدد!")
      return

    status_msg = await message.reply("⚙️ **جاري نزع الرتبة من الجميع...**")
    count = 0
    try:
      for member in role.members:
        await member.remove_roles(role)
        count += 1
      embed = discord.Embed(
          description=(
              f"🧹 **تم إزالة رتبة {role.mention} بنجاح من `{count}` عضو.**"
          ),
          color=discord.Color.green(),
      )
      await status_msg.edit(content=None, embed=embed)
    except Exception as e:
      await status_msg.edit(content=f"❌ **خطأ:** `{e}`")
    return

  await bot.process_commands(message)


@bot.event
async def on_ready():
  print(f"🚀 البوت شغال باسم: {bot.user}")


bot.run(TOKEN)
