$AttachmentPath = "C:\temp\cwcharteagrmnttest.csv"
$QueryFmt= "
SELECT A.AGR_Date_Start, C.Company_Name, B.AGR_Type_Desc, DATEDIFF(day,A.AGR_Date_Start,getdate()) as DaysFromStart
FROM AGR_header AS A
        JOIN Company as C
                ON A.Company_RecID = C.Company_RecID
        Join AGR_Type as B
                ON A.AGR_Type_RecID = B.AGR_Type_RecID
Where B.AGR_Type_RecID = 6
        OR B.AGR_Type_RecID = 9
        OR B.AGR_Type_RecID = 10
        OR B.AGR_Type_RecID = 11"

Invoke-Sqlcmd -ServerInstance CT-SQL1 -Database CWWEBAPP_CHARTEC -Query $QueryFmt | convertto-CSV -notype | select -skip 1  > $AttachmentPath
$Result = Invoke-Sqlcmd -ServerInstance CT-SQL1 -Database CWWEBAPP_CHARTEC -Query $QueryFmt
write-host $Result