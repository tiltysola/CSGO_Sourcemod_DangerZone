#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include "dangerzone/PingPosition.sp"

/*************************************************
 *                                               *
 *      Youmu Konpaku Danger Zone Plugin         *
 *                            for sourcemod      *
 *                                               *
 *      Site:  https://www.youmukonpaku.cn/      *
 *      QQ:    69302630                          *
 *      Email: kanade@acgme.cn                   *
 *                                               *
 *************************************************/

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 2

//////////////////////////////
//    PLUGIN DEFINITION     //
//////////////////////////////
#define PLUGIN_NAME         "YK DangerZone Core"
#define PLUGIN_AUTHOR       "YoumuKonapku"
#define PLUGIN_DESCRIPTION  "DangerZone Core Plugin For CSGO"
#define PLUGIN_VERSION      "1.0"
#define PLUGIN_URL          "https://www.youmukonpaku.cn/"

//////////////////////////////
//       PLUGIN INFO        //
//////////////////////////////
public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

//////////////////////////////
//     GLOBAL VARIABLES     //
//////////////////////////////
Database g_hDatabase = null;
ConVar g_hPluginEnable = null;
bool g_bPluginEnable = true;
bool g_bPluginPreprocess = false;

// Ready system
int g_iPlayerReadyStatus[MAXPLAYERS + 1];
int g_iGameStartedStatus = 0;

Handle g_hReadyTimer = null;

// Broadcast system
ConVar g_hBroadcastInterval = null;
Handle g_hBroadcastTimer = null;

int g_iPlayerAliveStatus[65];

int g_iBroadcastInterval = 60;
int g_iBroadcastTimeout = -1;

// Spec system
Handle g_hSpecTimer = null;

// Announce system
Handle g_hAnnounceTimer = null;

// Team system
ConVar g_hMaxTeamCount = null;
int g_iMaxTeamCount = 1;

// Admin system
Menu g_mDzAdminMenu = null;

// Health system
ConVar g_hSpawnHealth = null;
ConVar g_hMaxHealth = null;

int g_iSpawnHealth = 185;
int g_iMaxHealth = 320;

// Setting system
Menu g_mSettingMenu = null;

// Respawn system
Menu g_mRespawnMenu = null;

// Give weapon system
Menu g_mGiveWeaponMenu = null;

// Kill system
int g_iPlayerKillsCount[65];

//////////////////////////////
//     PLUGIN FORWARDS      //
//////////////////////////////
public void OnPluginStart () {
  YK_InitPlugin();
  OnPingPositionStart();
}

public void OnMapStart () {
  ServerCommand("sv_dz_cash_bundle_size 100");
  ServerCommand("sv_dz_warmup_weapon weapon_awp"); 
  YK_PrecacheSounds();
}

public void OnClientPutInServer (int client) {
  char clientName[255];
  GetClientName(client, clientName, 255);
  tPrintToChatAll(" %t %t", "prefix", "join game", clientName);
  DB_InitUser(client);
  if (g_iGameStartedStatus == 1) {
    g_iPlayerAliveStatus[client] = 2;
  }
}

public void OnClientDisconnect (int client) {
  char clientName[255];
  GetClientName(client, clientName, 255);
  tPrintToChatAll(" %t %t", "prefix", "left game", clientName);
}

public void YK_InitPlugin () {
  PrintToServer("Initializing plugin: %s", PLUGIN_NAME);
  // ANY FUNCTIONS THAT SHOULD BE IN OnPluginStart
  LoadTranslations("yk_dangerzone.phrases");
  YK_DatabaseInit();
  YK_WelcomeMessage();
	YK_InitConvars();
  YK_InitCommands();
  ServerCommand("mp_restartgame 1"); // for debug only
  // ANY FUNCTIONS THAT SHOULD BE IN OnPluginStart
  PrintToServer("Initialized plugin: %s", PLUGIN_NAME);
}

//////////////////////////////
//          CONVAR          //
//////////////////////////////
public void ConVarChanged (ConVar convar, const char[] oldValue, const char[] newValue) {
	if (convar == g_hPluginEnable) {
		if (StringToInt(newValue) == 0.0)
			g_bPluginEnable = false;
		else
			g_bPluginEnable = true;
	}
	if (convar == g_hBroadcastInterval) {
		if (StringToInt(newValue) < 30.0)
			g_iBroadcastInterval = 30;
		else if (StringToInt(newValue) > 180.0)
			g_iBroadcastInterval = 180;
		else
			g_iBroadcastInterval = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "broadcast interval setting", g_iBroadcastInterval);
	}
	if (convar == g_hMaxTeamCount) {
		if (StringToInt(newValue) < 1.0)
			g_iMaxTeamCount = 1;
		else if (StringToInt(newValue) > 3.0)
			g_iMaxTeamCount = 3;
		else
			g_iMaxTeamCount = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "team count setting", g_iMaxTeamCount);
	}
	if (convar == g_hSpawnHealth) {
		if (StringToInt(newValue) < 1.0)
			g_iSpawnHealth = 1;
		else if (StringToInt(newValue) > 3.0)
			g_iSpawnHealth = 3;
		else
			g_iSpawnHealth = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "spawn health setting", g_iSpawnHealth);
	}
	if (convar == g_hMaxHealth) {
		if (StringToInt(newValue) < 1.0)
			g_iMaxHealth = 1;
		else if (StringToInt(newValue) > 3.0)
			g_iMaxHealth = 3;
		else
			g_iMaxHealth = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "max health setting", g_iMaxHealth);
	}
}

