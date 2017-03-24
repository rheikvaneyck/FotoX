SELECT 
	fullpath 
	FROM files 
	WHERE type IN ('3gp','AVI','avi','MOV','mov','MP4','mp4','MPG','mpg') 
	GROUP BY md5,filename 
	ORDER BY COUNT(md5)
;
