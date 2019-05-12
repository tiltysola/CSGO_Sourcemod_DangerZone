#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include "includes/color_Stock.inc"
#include "dangerzone/dangerzone_teams.sp"
#include "dangerzone/killsounds.sp"

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
ConVar g_hReadyToStartPlayersCount = null;

int g_iReadyToStartPlayersCount = 6;

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
int g_iFirstBlood = 0;
int g_iPlayerKillsCount[65];

//////////////////////////////
//     PLUGIN FORWARDS      //
//////////////////////////////
public void OnPluginStart () {
  YK_InitPlugin();
  OnTeamsPluginStart();
}

public void OnMapStart () {
  ServerCommand("sv_dz_cash_bundle_size 100");
  ServerCommand("sv_dz_warmup_weapon weapon_awp"); 
  YK_InitKillSounds();
}

public void OnClientPutInServer (int client) {
  char clientName[255];
  GetClientName(client, clientName, 255);
  tPrintToChatAll(" %t %t", "prefix", "join game", clientName);
  DB_InitUser(client);
  if (g_iGameStartedStatus == 1) {
    g_iPlayerAliveStatus[client] = 2;
  }
  YK_BroadcastDangerZoneServerInfo(client);
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
  Cvars_LoadConfigs();
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
		else if (StringToInt(newValue) > 1800.0)
			g_iBroadcastInterval = 1800;
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
    ServerCommand("sv_dz_team_count %d", g_iMaxTeamCount);
    if (g_iMaxTeamCount > 1) {
      for (int client = 1; client <= MaxClients; ++client) {
        ShowTeamMenu(client);
      }
    }
    tPrintToChatAll(" %t %t", "prefix", "teamcount setting", g_iMaxTeamCount);
	}
	if (convar == g_hSpawnHealth) {
		if (StringToInt(newValue) < 1.0)
			g_iSpawnHealth = 1;
		else if (StringToInt(newValue) > 1000.0)
			g_iSpawnHealth = 1000;
		else
			g_iSpawnHealth = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "spawn health setting", g_iSpawnHealth);
	}
	if (convar == g_hMaxHealth) {
		if (StringToInt(newValue) < 1.0)
			g_iMaxHealth = 1;
		else if (StringToInt(newValue) > 1000.0)
			g_iMaxHealth = 1000;
		else
			g_iMaxHealth = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "max health setting", g_iMaxHealth);
	}
	if (convar == g_hReadyToStartPlayersCount) {
		if (StringToInt(newValue) < 2.0)
			g_iReadyToStartPlayersCount = 2;
		else if (StringToInt(newValue) > 18.0)
			g_iReadyToStartPlayersCount = 18;
		else
			g_iReadyToStartPlayersCount = StringToInt(newValue);
    tPrintToChatAll(" %t %t", "prefix", "ready start players count", g_iReadyToStartPlayersCount);
	}
}

