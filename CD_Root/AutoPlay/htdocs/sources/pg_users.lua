function getUsersList ()
	local usersListColumnsName = {"Lastname", "Firstname", "Username", "Role", "Sign check list", "Status"}
	initList("GD_USERS_LIST", usersListColumnsName)
	GRID_INITIALIZATION = 1;

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		mySQLCursor = mySQLConnection:execute("SELECT * FROM IT_USERS;");
		row = mySQLCursor:fetch({},"a")
		
		Grid.DeleteNonFixedRows("GD_USERS_LIST", true);
		while row do
			username = row.Username;
			lastname = row.Lastname;
			firstname = row.Firstname;
			role = row.Role;
			signCheckList = row.Sign_Check_List;
			status = row.Active;

			index = Grid.InsertRow("GD_USERS_LIST", -1, true);
			Grid.SetCellText("GD_USERS_LIST", index, 0, lastname, true);
			Grid.SetCellText("GD_USERS_LIST", index, 1, firstname, true);
			Grid.SetCellText("GD_USERS_LIST", index, 2, username, true);
			Grid.SetCellText("GD_USERS_LIST", index, 3, role, true);
			Grid.SetCellText("GD_USERS_LIST", index, 4, signCheckList, true);
			if status == '1' then
				Grid.SetCellText("GD_USERS_LIST", index, 5, "Active", true);
			else
				Grid.SetCellText("GD_USERS_LIST", index, 5, "Disabled", true);
			end

			row = mySQLCursor:fetch(row,"a");
		end

		resizeList("GD_USERS_LIST");

		mySQLCursor:close();
		mySQLConnection:close();
	end

	GRID_INITIALIZATION = 0;
	-- check file exist
	DXML.ReadFromFile("AutoPlay\\htdocs\\xml data\\users_template.xml", "UpdatingUsers");
end

