select SR_Team.Description,SR_Board.Board_Name from SR_Team
	join SR_Board on (SR_Team.SR_Board_RecID = SR_Board.SR_Board_RecID)
	Order by SR_Team.Description