//////////////////////////////
//          COMMAND         //
//////////////////////////////
public Action Command_Ready (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
        return Plugin_Handled;
    if (g_iGameStartedStatus == 0) {
      if (g_iPlayerReadyStatus[client] == 0) {
        g_iPlayerReadyStatus[client] = 1;
        tPrintToChatAll(" %t %t", "prefix", "ready");
      } else {
        tPrintToChatAll(" %t %t", "prefix", "retype ready");
      }
    }
    return Plugin_Continue;
}

public Action Command_Unready (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
        return Plugin_Handled;
    if (g_iGameStartedStatus == 0) {
      if (g_iPlayerReadyStatus[client] == 1) {
        g_iPlayerReadyStatus[client] = 0;
        tPrintToChatAll(" %t %t", "prefix", "unready");
      } else {
        tPrintToChatAll(" %t %t", "prefix", "retype unready");
      }
    }
    return Plugin_Continue;
}

public Action Command_Start (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
        return Plugin_Handled;
    if (g_iGameStartedStatus == 0) {
      g_iGameStartedStatus = 2;
    }
    return Plugin_Continue;
}

public Action Command_DzAdmin (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
      return Plugin_Handled;
    g_mDzAdminMenu = BuildDzAdminMenu();
    g_mDzAdminMenu.Display(client, MENU_TIME_FOREVER);
    return Plugin_Continue;
}

public Action Command_End (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
        return Plugin_Handled;
    if (g_iGameStartedStatus == 1) {
      g_iGameStartedStatus = 0;
      tPrintToChatAll(" %t %t", "prefix", "admin end match");
      YK_EndGame();
    }
    return Plugin_Continue;
}

public Action Command_ForceEnd (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
      return Plugin_Handled;
    g_iGameStartedStatus = 0;
    tPrintToChatAll(" %t %t", "prefix", "admin end match");
    YK_EndGame();
    return Plugin_Continue;
}

public Action Command_RespawnMenu (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
      return Plugin_Handled;
    g_mRespawnMenu = BuildRespawnMenu();
    if (g_mRespawnMenu == null) {
      tPrintToChatAll(" %t %t", "prefix", "respawn player not found");
      return Plugin_Handled;
    }
    g_mRespawnMenu.Display(client, MENU_TIME_FOREVER);
    return Plugin_Continue;
}

public Action Command_GiveWeaponMenu (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
      return Plugin_Handled;
    g_mGiveWeaponMenu = BuildGiveWeaponMenu(0);
    g_mGiveWeaponMenu.Display(client, MENU_TIME_FOREVER);
    return Plugin_Continue;
}

//////////////////////////////
//          EVENT           //
//////////////////////////////
public void Event_RoundStarted (Event event, const char[] name, bool dontBroadcast) {
  if (YK_IsMapDangerZone() && g_bPluginEnable) {
    tPrintToChatAll(" %t %t", "prefix", "plugin enabled");
    if (g_bPluginPreprocess == false) {
      g_bPluginPreprocess = true;
      YK_EndGame();
    } else if (g_iGameStartedStatus == 0) {
      ServerCommand("mp_warmuptime 3600");
      ServerCommand("mp_warmup_pausetimer 1");
      ServerCommand("sv_dz_team_count 1");
      ServerCommand("sv_dz_player_max_health %d", g_iMaxHealth);
      ServerCommand("sv_dz_player_spawn_health %d", g_iSpawnHealth);
      YK_ActiveReadyTimer();
      YK_ActiveAnnounceTimer();
    } else if (g_iGameStartedStatus == 2) {
      g_iGameStartedStatus = 1;
      for (int client = 1; client <= MaxClients; ++client) {
        if (IsClientInGame(client) && IsClientConnected(client)) {
          g_iPlayerKillsCount[client] = 0;
          if (GetClientTeam(client) == 1) {
            g_iPlayerAliveStatus[client] = 2;
          } else {
            g_iPlayerAliveStatus[client] = 1;
          }
        }
      }
    }
  } else {
    tPrintToChatAll(" %t %t", "prefix", "plugin disabled");
  }
}

public void Event_RoundEnd (Event event, const char[] name, bool dontBroadcast) {
  if (g_iGameStartedStatus == 1) {
    for (int client = 1; client <= MaxClients; ++client) {
      if (IsClientInGame(client)) {
        if (IsPlayerAlive(client) && !IsFakeClient(client)) {
          DB_AddWinToPlayer(client);
        }
      }
    }
  }
  g_iGameStartedStatus = 0;
	if(g_hBroadcastTimer != null)
		KillTimer(g_hBroadcastTimer);
	g_hBroadcastTimer = null;
	if(g_hSpecTimer != null)
		KillTimer(g_hSpecTimer);
	g_hSpecTimer = null;
	g_iBroadcastTimeout = -1;
  if (g_mRespawnMenu != null)
    delete g_mRespawnMenu;
  if (g_mGiveWeaponMenu != null)
    delete g_mGiveWeaponMenu;
}

