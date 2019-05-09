#include <sourcemod>
#include <sdktools>
#include <cstrike>

//////////////////////////////
//       KILL SOUNDS        //
//////////////////////////////
public void YK_InitKillSounds () {
  YK_PrecacheKillSounds_LOL_jaJP();
}

public void YK_PlayKillSounds (int attacker, int victim, int firstBlood, int killCount) {
  // Judge Executed
  if (attacker == 0 && victim == 0 && killCount == 0) {
    int random = GetRandomInt(0, 2);
    switch (random) {
      case 0: YK_PerformanceKillSounds(attacker, victim, "File0021.mp3", "File0021.mp3", "File0021.mp3"); //  break;
      case 1: YK_PerformanceKillSounds(attacker, victim, "File0022.mp3", "File0022.mp3", "File0023.mp3"); //  break;
      case 2: YK_PerformanceKillSounds(attacker, victim, "File0023.mp3", "File0022.mp3", "File0023.mp3"); //  break;
    }
  }
  // Judge firstblood
  else if (firstBlood == 0) {
    // FIRSTBLOOD!!!!
    YK_PerformanceKillSounds(attacker, victim, "File0052.mp3", "File0052.mp3", "File0052.mp3");
  } else {
    // Not FirstBlood.
    if (killCount < 3) {
      int random = GetRandomInt(0, 2);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0024.mp3", "File0017.mp3", "File0014.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0025.mp3", "File0018.mp3", "File0015.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0026.mp3", "File0017.mp3", "File0016.mp3"); //  break;
      }
    } else if (killCount == 3) {
      int random = GetRandomInt(0, 2);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0058.mp3", "File0018.mp3", "File0056.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0059.mp3", "File0017.mp3", "File0057.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0060.mp3", "File0018.mp3", "File0056.mp3"); //  break;
      }
    } else if (killCount == 4) {
      int random = GetRandomInt(0, 3);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0062.mp3", "File0017.mp3", "File0061.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0063.mp3", "File0018.mp3", "File0061.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0064.mp3", "File0017.mp3", "File0061.mp3"); //  break;
        case 3: YK_PerformanceKillSounds(attacker, victim, "File0065.mp3", "File0018.mp3", "File0061.mp3"); //  break;
      }
    } else if (killCount == 5) {
      int random = GetRandomInt(0, 2);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0068.mp3", "File0017.mp3", "File0066.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0069.mp3", "File0018.mp3", "File0067.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0070.mp3", "File0017.mp3", "File0066.mp3"); //  break;
      }
    } else if (killCount == 6) {
      int random = GetRandomInt(0, 1);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0072.mp3", "File0018.mp3", "File0071.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0073.mp3", "File0017.mp3", "File0071.mp3"); //  break;
      }
    } else if (killCount == 7) {
      int random = GetRandomInt(0, 3);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0076.mp3", "File0018.mp3", "File0074.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0077.mp3", "File0017.mp3", "File0075.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0078.mp3", "File0018.mp3", "File0074.mp3"); //  break;
        case 3: YK_PerformanceKillSounds(attacker, victim, "File0079.mp3", "File0017.mp3", "File0075.mp3"); //  break;
      }
    } else if (killCount >= 8) {
      int random = GetRandomInt(0, 4);
      switch (random) {
        case 0: YK_PerformanceKillSounds(attacker, victim, "File0082.mp3", "File0018.mp3", "File0080.mp3"); //  break;
        case 1: YK_PerformanceKillSounds(attacker, victim, "File0083.mp3", "File0017.mp3", "File0081.mp3"); //  break;
        case 2: YK_PerformanceKillSounds(attacker, victim, "File0084.mp3", "File0018.mp3", "File0080.mp3"); //  break;
        case 3: YK_PerformanceKillSounds(attacker, victim, "File0085.mp3", "File0017.mp3", "File0081.mp3"); //  break;
        case 4: YK_PerformanceKillSounds(attacker, victim, "File0086.mp3", "File0018.mp3", "File0080.mp3"); //  break;
      }
    }
  }
}

