 char colors[][] = {
    "Blue Team",
    "Turquoise Team",
    "Banana Team",
    "Magenta Team",
    "Artic Team",
    "Lime Team",
    "Orange Team",
    "Pink Team",
    "Purple Team",
    "White Team"
};

#include <sdktools>

ConVar sv_dz_team_count

// #define DATA "1.0"

// public Plugin:myinfo =
// {
// 	name = "SM Danger Zone Team Manager",
// 	author = "Franc1sco franug",
// 	description = "",
// 	version = DATA,
// 	url = "http://steamcommunity.com/id/franug"
// };

// public void OnPluginStart()
public void OnTeamsPluginStart()
{
	LoadTranslations("yk_dangerzone_team.phrases");

	sv_dz_team_count = FindConVar("sv_dz_team_count");
	if(sv_dz_team_count == null) SetFailState("No such Cvar 'sv_dz_team_count'");
	RegConsoleCmd("sm_dzteam", JoinTeam);
	// HookEvent("player_spawn", Event_PlayerSpawn);
}

/*
public OnClientPostAdminCheck(int client)
{
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)return;
	
	ShowTeamMenu(client);	
}*/

// public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
// {
// 	if (GameRules_GetProp("m_bWarmupPeriod") != 1)return;
// 	int client = GetClientOfUserId(GetEventInt(event, "userid"));
// 	if (GetEntProp(client, Prop_Send, "m_nSurvivalTeam") > -1)return;
// 	sv_dz_team_count = FindConVar("sv_dz_team_count");
// 	if(sv_dz_team_count == null) SetFailState("No such Cvar 'sv_dz_team_count'");
// 	char buffer[128];
//  sv_dz_team_count.GetString(buffer, 128);
//  if (StringToInt(buffer) > 1) {
// 	  ShowTeamMenu(client);
//  }
// }

public Action JoinTeam(int client, int args)
{
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		tPrintToChat(client, " %t %t", "prefix", "error select team");
		return Plugin_Handled;
	}
	char buffer[128];
	sv_dz_team_count.GetString(buffer, 128);
	if (StringToInt(buffer) > 1) {
		ShowTeamMenu(client);
	}
	return Plugin_Handled;
}

void ShowTeamMenu(int client)
{
	int team_count = sv_dz_team_count.IntValue;
	int[] m_nSurvivalTeam = new int[MaxClients+1];
	for(int i = 1; i <= MaxClients; i++)
	{
		m_nSurvivalTeam[i] = -1;
		if(!IsClientInGame(i)) continue;
		m_nSurvivalTeam[i] = GetEntProp(i, Prop_Send, "m_nSurvivalTeam");
	}
	Menu menu = new Menu(handler, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("%t", "join Survival Team");
	int counter;
	char buffer[PLATFORM_MAX_PATH];
	for(int x = 0; x < sizeof(colors); x++)
	{
		Format(buffer, sizeof(buffer), "%t:", colors[x]);
		counter = 0;
		for(int i = 1; i <= MaxClients; i++)
		{
			if(m_nSurvivalTeam[i] != x) continue;
			Format(buffer, sizeof(buffer), "%s (%N)", buffer, i);
			counter++;
		}
		for(; counter < team_count; counter++) Format(buffer, sizeof(buffer), "%s ( )", buffer);
		menu.AddItem("", buffer);
	}
	menu.Display(client, 0);
}

public int handler(Menu menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_End) delete menu;
    if(action == MenuAction_Select)
    {
			FakeClientCommand(param1, "dz_jointeam %i", param2+1);
			JoinTeam(param1, 0);
    }
}  