public void Event_PlayerHurt (Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
  int victim = GetClientOfUserId(GetEventInt(event, "userid"));
  int damage = GetEventInt(event, "dmg_health");
  char attackerName[255], victimName[255], weaponName[255];
  GetClientName(attacker, attackerName, 255);
  GetClientName(victim, victimName, 255);
  GetEventString(event, "weapon", weaponName, 255);
  if (attacker != 0 && attacker != victim) {
    tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01使用\x0C%s\x01对\x09%s\x01造成了\x02%d\x01点伤害。", attackerName, weaponName, victimName, damage);
  } else {
    tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01对自己造成了\x02%d\x01点伤害。", victimName, damage);
  }
}

public void Event_PlayerBlind (Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
  int victim = GetClientOfUserId(GetEventInt(event, "userid"));
  float duration = GetEventFloat(event, "blind_duration");
  char attackerName[255], victimName[255];
  GetClientName(attacker, attackerName, 255);
  GetClientName(victim, victimName, 255);
  if (attacker != victim) {
    tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01使用\x09闪光弹\x01闪瞎了\x09%s\x01的狗眼\x02%.1f\x01秒。", attackerName, victimName, duration);
  } else {
    tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01闪瞎了自己的狗眼\x02%.1f\x01秒。", victimName, duration);
  }
}

