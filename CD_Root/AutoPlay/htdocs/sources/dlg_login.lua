function login ()
	local userName = Input.GetText("IN_USERNAME");
	local password = Input.GetText("IN_PASSWORD");

	if userName == "" then
		showMsgBox ("Error", "", "Username can't be empty", "OK");
		DialogEx.SetFocus("IN_USERNAME");
		Application.ExitScript();
	end

	if password == "" then
		showMsgBox ("Error", "", "Password can't be empty", "OK");
		DialogEx.SetFocus("IN_PASSWORD");
		Application.ExitScript();
	end

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		mySQLCursor = mySQLConnection:execute("SELECT * FROM IT_USERS WHERE Username = '"..userName.."';");
		row = mySQLCursor:fetch({},"a")
		while row do
			dbUsername = row.Username;
			dbPassword = row.Password;
			dbStatus = row.Active;
			row = mySQLCursor:fetch(row,"a");
		end

		if not dbUsername then
			showMsgBox ("Error", "", "The username '"..userName.. "' is not recognized.", "OK");
			DialogEx.SetFocus("IN_USERNAME");
		else
			if dbStatus == '1' then
				if (String.CompareNoCase(userName, dbUsername) == 0 and String.CompareNoCase(Crypto.MD5DigestFromString(password), dbPassword) == 0) then
					CURRENT_USER = dbUsername;
					EXIT = 1;
					mySQLCursor, err = mySQLConnection:execute("UPDATE IT_USERS SET `Last_connection`=now() WHERE Username = '"..dbUsername.."';");
					if err then
						showMsgBox ("Error", "Updating Last_connection failed ()", err, "OK");
						Application.ExitScript();
					end
					File.Run("AutoPlay\\htdocs\\images\\animations\\Loading.exe", "", "", SW_SHOWNORMAL, false);
					Application.Sleep(3000);
					DialogEx.Close(this);
				else
					showMsgBox ("Error", "", "Password incorrect.", "OK");
					DialogEx.SetFocus("IN_USERNAME");
				end
			else
				showMsgBox ("Notice", "", "The account '"..dbUsername.. "' is disabled, Please contact your administrator.", "OK");
			end
		end
		dbUsername = nil;
		dbStatus = nil;

		mySQLCursor:close();
		mySQLConnection:close();
	end
end