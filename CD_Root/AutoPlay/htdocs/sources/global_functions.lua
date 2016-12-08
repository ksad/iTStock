PROJEJCT_PAGE_WIDTH = 1366;
PROJECT_PAGE_HEIGHT = 768;
MENU_TREE_INDEXS = {Home="1", Settings="2", Users= "2.1", NONE=""}
SAVE_XML = false;
PAGE_LIMIT_RATIO = 2;

function dbConnect ()
	require("AutoPlay\\htdocs\\sources\\pg_database");
	if File.DoesExist("AutoPlay\\htdocs\\database\\db_access.enc") then
		local serverStatus = checkSQLServerStatus();

		if String.Left(serverStatus , 3) ~= "[4]" then
			errorMsg = String.Mid(serverStatus, 4, -1);
			local userAction = showMsgBox ("Warning", Trans("db.config.dialog.title", "database"), Trans("db.error.msg.config", "database", {errorMsg}), Trans("common.yes", "common").."|"..Trans("common.no", "common"));
			if userAction == "ID"..Trans("common.yes", "common") then
				local userAction = DialogEx.Show("DB_CONFIG", true, nil, nil);
				if userAction == 2 then
					Application.ExitScript();
				end
			else
				Application.ExitScript();
			end
		end
	else
		showTimedMsgBox ("Error", Trans("db.error.first.config", "database"), "5000");
		local userAction = DialogEx.Show("DB_CONFIG", true, nil, nil);
		if userAction == 2 then
			Application.ExitScript();
		end
	end

	return MySQLConnection
end

function loadDefaultLanguage ()
	local lang = Application.LoadValue("ITStock", "LANG");
	if lang == "fr_FR" then
		RadioButton.SetChecked("RD_FR", true);
		Image.Load("IMG_FLAG", "AutoPlay\\htdocs\\images\\icons\\fr_FR.png");
	else
		RadioButton.SetChecked("RD_UK", true);
		Image.Load("IMG_FLAG", "AutoPlay\\htdocs\\images\\icons\\en_UK.png");
	end
end

function loadProfilInfos ()
	if String.Length(CURRENT_USER) > 20 then
		CURRENT_USER = String.Left(CURRENT_USER, 20).."...";
	end

	if String.Length(CURRENT_USER_ROLE) > 20 then
		CURRENT_USER_ROLE = String.Left(CURRENT_USER_ROLE, 20).."...";
	end

	Label.SetText("LB_FULLNAME", CURRENT_USER);
	Label.SetText("LB_ROLE", CURRENT_USER_ROLE);

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		mySQLCursor, err = mySQLConnection:execute("SELECT Profil_Pict FROM IT_USERS WHERE Username = '"..CURRENT_USERNAME.."';");
		if err then
			showMsgBox ("Error", "", Trans("common.update.pict.error", "common"), "OK");
			-- WRITE LOG (err)
			Application.ExitScript();
		end
		row = mySQLCursor:fetch({},"a")
		while row do
			dbProfilPict = row.Profil_Pict;
			row = mySQLCursor:fetch(row,"a");
		end
	end

	Image.Load("IMG_USER_PROFIL_PICT", "AutoPlay\\htdocs\\images\\img_profil\\"..dbProfilPict);
end

function loadPageHeader ()
	Label.SetText("LB_HELLO", Trans("common.welcome.msg", "common", {CURRENT_USER}));
	Label.SetText("LB_IP", "@IP : "..System.GetLANInfo().IP);
	Label.SetText("LB_DATE_TIME", System.GetTime(TIME_FMT_MIL).." "..System.GetDate(DATE_FMT_EUROPE));
	Page.StartTimer(1000, 2);
end