public void Event_PlayerDeath (Event event, const char[] name, bool dontBroadcast) {
  if (g_iGameStartedStatus == 1) {
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    char attackerName[255];
    GetClientName(attacker, attackerName, 255);
    if (attacker != victim && attacker != 0) {
      DB_AddKillToPlayer(attacker);
    }
    DB_AddDeathToPlayer(victim);
    g_iPlayerKillsCount[attacker]++;
    if (g_iPlayerKillsCount[attacker] >= 3) {
      for (int time = 0; time < g_iPlayerKillsCount[attacker]; time++)
        tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01已经杀了\x02%d\x01个人了，快去终结他吧！", attackerName, g_iPlayerKillsCount[attacker]);
    }
    for (int client = 1; client <= MaxClients; ++client) {
      if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {
        if (client == victim) {
          EmitSoundToClient(client, "einzbern/229875-e1721e64-3864-4528-b495-7a77efc7be1c.mp3", client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
        } else if (client == attacker) {
          EmitSoundToClient(client, "einzbern/229875-925e9c0e-8f02-4e27-bd84-5f0704012a51.mp3", client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
        } else {
          EmitSoundToClient(client, "einzbern/229875-a39ebdcd-20df-417c-b3e9-ac254dc1a701.mp3", client, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS);
        }
      }
    }
  }
}

public void Event_DzInteraction (Event event, const char[] name, bool dontBroadcast) {
  int userid = GetClientOfUserId(GetEventInt(event, "userid"));
  char caseType[255], userName[255];
  GetEventString(event, "type", caseType, 255);
  GetClientName(userid, userName, 255);
  tPrintToChatAll(" \x04[爱因兹贝伦] \x09%s\x01与\x09%s\x01进行了交互。", userName, caseType);
}

//////////////////////////////
//        FUNCTIONS         //
//////////////////////////////
public void YK_InitConvars () {
  g_hPluginEnable = CreateConVar("yk_dzEnable", "1",
					"You can set it 0 to disable the plugin.", _, true, 0.0,   true, 1.0);
	g_hBroadcastInterval = CreateConVar("yk_dzInterval", "60",
					"Min value is 30 and max value is 3600.", _, true, 30.0,   true, 3600.0);
	g_hMaxTeamCount = CreateConVar("yk_dzTeamCount", "1",
					"Min value is 1 and max value is 3.", _, true, 1.0,   true, 3.0);
	g_hSpawnHealth = CreateConVar("yk_dzSpawnHealth", "185",
					"Min value is 1 and max value is 1000.", _, true, 1.0,   true, 1000.0);
	g_hMaxHealth = CreateConVar("yk_dzMaxHealth", "320",
					"Min value is 1 and max value is 1000.", _, true, 1.0,   true, 1000.0);
	HookConVarChange(g_hPluginEnable, ConVarChanged);
	HookConVarChange(g_hBroadcastInterval, ConVarChanged);
	HookConVarChange(g_hMaxTeamCount, ConVarChanged);
	HookConVarChange(g_hSpawnHealth, ConVarChanged);
	HookConVarChange(g_hMaxHealth, ConVarChanged);
	HookEventEx("round_freeze_end", Event_RoundStarted, EventHookMode_Post);
	HookEventEx("round_end", Event_RoundEnd, EventHookMode_Post);
	HookEventEx("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEventEx("player_blind", Event_PlayerBlind, EventHookMode_Post);
  HookEventEx("player_death", Event_PlayerDeath, EventHookMode_Post);
  // HookEventEx("dz_item_interaction", Event_DzInteraction, EventHookMode_Post);
	AutoExecConfig();
}

public void YK_InitCommands () {
  RegConsoleCmd("sm_ready", Command_Ready);
  RegConsoleCmd("sm_unready", Command_Unready);
  RegAdminCmd("sm_dzadmin", Command_DzAdmin, ADMFLAG_CHEATS);
  RegAdminCmd("sm_start", Command_Start, ADMFLAG_CHEATS);
  RegAdminCmd("sm_end", Command_End, ADMFLAG_CHEATS);
  RegAdminCmd("sm_fend", Command_ForceEnd, ADMFLAG_CHEATS);
  RegAdminCmd("sm_respawn", Command_RespawnMenu, ADMFLAG_CHEATS);
  RegAdminCmd("sm_give", Command_GiveWeaponMenu, ADMFLAG_CHEATS);
}

public bool YK_IsMapDangerZone () {
  char mapName[128];
  GetCurrentMap(mapName, 128);
	if(StrContains(mapName, "dz_", false) == 0){
		return true;
	} else {
    return false;
  }
}

public bool YK_IsMapBlackSite () {
  char mapName[128];
  GetCurrentMap(mapName, 128);
	if(StrContains(mapName, "dz_blacksite", false) == 0){
		return true;
	} else {
    return false;
  }
}

public void YK_BroadcastDangerZoneInfoToAll () {
  int printIdPrefix = 0;
	tPrintToChatAll(" %t %t", "prefix", "player alive title");
	for (int client = 1; client <= MaxClients; ++client) {
		if (IsClientInGame(client)) {
			char clientName[255];
			GetClientName(client, clientName, 255);
      if (strcmp(clientName, "GOTV") != 0) {
        printIdPrefix++;
        if (IsPlayerAlive(client)) {
          tPrintToChatAll(" \x04%d. %s (Alive) Left: %dhp", printIdPrefix, clientName, GetClientHealth(client));
        } else if (g_iPlayerAliveStatus[client] == 1) {
          tPrintToChatAll(" \x02%d. %s (Dead)", printIdPrefix, clientName);
        } else if (g_iPlayerAliveStatus[client] == 2) {
          tPrintToChatAll(" \x0E%d. %s (Spec)", printIdPrefix, clientName);
        }
      }
		}
	}
}

public void YK_BroadcastDangerZoneServerInfoToAll () {
  tPrintToChatAll(" %t %t", "prefix", "broadcast team count", g_iMaxTeamCount);
  tPrintToChatAll(" %t %t", "prefix", "broadcast spawn health", g_iSpawnHealth);
  tPrintToChatAll(" %t %t", "prefix", "broadcast max health", g_iMaxHealth);
}

public void YK_MoveAllPlayersInGame () {
	for (int client = 1; client <= MaxClients; ++client) {
		if (IsClientInGame(client)) {
			char clientName[255];
			GetClientName(client, clientName, 255);
      if (strcmp(clientName, "GOTV") != 0) {
        if (!IsPlayerAlive(client)) {
          ChangeClientTeam(client, 3);
          CS_RespawnPlayer(client);
        }
      }
		}
	}
}

public void YK_StartGame (int readyPlayersCount) {
  if (readyPlayersCount != 0) {
    tPrintToChatAll(" %t %t", "prefix", "game start with players", readyPlayersCount);
  } else {
    tPrintToChatAll(" %t %t", "prefix", "game start");
  }
  YK_BroadcastDangerZoneServerInfoToAll();
  ServerCommand("mp_warmuptime 10");
  ServerCommand("mp_warmup_pausetimer 0");
  ServerCommand("sv_dz_team_count %d", g_iMaxTeamCount);
  KillTimer(g_hReadyTimer);
  g_hReadyTimer = null;
  YK_ActiveBroadcastTimer();
  YK_ActiveSpecTimer();
}

public void YK_EndGame () {
  ServerCommand("mp_warmuptime 3600");
  ServerCommand("mp_warmup_pausetimer 1");
  ServerCommand("mp_warmup_start");
  ServerCommand("mp_restartgame 1");
  if (g_hBroadcastTimer != null)
    KillTimer(g_hBroadcastTimer);
  g_hBroadcastTimer = null;
  YK_ActiveReadyTimer();
  YK_MoveAllPlayersInGame();
}

//////////////////////////////
//         TIMERS           //
//////////////////////////////
public void YK_ActiveBroadcastTimer () {
  g_iBroadcastTimeout = g_iBroadcastInterval;
	if (g_hBroadcastTimer != null)
		KillTimer(g_hBroadcastTimer);
  g_hBroadcastTimer = CreateTimer(1.0, Timer_BroadcastTimer, _, TIMER_REPEAT);
}

public void YK_ActiveReadyTimer () {
  for(int client = 1; client <= MaxClients; ++client){
    g_iPlayerReadyStatus[client] = 0;
  }
	if (g_hReadyTimer != null)
		KillTimer(g_hReadyTimer);
  g_hReadyTimer = CreateTimer(1.0, Timer_ReadyTimer, _, TIMER_REPEAT);
}

public void YK_ActiveSpecTimer () {
	if (g_hSpecTimer != null)
		KillTimer(g_hSpecTimer);
  g_hSpecTimer = CreateTimer(1.0, Timer_SpecTimer, _, TIMER_REPEAT);
}

public void YK_ActiveAnnounceTimer () {
	if (g_hAnnounceTimer != null)
		KillTimer(g_hAnnounceTimer);
  g_hAnnounceTimer = CreateTimer(30.0, Timer_AnnounceTimer, _, TIMER_REPEAT);
}

public Action Timer_BroadcastTimer (Handle timer) {
	g_iBroadcastTimeout--;
	if(g_iBroadcastTimeout == 0)
	{
		YK_BroadcastDangerZoneInfoToAll();
		g_iBroadcastTimeout = g_iBroadcastInterval;
	}
	return Plugin_Continue;
}

public Action Timer_ReadyTimer (Handle timer) {
  int readyPlayersCount = 0, unreadyPlayersCount = 0;
  if (g_iGameStartedStatus == 0) {
    YK_MoveAllPlayersInGame();
    for (int client = 1; client <= MaxClients; ++client) {
      if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {
        char clientName[255];
        GetClientName(client, clientName, 255);
        if (strcmp(clientName, "GOTV") != 0) {
          if (g_iPlayerReadyStatus[client] == 1) {
            readyPlayersCount++;
          } else {
            unreadyPlayersCount++;
          }
        }
      }
    }
    for (int client = 1; client <= MaxClients; ++client) {
      if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {
        if (g_iPlayerReadyStatus[client] == 0) {
          char szBuffer[256];
          FormatEx(szBuffer, 255, "%t", "hint unready", readyPlayersCount, readyPlayersCount + unreadyPlayersCount);
          ReplaceColorsCode(szBuffer, 256);
          PrintHintText(client, szBuffer);
        } else {
          if (readyPlayersCount + unreadyPlayersCount < 6){
            char szBuffer[256];
            FormatEx(szBuffer, 255, "%t", "hint ready 1", readyPlayersCount, readyPlayersCount + unreadyPlayersCount);
            ReplaceColorsCode(szBuffer, 256);
            PrintHintText(client, szBuffer);
          } else {
            int restPlayersCount = ((6 - readyPlayersCount) > 0) ? (6 - readyPlayersCount) : 0;
            char szBuffer[256];
            FormatEx(szBuffer, 255, "%t", "hint ready 2", readyPlayersCount, readyPlayersCount + unreadyPlayersCount, restPlayersCount);
            ReplaceColorsCode(szBuffer, 256);
            PrintHintText(client, szBuffer);
          }
        }
      }
    }
    if ((unreadyPlayersCount == 0 && readyPlayersCount >= 2) || (readyPlayersCount >= 6)) {
      g_iGameStartedStatus = 2;
    }
  } else {
    YK_StartGame(readyPlayersCount + unreadyPlayersCount);
  }
}

public Action Timer_SpecTimer (Handle timer) {
  if (g_iGameStartedStatus == 1) {
    for (int client = 1; client <= MaxClients; ++client) {
      if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {
        if(!IsPlayerAlive(client) && GetClientTeam(client) != 1){
          ChangeClientTeam(client, 1);
        }
      }
    }
  }
	return Plugin_Continue;
}

public Action Timer_AnnounceTimer (Handle timer) {
  if (g_iGameStartedStatus == 0) {
    YK_BroadcastDangerZoneServerInfoToAll();
  }
	return Plugin_Continue;
}

//////////////////////////////
//          MENUS           //
//////////////////////////////
public int Menu_DzAdminMenu (Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(param2, info, sizeof(info));
    if (found) {
      if (!strcmp(info, "setting")) {
        g_mSettingMenu = BuildSettingMenu(0);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "respawn")) {
        g_mRespawnMenu = BuildRespawnMenu();
        g_mRespawnMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "give")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(0);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "start")) {
        if (g_iGameStartedStatus == 0) {
          g_iGameStartedStatus = 2;
        }
      } else if (!strcmp(info, "end")) {
        if (g_iGameStartedStatus == 1) {
          g_iGameStartedStatus = 0;
          tPrintToChatAll(" %t %t", "prefix", "admin end match", g_iMaxTeamCount);
          YK_EndGame();
        }
      } else if (!strcmp(info, "fend")) {
        g_iGameStartedStatus = 0;
        tPrintToChatAll(" %t %t", "prefix", "admin end match", g_iMaxTeamCount);
        YK_EndGame();
      }
    }
	}
}

