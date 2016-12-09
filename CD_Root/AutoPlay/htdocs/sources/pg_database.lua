function checkSQLServerStatus(dbName, dbUser, dbPassword, dbAddress, dbPort)
	if not dbName or not dbUser or not dbPassword or not dbPort or not dbAddress then
		Crypto.BlowfishDecrypt("AutoPlay\\htdocs\\database\\db_access.enc", "AutoPlay\\htdocs\\database\\~tmp_db_access.txt", "securestockitwiththispassword");
		local db_access = TextFile.ReadToTable("AutoPlay\\htdocs\\database\\~tmp_db_access.txt");
		File.Delete("AutoPlay\\htdocs\\database\\~tmp_db_access.txt", false, false, false, nil);

		dbName = String.TrimLeft(db_access[1], "[DB_NAME]=");
		dbUser = String.TrimLeft(db_access[2], "[USER]=");
		dbPassword = String.TrimLeft(db_access[3], "[PASSWORD]=");
		dbAddress = String.TrimLeft(db_access[4], "[ADDRESS]=");
		dbPort = String.TrimLeft(db_access[5], "[PORT]=");
	end

	if dbAddress == "localhost" or dbAddress == "127.0.0.1" then
		sqlServerStatus = Service.Query("mysql57", "mysql57");

		if sqlServerStatus == 0 then
			serverStatusMsg = Trans("sql.server.status0", "database");
		elseif sqlServerStatus == 1 then
			serverStatusMsg = Trans("sql.server.status1", "database");
		elseif sqlServerStatus == 2 then
			serverStatusMsg = Trans("sql.server.status2", "database");
		elseif sqlServerStatus == 3 then
			serverStatusMsg = Trans("sql.server.status3", "database");
		elseif sqlServerStatus == 4 then
			MySQLConnection, err = MySQL:connect(dbName, dbUser, dbPassword, dbAddress, dbPort);
			serverStatusMsg = Trans("sql.server.status4", "database");
		elseif sqlServerStatus == 5 then
			serverStatusMsg = Trans("sql.server.status5", "database");
		elseif sqlServerStatus == 6 then
			serverStatusMsg = Trans("sql.server.status6", "database");
		elseif sqlServerStatus == 7 then
			serverStatusMsg = Trans("sql.server.status7", "database");
		elseif sqlServerStatus == -1 then
			serverStatusMsg = Trans("sql.server.status#", "database");
		end
	else
		MySQLConnection, err = MySQL:connect(dbName, dbUser, dbPassword, dbAddress, dbPort);
		if err then
			sqlServerStatus = 8;
			serverStatusMsg = err;
		else
			sqlServerStatus = 4;
			serverStatusMsg = Trans("sql.server.status4", "database");
		end
	end

	return "["..sqlServerStatus.."]"..serverStatusMsg;
end

function loadDbAccess ()
	Crypto.BlowfishDecrypt("AutoPlay\\htdocs\\database\\db_access.enc", "AutoPlay\\htdocs\\database\\~tmp_db_access.txt", "securestockitwiththispassword");
	local db_access = TextFile.ReadToTable("AutoPlay\\htdocs\\database\\~tmp_db_access.txt");
	File.Delete("AutoPlay\\htdocs\\database\\~tmp_db_access.txt", false, false, false, nil);

	dbName = String.TrimLeft(db_access[1], "[DB_NAME]=");
	dbUser = String.TrimLeft(db_access[2], "[USER]=");
	dbPassword = String.TrimLeft(db_access[3], "[PASSWORD]=");
	dbAddress = String.TrimLeft(db_access[4], "[ADDRESS]=");
	dbPort = String.TrimLeft(db_access[5], "[PORT]=");

	Input.SetText("IN_DB_NAME_DBCF", dbName);
	Input.SetText("IN_DB_USERNAME_DBCF", dbUser);
	Input.SetText("IN_DB_PASSWORD_DBCF", dbPassword);
	Input.SetText("IN_DB_ADDRESS_DBCF", dbAddress);
	Input.SetText("IN_DB_PORT_DBCF", dbPort);

	local serverStatus = checkSQLServerStatus(databaseName, userName, password, serverAddress, port);
	local serverStatusMsg = String.Mid(serverStatus, 4, -1);

	Paragraph.SetVisible("PH_SERVER_STATUS", true);
	Image.SetVisible("IMG_SERVER", true);

	if String.Left(serverStatus , 3) == "[8]" then
		Paragraph.SetText("PH_SERVER_STATUS", "MySQL Server error @"..dbAddress);
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
		showMsgBox ("Error", "SQL server error", "There is a problem with the SQL Server : @"..dbAddress.."\r\n"..serverStatusMsg, "OK");
		Application.ExitScript();
	end

	if String.Left(serverStatus , 3) ~= "[4]" then
		Paragraph.SetText("PH_SERVER_STATUS", "MySQL Server "..serverStatusMsg.." @ "..serverAddress);
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
		Application.ExitScript();
	else
		Paragraph.SetText("PH_SERVER_STATUS", "MySQL Server "..serverStatusMsg.." @ "..serverAddress);
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ok.png");
	end
