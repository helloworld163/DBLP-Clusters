--QUERIES FOR INFOMAP DATA

--get top conferences
create table topX as (
select a.area, a.booktitle 
from conferences a 
where booktitle in
 (select i.booktitle 
 from inproceedings i, conferences c 
 where i.booktitle=c.booktitle and c.area=a.area 
 group by i.booktitle order by count(*) desc limit 3) order by a.area);



--get 7500 random publications per area
create temporary table topPub7500 as
select x.pubid, x.area, x.booktitle
from (
select i.pubid, c.area, c.booktitle, row_number() over (partition by c.area order by random()) rn 
from inproceedings i, topX c where i.booktitle = c.booktitle 
order by c.area asc ) x
where x.rn <= 7500


create temporary table topAuthors7500 as
select a.authorid, au.pubid, b.area, count(*)
from author a, authored au, inproceedings pub, topPub7500 b
where b.pubid = pub.pubid and a.authorid = au.authorid and au.pubid = pub.pubid
group by a.authorid, b.area, au.pubid
order by b.area, count(*) desc


--find the truth for each author -- dump to truth.csv
select temp.authorid, temp.name, temp.area, temp.count, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 from (
select a.authorid, au.name, replace(replace(au.name, ' ', '_'), '.', '') name2, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) percent
 from topAuthors7500 as a, author as au, inproceedings as i, topX as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by c.area) as temp
where percent > 0.05;


--COAUTHORS FOR INFOMAP
create temporary table level1 as
select distinct au.authorid as author, au2.authorid as coauthor
FROM  topAuthors7500 au,  topAuthors7500 au2
where au.authorid != au2.authorid and au.pubid = au2.pubid

--recursive queries
select distinct author from level1

create temporary table level2 as
select distinct l.author, l.coauthor
from level1 l, level1 l2
where l.coauthor = l2.author
and l.author != l2.coauthor

create temporary table level3 as
select distinct l.author, l.coauthor
from level2 l, level2 l2
where l.coauthor = l2.author
and l.author != l2.coauthor

create temporary table level2 as
select distinct l.author, l.coauthor
from level3 l, level3 l2
where l.coauthor = l2.author
and l.author != l2.coauthor

select distinct author from level1
select distinct author from level2

create temporary table counts as 
select au1.authorid as author, au2.authorid as coauthor, count(*) as count
from topAuthors7500 au1, topAuthors7500 au2
where au1.authorid != au2.authorid and au1.pubid = au2.pubid
group by au1.authorid, au2.authorid

--weighted version
select distinct l.author, l.coauthor, c.count
from level3 l, level3 l2, counts c
where l.coauthor = l2.author
and l.author != l2.coauthor and c.author = l.author and c.coauthor = l.coauthor


--from INFOMAP after parsing the map file
drop table clusterPubUnweighted
create table clusterPubUnweighted (
cluster integer,
authorid integer
);

copy clusterPubUnweighted FROM 'C:/Users/Public/outputMAP.txt' DELIMITER ',' CSV;


drop table countAreasWithout
create temporary table countAreasWithout as
select c.cluster, con.area, count(*) as count
from clusterPubUnweighted c, authored au, publication pub, inproceedings i, conferences con
where c.authorid = au.authorid and au.pubid = pub.pubid and pub.pubid = i.pubid and i.booktitle = con.booktitle
group by c.cluster, con.area
order by c.cluster asc, count desc

create temporary table intermed as
select distinct c.cluster, con.area, pub.pubid
from clusterPubUnweighted c, authored au, publication pub, inproceedings i, conferences con
where c.authorid = au.authorid and au.pubid = pub.pubid and pub.pubid = i.pubid and i.booktitle = con.booktitle

drop table intermed

drop table countsCluster
create temporary table countsCluster as
select i.cluster, i.area, count(*) as count
from intermed i
group by i.cluster, i.area
order by i.cluster asc, count(*) desc

 drop table totalCountClusters
--for each author find the total number of publications
create temporary table totalCountClusters as
select i.cluster, sum(i.count)
from countsCluster i
group by i.cluster


drop table labelCluster 
create temporary table labelCluster as
select distinct a.cluster, a.area, a.count/c.sum * 100 as percent
from countsCluster a, totalCountClusters c
where a.cluster = c.cluster

drop table authorCluster
select a.authorid, l.area, l.percent
from labelCluster l, clusterPubUnweighted a
where l.cluster = a.cluster and percent > .2
order by a.authorid


select temp.authorid, temp.area, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 
from (
select au.authorid, a.area, count(*), (count(*))/sum(count(*)) over (partition by au.authorid) percent
 from countsCluster a, totalCountClusters c, clusterPubUnweighted au
 where a.cluster = c.cluster and c.cluster = au.cluster
 group by au.authorid, a.area order by authorid) as temp
where percent > 0.2
order by authorid


select temp.authorid, temp.area, temp.count, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 
from (
select au.authorid, c.area, count(*) as count, (count(*))/sum(count(*)) over (partition by au.authorid) percent
 from topAuthors7500 as au, inproceedings as i, topX as c 
 where au.pubid = i.pubid and i.booktitle = c.booktitle
 group by au.authorid, c.area order by c.area) as temp
where percent > 0.2;



--WEIGHTED HERE
drop table clusterPubWeighted
create table clusterPubWeighted (
cluster integer,
authorid integer
);

copy clusterPubWeighted FROM 'C:/Users/Public/outputMAP.txt' DELIMITER ',' CSV;


select distinct authorid from clusterPubWeighted


drop table countAreasWithout
create temporary table countAreasWithout as
select c.cluster, con.area, count(*) as count
from clusterPubWeighted c, authored au, publication pub, inproceedings i, conferences con
where c.authorid = au.authorid and au.pubid = pub.pubid and pub.pubid = i.pubid and i.booktitle = con.booktitle
group by c.cluster, con.area
order by c.cluster asc, count desc


create temporary table intermed as
select distinct c.cluster, con.area, pub.pubid
from clusterPubWeighted c, authored au, publication pub, inproceedings i, conferences con
where c.authorid = au.authorid and au.pubid = pub.pubid and pub.pubid = i.pubid and i.booktitle = con.booktitle

drop table intermed

drop table countsCluster
create temporary table countsCluster as
select i.cluster, i.area, count(*) as count
from intermed i
group by i.cluster, i.area
order by i.cluster asc, count(*) desc

 drop table totalCountClusters
--for each author find the total number of publications
create temporary table totalCountClusters as
select i.cluster, sum(i.count)
from countsCluster i
group by i.cluster


drop table labelCluster 
create temporary table labelCluster as
select distinct a.cluster, a.area, a.count/c.sum * 100 as percent
from countsCluster a, totalCountClusters c
where a.cluster = c.cluster

drop table authorCluster
create temporary table authorCluster as
select a.authorid, l.area, l.percent
from labelCluster l, clusterPubUnweighted a
where l.cluster = a.cluster and percent > .2
order by a.authorid


select distinct authorid from authorCluster

select temp.authorid, temp.area, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 
from (
select au.authorid, a.area, count(*), (count(*))/sum(count(*)) over (partition by au.authorid) percent
 from countsCluster a, totalCountClusters c, clusterPubUnweighted au
 where a.cluster = c.cluster and c.cluster = au.cluster
 group by au.authorid, a.area order by authorid) as temp
where percent > 0.2
order by authorid