function xmlDataPagesSetup (currentPage)
	if SAVE_XML == true then
		saveXmlData();
		Page.Navigate(PAGE_NEXT);
	else
		if Application.LoadValue("ITStock", "FirstRun") == "Y" then
			Window.Maximize(Application.GetWndHandle());
			setObjectsSizeAndPositions(currentPage);
			Window.Hide(Application.GetWndHandle());
			Page.Navigate(PAGE_NEXT);
		else
			local windowLoadingHandle = Application.LoadValue("Loading", "windowHandle");
			Window.Close(windowLoadingHandle, CLOSEWND_TERMINATE);
			Window.Maximize(Application.GetWndHandle());
		end
	end
end

function xmlDataPagesLoad (currentPage)
	if SAVE_XML == true then
		saveXmlData();
		Page.Navigate(PAGE_NEXT);
	else
		if Application.LoadValue("ITStock", "FirstRun") == "Y" then
			setObjectsSizeAndPositions(currentPage);
			local allPages = Application.GetPages();
			local nCount = Table.Count(allPages);
			if allPages[nCount] == currentPage then
				Application.SaveValue("ITStock", "FirstRun", "N");
				Page.Navigate(PAGE_FIRST);
			else
				Page.Navigate(PAGE_NEXT);
			end
		end
	end
end

function leftMenuReset ()
	local objectList = Page.EnumerateObjects();

	for i, object in pairs(objectList) do
		objectType = Page.GetObjectType(object);
		if objectType == 3 and String.Find(object, "IMG_MENU", 1, false) ~= -1 then
			local path = String.SplitPath(Image.GetFilename(object));
			if path.Filename ~= "bg_menu_item_active" then
				Image.Load(object, "AutoPlay\\htdocs\\images\\backgrounds\\bg_menu_item.png");
			end
		end
	end
end