public int Menu_SettingMenu (Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(param2, info, sizeof(info));
    if (found) {
      if (!strcmp(info, "teamcount")) {
        g_mSettingMenu = BuildSettingMenu(1);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "broadcast")) {
        g_mSettingMenu = BuildSettingMenu(2);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "spawnhealth")) {
        g_mSettingMenu = BuildSettingMenu(3);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "maxhealth")) {
        g_mSettingMenu = BuildSettingMenu(4);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "teamcount_one")) {
        ServerCommand("yk_dzTeamCount 1"); 
      } else if (!strcmp(info, "teamcount_two")) {
        ServerCommand("yk_dzTeamCount 2"); 
      } else if (!strcmp(info, "teamcount_three")) {
        ServerCommand("yk_dzTeamCount 3"); 
      } else if (!strcmp(info, "broadcast_30")) {
        ServerCommand("yk_dzInterval 30"); 
      } else if (!strcmp(info, "broadcast_60")) {
        ServerCommand("yk_dzInterval 60"); 
      } else if (!strcmp(info, "broadcast_90")) {
        ServerCommand("yk_dzInterval 90"); 
      } else if (!strcmp(info, "broadcast_180")) {
        ServerCommand("yk_dzInterval 180"); 
      } else if (!strcmp(info, "broadcast_1800")) {
        ServerCommand("yk_dzInterval 1800"); 
      } else if (!strcmp(info, "spawnhealth_1")) {
        ServerCommand("yk_dzSpawnHealth 1"); 
      } else if (!strcmp(info, "spawnhealth_65")) {
        ServerCommand("yk_dzSpawnHealth 65"); 
      } else if (!strcmp(info, "spawnhealth_100")) {
        ServerCommand("yk_dzSpawnHealth 100"); 
      } else if (!strcmp(info, "spawnhealth_185")) {
        ServerCommand("yk_dzSpawnHealth 185"); 
      } else if (!strcmp(info, "spawnhealth_320")) {
        ServerCommand("yk_dzSpawnHealth 320"); 
      } else if (!strcmp(info, "spawnhealth_1000")) {
        ServerCommand("yk_dzSpawnHealth 1000"); 
      } else if (!strcmp(info, "maxhealth_1")) {
        ServerCommand("yk_dzMaxHealth 1"); 
      } else if (!strcmp(info, "maxhealth_65")) {
        ServerCommand("yk_dzMaxHealth 65"); 
      } else if (!strcmp(info, "maxhealth_100")) {
        ServerCommand("yk_dzMaxHealth 100"); 
      } else if (!strcmp(info, "maxhealth_185")) {
        ServerCommand("yk_dzMaxHealth 185"); 
      } else if (!strcmp(info, "maxhealth_320")) {
        ServerCommand("yk_dzMaxHealth 320"); 
      } else if (!strcmp(info, "maxhealth_1000")) {
        ServerCommand("yk_dzMaxHealth 1000"); 
      }
    }
	}
}