end

function setDbConfigFormDialog (currentObject)
	objectList = DialogEx.EnumerateObjects();
	
	for i, object in pairs(objectList) do
		objectType = DialogEx.GetObjectType(object);

		if object == currentObject then
			local objectText = Input.GetText(object);
			if objectText == Trans("db.input.dbname", "database")
				or objectText == Trans("db.input.username", "database")
				or objectText == Trans("db.input.password", "database")
				or objectText == Trans("db.input.port", "database")
				or objectText == Trans("db.input.host", "database") then
				Input.SetText(currentObject, "");
			else
				Input.SetSelection(currentObject, 1, -1);
			end
			Image.Load(String.Replace(currentObject, "IN", "IMG", false), "AutoPlay\\htdocs\\images\\inputs\\input_selected.png");
		else
			if objectType == 3 and String.Find(object, "DBCF", 1, false) ~= -1 then
				Image.Load(object, "AutoPlay\\htdocs\\images\\inputs\\input.png");
				Label.SetVisible("LB_MANDATORY_FIELDS", false);
			end

			if objectType == 7 and Input.GetText(object) == "" then
				if String.Find(object, "DB_NAME", 1, false) ~= -1 then
					Input.SetText(object, Trans("db.input.dbname", "database"));
				elseif String.Find(object, "USERNAME", 1, false) ~= -1 then
					Input.SetText(object, Trans("db.input.username", "database"));
				elseif String.Find(object, "PASSWORD", 1, false) ~= -1 then
					Input.SetText(object, Trans("db.input.password", "database"));
				elseif String.Find(object, "PORT", 1, false) ~= -1 then
					Input.SetText(object, Trans("db.input.port", "database"));
				elseif String.Find(object, "ADDRESS", 1, false) ~= -1 then
					Input.SetText(object, Trans("db.input.host", "database"));
				else
					Input.SetText(object, "...");
				end
			end
		end
	end
end