public void YK_PerformanceKillSounds (int attacker, int victim, char[] attackerSound, char[] victimSound, char[] othersSound) {
  char buffer[255];
  for (int client = 1; client <= MaxClients; ++client) {
    if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {
      if (client == victim) {
        FormatEx(buffer, 255, "einzbern/killsounds/lol/jaJP/%s", victimSound);
        EmitSoundToClient(client, buffer, client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
      } else if (client == attacker) {
        FormatEx(buffer, 255, "einzbern/killsounds/lol/jaJP/%s", attackerSound);
        EmitSoundToClient(client, buffer, client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
      } else {
        FormatEx(buffer, 255, "einzbern/killsounds/lol/jaJP/%s", othersSound);
        EmitSoundToClient(client, buffer, client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
      }
    }
  }
}

//////////////////////////////
//     SOUNDS PRECACHE      //
//////////////////////////////
public void YK_PrecacheKillSounds_GabeNewell () {
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_firstblood_01.mp3"); // First blood! Thanks and have fun.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_firstblood_02.mp3"); // Hello. I'm Gabe Newell. You've just achieved first blood. Thanks and have fun.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_double_01.mp3"); // Double kill.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_double_03.mp3"); // Hello! This is Gabe Newell. Thanks for playing Dota 2. Double Kill!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_triple_02.mp3"); // Impossible kill.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_triple_03.mp3"); // More than two kills, but less than four kills.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_triple_01.mp3"); // I will ignore your email number of kills.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_no_01.mp3"); // I'm not reading this.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_ultra_01.mp3"); // Ultra kill.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_rampage_02.mp3"); // Rampage!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_spree_02.mp3"); // Killing spree.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_dominate_01.mp3"); // A dominating performance.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_dominate_02.mp3"); // Dominating, I guess...
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_mega_01.mp3"); // Mega kill!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_unstoppable_01.mp3"); // They're unstoppable?
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_unstoppable_02.mp3"); // They're unstoppable.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_wicked_03.mp3"); // That was unreal.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_wicked_02.mp3"); // If you were a millennial, I'd say 'wicked sick'.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_wicked_01.mp3"); // That was, as they say, 'wicked sick'.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_monster_01.mp3"); // Monster kill.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_monster_02.mp3"); // Monster kill!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_monster_03.mp3"); // My favorite kill is the monster kill.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_godlike_01.mp3"); // Godlike!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_godlike_02.mp3"); // Godlike!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_holy_01.mp3"); // Goodness!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_followup_18.mp3"); // It happened again.
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_followup_39.mp3"); // There they go... 
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_ownage_01.mp3"); // Ownage!
  AddFileToDownloadsTable("sound/einzbern/killsounds/gabe/Gaben_ann_kill_ownage_02.mp3"); // Ownage!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_firstblood_01.mp3"); // First blood! Thanks and have fun.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_firstblood_02.mp3"); // Hello. I'm Gabe Newell. You've just achieved first blood. Thanks and have fun.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_double_01.mp3"); // Double kill.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_double_03.mp3"); // Hello! This is Gabe Newell. Thanks for playing Dota 2. Double Kill!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_triple_02.mp3"); // Impossible kill.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_triple_03.mp3"); // More than two kills, but less than four kills.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_triple_01.mp3"); // I will ignore your email number of kills.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_no_01.mp3"); // I'm not reading this.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_ultra_01.mp3"); // Ultra kill.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_rampage_02.mp3"); // Rampage!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_spree_02.mp3"); // Killing spree.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_dominate_01.mp3"); // A dominating performance.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_dominate_02.mp3"); // Dominating, I guess...
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_mega_01.mp3"); // Mega kill!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_unstoppable_01.mp3"); // They're unstoppable?
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_unstoppable_02.mp3"); // They're unstoppable.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_wicked_03.mp3"); // That was unreal.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_wicked_02.mp3"); // If you were a millennial, I'd say 'wicked sick'.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_wicked_01.mp3"); // That was, as they say, 'wicked sick'.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_monster_01.mp3"); // Monster kill.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_monster_02.mp3"); // Monster kill!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_monster_03.mp3"); // My favorite kill is the monster kill.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_godlike_01.mp3"); // Godlike!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_godlike_02.mp3"); // Godlike!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_holy_01.mp3"); // Goodness!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_followup_18.mp3"); // It happened again.
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_followup_39.mp3"); // There they go... 
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_ownage_01.mp3"); // Ownage!
  PrecacheSound("einzbern/killsounds/gabe/Gaben_ann_kill_ownage_02.mp3"); // Ownage!
} // You can use this GABE kill sounds manually.

