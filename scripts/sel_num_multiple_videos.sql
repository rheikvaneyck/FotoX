SELECT COUNT(*),filename 
	FROM (
		SELECT filename,path 
			FROM files 
			WHERE type IN ('3gp','AVI','avi','MOV','mov','MP4','mp4','MPG','mpg') 
			GROUP BY md5,filename 
			ORDER BY COUNT(md5)
		) 
	GROUP BY filename 
	HAVING COUNT(*) > 1 
	ORDER BY COUNT(*)
;
