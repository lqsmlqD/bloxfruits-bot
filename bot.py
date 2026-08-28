import discord
from discord import app_commands
from discord.ext import commands
import json
import re
import asyncio
from datetime import timedelta

TOKEN = "MTU0Mjk2NzAxOTgyODI4NTU5MA.GNN1Ui.VN1hVzgraeHhNT5zjCoZepx9reV85ncPT-Cn5U" # حط التوكن حقك هنا
GUILD_ID = discord.Object(id=1540821164300046406)

class MyBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.message_content = True
        intents.members = True
        super().__init__(command_prefix="!", intents=intents)

    async def setup_hook(self):
        self.tree.clear_commands(guild=None)
        await self.tree.sync(guild=None)
        
        self.tree.clear_commands(guild=GUILD_ID)
        self.tree.add_command(script_command, guild=GUILD_ID)
        await self.tree.sync(guild=GUILD_ID)
        print("✅ تم تجهيز الأوامر وتحديثها بنجاح!")

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
        raw_script = self.script_data.get('script', '-- لا يوجد كود متوفر')
        title = self.script_data.get('title', 'Blox Fruits Script')
        key_status = "نعم" if self.script_data.get('key', False) else "لا (بدون كي)"

        embed = discord.Embed(
            title=f"📜 {title}",
            description=f"**يتطلب مفتاح (Key)؟** `{key_status}`\n\n```lua\n{raw_script}\n```",
            color=discord.Color.green()
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

        prev_btn = discord.ui.Button(label="◀ السابق", style=discord.ButtonStyle.secondary, disabled=(self.current_page == 0), row=2)
        next_btn = discord.ui.Button(label="التالي ▶", style=discord.ButtonStyle.secondary, disabled=(end_idx >= len(self.scripts)), row=2)
        
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
        
        description = f"⭐ **قائمة الأشهر والأكثر أماناً لـ Blox Fruits** (عدد السكربتات: {total})\n\n"
        for i, s in enumerate(self.scripts[start_idx:end_idx]):
            description += f"**{i+1}.** {s.get('title')} ✅\n"

        embed = discord.Embed(
            title=f"🏴‍☠️ السكربتات الموثوقة (صفحة {self.current_page + 1})",
            description=description,
            color=discord.Color.gold()
        )
        embed.set_footer(text="اضغط رقم السكربت للحصول على كوده المباشر.")
        return embed

@app_commands.command(name="script", description="عرض السكربتات الشهيرة والمستقرة لـ Blox Fruits")
async def script_command(interaction: discord.Interaction):
    scripts = load_local_scripts()
    if not scripts:
        await interaction.response.send_message("❌ لم يتم العثور على `scripts.json`. شغل `fetch_all.py` أولاً!", ephemeral=True)
        return

    view = LocalScriptPaginatorView(scripts)
    embed = view.get_page_embed()
    await interaction.response.send_message(embed=embed, view=view, ephemeral=True)

def parse_duration_from_text(text):
    clean_text = re.sub(r'<@!?\d+>', '', text).strip()
    matches = re.findall(r'(\d+(?:\.\d+)?)\s*([s|m|h|d|ث|د|س|ي]?)', clean_text.lower())
    for amount_str, unit in matches:
        if not amount_str: continue
        amount = float(amount_str)
        seconds = 0
        if unit in ['ث', 's']: seconds = amount
        elif unit in ['د', 'm', '']: seconds = amount * 60
        elif unit in ['س', 'h']: seconds = amount * 3600
        elif unit in ['ي', 'd']: seconds = amount * 86400
        if seconds > 0:
            original_str = f"{amount_str}{unit if unit else 'د'}"
            if seconds < 60: seconds = 60
            elif seconds > 2419200: seconds = 2419200
            return timedelta(seconds=seconds), original_str
    return timedelta(seconds=60), "60s"

@bot.event
async def on_message(message: discord.Message):
    if message.author.bot or not message.guild:
        return

    content = message.content.strip()
    admin_commands = ["#قفل", "#غلق", "#فتح", "#قتل", "#قتفل", "نضف", "نظف", "مسح", "اص", "تكلم", "تكلموا", "بنعالي"]
    is_admin_cmd = any(content.startswith(cmd) for cmd in admin_commands)

    if is_admin_cmd:
        if not isinstance(message.author, discord.Member) or not message.author.guild_permissions.administrator:
            await message.reply("يرجال دز ههههههههههههههه")
            return

    if content in ["#قفل", "#غلق"]:
        await asyncio.gather(
            message.channel.set_permissions(message.guild.default_role, send_messages=False),
            message.reply("🔒 **تم قفل الروم.**")
        )
        return

    if content == "#فتح":
        await asyncio.gather(
            message.channel.set_permissions(message.guild.default_role, send_messages=True),
            message.reply("🔓 **تم فتح الروم.**")
        )
        return

    if content in ["نضف", "نظف", "مسح"]:
        prompt_msg = await message.reply("🗑️ كم عدد الرسائل التي تريد حذفها؟")
        def check(m):
            return m.author == message.author and m.channel == message.channel and m.content.isdigit()

        try:
            response = await bot.wait_for('message', check=check, timeout=15.0)
            amount = int(response.content)
            await message.channel.purge(limit=amount + 3)
            confirm_msg = await message.channel.send(f"🧹 **تم حذف `{amount}` رسالة.**")
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
            await message.reply("⚠️ يرجى منشن العضو! (مثال: `اص @العضو 5د`)")
            return
        target = message.mentions[0]
        duration, duration_str = parse_duration_from_text(content)
        try:
            await target.timeout(duration, reason=f"بواسطة {message.author}")
            await message.reply(f"🤫 **تم إسكات {target.mention} لمدة `{duration_str}`.**")
        except discord.Forbidden:
            await message.reply("❌ **فشل:** رتبة البوت أقل من العضو!")
        except Exception as e:
            await message.reply(f"❌ **خطأ:** `{e}`")
        return

    if content.startswith("تكلم") or content.startswith("تكلموا"):
        if not message.mentions:
            await message.reply("⚠️ يرجى منشن العضو! (مثال: `تكلم @العضو`)")
            return
        target = message.mentions[0]
        try:
            await target.timeout(None, reason=f"فك الإسكات بواسطة {message.author}")
            await message.reply(f"🔊 **تم فك الإسكات عن {target.mention}.**")
        except discord.Forbidden:
            await message.reply("❌ **فشل:** رتبة البوت أقل من العضو!")
        except Exception as e:
            await message.reply(f"❌ **خطأ:** `{e}`")
        return

    if content.startswith("بنعالي"):
        if not message.mentions:
            await message.reply("⚠️ يرجى منشن العضو! (مثال: `بنعالي @العضو`)")
            return
        target = message.mentions[0]
        try:
            await target.ban(reason=f"بواسطة {message.author}")
            await message.reply(f"👞 **تم حظر {target.mention}.**")
        except discord.Forbidden:
            await message.reply("❌ **فشل:** رتبة البوت أقل من العضو أو ينقصه صلاحية Ban!")
        except Exception as e:
            await message.reply(f"❌ **خطأ:** `{e}`")
        return

    await bot.process_commands(message)

@bot.event
async def on_ready():
    print(f"🚀 تم تشغيل البوت بنجاح تحت اسم: {bot.user}")

bot.run(TOKEN)