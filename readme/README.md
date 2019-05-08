# CSGO DangerZone Community Plugin
A plugin designed for DangerZone Community Server mode, it has many functions to make server run well with DangerZone.

### Alerts:
This is a beta plugin, if you have any questions, please submit an issue, I can't promise I will solve that problem, but I want to try my best.
You can modify this plugin, but I wish you don't delete and modify this function: `YK_WelcomeMessages()`, thank you!

## Functions:

1. Ready System: At least 6 players are ready, the game will start.
2. Broadcast System: The system will broadcast players status every {interval} seconds.
3. Status Save System: Plugin will auto save players status (Kill, Dead, Win) to mySql Database.
4. Squad Manage System: Now you can only change the team players count to 1 - 3.
5. Health System: You can change the spawn health and max health when the game begin.
6. Admin Panel: You can change game convars and respawn players, also cheats.
7. Death Sounds: You has been slained, You has slained an enemy, An enemy has been slained?
8. I18N System: Now plugin supports Chinese and English.
9. Other repair: When a player died, plugin will auto put him to spectator.

## Commands:

1. !ready：Ready
2. !unready：Unready
3. !start：Force start game (Admin Only)
4. !end：End game (Admin Only)
5. !fend：Force end game (Admin Only)
6. !dzadmin：Admin panel (Admin Only)
7. !respawn: Respawn a player (Admin Only)
8. !give: Give Items (Admin Only)
9. !savecfg: Save server info (Admin Only)

## Cvars：

1. yk_dzEnable : PLEASE DONT USE THIS COMMAND AT THIS TIME !!!
2. yk_dzInterval : Broadcast interval (30s - 3600s)
3. yk_dzTeamCount : Set squad players count (1 man - 3 men)
4. yk_dzSpawnHealth : Set players spawn health after game begin (1hp - 1000hp)
5. yk_dzMaxHealth : Set players max health after game begin (1hp - 1000hp)

## What I want:

1. Rank system
2. Squad Manage System
3. others...

## Problems you need care:

1. DO NOT USE yk_dzEnable COMMAND, IT WILL TRIGGER A EXCEPTION. When you want to disable the plugin, move `yk_dangerzone.smx` to `disable` folder.
2. Server will not auto-save your settings, you need to type `!savecfg` or go to Admin Panel to save them.
3. Other problems? Submit an issue!

## Install:

1. Download and compile `yk_dangerzone.smx`, then move it to `addons/sourcemod/plugins/`.
2. Move `translations` folder to `addons/sourcemod/translations/`.
3. Move `sound` folder to `csgo/sound`.
4. Modify `addons/sourcemod/configs/databases.cfg` and add this:
```
	"csgo"
	{
		"driver"			"mysql"
		"host"				"<localhost>"
		"database"		"<database>"
		"user"				"<user>"
		"pass"				"<pass>"
	}
```
5. DataBase Table Infomation
```
/*
 Navicat Premium Data Transfer

 Target Server Type    : MySQL
 Target Server Version : 80015
 File Encoding         : 65001

 Date: 09/05/2019 00:02:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for dangerzone
-- ----------------------------
DROP TABLE IF EXISTS `dangerzone`;
CREATE TABLE `dangerzone`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `steamid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `kill` int(11) NOT NULL DEFAULT 0,
  `death` int(11) NOT NULL DEFAULT 0,
  `win` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`, `steamid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
```

### Support Me:
1. Paypal: kanade@acgme.cn
2. Alipay: kanade@acgme.cn