public int Menu_RespawnMenu (Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(param2, info, sizeof(info));
    if (found) {
      ChangeClientTeam(StringToInt(info), 3);
      CS_RespawnPlayer(StringToInt(info));
    }
	}
}

public int Menu_GiveWeaponMenu (Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(param2, info, sizeof(info));
    if (found) {
      if (!strcmp(info, "pistols")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(1);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "heavy")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(2);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "smgs")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(3);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "rifles")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(4);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "gear")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(5);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "grenades")) {
        g_mGiveWeaponMenu = BuildGiveWeaponMenu(6);
        g_mGiveWeaponMenu.Display(param1, MENU_TIME_FOREVER);
      } else {
        GivePlayerItem(param1, info);
      }
    }
	}
}

public Menu BuildDzAdminMenu () {
	Menu menu = new Menu(Menu_DzAdminMenu);
  menu.SetTitle("DZ管理员面板");
  menu.AddItem("setting", "设置服务器参数");
  menu.AddItem("respawn", "复活玩家");
  menu.AddItem("give", "给予道具");
  menu.AddItem("start", "开始游戏");
  menu.AddItem("end", "结束游戏");
  menu.AddItem("fend", "强制结束游戏");
  menu.ExitButton = true;
  return menu;
}

public Menu BuildSettingMenu (int id) {
	Menu menu = new Menu(Menu_SettingMenu);
  if (id == 0) {
    menu.SetTitle("头号行动设置面板");
    menu.AddItem("teamcount", "设置队伍人数");
    menu.AddItem("broadcast", "设置播报时间");
    menu.AddItem("spawnhealth", "设置初始血量");
    menu.AddItem("maxhealth", "设置最大血量");
  } else if (id == 1) {
    menu.SetTitle("设置队伍人数");
    menu.AddItem("teamcount_one", "1");
    menu.AddItem("teamcount_two", "2");
    menu.AddItem("teamcount_three", "3");
  } else if (id == 2) {
    menu.SetTitle("设置播报时间");
    menu.AddItem("broadcast_30", "30s");
    menu.AddItem("broadcast_60", "60s");
    menu.AddItem("broadcast_90", "90s");
    menu.AddItem("broadcast_180", "180s");
    menu.AddItem("broadcast_1800", "1800s");
  } else if (id == 3) {
    menu.SetTitle("设置初始血量");
    menu.AddItem("spawnhealth_1", "1");
    menu.AddItem("spawnhealth_65", "65");
    menu.AddItem("spawnhealth_100", "100");
    menu.AddItem("spawnhealth_185", "185");
    menu.AddItem("spawnhealth_320", "320");
    menu.AddItem("spawnhealth_1000", "1000");
  } else if (id == 4) {
    menu.SetTitle("设置最大血量");
    menu.AddItem("maxhealth_1", "1");
    menu.AddItem("maxhealth_65", "65");
    menu.AddItem("maxhealth_100", "100");
    menu.AddItem("maxhealth_185", "185");
    menu.AddItem("maxhealth_320", "320");
    menu.AddItem("maxhealth_1000", "1000");
  }
  menu.ExitButton = true;
  return menu;
}

public Menu BuildRespawnMenu () {
  int deadPlayersCount = 0;
	Menu menu = new Menu(Menu_RespawnMenu);
  menu.SetTitle("重生一名玩家");
	for (int client = 1; client <= MaxClients; ++client) {
		if (IsClientInGame(client)) {
			char clientName[255];
			GetClientName(client, clientName, 255);
      if (strcmp(clientName, "GOTV") != 0) {
        if (!IsPlayerAlive(client)) {
          deadPlayersCount++;
          char buffer[8];
          FormatEx(buffer, 8, "%d", client);
          menu.AddItem(buffer, clientName);
        }
      }
		}
	}
  menu.ExitButton = true;
  if (deadPlayersCount == 0)
    return null;
  else
    return menu;
}

