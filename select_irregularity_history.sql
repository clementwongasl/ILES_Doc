SELECT clih.CASE_LC_INFO_ID, c.DISPLAY_ID , COUNT(*) AS count_record FROM CASE_LC_IRREGULARITY_HISTORIES clih 
LEFT JOIN CASE_LC_INFOS cli ON clih.CASE_LC_INFO_ID = cli.ID 
LEFT JOIN CASES c ON cli.CASE_ID = c.ID
GROUP BY clih.CASE_LC_INFO_ID , c.DISPLAY_ID 
HAVING COUNT(*) >1

DELETE FROM CASE_LC_IRREGULARITY_HISTORIES clih
WHERE ROWID IN (
    SELECT SELECT_ROWID 
    FROM (
        SELECT clih.ROWID AS SELECT_ROWID,
               ROW_NUMBER() OVER (
                   PARTITION BY clih.CASE_LC_INFO_ID 
                   ORDER BY clih.ROWID -- Keeps one record (change to a specific column/date if you want to keep the latest/oldest)
               ) AS rn
        FROM CASE_LC_IRREGULARITY_HISTORIES clih
        LEFT JOIN CASE_LC_INFOS cli ON clih.CASE_LC_INFO_ID = cli.ID
        LEFT JOIN CASES c ON cli.CASE_ID = c.ID
        WHERE clih.CASE_LC_INFO_ID IN (
            -- This subquery limits the deletion strictly to the IDs that match your HAVING COUNT(*) > 1 condition
            SELECT inner_clih.CASE_LC_INFO_ID 
            FROM CASE_LC_IRREGULARITY_HISTORIES inner_clih
            GROUP BY inner_clih.CASE_LC_INFO_ID 
            HAVING COUNT(*) > 1
        )
    )
    WHERE rn > 1
);