function setObjectsSizeAndPositions (pageName)
	PAGEWIDTH = Page.GetSize().Width;
	PAGEHEIGHT = Page.GetSize().Height;

	XML.Load("AutoPlay\\htdocs\\xml data\\pages_config\\xml_data_"..pageName..".xml");

	error = Application.GetLastError();
	if (error ~= XML.OK) then
	    showMsgBox ("Error", "XML Loading", _tblErrorMessages[error], "OK");
	end

	allObjects = Page.EnumerateObjects();

	for i, object in pairs(allObjects) do
		local objectType = Page.GetObjectType(object);
		perWidth = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perWidth"));
		perHeight = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perHeight"));
		NewWidth = (perWidth*PAGEWIDTH)/100;
		NewHeight = (perHeight*PAGEHEIGHT)/100;

		perX = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perPosX"));
		perY = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perPosY"));
		NewX = (perX*PAGEWIDTH)/100
		NewY = (perY*PAGEHEIGHT)/100

		if objectType ==0 then
			Button.SetSize(object, NewWidth, NewHeight);
			Button.SetPos(object, NewX, NewY);
		elseif objectType ==1 then
			Label.SetSize(object, NewWidth, NewHeight);
			Label.SetPos(object, NewX, NewY);
		elseif objectType ==2 then
			Paragraph.SetSize(object, NewWidth, NewHeight);
			Paragraph.SetPos(object, NewX, NewY);
		elseif objectType ==3 then
			Image.SetSize(object, NewWidth, NewHeight);
			Image.SetPos(object, NewX, NewY);
		elseif objectType ==4 then
			Flash.SetSize(object, NewWidth, NewHeight);
			Flash.SetPos(object, NewX, NewY);
		elseif objectType ==5 then
			Video.SetSize(object, NewWidth, NewHeight);
			Video.SetPos(object, NewX, NewY);
		elseif objectType ==6 then
			Web.SetSize(object, NewWidth, NewHeight);
			Web.SetPos(object, NewX, NewY);
		elseif objectType ==7 then
			perFont = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perFontSize"));
			newFontSize = (perFont*PAGEWIDTH)/100;
			tblInputProps = {};
			tblInputProps.FontSize = Math.Round(newFontSize, 0);
			tblInputProps.Height = NewHeight;
			tblInputProps.Width = NewWidth;
			tblInputProps.X = NewX;
			tblInputProps.Y = NewY;
			Input.SetProperties(object, tblInputProps);
		elseif objectType ==8 then
			Hotspot.SetSize(object, NewWidth, NewHeight);
			Hotspot.SetPos(object, NewX, NewY);
		elseif objectType ==9 then
			perFont = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perFontSize"));
			newFontSize = (perFont*PAGEWIDTH)/100;
			tblListBoxProps = {};
			tblListBoxProps.FontSize = Math.Round(newFontSize, 0);
			tblListBoxProps.Height = NewHeight;
			tblListBoxProps.Width = NewWidth;
			tblListBoxProps.X = NewX;
			tblListBoxProps.Y = NewY;
			ListBox.SetProperties(object, tblListBoxProps);
		elseif objectType ==10 then
			ComboBox.SetSize(object, NewWidth, NewHeight);
			ComboBox.SetPos(object, NewX, NewY);
		elseif objectType ==11 then
			Progress.SetSize(object, NewWidth, NewHeight);
			Progress.SetPos(object, NewX, NewY);
		elseif objectType ==12 then
			Tree.SetSize(object, NewWidth, NewHeight);
			Tree.SetPos(object, NewX, NewY);
		elseif objectType ==13 then
			RadioButton.SetSize(object, NewWidth, NewHeight);
			RadioButton.SetPos(object, NewX, NewY);
		elseif objectType ==14 then
			RichText.SetSize(object, NewWidth, NewHeight);
			RichText.SetPos(object, NewX, NewY);
		elseif objectType ==15 then
			perFont = String.ToNumber(XML.GetValue("ROOT/PAGE/"..object.."/perFontSize"));
			newFontSize = (perFont*PAGEWIDTH)/100;
			tblCheckBoxProps = {};
			tblCheckBoxProps.FontSize = Math.Round(newFontSize, 0);
			tblCheckBoxProps.Height = NewHeight;
			tblCheckBoxProps.Width = NewWidth;
			tblCheckBoxProps.X = NewX;
			tblCheckBoxProps.Y = NewY;
			CheckBox.SetProperties(object, tblCheckBoxProps);
		elseif objectType ==16 then
			SlideShow.SetSize(object, NewWidth, NewHeight);
			SlideShow.SetPos(object, NewX, NewY);
		elseif objectType ==17 then
			Grid.SetSize(object, NewWidth, NewHeight);
			Grid.SetPos(object, NewX, NewY);
		elseif objectType ==18 then
			PDF.SetSize(object, NewWidth, NewHeight);
			PDF.SetPos(object, NewX, NewY);
		elseif objectType ==19 then
			QuickTime.SetSize(object, NewWidth, NewHeight);
			QuickTime.SetPos(object, NewX, NewY);
		elseif objectType ==20 then
				xButton.SetSize(object, NewWidth, NewHeight);
				xButton.SetPos(object, NewX, NewY);
		elseif objectType ==40 then
			Plugin.SetSize(object, NewWidth, NewHeight);
			Plugin.SetPos(object, NewX, NewY);
		else
			showMsgBox ("Error", "", object.." : Object undifined", "OK");
		end
	end
end