public void ConVarSaving () {
  char dangerzone[255];
  FormatEx(dangerzone, 256, "sourcemod/dangerzone.cfg");
  char path[255];
  FormatEx(path, 255, "cfg/%s", dangerzone);
  GenerateNewConfigs(path, g_bPluginEnable, g_iBroadcastInterval, g_iMaxTeamCount, g_iSpawnHealth, g_iMaxHealth, g_iReadyToStartPlayersCount);
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
        // tPrintToChat(client, " %t %t", "prefix", "ready");
        int readyPlayersCount = 0, unreadyPlayersCount = 0;
        for (int c = 1; c <= MaxClients; ++c) {
          if (IsClientInGame(c) && IsClientConnected(c) && !IsFakeClient(c)) {
            char clientName[255];
            GetClientName(c, clientName, 255);
            if (strcmp(clientName, "GOTV") != 0) {
              if (g_iPlayerReadyStatus[c] == 1) {
                readyPlayersCount++;
              } else {
                unreadyPlayersCount++;
              }
            }
          }
        }
        int restPlayersCount = ((g_iReadyToStartPlayersCount - readyPlayersCount) > 0) ? (g_iReadyToStartPlayersCount - readyPlayersCount) : 0;
        char buffer[255];
        GetClientName(client, buffer, 255);
        tPrintToChatAll(" %t %t", "prefix", "ready all", buffer, restPlayersCount);
      } else {
        tPrintToChat(client, " %t %t", "prefix", "retype ready");
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
        // tPrintToChat(client, " %t %t", "prefix", "unready");
        int readyPlayersCount = 0, unreadyPlayersCount = 0;
        for (int c = 1; c <= MaxClients; ++c) {
          if (IsClientInGame(c) && IsClientConnected(c) && !IsFakeClient(c)) {
            char clientName[255];
            GetClientName(c, clientName, 255);
            if (strcmp(clientName, "GOTV") != 0) {
              if (g_iPlayerReadyStatus[c] == 1) {
                readyPlayersCount++;
              } else {
                unreadyPlayersCount++;
              }
            }
          }
        }
        int restPlayersCount = ((g_iReadyToStartPlayersCount - readyPlayersCount) > 0) ? (g_iReadyToStartPlayersCount - readyPlayersCount) : 0;
        char buffer[255];
        GetClientName(client, buffer, 255);
        tPrintToChatAll(" %t %t", "prefix", "unready all", buffer, restPlayersCount);
      } else {
        tPrintToChat(client, " %t %t", "prefix", "retype unready");
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

public Action Command_SaveCFG (int client, int args) {
    if (!IsClientInGame(client) && !IsFakeClient(client))
      return Plugin_Handled;
    ConVarSaving();
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
      tPrintToChat(client, " %t %t", "prefix", "respawn player not found");
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
    Cvars_LoadConfigs();
    if (g_bPluginPreprocess == false) {
      g_bPluginPreprocess = true;
      YK_EndGame();
    } else if (g_iGameStartedStatus == 0) {
      ServerCommand("mp_warmuptime 3600");
      ServerCommand("mp_warmup_pausetimer 1");
      // ServerCommand("sv_dz_team_count 1");
      ServerCommand("sv_dz_autojointeam 0");
      ServerCommand("sv_dz_jointeam_allowed 1");
      ServerCommand("sv_dz_player_max_health 1000");
      ServerCommand("sv_dz_player_spawn_health 1000");
      YK_ActiveReadyTimer();
      // YK_ActiveAnnounceTimer();
      if (g_iMaxTeamCount > 1) {
        for (int client = 1; client <= MaxClients; ++client) {
          ShowTeamMenu(client);
        }
      }
    } else if (g_iGameStartedStatus == 2) {
      ServerCommand("sv_dz_jointeam_allowed 0");
      g_iGameStartedStatus = 1;
      g_iFirstBlood = 0;
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
    tPrintToChatAll(" %t %t", "prefix", "hurt others", attackerName, weaponName, victimName, damage);
  } else {
    tPrintToChatAll(" %t %t", "prefix", "hurt self", victimName, damage);
  }
}

public void Event_PlayerBlind (Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
  int victim = GetClientOfUserId(GetEventInt(event, "userid"));
  float duration = GetEventFloat(event, "blind_duration");
  char attackerName[255], victimName[255];
  GetClientName(attacker, attackerName, 255);
  GetClientName(victim, victimName, 255);
  if (strcmp(attackerName, "GOTV") != 0 && strcmp(victimName, "GOTV") != 0 && IsPlayerAlive(victim)) {
    if (attacker != victim) {
      tPrintToChatAll(" %t %t", "prefix", "flash others", attackerName, victimName, duration);
    } else {
      tPrintToChatAll(" %t %t", "prefix", "flash self", victimName, duration);
    }
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
    if (attacker != victim && attacker != 0) {
      g_iPlayerKillsCount[attacker]++;
      if (g_iPlayerKillsCount[attacker] >= 3) {
        for (int time = 0; time < g_iPlayerKillsCount[attacker]; time++)
          tPrintToChatAll(" %t %t", "prefix", "multi kill", attackerName, g_iPlayerKillsCount[attacker]);
      }
      YK_PlayKillSounds(attacker, victim, g_iFirstBlood, g_iPlayerKillsCount[attacker]);
      g_iFirstBlood = 1;
    } else {
      YK_PlayKillSounds(0, 0, 0, 0);
    }
  }
}

public void Event_DzInteraction (Event event, const char[] name, bool dontBroadcast) {
  int userid = GetClientOfUserId(GetEventInt(event, "userid"));
  char caseType[255], userName[255];
  GetEventString(event, "type", caseType, 255);
  GetClientName(userid, userName, 255);
  tPrintToChatAll(" %t %t", "prefix", "interact", userName, caseType);
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
  g_hReadyToStartPlayersCount = CreateConVar("yk_dzReadyToStartPlayersCount", "6",
					"Min value is 2 and max value is 18.", _, true, 2.0,   true, 18.0);
	HookConVarChange(g_hPluginEnable, ConVarChanged);
	HookConVarChange(g_hBroadcastInterval, ConVarChanged);
	HookConVarChange(g_hMaxTeamCount, ConVarChanged);
	HookConVarChange(g_hSpawnHealth, ConVarChanged);
	HookConVarChange(g_hMaxHealth, ConVarChanged);
	HookConVarChange(g_hReadyToStartPlayersCount, ConVarChanged);
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
  RegConsoleCmd("sm_r", Command_Ready);
  RegConsoleCmd("sm_unready", Command_Unready);
  RegConsoleCmd("sm_ur", Command_Unready);
  RegAdminCmd("sm_dzadmin", Command_DzAdmin, ADMFLAG_CHEATS);
  RegAdminCmd("sm_savecfg", Command_SaveCFG, ADMFLAG_CHEATS);
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
          tPrintToChatAll(" \x04%d. %s (%t) %t: %dhp", printIdPrefix, clientName, "alive", "left", GetClientHealth(client));
        } else if (g_iPlayerAliveStatus[client] == 1) {
          tPrintToChatAll(" \x02%d. %s (%t)", printIdPrefix, clientName, "dead");
        } else if (g_iPlayerAliveStatus[client] == 2) {
          tPrintToChatAll(" \x0E%d. %s (%t)", printIdPrefix, clientName, "spec");
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

public void YK_BroadcastDangerZoneServerInfo (int client) {
  tPrintToChat(client, " %t %t", "prefix", "broadcast team count", g_iMaxTeamCount);
  tPrintToChat(client, " %t %t", "prefix", "broadcast spawn health", g_iSpawnHealth);
  tPrintToChat(client, " %t %t", "prefix", "broadcast max health", g_iMaxHealth);
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
  ServerCommand("sv_dz_player_max_health %d", g_iMaxHealth);
  ServerCommand("sv_dz_player_spawn_health %d", g_iSpawnHealth);
  KillTimer(g_hReadyTimer);
  g_hReadyTimer = null;
  YK_ActiveBroadcastTimer();
  YK_ActiveSpecTimer();
}

public void YK_EndGame () {
  ServerCommand("mp_warmuptime 3600");
  ServerCommand("mp_warmup_pausetimer 1");
  ServerCommand("mp_warmup_start");
  ServerCommand("mp_restartgame 3");
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
  g_hReadyTimer = CreateTimer(0.1, Timer_ReadyTimer, _, TIMER_REPEAT);
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
      // GodMode WarmUp
      if (IsClientInGame(client)) {
        SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
      }
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
          if (g_iMaxTeamCount > 1) {
            FormatEx(szBuffer, 255, "%t", "hint unready team", readyPlayersCount, readyPlayersCount + unreadyPlayersCount);
          } else {
            FormatEx(szBuffer, 255, "%t", "hint unready", readyPlayersCount, readyPlayersCount + unreadyPlayersCount);
          }
          PrintHintText(client, szBuffer);
        } else {
          if (readyPlayersCount + unreadyPlayersCount < g_iReadyToStartPlayersCount){
            char szBuffer[256];
            FormatEx(szBuffer, 255, "%t", "hint ready 1", readyPlayersCount, readyPlayersCount + unreadyPlayersCount, g_iReadyToStartPlayersCount);
            PrintHintText(client, szBuffer);
          } else {
            int restPlayersCount = ((g_iReadyToStartPlayersCount - readyPlayersCount) > 0) ? (g_iReadyToStartPlayersCount - readyPlayersCount) : 0;
            char szBuffer[256];
            FormatEx(szBuffer, 255, "%t", "hint ready 2", readyPlayersCount, readyPlayersCount + unreadyPlayersCount, restPlayersCount);
            PrintHintText(client, szBuffer);
          }
        }
      }
    }
    if (readyPlayersCount >= g_iReadyToStartPlayersCount) {
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
        if (g_mRespawnMenu == null) {
          tPrintToChat(param1, " %t %t", "prefix", "respawn player not found");
        }
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
      } else if (!strcmp(info, "readyplayers")) {
        g_mSettingMenu = BuildSettingMenu(5);
        g_mSettingMenu.Display(param1, MENU_TIME_FOREVER);
      } else if (!strcmp(info, "savecfg")) {
        ConVarSaving();
        tPrintToChat(param1, " %t %t", "prefix", "cfg saved");
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
      } else if (!strcmp(info, "readyplayers_2")) {
        ServerCommand("yk_dzReadyToStartPlayersCount 2"); 
      } else if (!strcmp(info, "readyplayers_6")) {
        ServerCommand("yk_dzReadyToStartPlayersCount 6"); 
      } else if (!strcmp(info, "readyplayers_10")) {
        ServerCommand("yk_dzReadyToStartPlayersCount 10"); 
      } else if (!strcmp(info, "readyplayers_14")) {
        ServerCommand("yk_dzReadyToStartPlayersCount 14"); 
      } else if (!strcmp(info, "readyplayers_18")) {
        ServerCommand("yk_dzReadyToStartPlayersCount 18"); 
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
  char buffer[255];
	Menu menu = new Menu(Menu_DzAdminMenu);
  FormatEx(buffer, 255, "%t", "dz admin");
  menu.SetTitle(buffer);
  FormatEx(buffer, 255, "%t", "dz server cvars");
  menu.AddItem("setting", buffer);
  FormatEx(buffer, 255, "%t", "dz respawn");
  menu.AddItem("respawn", buffer);
  FormatEx(buffer, 255, "%t", "dz give");
  menu.AddItem("give", buffer);
  FormatEx(buffer, 255, "%t", "dz start");
  menu.AddItem("start", buffer);
  FormatEx(buffer, 255, "%t", "dz end");
  menu.AddItem("end", buffer);
  FormatEx(buffer, 255, "%t", "dz fend");
  menu.AddItem("fend", buffer);
  menu.ExitButton = true;
  return menu;
}

