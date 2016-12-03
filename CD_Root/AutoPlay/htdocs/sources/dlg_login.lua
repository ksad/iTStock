function login ()
	local userName = Input.GetText("IN_USERNAME_LF");
	local password = Input.GetText("IN_PASSWORD_LF");

	if userName == "" or userName == Trans("user.input.username", "users") then
		Image.Load("IMG_USERNAME_LF", "AutoPlay\\htdocs\\images\\inputs\\input_username_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
	end

	if password == "" or password == Trans("user.input.password", "users") then
		Image.Load("IMG_PASSWORD_LF", "AutoPlay\\htdocs\\images\\inputs\\input_password_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		if Application.LoadValue("ItStock", "FORM_LAST_ERROR") == "" then
			Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
		end
	end

	error = Application.LoadValue("ItStock", "FORM_LAST_ERROR");
	if (error == "Error616") then
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
			showMsgBox ("Error", Trans("login.msgbox.title.connection", "login"), Trans("login.msg.notrecognized", "login", {userName}), "OK");
			DialogEx.SetFocus("IN_USERNAME_LF");
		else
			if dbStatus == '1' then
				if (String.CompareNoCase(userName, dbUsername) == 0 and String.CompareNoCase(Crypto.MD5DigestFromString(password), dbPassword) == 0) then
					CURRENT_USER = dbUsername;
					EXIT = 1;
					mySQLCursor, err = mySQLConnection:execute("UPDATE IT_USERS SET `Last_connection`=now() WHERE Username = '"..dbUsername.."';");
					if err then
						showMsgBox ("Error", Trans("login.msgbox.title.updatelastconnection", "login"), err, "OK");
						Application.ExitScript();
					end
					loginRemember(userName, password);
					File.Run("AutoPlay\\htdocs\\images\\animations\\Loading.exe", "", "", SW_SHOWNORMAL, false);
					Application.Sleep(3000);
					DialogEx.Close(this);
				else
					showMsgBox ("Error", Trans("login.msgbox.title.connection", "login"), Trans("login.msgbox.error.password", "login"), "OK");
					DialogEx.SetFocus("IN_USERNAME_LF");
				end
			else
				showMsgBox ("Notice", "", Trans("login.msgbox.account.disabled", "login", {userName}), "OK");
			end
		end
		dbUsername = nil;
		dbStatus = nil;

		mySQLCursor:close();
		mySQLConnection:close();
	end
end

function loginRemember (username, password)
	local LoadedImage = Image.GetFilename("IMG_CHECKBOX");
	local ImageStatus = String.SplitPath(LoadedImage);
	ImageStatus = ImageStatus.Filename;

	if ImageStatus == "checkbox_on" then
		local credentials = "[USERNAME]="..username.."\r\n".."[PASSWORD]="..password;
		TextFile.WriteFromString("AutoPlay\\htdocs\\sources\\credentials\\cred.txt", credentials, false);
		Crypto.BlowfishEncrypt("AutoPlay\\htdocs\\sources\\credentials\\cred.txt", "AutoPlay\\htdocs\\sources\\credentials\\cred.enc", "credentialSecure");
		File.Delete("AutoPlay\\htdocs\\sources\\credentials\\cred.txt", false, false, false, nil);

		-- Test for error
		error = Application.GetLastError();
		if (error ~= 0) then
			showMsgBox ("Error", Trans("login.crypt.file.access", "login"), error, "OK");
			Application.ExitScript();
		end
	else
		File.Delete("AutoPlay\\htdocs\\sources\\credentials\\cred.enc", false, false, false, nil);
	end
end

function loadCredentials()
	if File.DoesExist("AutoPlay\\htdocs\\sources\\credentials\\cred.enc") then
		Image.Load("IMG_CHECKBOX", "AutoPlay\\htdocs\\images\\icons\\checkbox_on.png");

		Crypto.BlowfishDecrypt("AutoPlay\\htdocs\\sources\\credentials\\cred.enc", "AutoPlay\\htdocs\\sources\\credentials\\~tmp_cred.txt", "credentialSecure");
		local credentials = TextFile.ReadToTable("AutoPlay\\htdocs\\sources\\credentials\\~tmp_cred.txt");
		File.Delete("AutoPlay\\htdocs\\sources\\credentials\\~tmp_cred.txt", false, false, false, nil);

		username = String.TrimLeft(credentials[1], "[USERNAME]=");
		password = String.TrimLeft(credentials[2], "[PASSWORD]=");

		Input.SetText("IN_USERNAME", username);
		Input.SetText("IN_PASSWORD", password);
	else
		Image.Load("IMG_CHECKBOX", "AutoPlay\\htdocs\\images\\icons\\checkbox_off.png");
	end
end