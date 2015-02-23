MsgC(Color(0, 255, 0), "Initialize UnitedBan Module...\n")

// 플레이어가 서버에 스폰될 때 실행
hook.Add("PlayerInitialSpawn", "UnitedBan", function(pl)
	// http.Fetch: GET
	// http.Post: POST
	// 첫번째 인수의 URL로 요청을 보내고, 성공했을 시 두번째 인수에 할당된 함수를 실행.
	// 실패했을 경우 세 번째 인수에 할당된 함수를 실행한다.
	// 위 두 함수엔 body, len, headers, status 정보를 받아온은 매개변수가 존재한다.
	http.Fetch("http://kkulkkule.dyndns.info:8282/unitedBan.jsp", function(body, l, h, s)
		// 서버측에서 가져온 본문의 줄바꿈 문자를 모두 제거. 줄은 <br />로 나눈다.
		body = string.Replace(body, "\n", "")
		
		// <br /> 문자에 따라 나눠진 본문을 lines 변수에 할당
		local lines = string.Explode("<br />", body)
		
		// 마지막 줄은 빈 값이 되므로 제거한다.
		table.remove(lines, table.Count(lines))
		
		// 각 라인마다 반복함.
		for _, line in pairs(lines) do
			
			// 콤마를 기준으로 정보를 나눔.
			local exploded = string.Explode(",", line)
			local nick, serial, reason, bannedAt, bannedTo = exploded[1],exploded[2],exploded[3],exploded[4],exploded[5]
			
			// 스팀아이디 형식인지 아닌지 구분할 변수
			local issid = false
			
			// 스팀아이디 형식인지 판독
			if string.match(string.upper(serial), "^STEAM_%d:%d:%d+$") then
				issid = true
			elseif string.match(serial, "^%d+%.%d+%.%d+%.%d+$") then
				issid = false
			end
			
			// 처리할지 안할지 구분할 변수
			local process = false
			
			if issid then
				// serial이 스팀아이디 형식이고, 현재 스폰된 플레이어의 스팀아이디로 보인다면 처리, 아니면 안 함.
				// 아래와 같은 형식으로 쓰는 이유는
				// string.find("ABC", "BC")를 실행할 경우 (2	3)이 반환되어 nil이 아니고, string.find("ABC", "D")를 실행할 경우 nil이 반환되기 때문.
				// 즉, 플레이어의 스팀아이디가 serial에서 찾아진다면 nil이 아니므로 (nil이 아닌 값 != nil) == true 가 되므로 process = true가 됨.
				process = string.find(serial, pl:SteamID()) != nil
			else
				// serial이 IP 형식이고, 현재 스폰된 플레이어의 아이피와 일치하는 것으로 보인다면 처리, 아니면 안 함.
				// 원리는 위와 같음. 다만 Player:IPAddress()는 포트를 포함하기 때문에 string.match로 포트를 제외한 부분만 가져온다.
				process = string.find(serial, string.match(pl:IPAddress(), "%d+%.%d+%.%d+%.%d+")) != nil
			end
			
			// 밴 리스트에 존재하고, 처리해야 할 플레이어라면
			if process then 
				
				// 날짜 형식 변환 작업
				
				local date = string.match(bannedAt, "%d+-%d+-%d+")
				local time = string.match(bannedAt, "%d+:%d+:%d+%.?%d?")
				
				local bannedAtData = {
					year = string.sub(date, 1, 4),
					month = string.sub(date, 6, 7),
					day = string.sub(date, 9, 10),
					hour = string.sub(time, 1, 2),
					min = string.sub(time, 4, 5),
					sec = string.sub(time, 7, 8),
				}
				
				local date = string.match(bannedTo, "%d+-%d+-%d+")
				local time = string.match(bannedTo, "%d+:%d+:%d+%.?%d?")
				
				local bannedToData = {
					year = string.sub(date, 1, 4),
					month = string.sub(date, 6, 7),
					day = string.sub(date, 9, 10),
					hour = string.sub(time, 1, 2),
					min = string.sub(time, 4, 5),
					sec = string.sub(time, 7, 8),
				}
				
				bannedAt = os.time(bannedAtData)
				bannedTo = os.time(bannedToData)
				
				// 밴이 끝나는 날짜가 오늘보다 미래라면 킥.
				if bannedTo > os.time() then
					ulx.kick(NULL, pl, "혼살서버 연합 밴 리스트에 등록된 유저입니다. 사유: " .. reason)
				end
			end
		end
	end)
end)

MsgC(Color(0, 255, 0), "Complete!\n")