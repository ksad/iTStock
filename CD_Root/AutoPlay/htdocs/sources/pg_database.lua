function checkSQLServerStatus()
	local checkSQLServer = Service.Query("mysql57", "mysql57");

	Label.SetVisible("LB_SERVER_STATUS", true);
	if checkSQLServer == 4 then
		Label.SetText("LB_SERVER_STATUS", "Server is running");
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ok.png");
	elseif checkSQLServer == 0 then
		Label.SetText("LB_SERVER_STATUS", "Server not found");
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
	elseif checkSQLServer == 1 then
		Label.SetText("LB_SERVER_STATUS", "Server stopped");
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
	end
	
	return checkSQLServer;
end

function loadDbAccess ()
	Crypto.BlowfishDecrypt("AutoPlay\\htdocs\\database\\db_access.enc", "AutoPlay\\htdocs\\database\\~tmp_db_access.txt", "securestockitwiththispassword");
	local db_access = TextFile.ReadToTable("AutoPlay\\htdocs\\database\\~tmp_db_access.txt");
	File.Delete("AutoPlay\\htdocs\\database\\~tmp_db_access.txt", false, false, false, nil);

	Input.SetText("IN_DB_NAME_DBCF", String.TrimLeft(db_access[1], "[DB_NAME]="));
	Input.SetText("IN_DB_USERNAME_DBCF", String.TrimLeft(db_access[2], "[USER]="));
	Input.SetText("IN_DB_PASSWORD_DBCF", String.TrimLeft(db_access[3], "[PASSWORD]="));
	Input.SetText("IN_DB_ADDRESS_DBCF", String.TrimLeft(db_access[4], "[ADDRESS]="));
	Input.SetText("IN_DB_PORT_DBCF", String.TrimLeft(db_access[5], "[PORT]="));
end

function setDbConfigForm (currentObject, mode)
	if mode == "Dialog" then
		objectList = DialogEx.EnumerateObjects();
	else
		objectList = Page.EnumerateObjects();
	end

	for i, object in pairs(objectList) do
		if mode == "Dialog" then
			objectType = DialogEx.GetObjectType(object);
		else
			objectType = Page.GetObjectType(object);
		end
		if object == currentObject then
			local objectText = Input.GetText(object);
			if objectText == "Database" or objectText == "Username" or objectText == "Password" or objectText == "Port" or objectText == "Address" then
				Input.SetText(currentObject, "");
			else
				Input.SetSelection(currentObject, 1, -1);
			end
			Image.Load(String.Replace(currentObject, "IN", "IMG", false), "AutoPlay\\htdocs\\images\\inputs\\input_selected.png");
		else
			if objectType == 3 and String.Find(object, "DBCF", 1, false) ~= -1 then
				Image.Load(object, "AutoPlay\\htdocs\\images\\inputs\\input.png");
			end

			if objectType == 7 and Input.GetText(object) == "" then
				if String.Find(object, "DB_NAME", 1, false) ~= -1 then
					Input.SetText(object, "Database");
				elseif String.Find(object, "USERNAME", 1, false) ~= -1 then
					Input.SetText(object, "Username");
				elseif String.Find(object, "PASSWORD", 1, false) ~= -1 then
					Input.SetText(object, "Password");
				elseif String.Find(object, "PORT", 1, false) ~= -1 then
					Input.SetText(object, "Port");
				elseif String.Find(object, "ADDRESS", 1, false) ~= -1 then
					Input.SetText(object, "Address");
				else
					Input.SetText(object, "...");
				end
			end
		end
	end
end

