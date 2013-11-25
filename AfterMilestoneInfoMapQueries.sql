create table topX as (
select a.area, a.booktitle 
from conferences a 
where booktitle in
 (select i.booktitle 
 from inproceedings i, conferences c 
 where i.booktitle=c.booktitle and c.area=a.area 
 group by i.booktitle order by count(*) desc limit 3) order by a.area);

 --BUILD MINE FROM THE NUMBER OF PUBLICATIONS


select c.area, count(distinct(i.pubid)) from inproceedings i, topX c where i.booktitle=c.booktitle
group by c.area;

drop table topPub7500

--get 7500 random publications per area
create temporary table topPub7500 as
select x.pubid, x.area, x.booktitle
from (
select i.pubid, c.area, c.booktitle, row_number() over (partition by c.area order by random()) rn 
from inproceedings i, topX c where i.booktitle = c.booktitle 
order by c.area asc ) x
where x.rn <= 7500

drop table topAuthors7500;

create temporary table topAuthors7500 as
select a.authorid, au.pubid, b.area, count(*)
from author a, authored au, inproceedings pub, topPub7500 b
where b.pubid = pub.pubid and a.authorid = au.authorid and au.pubid = pub.pubid
group by a.authorid, b.area, au.pubid
order by b.area, count(*) desc

--check the count of total authors
select count(*) from topAuthors7500 a
--101390 total authors

drop table final;
--final table (can be random, but eliminate for now) -- ready to cluster

select distinct p.pubid, pub.title from topPub7500 p, publication pub where p.pubid = pub.pubid and pub.title not like '%"%';


--find the truth for each author -- dump to truth.csv
select temp.authorid, temp.name, temp.area, temp.count, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 from (
select a.authorid, au.name, replace(replace(au.name, ' ', '_'), '.', '') name2, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) percent
 from topAuthors7500 as a, author as au, inproceedings as i, topX as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by c.area) as temp
where percent > 0.05;

--After clustering, tying results to the author



--query to dump csv to table
create table clusteringResults 
(pubid int, cluster char(20));

COPY clusteringResults FROM 'C:/Users/Public/results3ID.csv' DELIMITER ',' CSV;

select count(*) from clusteringResults

drop table countsArea
--FROM WEKA
create temporary table countsArea as
SELECT  r.cluster, b.area, count(*)
 FROM clusteringResults r, 
      topPub7500 b
 WHERE r.pubid = b.pubid
Group by cluster, area
order by cluster asc, count(*) desc


select * from sumsCluster a limit 100

drop table sumsCluster
--For each cluster, count how many publications total
create temporary table sumsCluster as
 select cluster, sum(count)
 FROM countsArea
 group by cluster

 drop table percentages

-- Get the percentages of each cluster (each cluster will have several areas and percentages)
create temporary table percentages as
select a.cluster, a.area, a.count/c.sum * 100 as percent
 from countsArea a, sumsCluster c
 where a.cluster = c.cluster
 order by cluster asc, percent  desc

 drop table maxCluster
--find the cluster areas (based on max)
create temporary table maxCluster as
select x.cluster, p.area
from
(select a.cluster , max(percent) as maxP
from percentages a
group by a.cluster) x, percentages p 
where p.cluster = x.cluster and p.percent = x.maxP

select * from maxCluster

 drop table authorClusterCounts
----for each author, find the area and num publications
create temporary table authorClusterCounts as
select a.authorid, c.area, count(*)
from topAuthors7500 a, authored au, topPub7500 r, maxCluster c,
     results res
where a.authorid = au.authorid and au.pubid = r.pubid and c.cluster = res.cluster 
and res.pubid = r.pubid
group by a.authorid, c.area
order by a.authorid, c.area

 drop table countTotalArticles
--for each author find the total number of publications
create temporary table countTotalArticles as
select a.authorid, sum(a.count)
from authorClusterCounts a
group by a.authorid
order by a.authorid

drop table mine 
create temporary table mine as
select distinct a.authorid, c.area, c.count, c.count/a.sum * 100 as percent
from countTotalArticles a, authorClusterCounts c
where a.authorid = c.authorid

--To csv for evaluation
select * from mine

--dumping mine to csv 


--clean up gibhub
--side note: Also turn in the code used to compare these two csv files 


--version 2 
drop table authorsExtended
--authors from topX and find their coauthors (don't have to be from the conferences -- but does truth have them?)
--getting more outside publications? (outside the 7500)
create temporary table authorsExtended as
select distinct au2.authorid
from topAuthors7500 t, authored au, topX pub, inproceedings i, authored au2
Where t.authorid = au.authorid 
and au.pubid = i.pubid 
and i.booktitle = pub.booktitle
and au2.pubid = i.pubid 
and au.authorid != au2.authorid

--get all new authors -- more authors to fit to the clusters generated earlier!
drop table allAuthors
create temporary table allAuthors as 
select distinct *
from(
select authorid from authorsExtended union (select distinct authorid from topAuthors7500)) x

--checking if there really are more authors
select distinct from allAuthors;
select distinct(authorid) from topAuthors7500;

--get beginning stats of all the new authors
drop table authorClusterCounts
create temporary table authorClusterCounts as
select a.authorid, c.area, count(*)
from allAuthors a, authored au, inproceedings r, maxCluster c,
     results res
where a.authorid = au.authorid and au.pubid = r.pubid and c.cluster = res.cluster 
and res.pubid = r.pubid
group by a.authorid, c.area
order by a.authorid, c.area

 drop table countTotalArticles
--for each author find the total number of publications
create temporary table countTotalArticles as
select a.authorid, sum(a.count)
from authorClusterCounts a
group by a.authorid
order by a.authorid

drop table mine 
create temporary table mine as
select distinct a.authorid, c.area, c.count, c.count/a.sum * 100 as percent
from countTotalArticles a, authorClusterCounts c
where a.authorid = c.authorid

--To csv for evaluation
select * from mine

select count(*) from topAuthors7500

drop table sampleAuthors
drop table sampleAuthors
create temporary table sampleAuthors as 
select * from topAuthors7500 order by random()*197547 LIMIT 100000

drop table coauthorsLarge
--INFO MAP -- co-authors (there weren't too many connected before) -- trying this now
create temporary table coauthorsLarge as 
select distinct au.authorid as author, au2.authorid as coauthor
from topAuthors7500 au, topX pub, inproceedings i, topAuthors7500 au2
Where  au.pubid = i.pubid 
and i.booktitle = pub.booktitle
and au2.pubid = i.pubid 
and au.authorid != au2.authorid

 
select distinct c.author as c1author, c.coauthor as c1coauthor
from coauthorsLarge c, coauthorsLarge c2, coauthorsLarge c3
where c.coauthor = c2.author and c2.coauthor = c3.author
and c.author != c3.author


select * from topAuthors7500 c where authorid=1250653;


SELECT * FROM AUTHOR WHERE AUTHORID = 1250653