function setDbConfigFormPage (currentObject)
	objectList = Page.EnumerateObjects();
	
	for i, object in pairs(objectList) do
		objectType = Page.GetObjectType(object);

		if object == currentObject then
			local objectText = Input.GetText(object);
			if objectText ~= "" then
				Input.SetSelection(currentObject, 1, -1);
			end
			Image.Load(String.Replace(currentObject, "IN", "IMG", false), "AutoPlay\\htdocs\\images\\inputs\\input_selected.png");
		else
			if objectType == 3 and String.Find(object, "DBCF", 1, false) ~= -1 then
				Image.Load(object, "AutoPlay\\htdocs\\images\\inputs\\input.png");
				Label.SetVisible("LB_MANDATORY_FIELDS", false);
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

	if databaseName == "" or databaseName == Trans("db.input.dbname", "database") then
		Image.Load("IMG_DB_NAME_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
	end

	if userName == "" or userName == Trans("db.input.username", "database") then
		Image.Load("IMG_DB_USERNAME_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		if Application.LoadValue("ItStock", "FORM_LAST_ERROR") == "" then
			Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
		end
	end

	if password == "" or password == Trans("db.input.password", "database") then
		Image.Load("IMG_DB_PASSWORD_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		if Application.LoadValue("ItStock", "FORM_LAST_ERROR") == "" then
			Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
		end
	end

	if port == "" or port == Trans("db.input.port", "database") then
		Image.Load("IMG_DB_PORT_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		local portIsValid = String.ToNumber(port);
		if portIsValid == 0 then
			showMsgBox ("Error", "", Trans("db.check.port", "database"), "OK");
			Image.Load("IMG_DB_PORT_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
			if Application.LoadValue("ItStock", "FORM_LAST_ERROR") == "" then
				Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
			end
		end
	end

	if serverAddress == "" or serverAddress == Trans("db.input.host", "database") then
		Image.Load("IMG_DB_ADDRESS_DBCF", "AutoPlay\\htdocs\\images\\inputs\\input_mandatory.png");
		Application.SaveValue("ItStock", "FORM_LAST_ERROR", "Error616");
	else
		if Application.LoadValue("ItStock", "FORM_LAST_ERROR") == "" then
			Application.SaveValue("ItStock", "FORM_LAST_ERROR", "");
		end
	end

	error = Application.LoadValue("ItStock", "FORM_LAST_ERROR");
	if (error == "Error616") then
		Label.SetVisible("LB_MANDATORY_FIELDS", true);
		Application.ExitScript();
	end

	local serverStatus = checkSQLServerStatus(databaseName, userName, password, serverAddress, port);
	local serverStatusMsg = String.Mid(serverStatus, 4, -1);

	Paragraph.SetVisible("PH_SERVER_STATUS", true);
	Image.SetVisible("IMG_SERVER", true);

	if String.Left(serverStatus , 3) == "[8]" then
		Paragraph.SetText("PH_SERVER_STATUS", Trans("sql.server.config.status", "database", {serverAddress}));
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
		showMsgBox ("Error", Trans("sql.server.error.msg", "database"), "There is a problem with the SQL Server : @"..serverAddress.."\r\n"..serverStatusMsg, "OK");
		Application.ExitScript();
	end

	if String.Left(serverStatus , 3) ~= "[4]" then
		Paragraph.SetText("PH_SERVER_STATUS", Trans("sql.server.status.msg", "database", {serverStatusMsg,serverAddress}));
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ko.png");
		Application.ExitScript();
	else
		Paragraph.SetText("PH_SERVER_STATUS", Trans("sql.server.status.msg", "database", {serverStatusMsg,serverAddress}));
		Image.Load("IMG_SERVER_STATUS", "AutoPlay\\htdocs\\images\\icons\\server_ok.png");
	end

	Image.SetVisible("IMG_DB_NAME_DBCF", false);
	Image.SetVisible("IMG_DB_USERNAME_DBCF", false);
	Image.SetVisible("IMG_DB_PASSWORD_DBCF", false);
	Image.SetVisible("IMG_DB_ADDRESS_DBCF", false);
	Image.SetVisible("IMG_DB_PORT_DBCF", false);
	Button.SetVisible("BTN_SAVE_DB_CONFIG", false);
	Button.SetVisible("BTN_CANCEL", false);
	
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
	Button.SetVisible("BTN_SAVE_DB_CONFIG", true);
	Button.SetVisible("BTN_CANCEL", true);
	Input.SetVisible("IN_DB_NAME_DBCF", true);
	Input.SetVisible("IN_DB_USERNAME_DBCF", true);
	Input.SetVisible("IN_DB_PASSWORD_DBCF", true);
	Input.SetVisible("IN_DB_ADDRESS_DBCF", true);
	Input.SetVisible("IN_DB_PORT_DBCF", true);
	Label.SetVisible("LB_CHECK_DB_CONNECTION", false);
	Image.SetVisible("IMG_CHECK_DB_CONNECT", false);

	if err then
		-- If there is an error connecting to the database, display a dialog box with the error
		showMsgBox ("Error", Trans("db.connection.error", "database"), err, "OK");
		Application.ExitScript();
	end

	local db_access = "[DB_NAME]="..databaseName.."\r\n".."[USER]="..userName.."\r\n".."[PASSWORD]="..password.."\r\n".."[ADDRESS]="..serverAddress.."\r\n".."[PORT]="..port;
	TextFile.WriteFromString("AutoPlay\\htdocs\\database\\db_access.txt", db_access, false);
	Crypto.BlowfishEncrypt("AutoPlay\\htdocs\\database\\db_access.txt", "AutoPlay\\htdocs\\database\\db_access.enc", "securestockitwiththispassword");
	File.Delete("AutoPlay\\htdocs\\database\\db_access.txt", false, false, false, nil);

	-- Test for error
	error = Application.GetLastError();
	if (error ~= 0) then
		showMsgBox ("Error", Trans("db.crypt.file.access", "database"), error, "OK");
		Application.ExitScript();
	else
		showMsgBox ("Success", "", Trans("db.config.saved", "database"), "OK");
		DialogEx.Close(this);
	end
end