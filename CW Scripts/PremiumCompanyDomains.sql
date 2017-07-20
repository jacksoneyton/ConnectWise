SELECT DISTINCT * FROM 
(
	SELECT DISTINCT Substring(Contact_Communication_Type.Description,CharIndex('@',Contact_Communication_Type.Description)+1 ,LEN(Contact_Communication_Type.Description)) as Premium_Domains, Company.Company_ID
		FROM Contact_Communication_Type
			JOIN Contact on contact.Contact_RecID = Contact_Communication_Type.Contact_RecID
			JOIN Company on company.Company_RecID = Contact.Company_RecID
			JOIN Company_Status on Company_Status.Company_Status_RecID = company.Company_Status_RecID
			WHERE Communication_Type_RecID = '1'
				AND Company_Status.Description like '%prem%'
				AND LEN(Contact_Communication_Type.Description)>1
				AND Company.Company_ID not in ('arrc','connectwise')

	UNION ALL

	SELECT DISTINCT replace(replace(replace(Website_URL,'www.',''),'http://',''),'/','') AS Premium_Domains, Company.Company_ID
		FROM Company
			JOIN Company_Status ON Company_Status.Company_Status_RecID = company.Company_Status_RecID
			WHERE Company_Status.Description like '%prem%'
				AND Website_URL != ''
				AND Company.Company_ID not in ('arrc','connectwise')
) 
	AS Premium_Domains 
		WHERE Premium_Domains NOT IN ('gmail.com','yahoo.com','msn.com','me.com')
		ORDER BY Company_ID ASC