function saveDatabaseConfiguration ()

	local databaseName = Input.GetText("IN_DB_NAME_DBCF");
	local userName = Input.GetText("IN_DB_USERNAME_DBCF");
	local password = Input.GetText("IN_DB_PASSWORD_DBCF");
	local serverAddress = Input.GetText("IN_DB_ADDRESS_DBCF");
	local port = Input.GetText("IN_DB_PORT_DBCF");

	if databaseName == "" or databaseName == "Database" then
		Image.Load("IMG_DB_NAME_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SetLastError(0616);
	end

	if userName == "" or userName == "Username" then
		Image.Load("IMG_DB_USERNAME_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SetLastError(0616);
	end

	if password == "" or password == "Password" then
		Image.Load("IMG_DB_PASSWORD_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SetLastError(0616);
	end

	if serverAddress == "" or serverAddress == "Address" then
		Image.Load("IMG_DB_ADDRESS_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SetLastError(0616);
	end

	if port == "" or port == "Port" then
		Image.Load("IMG_DB_PORT_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SetLastError(0616);
	else
		local portIsValid = String.ToNumber(port);
		if portIsValid == 0 then
			Dialog.Message("Error", "Invalid port number.", MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
			Image.Load("IMG_DB_PORT_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
			Application.ExitScript();
		end
	end

	error = Application.GetLastError();
	if (error == 0616) then
		Application.ExitScript();
	end

	Image.SetVisible("IMG_DB_NAME_DBCF", false);
	Image.SetVisible("IMG_DB_USERNAME_DBCF", false);
	Image.SetVisible("IMG_DB_PASSWORD_DBCF", false);
	Image.SetVisible("IMG_DB_ADDRESS_DBCF", false);
	Image.SetVisible("IMG_DB_PORT_DBCF", false);
	Image.SetVisible("IMG_SAVE_CONFIG_SERVER", false);
	Input.SetVisible("IN_DB_NAME_DBCF", false);
	Input.SetVisible("IN_DB_USERNAME_DBCF", false);
	Input.SetVisible("IN_DB_PASSWORD_DBCF", false);
	Input.SetVisible("IN_DB_ADDRESS_DBCF", false);
	Input.SetVisible("IN_DB_PORT_DBCF", false);
	Label.SetVisible("LB_CHECK_DB_CONNECTION", true);
	Image.SetVisible("IMG_CHECK_DB_CONNECT", true);

	Application.Sleep(3000);

	MySQLConnection, err = MySQL:connect(databaseName, userName, password, serverAddress, port);

	Image.SetVisible("IMG_DB_NAME_DBCF", true);
	Image.SetVisible("IMG_DB_USERNAME_DBCF", true);
	Image.SetVisible("IMG_DB_PASSWORD_DBCF", true);
	Image.SetVisible("IMG_DB_ADDRESS_DBCF", true);
	Image.SetVisible("IMG_DB_PORT_DBCF", true);
	Image.SetVisible("IMG_SAVE_CONFIG_SERVER", true);
	Input.SetVisible("IN_DB_NAME_DBCF", true);
	Input.SetVisible("IN_DB_USERNAME_DBCF", true);
	Input.SetVisible("IN_DB_PASSWORD_DBCF", true);
	Input.SetVisible("IN_DB_ADDRESS_DBCF", true);
	Input.SetVisible("IN_DB_PORT_DBCF", true);
	Label.SetVisible("LB_CHECK_DB_CONNECTION", false);
	Image.SetVisible("IMG_CHECK_DB_CONNECT", false);

	if err then
		-- If there is an error connecting to the database, display a dialog box with the error
		Dialog.Message("Error coonection", err, MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
		Application.ExitScript();
	end

	local db_access = "[DB_NAME]="..databaseName.."\r\n".."[USER]="..userName.."\r\n".."[PASSWORD]="..password.."\r\n".."[ADDRESS]="..serverAddress.."\r\n".."[PORT]="..port;
	TextFile.WriteFromString("AutoPlay\\htdocs\\database\\db_access.txt", db_access, false);
	Crypto.BlowfishEncrypt("AutoPlay\\htdocs\\database\\db_access.txt", "AutoPlay\\htdocs\\database\\db_access.enc", "securestockitwiththispassword");
	File.Delete("AutoPlay\\htdocs\\database\\db_access.txt", false, false, false, nil);

	-- Test for error
	error = Application.GetLastError();
	if (error ~= 0) then
		PopUp("0");
		Application.ExitScript();
	else
		PopUp("1");
		DialogEx.Close(this);
	end
end