public Menu BuildGiveWeaponMenu (int id) {
	Menu menu = new Menu(Menu_GiveWeaponMenu);
  if (id == 0) {
      menu.SetTitle("选择武器类型");
      menu.AddItem("pistols", "手枪");
      menu.AddItem("heavy", "重型武器");
      menu.AddItem("smgs", "冲锋枪");
      menu.AddItem("rifles", "步枪");
      menu.AddItem("gear", "近战武器");
      menu.AddItem("grenades", "投掷物");
  } else if (id == 1) {
      menu.SetTitle("选择一个手枪");
      menu.AddItem("weapon_glock", "Glock");
      menu.AddItem("weapon_p250", "P250");
      menu.AddItem("weapon_fiveseven", "57");
      menu.AddItem("weapon_deagle", "Deagle");
      menu.AddItem("weapon_hkp2000", "P2000");
      menu.AddItem("weapon_tec9", "Tec9");
  } else if (id == 2) {
      menu.SetTitle("选择一个重型武器");
      menu.AddItem("weapon_nova", "Nova");
      menu.AddItem("weapon_xm1014", "XM1014");
      menu.AddItem("weapon_mag7", "Mag7");
      menu.AddItem("weapon_sawedoff", "SawedOff");
      menu.AddItem("weapon_m249", "M249");
      menu.AddItem("weapon_negev", "Negav");
  } else if (id == 3) {
      menu.SetTitle("选择一个冲锋枪");
      menu.AddItem("weapon_mp9", "MP9");
      menu.AddItem("weapon_mac10", "Mac10");
      menu.AddItem("weapon_mp7", "Mp7");
      menu.AddItem("weapon_ump45", "Ump45");
      menu.AddItem("weapon_p90", "P90");
      menu.AddItem("weapon_bizon", "Bizon-PP");
  } else if (id == 4) {
      menu.SetTitle("选择一个步枪");
      menu.AddItem("weapon_famas", "Famas");
      menu.AddItem("weapon_m4a1", "M4A1");
      menu.AddItem("weapon_galilar", "Galilar");
      menu.AddItem("weapon_ak47", "AK47");
      menu.AddItem("weapon_ssg08", "SSG-08");
      menu.AddItem("weapon_aug", "AUG");
      menu.AddItem("weapon_sg556", "SG553");
      menu.AddItem("weapon_awp", "AWP");
      menu.AddItem("weapon_scar20", "Scar20");
      menu.AddItem("weapon_g3sg1", "G3SG1");
  } else if (id == 5) {
      menu.SetTitle("选择一个近战武器");
      menu.AddItem("weapon_taser", "Taser");
      menu.AddItem("weapon_knife", "knife");
  } else if (id == 6) {
      menu.SetTitle("选择一个投掷物");
      menu.AddItem("weapon_hegrenade", "Hegrenade");
      menu.AddItem("weapon_flashbang", "Flash");
      menu.AddItem("weapon_smokegrenade", "Smoke");
      menu.AddItem("weapon_molotov", "Molotov");
      menu.AddItem("weapon_decoy", "Decoy");
  }
  menu.ExitButton = true;
  return menu;
}

//////////////////////////////
//         DATABASE         //
//////////////////////////////
public void YK_DatabaseInit () {
  Database.Connect(SQLCallback_Connection, "csgo", 0);
}

public void SQLCallback_Connection (Database db, const char[] error, int retry) {
  retry++;
  if (db == null || error[0]) {
    PrintToServer("Failed to connect to SQL database. [%03d] Error: %s", retry, error);
    CreateTimer(5.0, Timer_DababaseRetry, retry);
    return;
  }
  if (g_hDatabase != null) {
    delete db;
    return;
  }
  g_hDatabase = db;
  if (!g_hDatabase.SetCharset("utf8mb4")) {
    g_hDatabase.SetCharset("utf8");
  }
}

public Action Timer_DababaseRetry (Handle timer, int retry) {
  if (g_hDatabase != null)
    return Plugin_Stop;
  if (retry >= 100) {
    SetFailState("Database connection failed to initialize after 100 retrie");
    return Plugin_Stop;
  }
  Database.Connect(SQLCallback_Connection, "csgo", retry);
  return Plugin_Stop;
}

public void DB_InitUser (int client) {
  if (IsFakeClient(client))
    return;
  char username[255], sql[255];
  int steamid = GetSteamAccountID(client);
  GetClientName(client, username, 255);
  FormatEx(sql, 255, "SELECT * FROM dangerzone WHERE steamid = '%d'", steamid);
  DBResultSet results = SQL_Query(g_hDatabase, sql);
  if (results == null) {
    char error[255];
    SQL_GetError(g_hDatabase, error, sizeof(error));
    PrintToServer("Failed to query (error: %s)", error);
  } else if (!(results.FetchRow() && results.RowCount > 0)) {
    FormatEx(sql, 255, "INSERT INTO dangerzone (username, steamid) VALUES ('%s', '%d')", username, steamid);
    SQL_Query(g_hDatabase, sql);
    delete results;
  }
}

public void DB_AddKillToPlayer (int client) {
  if (IsFakeClient(client))
    return;
  char sql[255];
  int steamid = GetSteamAccountID(client);
  FormatEx(sql, 255, "UPDATE `dangerzone` SET `kill` = `kill` + 1 WHERE `steamid` = '%d'", steamid);
  DBResultSet results = SQL_Query(g_hDatabase, sql);
  if (results == null) {
    char error[255];
    SQL_GetError(g_hDatabase, error, sizeof(error));
    PrintToServer("Failed to query (error: %s)", error);
  } else {
    delete results;
  }
}

public void DB_AddDeathToPlayer (int client) {
  if (IsFakeClient(client))
    return;
  char sql[255];
  int steamid = GetSteamAccountID(client);
  FormatEx(sql, 255, "UPDATE `dangerzone` SET `death` = `death` + 1 WHERE `steamid` = '%d'", steamid);
  DBResultSet results = SQL_Query(g_hDatabase, sql);
  if (results == null) {
    char error[255];
    SQL_GetError(g_hDatabase, error, sizeof(error));
    PrintToServer("Failed to query (error: %s)", error);
  } else {
    delete results;
  }
}