function saveXmlData()
	xml = '';

	xml = xml..'<ROOT>\r\n';
	xml = xml..'\t<PAGE Name = "'..Application.GetCurrentPage()..'">\r\n';

	allObjects = Page.EnumerateObjects();

	for i,object in pairs (allObjects) do
		local objectType = Page.GetObjectType(object);
		xmlFont = "";
		if object ~= "BTN_SAVE_XML" then
			if objectType ==0 and String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Button.GetProperties(object);
			elseif objectType ==1  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Label.GetProperties(object);
				perFont = (objProp.FontSize*100)/PROJEJCT_PAGE_WIDTH;
				xmlFont = '\t\t\t<perFontSize>'..perFont..'</perFontSize>\r\n';
			elseif objectType ==2  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Paragraph.GetProperties(object);
			elseif objectType ==3  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Image.GetProperties(object);
			elseif objectType ==4  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Flash.GetProperties(object);
			elseif objectType ==5  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Video.GetProperties(object);
			elseif objectType ==6  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Web.GetProperties(object);
			elseif objectType ==7  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Input.GetProperties(object);
				perFont = (objProp.FontSize*100)/PROJEJCT_PAGE_WIDTH;
				xmlFont = '\t\t\t<perFontSize>'..perFont..'</perFontSize>\r\n';
			elseif objectType ==8  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Hotspot.GetProperties(object);
			elseif objectType ==9  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = ListBox.GetProperties(object);
				perFont = (objProp.FontSize*100)/PROJEJCT_PAGE_WIDTH;
				xmlFont = '\t\t\t<perFontSize>'..perFont..'</perFontSize>\r\n';
			elseif objectType ==10  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = ComboBox.GetProperties(object);
				perFont = (objProp.FontSize*100)/PROJEJCT_PAGE_WIDTH;
				xmlFont = '\t\t\t<perFontSize>'..perFont..'</perFontSize>\r\n';
			elseif objectType ==11  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Progress.GetProperties(object);
			elseif objectType ==12  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Tree.GetProperties(object);
			elseif objectType ==13  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = RadioButton.GetProperties(object);
			elseif objectType ==14  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = RichText.GetProperties(object);
			elseif objectType ==15  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = CheckBox.GetProperties(object);
				perFont = (objProp.FontSize*100)/PROJEJCT_PAGE_WIDTH;
				xmlFont = '\t\t\t<perFontSize>'..perFont..'</perFontSize>\r\n';
			elseif objectType ==16  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = SlideShow.GetProperties(object);
			elseif objectType ==17  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Grid.GetProperties(object);
			elseif objectType ==18  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = PDF.GetProperties(object);
			elseif objectType ==19  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = QuickTime.GetProperties(object);
			elseif objectType ==20  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = xButton.GetProperties(object);
			elseif objectType ==40  and  String.Find(object, "IGNORED", 1, false) == -1 then
				objProp = Plugin.GetProperties(object);
			else
				showMsgBox ("Error", "", object.." : Object undifined", "OK");
			end

			xml = xml..'\t\t<'..object..' Width = "'..objProp.Width..'" Height = "'..objProp.Height..'" PosX = "'..objProp.X..'" PosY = "'..objProp.Y..'">\r\n';

			perWidth = (objProp.Width*100)/PROJEJCT_PAGE_WIDTH;
			perHeight = (objProp.Height*100)/PROJECT_PAGE_HEIGHT;

			perX = (objProp.X*100)/PROJEJCT_PAGE_WIDTH;
			perY = (objProp.Y*100)/PROJECT_PAGE_HEIGHT;

			xml = xml..'\t\t\t<perWidth>'..perWidth..'</perWidth>\r\n';
			xml = xml..'\t\t\t<perHeight>'..perHeight..'</perHeight>\r\n';
			xml = xml..'\t\t\t<perPosX>'..perX..'</perPosX>\r\n';
			xml = xml..'\t\t\t<perPosY>'..perY..'</perPosY>\r\n';
			if xmlFont ~= nil then
				xml = xml..xmlFont;
			end
			xml = xml..'\t\t</'..object..'>\r\n';
		end
	end

	xml = xml..'\t</PAGE>\r\n';
	xml = xml..'</ROOT>';

	TextFile.WriteFromString("AutoPlay\\htdocs\\xml data\\pages_config\\xml_data_"..Application.GetCurrentPage()..".xml", xml, false);

end

function initList (objectName, tbColumn)
	for i=0, Table.Count(tbColumn)-1 do
		Grid.SetCellText(objectName, 0, i, tbColumn[i+1], true);
	end
end

