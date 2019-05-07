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