public void DB_AddWinToPlayer (int client) {
  if (IsFakeClient(client))
    return;
  char sql[255];
  int steamid = GetSteamAccountID(client);
  FormatEx(sql, 255, "UPDATE `dangerzone` SET `win` = `win` + 1 WHERE `steamid` = '%d'", steamid);
  DBResultSet results = SQL_Query(g_hDatabase, sql);
  if (results == null) {
    char error[255];
    SQL_GetError(g_hDatabase, error, sizeof(error));
    PrintToServer("Failed to query (error: %s)", error);
  } else {
    delete results;
  }
}

//////////////////////////////
//         WELCOME          //
//////////////////////////////
public void YK_WelcomeMessage () {
  tPrintToChatAll("%t", "welcome line 1");
  tPrintToChatAll("%t", "welcome line 2");
  tPrintToChatAll("%t", "welcome line 3");
  tPrintToChatAll("%t", "welcome line 4");
  tPrintToChatAll("%t", "welcome line 5");
  tPrintToChatAll("%t", "welcome line 6");
  tPrintToChatAll("%t", "welcome line 1");
}

//////////////////////////////
//     SOUNDS PRECACHE      //
//////////////////////////////
public void YK_PrecacheSounds () {
  AddFileToDownloadsTable("sound/einzbern/229875-a39ebdcd-20df-417c-b3e9-ac254dc1a701.mp3");
  AddFileToDownloadsTable("sound/einzbern/229875-925e9c0e-8f02-4e27-bd84-5f0704012a51.mp3");
  AddFileToDownloadsTable("sound/einzbern/229875-e1721e64-3864-4528-b495-7a77efc7be1c.mp3");
  PrecacheSound("einzbern/229875-a39ebdcd-20df-417c-b3e9-ac254dc1a701.mp3"); // an enemy has been slain
  PrecacheSound("einzbern/229875-925e9c0e-8f02-4e27-bd84-5f0704012a51.mp3");  // you has slain an enemy
  PrecacheSound("einzbern/229875-e1721e64-3864-4528-b495-7a77efc7be1c.mp3");  // you has been slain
}

//////////////////////////////
//          STOCKS          //
//////////////////////////////
stock void tPrintToChat (int client, const char[] szMessage, any ...) {
  char szBuffer[256];
  VFormat(szBuffer, 256, szMessage, 3);
  ReplaceColorsCode(szBuffer, 256);
  Format(szBuffer, 256, "%s", szBuffer);
  Protobuf SayText2 = view_as<Protobuf>(StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS));
  if (SayText2 == null) {
    LogError("StartMessageOne -> SayText2 is null");
    return;
  }
  SayText2.SetInt("ent_idx", 0);
  SayText2.SetBool("chat", true);
  SayText2.SetString("msg_name", szBuffer);
  SayText2.AddString("params", "");
  SayText2.AddString("params", "");
  SayText2.AddString("params", "");
  SayText2.AddString("params", "");
  EndMessage();
}

stock void tPrintToChatAll (const char[] szMessage, any ...) {
  char szBuffer[256];
  for (int client = 1; client <= MaxClients; client++) {
    if (IsClientInGame(client) && !IsFakeClient(client)) {
      SetGlobalTransTarget(client);
      VFormat(szBuffer, 256, szMessage, 2);
      ReplaceColorsCode(szBuffer, 256);
      tPrintToChat(client, "%s", szBuffer);
    }
  }
}

stock void ReplaceColorsCode (char[] message, int maxLen, int team = 0) {
    ReplaceString(message, maxLen, "{normal}", "\x01", false);
    ReplaceString(message, maxLen, "{default}", "\x01", false);
    ReplaceString(message, maxLen, "{white}", "\x01", false);
    ReplaceString(message, maxLen, "{darkred}", "\x02", false);
    switch (team) {
        case 3 : ReplaceString(message, maxLen, "{teamcolor}", "\x0B", false);
        case 2 : ReplaceString(message, maxLen, "{teamcolor}", "\x05", false);
        default: ReplaceString(message, maxLen, "{teamcolor}", "\x01", false);
    }
    ReplaceString(message, maxLen, "{pink}", "\x03", false);
    ReplaceString(message, maxLen, "{green}", "\x04", false);
    ReplaceString(message, maxLen, "{highlight}", "\x04", false);
    ReplaceString(message, maxLen, "{yellow}", "\x05", false);
    ReplaceString(message, maxLen, "{lightgreen}", "\x05", false);
    ReplaceString(message, maxLen, "{lime}", "\x06", false);
    ReplaceString(message, maxLen, "{lightred}", "\x07", false);
    ReplaceString(message, maxLen, "{red}", "\x07", false);
    ReplaceString(message, maxLen, "{gray}", "\x08", false);
    ReplaceString(message, maxLen, "{grey}", "\x08", false);
    ReplaceString(message, maxLen, "{olive}", "\x09", false);
    ReplaceString(message, maxLen, "{orange}", "\x10", false);
    ReplaceString(message, maxLen, "{silver}", "\x0A", false);
    ReplaceString(message, maxLen, "{lightblue}", "\x0B", false);
    ReplaceString(message, maxLen, "{blue}", "\x0C", false);
    ReplaceString(message, maxLen, "{purple}", "\x0E", false);
    ReplaceString(message, maxLen, "{darkorange}", "\x0F", false);
}