function resizeList (objectName)
	Grid.AutoSizeColumns(objectName, GVS_BOTH, true);

	local gridHeight = Grid.GetSize(objectName).Height;
	newGridHeight = Grid.GetRowHeight(objectName, 0)*Grid.GetRowCount(objectName);

	if newGridHeight > Page.GetSize().Height - Grid.GetPos(objectName).Y then
		getLimitInPixel = PAGE_LIMIT_RATIO * Page.GetSize().Height / 100;
		margin = 18;

		newGridHeight = Page.GetSize().Height - Grid.GetPos(objectName).Y - getLimitInPixel;
	else
		margin = 3;
		newGridHeight = newGridHeight+20;
	end

	local gridWidth = Grid.GetSize(objectName).Width-margin;
	local nCols = Grid.GetColumnCount(objectName);
	globalColsWidth = 0;
	globalnewColsWidth = 0;
	for i=0, nCols-1 do
		globalColsWidth = globalColsWidth + Grid.GetColumnWidth(objectName, i);
	end

	for i=0, nCols-1 do
		local colRatio = Grid.GetColumnWidth(objectName, i)*100/globalColsWidth;
		local newColWidth = colRatio*gridWidth/100;
		Grid.SetColumnWidth(objectName, i, newColWidth, true);
		globalnewColsWidth = globalnewColsWidth + newColWidth;
	end

	Grid.SetSize(objectName, globalnewColsWidth+margin, newGridHeight);

	Grid.SetListMode(objectName, true);
	Grid.SetSingleRowSelection(objectName, true);
end

function checkGitRepo ()
	local IsConnected = HTTP.TestConnection("www.google.fr", 20, 80, nil, nil);
	if (IsConnected == true) then
		Shell.Execute("AutoPlay\\htdocs\\batchs\\check_repo.bat", "open", "", "AutoPlay\\htdocs\\batchs", SW_HIDE, true);

		local nLocalCommits = String.ToNumber(TextFile.ReadToString("AutoPlay\\htdocs\\batchs\\Temp\\local_rep.tmp"));
		local nRemoteCommits = String.ToNumber(TextFile.ReadToString("AutoPlay\\htdocs\\batchs\\Temp\\remote_rep.tmp"));

		if nLocalCommits < nRemoteCommits then
			showMsgBox ("Notice", "Git repository", "Your repo is not up to date. Please pull the new version\r\n"..nRemoteCommits-nLocalCommits.." new commits", "OK");
			--[[local commitsList = TextFile.ReadToString("AutoPlay\\htdocs\\batchs\\Temp\\commits_diff.tmp");

			if String.Find(commitsList, "[TMP]:", 1, false) == -1 then
				result = DialogEx.Show("CHECK_REPO", true, nil, nil);
			end]]
		end
	end
end

