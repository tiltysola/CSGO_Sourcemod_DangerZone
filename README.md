# CSGO头号特训插件 [English version](https://github.com/Illyasviels/CSGO_Sourcemod_DangerZone/tree/master/readme)
适用于CSGO社区服务器的一个头号特训插件，是一个将准备系统，存活情况播报系统，战绩记录系统，管理员面板等核心功能集结为一体的核心插件。

## 功能列表：

1. 玩家准备系统：只有6名玩家准备以后游戏才会开始，防止配置差的玩家一直无法进入游戏的尴尬局面。
2. 存活情况播报系统：每隔一定时间会对所有人播报当前存活玩家状况。
3. 战绩记录系统：游戏开始后，系统会将玩家的杀敌，死亡，获胜情况自动记录到后台数据库中。
4. 组队控制系统：管理员可手动设置队伍人数上限（1-3），游戏开始后，玩家会进行随机组队。
5. 血量控制系统：管理员可手动设置玩家初始血量，血量上限，适应服务器节奏。
6. 管理员面板：管理员可一键设置支持的参数，并且可以重生玩家，制造道具。
7. 死亡音效：当玩家死亡时，会对击杀者，受害者，其他玩家播放不同的击杀音效，更有代入感。
8. 多语言支持：已经支持了中文和英文，其他语言可自行进行翻译。
9. 其他问题修复：当玩家死亡后，系统会自动将其移入观察者，防止出现无法观战的情况。

## 命令列表：

1. !ready：准备
2. !unready：取消准备
3. !start：强制开始游戏（管理员指令）
4. !end：结束游戏（管理员指令）
5. !fend：强制结束游戏（管理员指令）
6. !dzadmin：管理员面板（管理员指令）
7. !respawn: 重生玩家（管理员指令）
8. !give: 给予道具（管理员指令）
9. !savecfg: 保存当前服务器参数（管理员指令）

## Cvar指令：

1. yk_dzEnable : 是否启用插件（无效）
2. yk_dzInterval : 播报时间间隔（30秒-3600秒）
3. yk_dzTeamCount : 设置小队人数上限（1名-3名）
4. yk_dzSpawnHealth : 设置游戏开始后玩家初始血量(1hp-1000hp)
5. yk_dzMaxHealth : 设置游戏开始后玩家血量上限(1hp-1000hp)

## 待添加的功能：

1. 排行榜系统
2. 小队控制系统
3. 等待添加...

## 需要注意的问题：

1. 请不要使用或修改 yk_dzEnable 指令，因为他会导致异常，如果需要禁用插件，只需将 yk_dangerzone.smx 移入 disable 文件夹中即可。
2. 修改完服务器参数后并不会自动保存，您需要输入 !savecfg 或进入管理员面板进行保存。
3. 其他问题请提交 issue 。

## 安装说明：

1. 下载并编译插件，将编译后的插件移入插件文件夹 `plugins`。
2. 将 `sound` 文件夹复制到服务器 `csgo/sound` 文件夹内。
3. 将 `translations` 文件夹移入插件文件夹 `translations`
4. 打开插件文件夹 `configs/databases.cfg` 加入如下信息：
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
5. 数据表信息
```
/*
 Navicat Premium Data Transfer

 Source Server         : ezcsgo.cn
 Source Server Type    : MySQL
 Source Server Version : 80015
 Source Host           : ezcsgo.cn:3306
 Source Schema         : csgostore

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