public Menu BuildSettingMenu (int id) {
  char buffer[255];
	Menu menu = new Menu(Menu_SettingMenu);
  if (id == 0) {
    FormatEx(buffer, 255, "%t", "dz server setting");
    menu.SetTitle(buffer);
    FormatEx(buffer, 255, "%t", "dz team count");
    menu.AddItem("teamcount", buffer);
    FormatEx(buffer, 255, "%t", "dz broadcast");
    menu.AddItem("broadcast", buffer);
    FormatEx(buffer, 255, "%t", "dz spawn health");
    menu.AddItem("spawnhealth", buffer);
    FormatEx(buffer, 255, "%t", "dz max health");
    menu.AddItem("maxhealth", buffer);
    FormatEx(buffer, 255, "%t", "dz ready players");
    menu.AddItem("readyplayers", buffer);
    FormatEx(buffer, 255, "%t", "dz save cfg");
    menu.AddItem("savecfg", buffer);
  } else if (id == 1) {
    FormatEx(buffer, 255, "%t", "dz team count");
    menu.SetTitle(buffer);
    menu.AddItem("teamcount_one", "1");
    menu.AddItem("teamcount_two", "2");
    menu.AddItem("teamcount_three", "3");
  } else if (id == 2) {
    FormatEx(buffer, 255, "%t", "dz broadcast");
    menu.SetTitle(buffer);
    menu.AddItem("broadcast_30", "30s");
    menu.AddItem("broadcast_60", "60s");
    menu.AddItem("broadcast_90", "90s");
    menu.AddItem("broadcast_180", "180s");
    menu.AddItem("broadcast_1800", "1800s");
  } else if (id == 3) {
    FormatEx(buffer, 255, "%t", "dz spawn health");
    menu.SetTitle(buffer);
    menu.AddItem("spawnhealth_1", "1");
    menu.AddItem("spawnhealth_65", "65");
    menu.AddItem("spawnhealth_100", "100");
    menu.AddItem("spawnhealth_185", "185");
    menu.AddItem("spawnhealth_320", "320");
    menu.AddItem("spawnhealth_1000", "1000");
  } else if (id == 4) {
    FormatEx(buffer, 255, "%t", "dz max health");
    menu.SetTitle(buffer);
    menu.AddItem("maxhealth_1", "1");
    menu.AddItem("maxhealth_65", "65");
    menu.AddItem("maxhealth_100", "100");
    menu.AddItem("maxhealth_185", "185");
    menu.AddItem("maxhealth_320", "320");
    menu.AddItem("maxhealth_1000", "1000");
  } else if (id == 5) {
    FormatEx(buffer, 255, "%t", "dz ready players");
    menu.SetTitle(buffer);
    menu.AddItem("readyplayers_2", "2");
    menu.AddItem("readyplayers_6", "6");
    menu.AddItem("readyplayers_10", "10");
    menu.AddItem("readyplayers_14", "14");
    menu.AddItem("readyplayers_18", "18");
  }
  menu.ExitButton = true;
  return menu;
}