function showMsgBox (title, msgtitle, msg, buttons)
	local checkMsgBoxTemplate = Folder.Find("AutoPlay\\htdocs\\images\\msgbox", title, false, nil);
	if checkMsgBoxTemplate == nil then
		Dialog.Message("Error", '"'..title..'" : template not found.\r\n'..msg, MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
		Application.ExitScript();
	end

	Application.SaveValue("MSGBOX", "title", title);
	if msgtitle then
		Application.SaveValue("MSGBOX", "msgtitle", msgtitle);
	end
	Application.SaveValue("MSGBOX", "msg", msg);
	if buttons == nil then
		Application.SaveValue("MSGBOX", "buttons", "");
	else
		Application.SaveValue("MSGBOX", "buttons", buttons);
	end
	DialogEx.Show("MSGBOX", true, nil, nil);

	return Application.LoadValue("MSGBOX", "PRESSED_KEY");
end

function showTimedMsgBox (title, msg, timer)
	local checkMsgBoxTemplate = Folder.Find("AutoPlay\\htdocs\\images\\msgbox", title, false, nil);
	if checkMsgBoxTemplate == nil then
		Dialog.Message("Error", '"'..title..'" : template not found.\r\n'..msg, MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
		Application.ExitScript();
	end

	Application.SaveValue("MSGBOX", "title", title);
	Application.SaveValue("MSGBOX", "msg", msg);
	Application.SaveValue("MSGBOX", "timer", timer);

	DialogEx.Show("MSGBOX", true, nil, nil);
end

function Trans (bundle, composant, tblBundleVars)
	if bundle ~= "" and composant ~= "" then
		local lang = Application.LoadValue("ITStock", "LANG");
		local tblBundleList = TextFile.ReadToTable("AutoPlay\\htdocs\\lang-properties\\"..lang.."\\"..composant.."_"..lang..".properties");

		for i,bundleLines in pairs (tblBundleList) do
			if String.Find(bundleLines, bundle, 1, false) ~= -1 then
				textBundle = String.Mid(bundleLines, String.Find(bundleLines, "=", 1, false)+1, -1);

				if tblBundleVars then
					for i,j in pairs (tblBundleVars) do
						textBundle = String.Replace(textBundle, "{"..i.."}", j, true);
					end
					return textBundle;
				else
					return textBundle;
				end
			end
		end

		return bundle;
	end
end

function TransPage (composant)
	allObjects = Page.EnumerateObjects();
	currentInterface = Application.GetCurrentPage();

	for i,object in pairs (allObjects) do
		objectType = Page.GetObjectType(object);
		interfaceSize = Page.GetSize();

		if objectType == 0 then
			objProp = Button.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			Button.SetText(object, objTransText);
		end

		if objectType == 1 then
			objProp = Label.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			local objRatio = Label.GetPos(object).X * 100 / (interfaceSize.Width - Label.GetSize(object).Width);
			Label.SetText(object, objTransText);

			if String.Find(objProp.Text, "#", 1, false) == -1 then
				local objNewPosX = objRatio * (interfaceSize.Width - Label.GetSize(object).Width) / 100;
				Label.SetPos(object, objNewPosX, Label.GetPos(object).Y);
			end
		end

		if objectType == 2 then
			objProp = Paragraph.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			Paragraph.SetText(object, objTransText);
		end
		
		if objectType == 7 then
			objProp = Input.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			if objTransText then
				Input.SetText(object, objTransText);
			end
		end

		if objectType == 10 then
			objText = ComboBox.GetText(object);
			local objTransText = Trans(objText, composant);
			if objTransText then
				ComboBox.SetItemText(object, 1, objTransText);
				ComboBox.SetSelected(object, 1);
			end
		end
	end
	Application.SaveValue("ITStock", "TRANS_FLAG_"..currentInterface, "Y");
end

function TransDialog (composant)
	allObjects = DialogEx.EnumerateObjects();
	currentInterface = Application.GetCurrentDialog();

	for i,object in pairs (allObjects) do
		objectType = DialogEx.GetObjectType(object);
		interfaceSize = DialogEx.GetSize();

		if objectType == 0 then
			objProp = Button.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			Button.SetText(object, objTransText);
		end

		if objectType == 1 then
			objProp = Label.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			local objRatio = Label.GetPos(object).X * 100 / (interfaceSize.Width - Label.GetSize(object).Width);
			Label.SetText(object, objTransText);

			if String.Find(objProp.Text, "#", 1, false) == -1 then
				local objNewPosX = objRatio * (interfaceSize.Width - Label.GetSize(object).Width) / 100;
				Label.SetPos(object, objNewPosX, Label.GetPos(object).Y);
			end
		end

		if objectType == 2 then
			objProp = Paragraph.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			Paragraph.SetText(object, objTransText);
		end

		if objectType == 7 then
			objProp = Input.GetProperties(object);
			local objTransText = Trans(objProp.Text, composant);
			Input.SetText(object, objTransText);
		end

		if objectType == 10 then
			objText = ComboBox.GetText(object);
			local objTransText = Trans(objText, composant);
			ComboBox.SetItemText(object, 1, objTransText);
			ComboBox.SetSelected(object, 1);
		end
		
		if objectType == 13 then
			objText = RadioButton.GetText(object);
			local objTransText = Trans(objText, composant);
			RadioButton.SetText(object, objTransText);
		end
	end
	Application.SaveValue("ITStock", "TRANS_FLAG_"..currentInterface, "Y");
end