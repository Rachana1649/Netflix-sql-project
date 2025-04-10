--- Netflix Project--
drop table if exists netflix;
Create table netflix
(
show_id varchar(10),
type varchar(10),
title varchar(150),
director varchar(210),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year INT,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
)

select * from netflix;

select count(*) as total_content from netflix;


select distinct type from netflix;

-- 1. Count the number of Movies vs Tv Shows --

select type,count(*) as total_content from netflix Group by type;

--2. Find the most common rating for movies and TV shows

select type,rating
from
(
select type,rating,count(*),Rank() over(partition by type Order By Count(*) desc) as ranking 
from netflix
group by 1,2
) as t1
where 
	ranking = 1

-- 3.List all movies released in a specific year (e.g. 2020)

select * from netflix
where type = 'Movie' and release_year ='2020';

-- 4. Find the top 5 countries with the most content an netflix

select UNNEST(STRING_TO_ARRAY (country,',')) as new_country ,
count(show_id) as total_count from netflix
group by 1
order by 2 desc
limit 5

-- 5. Identify the longest movie?

select * from netflix
where 
type = 'Movie' and duration = (select max(duration) from netflix)

-- 6. Find content added in the last 5 year

select * from netflix
where
	 To_Date(date_added,'Month DD,YYYY')>= current_date - Interval '5 years'

-- 7. Find all the movies/Tv shows by director 'Rajiv Chilaka'

select type,title,director from netflix where director Ilike '%Rajiv Chilaka%';

-- 8. List all Tv shows with more than 5 seasons

select *
from netflix 
where type='TV Show'
  and SPLIT_PART(duration,' ',1):: numeric > 5  

-- 9. Count the number of content items in each genre

select UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre, count(show_id) as total_content from netflix group by 1

--10. Find each year and the average numbers of content release by India on netflix.return top 5 year with highest avg content release

select EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as YEAR,
count(*) as yearly_content,
round(
count(*):: numeric/(SELECT COUNT(*) FROM netflix where country = 'India'):: numeric * 100,2) as avg_content_per_year
from netflix 
where country = 'India'
group by 1

-- 11. List all movies that are documentaries

select * from netflix where
listed_in ILike '%documentaries%'

-- 12. Find all the content without a director

select * from netflix
where 
	director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

select * from netflix where casts Ilike '%Salman Khan%'
and release_year > EXTRACT (Year from current_date)-10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,count(*) as total_content
from netflix
where country ILIke '%india%'
group by 1
order by 2 desc
limit 10

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'voilence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category

with new_table
As
(
select *, 
			case
			when 
			description ilike'%kill%' or 
			description ilike'%violence%' then 'Bad_Content' 
			else 'Good Content' end category
from netflix
)
select
	category,
	count(*) as total_content
	from new_table
	group by 1