public Menu BuildRespawnMenu () {
  char buffer[255];
  int deadPlayersCount = 0;
	Menu menu = new Menu(Menu_RespawnMenu);
  FormatEx(buffer, 255, "%t", "dz respawn");
  menu.SetTitle(buffer);
	for (int client = 1; client <= MaxClients; ++client) {
		if (IsClientInGame(client)) {
			char clientName[255];
			GetClientName(client, clientName, 255);
      if (strcmp(clientName, "GOTV") != 0) {
        if (!IsPlayerAlive(client)) {
          deadPlayersCount++;
          char buffer2[8];
          FormatEx(buffer2, 8, "%d", client);
          menu.AddItem(buffer2, clientName);
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
  char buffer[255];
	Menu menu = new Menu(Menu_GiveWeaponMenu);
  if (id == 0) {
      FormatEx(buffer, 255, "%t", "dz give");
      menu.SetTitle(buffer);
      FormatEx(buffer, 255, "%t", "give pistols");
      menu.AddItem("pistols", buffer);
      FormatEx(buffer, 255, "%t", "give heavy");
      menu.AddItem("heavy", buffer);
      FormatEx(buffer, 255, "%t", "give smgs");
      menu.AddItem("smgs", buffer);
      FormatEx(buffer, 255, "%t", "give rifles");
      menu.AddItem("rifles", buffer);
      FormatEx(buffer, 255, "%t", "give gear");
      menu.AddItem("gear", buffer);
      FormatEx(buffer, 255, "%t", "give grenades");
      menu.AddItem("grenades", buffer);
  } else if (id == 1) {
      FormatEx(buffer, 255, "%t", "give pistols");
      menu.SetTitle(buffer);
      menu.AddItem("weapon_glock", "Glock");
      menu.AddItem("weapon_p250", "P250");
      menu.AddItem("weapon_fiveseven", "57");
      menu.AddItem("weapon_deagle", "Deagle");
      menu.AddItem("weapon_hkp2000", "P2000");
      menu.AddItem("weapon_tec9", "Tec9");
  } else if (id == 2) {
      FormatEx(buffer, 255, "%t", "give heavy");
      menu.SetTitle(buffer);
      menu.AddItem("weapon_nova", "Nova");
      menu.AddItem("weapon_xm1014", "XM1014");
      menu.AddItem("weapon_mag7", "Mag7");
      menu.AddItem("weapon_sawedoff", "SawedOff");
      menu.AddItem("weapon_m249", "M249");
      menu.AddItem("weapon_negev", "Negav");
  } else if (id == 3) {
      FormatEx(buffer, 255, "%t", "give smgs");
      menu.SetTitle(buffer);
      menu.AddItem("weapon_mp9", "MP9");
      menu.AddItem("weapon_mac10", "Mac10");
      menu.AddItem("weapon_mp7", "Mp7");
      menu.AddItem("weapon_ump45", "Ump45");
      menu.AddItem("weapon_p90", "P90");
      menu.AddItem("weapon_bizon", "Bizon-PP");
  } else if (id == 4) {
      FormatEx(buffer, 255, "%t", "give rifles");
      menu.SetTitle(buffer);
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
      FormatEx(buffer, 255, "%t", "give gear");
      menu.SetTitle(buffer);
      menu.AddItem("weapon_taser", "Taser");
      menu.AddItem("weapon_knife", "knife");
  } else if (id == 6) {
      FormatEx(buffer, 255, "%t", "give grenades");
      menu.SetTitle(buffer);
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
//           CFG            //
//////////////////////////////
static void Cvars_LoadConfigs () {
  // load map config
  char dangerzone[255];
  FormatEx(dangerzone, 256, "sourcemod/dangerzone.cfg");

  char path[255];
  FormatEx(path, 255, "cfg/%s", dangerzone);

  if (!FileExists(path)) {
    GenerateConfigs(path);
    LogMessage("[%s] does not exists, Auto-generated.", dangerzone);
    return;
  }

  ServerCommand("exec %s", dangerzone);
  LogMessage("Executed %s", dangerzone);
}

static void GenerateConfigs (char[] path) {
  File file = OpenFile(path, "w+");

  if (file == null) {
    LogError("Failed to create [%s]", path);
    return;
  }

  file.WriteLine("// This file was auto-generated by yk_dangerzone.smx");

  file.WriteLine("");
  file.WriteLine("");

  //Plugin Enable
  file.WriteLine("// 设置插件是否默认启用");
  file.WriteLine("// Set plugin enable");
  file.WriteLine("yk_dzEnable 1");
  file.WriteLine("");

  //Broadcast Interval
  file.WriteLine("// 设置播报时间间隔");
  file.WriteLine("// Set broadcast interval");
  file.WriteLine("yk_dzInterval 60");
  file.WriteLine("");

  //Team Player Count
  file.WriteLine("// 设置小队人数上限");
  file.WriteLine("// Set team players count");
  file.WriteLine("yk_dzTeamCount 1");
  file.WriteLine("");

  //Spawn Health
  file.WriteLine("// 设置初始血量");
  file.WriteLine("// Set spawn health");
  file.WriteLine("yk_dzSpawnHealth 185");
  file.WriteLine("");

  //Max Health
  file.WriteLine("// 设置最大血量");
  file.WriteLine("// Set max health");
  file.WriteLine("yk_dzMaxHealth 320");
  file.WriteLine("");

  //Start Need Players
  file.WriteLine("// 设置开始游戏需要准备玩家数");
  file.WriteLine("// Set game start needs players count");
  file.WriteLine("yk_dzReadyToStartPlayersCount 6");
  file.WriteLine("");

  delete file;
}

static void GenerateNewConfigs (char[] path, int a, int b, int c, int d, int e, int f) {
  File file = OpenFile(path, "w+");

  if (file == null) {
    LogError("Failed to create [%s]", path);
    return;
  }

  file.WriteLine("// This file was auto-generated by yk_dangerzone.smx");

  file.WriteLine("");
  file.WriteLine("");

  char buffer[255];

  //Plugin Enable
  file.WriteLine("// 设置插件是否默认启用");
  file.WriteLine("// Set plugin enable");
  FormatEx(buffer, 255, "yk_dzEnable %d", a);
  file.WriteLine(buffer);
  file.WriteLine("");

  //Broadcast Interval
  file.WriteLine("// 设置播报时间间隔");
  file.WriteLine("// Set broadcast interval");
  FormatEx(buffer, 255, "yk_dzInterval %d", b);
  file.WriteLine(buffer);
  file.WriteLine("");

  //Team Player Count
  file.WriteLine("// 设置小队人数上限");
  file.WriteLine("// Set team players count");
  FormatEx(buffer, 255, "yk_dzTeamCount %d", c);
  file.WriteLine(buffer);
  file.WriteLine("");

  //Spawn Health
  file.WriteLine("// 设置初始血量");
  file.WriteLine("// Set spawn health");
  FormatEx(buffer, 255, "yk_dzSpawnHealth %d", d);
  file.WriteLine(buffer);
  file.WriteLine("");

  //Max Health
  file.WriteLine("// 设置最大血量");
  file.WriteLine("// Set max health");
  FormatEx(buffer, 255, "yk_dzMaxHealth %d", e);
  file.WriteLine(buffer);
  file.WriteLine("");

  //Start Need Players
  file.WriteLine("// 设置开始游戏需要准备玩家数");
  file.WriteLine("// Set game start needs players count");
  FormatEx(buffer, 255, "yk_dzReadyToStartPlayersCount %d", f);
  file.WriteLine(buffer);
  file.WriteLine("");

  delete file;
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