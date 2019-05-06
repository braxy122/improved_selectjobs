quest selectJob begin
	state start begin
		function returnData()
			local data = {
				[0] = {"Razboinic Corp", "Razboinic Mental"},
				[1] = {"Ninja Pumnal", "Ninja Arc"},
				[2] = {"Sura Arme", "Sura Magie"},
				[3] = {"Saman Dragon", "Saman Vindecare"},
				
				["secondaryEnable"] = true,
				["languagesEnable"] = true,
				
				["secondSkillData"] = {
					{131, 10}, -- Imblanzire
					{129, 40}, -- Transformare
					{137, 20}, -- CAL1
					{138, 20}, -- CAL2
					{139, 20}, -- CAL3
					{140, 20}, -- CAL4
				},
				
				["languagesData"] = {
					{{127, 20}, {128, 20}}, -- limbile: galben, albastru
					{{126, 20}, {128, 20}}, -- limbile: rosu, albastru
					{{127, 20}, {126, 20}}  -- limbile: galben, rosu
				}
			};
			
			return data;
		end
		
		function setSecondSkills()
			local data = selectJob.returnData();
			
			if (data["secondaryEnable"]) then
				for index in data["secondSkillData"] do
					pc.set_skill_level(data["secondSkillData"][index][1], data["secondSkillData"][index][2]);
				end
				
				horse.set_level(21);
				pc.give_item2(50053, 1);
			end
			
			if (data["languagesEnable"]) then
				local playerEmpire = pc.get_empire();
				for secIndex in data["languagesData"][playerEmpire] do
					pc.set_skill_level(data["languagesData"][playerEmpire][secIndex][1], data["languagesData"][playerEmpire][secIndex][1]);
				end
			end
		end
		
		function removeTarget()
			local data = selectJob.returnData();
			local playerRace = pc.get_job();
			
			for index in data[playerRace] do
				target.delete(string.format("teacher%d", index));
			end
		end
		
		function selectGroupSkill(selectedGroup)
			local data = selectJob.returnData();
			local playerRace = pc.get_job();
			
			say_title("Alege Competentele:")
			say(string.format("Iti doresti cu adevarat sa devi: %s?", data[playerRace][selectedGroup]))
			if (select("Da, doresc", "Nu, nu doresc") == 1) then
				if (pc.get_skill_group() != 0) then
					say("Ti-ai ales deja competentele.")
					
					set_state("done");
					selectJob.removeTarget();
					return;
				end
				
				selectJob.setSecondSkills();
				pc.set_skill_group(selectedGroup);
				selectJob.removeTarget();
				
				set_state("done");
				pc.clear_skill();
				clear_letter();
			end
		end
		
		when login or enter or levelup with (pc.get_level() >= 5 and pc.get_skill_group() == 0) begin
			set_state("run");
		end
	end
	
	state run begin
		when letter begin
			send_letter("Alege Competentele");
			
			local data = selectJob.returnData();
			local playerRace = pc.get_job();
			
			for index in data[playerRace] do
				local selectVID = pc_find_skill_teacher_vid(index);
				
				if (selectVID != 0) then
					target.vid(string.format("teacher%d", index), selectVID, string.format("%s", data[playerRace][index]));
				end
			end
		end
		
		when leave begin
			selectJob.removeTarget();
		end
		
		when button or info begin
			local data = selectJob.returnData();
			local playerRace = pc.get_job();
			
			say_title("Alege Competentele:")
			say("Ce doresti sa alegi?")
			
			local selectChoice = select(string.format("%s", data[playerRace][1]), string.format("%s", data[playerRace][2]), "Renunta");
			if (selectChoice == 3) then return; end
			selectJob.selectGroupSkill(selectChoice);
		end
		
		when teacher1.target.click or teacher2.target.click begin
			local data = selectJob.returnData();
			local playerRace = pc.get_job();
			
			say_title("Alege Competentele:")
			say("Ce doresti sa alegi?")
			
			local selectChoice = select(string.format("%s", data[playerRace][1]), string.format("%s", data[playerRace][2]), "Renunta");
			if (selectChoice == 3) then return; end
			selectJob.selectGroupSkill(selectChoice);
		end
	end
	
	state done begin
		when login or enter begin
			q.done();
		end
	end
end
