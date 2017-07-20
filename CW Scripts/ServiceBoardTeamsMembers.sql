select Member.First_Name,Member.Last_Name,SR_Team.Description,SR_Board.Board_Name from SR_Team_Mbr
	join Member on (SR_Team_Mbr.Member_RecID = Member.Member_RecID)
	join SR_Team on (SR_Team_Mbr.SR_Team_RecID = SR_Team.SR_Team_RecID)
	join SR_Board on (SR_Team.SR_Board_RecID = SR_Board.SR_Board_RecID)
	Order by SR_Team.Description