function markUpdatedUser (e_Row, e_Column, e_OldText, e_NewText, selectedUser)
	if GRID_INITIALIZATION == 0 and Grid.GetCellState("GD_USERS_LIST", e_Row, e_Column).Fixed == false then
		Debug.Print("Je suis inside\r\n");
		if (String.CompareNoCase(e_OldText, e_NewText)) ~= 0 then
			if e_Column == 3 then
				local mySQLConnection = dbConnect();
				if mySQLConnection ~= nil then
					SQL = "SELECT DISTINCT(Role) FROM IT_USERS;";
					mySQLCursor = mySQLConnection:execute(SQL);
					row = mySQLCursor:fetch({},"a")

					tblRoleList ={};
					if row then
						while row do
							role = row.Role;
							Table.Insert(tblRoleList, Table.Count(tblRoleList)+1, role);
							row = mySQLCursor:fetch(row,"a");
						end
					else
						Table.Insert(tblRoleList, 1, "No role defined");
					end
					mySQLCursor:close();
					mySQLConnection:close();
				end

				for i,role in pairs(tblRoleList) do
					if e_NewText == role then
						Role = 1;
					else
						Role = 0;
					end
				end

				if Role == 0 then
					local selectedRole = Dialog.ComboBox("Select role", "Invalid data. Please select a valid role :", tblRoleList, "", false, false, MB_ICONSTOP);
					if selectedRole == "" or selectedRole == "CANCEL" then
						e_NewText = e_OldText;
						Grid.SetCellText("GD_USERS_LIST", e_Row, e_Column, e_NewText, true);
						Application.ExitScript();
					else
						if e_OldText == selectedRole then
							Grid.SetCellText("GD_USERS_LIST", e_Row, e_Column, e_OldText, true);
							Application.ExitScript();
						else
							e_NewText = selectedRole
							Grid.SetCellText("GD_USERS_LIST", e_Row, e_Column, selectedRole, true);
						end
					end
				end
			end

			if e_Column == 4 and (e_NewText ~= "Yes" and e_NewText ~= "No") then
				Dialog.Message("Error", "Invalid data.\r\n Allowed value : Yes/No", MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
				Grid.SetCellText("GD_USERS_LIST", e_Row, e_Column, e_OldText, true);
				Application.ExitScript();
			end

			if e_Column == 5 and (e_NewText ~= "Active" and e_NewText ~= "Disabled") then
				Dialog.Message("Error", "Invalid data.\r\n Allowed value : Active/Disabled", MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);
				Grid.SetCellText("GD_USERS_LIST", e_Row, e_Column, e_OldText, true);
				Application.ExitScript();
			end
			local userAttrValue = DXML.GetAttribute("UpdatingUsers", "List/UpdatedUsers/User", "Username");

			if userAttrValue == '' then
				if e_Column == 2 then
					DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User", '<User Username = "'..e_OldText..'" NewUsername = "'..e_NewText..'"></User>', XML.REPLACE);
				else
					DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User", '<User Username = "'..selectedUser..'" NewUsername = ""></User>', XML.REPLACE);
					DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User/Field", '<Field Name="'..Grid.GetCellText("GD_USERS_LIST", 0, e_Column)..'" OldText="'..e_OldText..'" NewText="'..e_NewText..'"/>', XML.REPLACE);
				end
			else
				if e_Column == 2 then
					local nNodes = DXML.Count("UpdatingUsers", "List/UpdatedUsers", "User");
					for i=1,nNodes do
						local usernameAttrValue = DXML.GetAttribute("UpdatingUsers", "List/UpdatedUsers/User:"..i, "Username");
						local newUsernameAttrValue = DXML.GetAttribute("UpdatingUsers", "List/UpdatedUsers/User:"..i, "NewUsername");

						if e_OldText == usernameAttrValue or e_OldText == newUsernameAttrValue then
							checkUserExist = 1;
							nodeIndex = i;
							break;
						else
							checkUserExist = 0;
						end
					end
					if checkUserExist == 0 then
						DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User", '<User Username = "'..e_OldText..'" NewUsername = "'..e_NewText..'"></User>', XML.INSERT_BEFORE);
					else
						DXML.SetAttribute("UpdatingUsers", "List/UpdatedUsers/User:"..nodeIndex, "NewUsername", e_NewText);
					end
				else
					local nNodes = DXML.Count("UpdatingUsers", "List/UpdatedUsers", "User");
					for i=1,nNodes do
						local usernameAttrValue = DXML.GetAttribute("UpdatingUsers", "List/UpdatedUsers/User:"..i, "Username");
						local newUsernameAttrValue = DXML.GetAttribute("UpdatingUsers", "List/UpdatedUsers/User:"..i, "NewUsername");
						if selectedUser == usernameAttrValue or selectedUser == newUsernameAttrValue then
							checkUserExist = 1;
							nodeIndex = i;
							break;
						else
							checkUserExist = 0;
						end
					end
					if checkUserExist == 0 then
						DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User", '<User Username = "'..selectedUser..'"><Field Name="'..Grid.GetCellText("GD_USERS_LIST", 0, e_Column)..'" OldText="'..e_OldText..'" NewText="'..e_NewText..'"/></User>', XML.INSERT_BEFORE);
					else
						DXML.InsertXML("UpdatingUsers", "List/UpdatedUsers/User:"..nodeIndex.."/Field", '<Field Name="'..Grid.GetCellText("GD_USERS_LIST", 0, e_Column)..'" OldText="'..e_OldText..'" NewText="'..e_NewText..'"/>', XML.INSERT_BEFORE);
					end
				end
			end
		end
		
		if Application.GetCurrentPage() == "USERS-SEARCH" then
			Image.SetVisible("IMG_LASTNAME_USF", false);
			Input.SetVisible("IN_LASTNAME", false);
			Image.SetVisible("IMG_FIRSTNAME_USF", false);
			Input.SetVisible("IN_FIRSTNAME", false);
			Image.SetVisible("IMG_USERNAME_USF", false);
			Input.SetVisible("IN_USERNAME", false);
			ComboBox.SetVisible("CB_ROLE", false);
			Image.SetVisible("IMG_EMAIL_USF", false);
			Input.SetVisible("IN_EMAIL", false);
			Label.SetVisible("LB_STATUS", false);
			Image.SetVisible("IMG_CHECKBOX", false);
			Label.SetVisible("LB_CHECKBOX", false);
			Label.SetVisible("LB_SIGN", false);
			Image.SetVisible("IMG_TOGGLE_YES_NO", false);
			Label.SetVisible("LB_CLS_FILTERS", false);
			Image.SetVisible("IMG_SAVE_MODIFICATION", true);
			Image.SetVisible("IMG_CANCEL_UPDATE", true);
			Image.SetEnabled("IMG_TOGGLE_UP", false);
			Image.SetEnabled("IMG_ACCORDION1", false);
			Image.SetVisible("IMG_ADD_USER", false);

			local margin = Image.GetPos("IMG_SAVE_MODIFICATION").Y - Image.GetPos("IMG_BG_BODY").Y;
			local newBgBodyHeight = margin + Image.GetSize("IMG_SAVE_MODIFICATION").Height + margin;
			Image.SetSize("IMG_BG_BODY", Image.GetSize("IMG_BG_BODY").Width, newBgBodyHeight);
			local newGridPosY = Image.GetPos("IMG_BG_BODY").Y + newBgBodyHeight + 18;
			Grid.SetPos("GD_USERS_LIST", Grid.GetPos("GD_USERS_LIST").X, newGridPosY);
		end

		if Application.GetCurrentPage() == "USERS" then
			Image.SetVisible("IMG_ACCORDION1", false);
			Image.SetVisible("IMG_TOGGLE_DOWN1", false);
			Image.SetVisible("IMG_CLEAR_SEARCH", false);
			Input.SetVisible("IN_SEARCH_USER", false);
			Image.SetVisible("IMG_SAVE_MODIFICATION", true);
			Image.SetVisible("IMG_CANCEL_UPDATE", true);
		end

		tbCellProps = {};
		tbCellProps.FaceName = "Nunito"
		tbCellProps.Height = 14;
		tbCellProps.Weight = FW_BOLD;
		tbCellProps.Italic = true
		local nCols = Grid.GetColumnCount("GD_USERS_LIST");
		for i = 0, nCols do
			Grid.SetCellFont("GD_USERS_LIST", e_Row, i, tbCellProps, true);
			Grid.SetCellColors("GD_USERS_LIST", e_Row, i, {Background=16777215,Text=Math.HexColorToNumber("FF0000")}, true);
		end
	end
end

function defaultSearchUser (inputSearch)
	GRID_INITIALIZATION = 1;
	local searchText = Input.GetText(inputSearch);
	local usersListColumnsName = {"Lastname", "Firsname", "Username", "Role", "Sign check list", "Status"}
	initList("GD_USERS_LIST", usersListColumnsName);
	Grid.DeleteNonFixedRows("GD_USERS_LIST", true);

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		if searchText == "" then
			mySQLCursor = mySQLConnection:execute("SELECT * FROM IT_USERS;");
		else
			mySQLCursor = mySQLConnection:execute("SELECT * FROM IT_USERS WHERE Lastname like '%"..searchText.."%';");
		end

		row = mySQLCursor:fetch({},"a")
		if row then
			while row do
				username = row.Username;
				lastname = row.Lastname;
				firstname = row.Firstname;
				role = row.Role;
				signCheckList = row.Sign_Check_List;
				status = row.Active;

				index = Grid.InsertRow("GD_USERS_LIST", -1, true);
				Grid.SetCellText("GD_USERS_LIST", index, 0, lastname, true);
				Grid.SetCellText("GD_USERS_LIST", index, 1, firstname, true);
				Grid.SetCellText("GD_USERS_LIST", index, 2, username, true);
				Grid.SetCellText("GD_USERS_LIST", index, 3, role, true);
				Grid.SetCellText("GD_USERS_LIST", index, 4, signCheckList, true);
				if status == '1' then
					Grid.SetCellText("GD_USERS_LIST", index, 5, "Active", true);
				else
					Grid.SetCellText("GD_USERS_LIST", index, 5, "Disabled", true);
				end
				--Debug.Print("Insert : "..index..". "..username.."\r\n");
				row = mySQLCursor:fetch(row,"a");
			end
		else
			Grid.SetGridLines("GD_USERS_LIST", GVL_HORZ);
			index = Grid.InsertRow("GD_USERS_LIST", -1, true);
			Grid.SetCellText("GD_USERS_LIST", index, 0, "No result", true);
		end

		resizeList("GD_USERS_LIST");

		mySQLCursor:close();
		mySQLConnection:close();
	end
end

function advancedSearchUsers(reset)
	GRID_INITIALIZATION = 1;
	local usersListColumnsName = {"Lastname", "Firsname", "Username", "Role", "Sign check list", "Status"}
	initList("GD_USERS_LIST", usersListColumnsName)
	Grid.DeleteNonFixedRows("GD_USERS_LIST", true);

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		local searchByFirstname = Input.GetText("IN_FIRSTNAME");
		if searchByFirstname == "Firstname" then
			sqlSearchByFirstname = "Firstname like '%%'";
		else
			sqlSearchByFirstname = "Firstname like '%"..searchByFirstname.."%'";
		end

		local searchByLastname = Input.GetText("IN_LASTNAME");
		if searchByLastname == "Lastname" then
			sqlSearchByLastname = "Lastname like '%%'";
		else
			sqlSearchByLastname = "Lastname like '%"..searchByLastname.."%'";
		end

		local searchByUsername = Input.GetText("IN_USERNAME");
		if searchByUsername == "Username" then
			sqlSsearchByUsername = "Username like '%%'";
		else
			sqlSsearchByUsername = "Username like '%"..searchByUsername.."%'";
		end

		local searchByRole = ComboBox.GetItemText("CB_ROLE", ComboBox.GetSelected("CB_ROLE"));
		if searchByRole == "Role" then
			sqlTosearchByRole = "Role like '%%'";
		else
			sqlTosearchByRole = "Role = '"..searchByRole.."'";
		end

		local LoadedImage = Image.GetFilename("IMG_TOGGLE_YES_NO");
		local ImageStatus = String.SplitPath(LoadedImage);
		if String.Find(ImageStatus.Filename, "idle", 1, false) ~= -1 then
			searchBySignCheckList = "Sign_Check_List like '%%'";
		else
			local SignCheckStatus = ImageStatus.Filename;
			if SignCheckStatus == "yes" then
				searchBySignCheckList = "Sign_Check_List = 'Yes'";
			else
				searchBySignCheckList = "Sign_Check_List = 'No'";
			end
		end

		local LoadedImage = Image.GetFilename("IMG_CHECKBOX");
		local ImageStatus = String.SplitPath(LoadedImage);
		local searchByStatus  = ImageStatus.Filename;

		if searchByStatus  == "checkbox_off" then
			sqlTosearchByStatus = "Active = '0'";
		end

		if searchByStatus  == "checkbox_on" then
			sqlTosearchByStatus = "Active = '1'";
		end

		if reset then
			SQL = "SELECT * FROM IT_USERS";
		else
			SQL = "SELECT * FROM IT_USERS WHERE "..sqlSearchByFirstname.." AND "..sqlSearchByLastname.." AND "..sqlSsearchByUsername.." AND "..sqlTosearchByRole.." AND "..searchBySignCheckList.." AND "..sqlTosearchByStatus..";";
		end

		mySQLCursor = mySQLConnection:execute(SQL);
		row = mySQLCursor:fetch({},"a")

		if row then
			while row do
				username = row.Username;
				lastname = row.Lastname;
				firstname = row.Firstname;
				role = row.Role;
				signCheckList = row.Sign_Check_List;
				status = row.Active;

				index = Grid.InsertRow("GD_USERS_LIST", -1, true);
				Grid.SetCellText("GD_USERS_LIST", index, 0, lastname, true);
				Grid.SetCellText("GD_USERS_LIST", index, 1, firstname, true);
				Grid.SetCellText("GD_USERS_LIST", index, 2, username, true);
				Grid.SetCellText("GD_USERS_LIST", index, 3, role, true);
				Grid.SetCellText("GD_USERS_LIST", index, 4, signCheckList, true);
				if status == '1' then
					Grid.SetCellText("GD_USERS_LIST", index, 5, "Active", true);
				else
					Grid.SetCellText("GD_USERS_LIST", index, 5, "Disabled", true);
				end

				row = mySQLCursor:fetch(row,"a");
			end
		else
			Grid.SetGridLines("GD_USERS_LIST", GVL_HORZ);
			index = Grid.InsertRow("GD_USERS_LIST", -1, true);
			Grid.SetCellText("GD_USERS_LIST", index, 0, "No result", true);
		end
		resizeList("GD_USERS_LIST");
		mySQLCursor:close();
		mySQLConnection:close();
	end
end

function setUserSearchForm (currentObject)
	objectList = Page.EnumerateObjects();

	for i, object in pairs(objectList) do
		objectType = Page.GetObjectType(object);

		if object == currentObject then
			local objectText = Input.GetText(object);
			if objectText == "Firstname" or objectText == "Username" or objectText == "Lastname" then
				Input.SetText(currentObject, "");
			else
				Input.SetSelection(currentObject, 1, -1);
			end
			Image.Load(String.Replace(currentObject, "IN", "IMG", false).."_USF", "AutoPlay\\htdocs\\images\\inputs\\input_selected.png");
		else
			if objectType == 3 and String.Find(object, "USF", 1, false) ~= -1 then -- USF = User Search Form
				Image.Load(object, "AutoPlay\\htdocs\\images\\inputs\\input.png");
			end

			if objectType == 7 and Input.GetText(object) == "" then
				if String.Find(object, "FIRSTNAME", 1, false) ~= -1 then
					Input.SetText(object, "Firstname");
				elseif String.Find(object, "USERNAME", 1, false) ~= -1 then
					Input.SetText(object, "Username");
				elseif String.Find(object, "LASTNAME", 1, false) ~= -1 then
					Input.SetText(object, "Lastname");
				else
					Input.SetText(object, "...");
				end
			end
		end
	end
end

function deleteUserAccount ()
	local indexSelecteduser = ListBox.GetSelected("LBX_UPDATED_USERS")[1];
	local dataSelecteduser = ListBox.GetItemData("LBX_UPDATED_USERS", indexSelecteduser);

	local mySQLConnection = dbConnect();
	if mySQLConnection ~= nil then
		SQL = "DELETE FROM `it_stock_manager`.`it_users` WHERE ID = '"..dataSelecteduser.."';";

		local userAction = Dialog.Message("Notice", "Delete user '"..updatedUsers.."', Please confirm.", MB_YESNO, MB_ICONINFORMATION, MB_DEFBUTTON1);

		if userAction == IDYES then
			mySQLCursor, err = mySQLConnection:execute(SQL);
			if err then
				-- Insert into lof write function
				Application.SaveValue("ITSTOCK", "ERROR_MSG", err);
				PopUp("0");
				Application.ExitScript();
			else
				local info = "User '"..username.."' successfly created.";
				-- Insert into lof write function
				Application.SaveValue("ITSTOCK", "INFO_MSG", info);
				PopUp("1");
				DialogEx.Close(this);
			end
			DialogEx.ClickObject("IMG_CANCEL");
		else
			Application.ExitScript();
		end
	end
end