public void YK_PrecacheKillSounds_LOL_jaJP () {
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0002.mp3"); // Aced
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0003.mp3"); // Aced
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0004.mp3"); // Enemy Double Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0005.mp3"); // Enemy Double Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0006.mp3"); // Double Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0007.mp3"); // Double Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0008.mp3"); // Double Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0012.mp3"); // Ally Has Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0013.mp3"); // Ally Has Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0014.mp3"); // Enemy Has Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0015.mp3"); // Enemy Has Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0016.mp3"); // Enemy Has Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0017.mp3"); // You Have Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0018.mp3"); // You Have Been Slain
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0021.mp3"); // Executed
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0022.mp3"); // Executed
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0023.mp3"); // Executed
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0024.mp3"); // You Have Slained An Enemy
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0025.mp3"); // You Have Slained An Enemy
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0026.mp3"); // You Have Slained An Enemy
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0027.mp3"); // Enemy Penta Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0028.mp3"); // Enemy Penta Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0029.mp3"); // Enemy Penta Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0030.mp3"); // Enemy Penta Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0031.mp3"); // Quadra Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0032.mp3"); // Quadra Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0033.mp3"); // Quadra Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0034.mp3"); // Triple Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0035.mp3"); // Triple Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0036.mp3"); // Triple Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0037.mp3"); // Triple Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0038.mp3"); // Enemy Legendary Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0039.mp3"); // Legendary Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0040.mp3"); // Legendary Kill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0052.mp3"); // First Blood
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0054.mp3"); // Shutdown
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0055.mp3"); // Shutdown
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0056.mp3"); // Enemy Killing Spree
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0057.mp3"); // Enemy Killing Spree
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0058.mp3"); // You are on the Killing Spree
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0059.mp3"); // Killing Spree
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0060.mp3"); // Killing Spree
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0061.mp3"); // Enemy Rampage
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0062.mp3"); // You are on the Rampage
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0063.mp3"); // You are on the Rampage
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0064.mp3"); // Rampage
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0065.mp3"); // Rampage
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0066.mp3"); // Enemy is unstoppable
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0067.mp3"); // Enemy is unstoppable
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0068.mp3"); // You are on unstoppable
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0069.mp3"); // You are on unstoppable
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0070.mp3"); // unstoppable
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0071.mp3"); // Enemy is dominating
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0072.mp3"); // You are dominating
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0073.mp3"); // dominating
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0074.mp3"); // Enemy is godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0075.mp3"); // Enemy is godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0076.mp3"); // You are godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0077.mp3"); // You are godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0078.mp3"); // godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0079.mp3"); // godlike
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0080.mp3"); // Enemy is legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0081.mp3"); // Enemy is legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0082.mp3"); // You are legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0083.mp3"); // You are legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0084.mp3"); // legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0085.mp3"); // legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0086.mp3"); // legendary
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0124.mp3"); // Enemy hexakill
  AddFileToDownloadsTable("sound/einzbern/killsounds/lol/jaJP/File0126.mp3"); // hexakill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0002.mp3"); // Aced
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0003.mp3"); // Aced
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0004.mp3"); // Enemy Double Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0005.mp3"); // Enemy Double Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0006.mp3"); // Double Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0007.mp3"); // Double Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0008.mp3"); // Double Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0012.mp3"); // Ally Has Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0013.mp3"); // Ally Has Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0014.mp3"); // Enemy Has Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0015.mp3"); // Enemy Has Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0016.mp3"); // Enemy Has Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0017.mp3"); // You Have Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0018.mp3"); // You Have Been Slain
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0021.mp3"); // Executed
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0022.mp3"); // Executed
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0023.mp3"); // Executed
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0024.mp3"); // You Have Slained An Enemy
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0025.mp3"); // You Have Slained An Enemy
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0026.mp3"); // You Have Slained An Enemy
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0027.mp3"); // Enemy Penta Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0028.mp3"); // Enemy Penta Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0029.mp3"); // Enemy Penta Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0030.mp3"); // Enemy Penta Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0031.mp3"); // Quadra Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0032.mp3"); // Quadra Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0033.mp3"); // Quadra Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0034.mp3"); // Triple Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0035.mp3"); // Triple Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0036.mp3"); // Triple Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0037.mp3"); // Triple Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0038.mp3"); // Enemy Legendary Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0039.mp3"); // Legendary Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0040.mp3"); // Legendary Kill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0052.mp3"); // First Blood
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0054.mp3"); // Shutdown
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0055.mp3"); // Shutdown
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0056.mp3"); // Enemy Killing Spree
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0057.mp3"); // Enemy Killing Spree
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0058.mp3"); // You are on the Killing Spree
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0059.mp3"); // Killing Spree
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0060.mp3"); // Killing Spree
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0061.mp3"); // Enemy Rampage
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0062.mp3"); // You are on the Enemy Rampage
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0063.mp3"); // You are on the Enemy Rampage
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0064.mp3"); // Enemy Rampage
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0065.mp3"); // Enemy Rampage
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0066.mp3"); // Enemy is unstoppable
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0067.mp3"); // Enemy is unstoppable
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0068.mp3"); // You are on unstoppable
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0069.mp3"); // You are on unstoppable
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0070.mp3"); // unstoppable
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0071.mp3"); // Enemy is dominating
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0072.mp3"); // You are dominating
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0073.mp3"); // dominating
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0074.mp3"); // Enemy is godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0075.mp3"); // Enemy is godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0076.mp3"); // You are godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0077.mp3"); // You are godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0078.mp3"); // godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0079.mp3"); // godlike
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0080.mp3"); // Enemy is legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0081.mp3"); // Enemy is legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0082.mp3"); // You are legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0083.mp3"); // You are legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0084.mp3"); // legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0085.mp3"); // legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0086.mp3"); // legendary
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0124.mp3"); // Enemy hexakill
  PrecacheSound("einzbern/killsounds/lol/jaJP/File0126.mp3"); // hexakill
} // You can modify this to english.