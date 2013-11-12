
--top booktitles
create temporary table topBookTitles as
select * from conferences a
where booktitle in (
select i.booktitle 
from inproceedings i, conferences c 
where i.booktitle=c.booktitle 
and c.area=a.area 
group by i.booktitle order by count(*) desc 
limit 1) order by a.area

select * from topBookTitles

create temporary table countsArea as
SELECT  r.cluster, b.area, count(*)
 FROM results r, 
      authored au,
      inproceedings i,
      topBookTitles b
 WHERE r.pubid = au.pubid 
 and i.pubid = au.pubid
 and b.booktitle = i.booktitle
Group by cluster, area
order by cluster asc, count(*) desc


create temporary table sumsCluster as
 select cluster, sum(count)
 FROM countsArea
 group by cluster

create temporary table percentages as
select a.cluster, a.area, a.count/c.sum * 100 as percent
 from countsArea a, sumsCluster c
 where a.cluster = c.cluster
 order by cluster asc, percent  desc


--new way from percentages
create temporary table maxCluster as
select x.cluster, p.area
from
(select a.cluster , max(percent) as maxP
from percentages a
group by a.cluster) x, percentages p 
where p.cluster = x.cluster and p.percent = x.maxP

create temporary table authorsToClassify as
SELECT distinct au.authorid
FROM TOPBOOKTITLES b, inproceedings i, authored au, rand1000Publications r
where b.booktitle = i.booktitle and i.pubid = au.pubid and r.pubid = i.pubid

create temporary table authorClusterCounts as
select a.authorid, c.area, count(*)
from authorsToClassify a, authored au, rand1000Publications r, maxCluster c,
     results res
where a.authorid = au.authorid and au.pubid = r.pubid and c.cluster = res.cluster 
and res.pubid = r.pubid
group by a.authorid, c.area
order by a.authorid, c.area

create temporary table countTotalArticles as
select a.authorid, sum(a.count)
from authorClusterCounts a
group by a.authorid
order by a.authorid

--MINE
create temporary table finalans2 as
select distinct a.authorid, c.area, c.count, c.count/a.sum * 100 as percent
from countTotalArticles a, authorClusterCounts c
where a.authorid = c.authorid

--OTHER
select distinct a.authorid, c.area
FROM authorsToClassify a, authored au, inproceedings i, conferences c
where a.authorid = au.authorid and au.pubid = i.pubid and c.booktitle = i.booktitle
order by authorid asc

create temporary table topaY as
select distinct a.authorid, au.pubid
from authorsToClassify a, authored au
where a.authorid = au.authorid

--truth
select temp.authorid, temp.name, temp.area, temp.count, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 from (
select a.authorid, au.name, replace(replace(au.name, ' ', '_'), '.', '') name2, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) percent
 from topaY as a, author as au, inproceedings as i, TOPBOOKTITLES as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by c.area) as temp
where percent > 0.05;




create temporary table weights as
 select au.authorid, r.cluster, COUNT(distinct (r.cluster))
 FROM results r, 
      authored au,
      percentages p
 WHERE r.pubid = au.pubid and r.cluster = p.cluster
 group by authorid, r.cluster

create temporary table weightedPercent as 
select w.authorid, w.cluster, p.area, percent*count as weightedPercent
from weights w, percentages p
where w.cluster = p.cluster
order by authorid asc, weightedPercent desc

create temporary table finalans as
select w.authorid, w.cluster, w.area, sum(weightedpercent) as percent
from weightedPercent w
group by w.authorid, w.cluster, w.area
order by w.authorid asc, percent desc



select distinct f2.authorid, f2.area, b.area
from (select a.authorid,  max(percent)
	       from  finalans a
	group by a.authorid) f,
	finalans f2, 
	       authored au, 
	       inproceedings i,
      topBookTitles b
where f.authorid = au.authorid and au.pubid = i.pubid and f2.percent = f.max and f2.authorid = f.authorid and i.booktitle = b.booktitle and f2.area != b.area



 

 select * from topBookTitles

SELECT t.booktitle, t.area, count(*)  FROM TOPBOOKTITLES t, inproceedings i
where t.booktitle = i.booktitle
group by t.booktitle, t.area

drop table rand1000Publications

create temporary table rand1000Publications as
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'AI' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'DB' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'GV' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'HA' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'HCI' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'ML' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'NC' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'PL' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)
UNION
(select distinct pub.pubid, pub.title, a.area
from topBookTitles a, publication pub, inproceedings i
where a.area = 'TH' and a.booktitle = i.booktitle and 
      i.pubid = pub.pubid
limit 1000)


SELECT pubid, title FROM rand1000Publications where title not like '%"%'



select * from topBookTitles

--top
create temporary table topAuthors as
select a.authorid, b.area, count(*)
from author a, authored au, inproceedings pub, topBookTitles b
where b.booktitle = pub.booktitle and a.authorid = au.authorid and au.pubid = pub.pubid
group by a.authorid, b.area
order by b.area, count(*) desc


drop  table top20Authors
--top 100 authors from each group
create temporary table top20Authors as
(select a.authorid, a.area
from topAuthors a
where a.area = 'AI'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'DB'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'GV'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'HA'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'HCI'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'ML'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'NC'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'PL'
limit 20)
UNION
(select a.authorid, a.area
from topAuthors a
where a.area = 'TH'
limit 20)


--coauthors
drop table final

create temporary table final as
(select distinct random(), pub.pubid as id1, pub.title
from top20Authors x, top20Authors y, authored helper, authored helper2,
     publication pub
where x.authorid = helper.authorid and 
      y.authorid = helper2.authorid and 
      helper.pubid = helper2.pubid and 
      x.authorid != y.authorid and 
      pub.title not like '%"%'
      and pub.pubid = helper.pubid
order by random() limit 2000)

select id1, title from final  f











 
