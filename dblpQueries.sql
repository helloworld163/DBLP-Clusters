/*CSE 546 Final Project
A bunch of postgres queries we used in our project to filter, collect, and modify the data. All of the actual data files are left out due to space limitations */

select p.booktitle, count(*) num_articles 
from inproceedings p, publication b
where p.pubid=b.pubid and b.year >= 2010
group by p.booktitle
order by count(*) desc limit 200;

select temp.title, temp.num from
(select p.booktitle title, count(*) num 
from inproceedings p, publication b
where p.pubid=b.pubid and b.year >= 2010
group by p.booktitle
order by count(*) desc limit 200) as temp
order by temp.title desc;

--COUNTING # AUTHORS
select count(distinct(au.authorid)) from authored au, inproceedings i where au.pubid = i.pubid and i.booktitle like 'Mobile HCI';

--COUNTING # Publications
select count(pubid) from inproceedings i where i.booktitle like 'Mobile HCI';

--Table Updates
update inproceedings set booktitle = 'AAAI' where booktitle like 'AAAI Spring%' or booktitle like 'AAAI Fall%' or booktitle like 'AAAI' or booktitle like 'AAAI/IAAI%' or booktitle like 'AAAI Workshop%' or booktitle like 'AAAI Mobile%';

update inproceedings set booktitle = 'IJCAI' where booktitle like 'IJCAI' or booktitle like 'IJCAI%' or booktitle like '%(IJCAI Workshop)';

update inproceedings set booktitle = 'ICRA' where booktitle like 'ICRA%';

update inproceedings set booktitle = 'UAI' where booktitle like 'UAI%';

update inproceedings set booktitle = 'AAMAS' where booktitle like 'AAMAS%';

update inproceedings set booktitle = 'ACL' where booktitle like 'ACL (%' or booktitle like 'ACL' or booktitle like 'ACL/%';

update inproceedings set booktitle = 'IROS' where booktitle like 'IROS%';

update inproceedings set booktitle = 'SOCG' where booktitle like 'Symposium on Computational Geometry';

update inproceedings set booktitle = 'FOCS' where booktitle like '%FOCS%';

update inproceedings set booktitle = 'ICIP' where booktitle like 'ICIP%';

update inproceedings set booktitle = 'SIGGRAPH' where booktitle like 'SIGGRAPH%' and booktitle not like 'SIGGRAPH ASIA%';

update inproceedings set booktitle = 'CVPR' where booktitle like 'CVPR%';

update inproceedings set booktitle = 'ECCV' where booktitle like 'ECCV%';

update inproceedings set booktitle = 'ICCV' where booktitle like 'ICCV %' or booktitle like 'ICCV';

update inproceedings set booktitle = 'VIS' where booktitle like 'IEEE Visualization' or booktitle like 'VIS';

update inproceedings set booktitle = 'VLDB' where booktitle like 'VLDB%';

update inproceedings set booktitle = 'SIGMOD' where booktitle like '%SIGMOD%' and booktitle not like 'SIGMOD/PODS%';

update inproceedings set booktitle = 'ICDE' where booktitle like 'ICDE %' or booktitle like 'ICDE';

update inproceedings set booktitle = 'ICDT' where booktitle like '%ICDT%';

update inproceedings set booktitle = 'ISCA' where booktitle like 'ISCA Workshops' or booktitle like 'ISCA';

update inproceedings set booktitle = 'MICRO' where booktitle like 'MICRO Workshops' or booktitle like 'MICRO';

update inproceedings set booktitle = 'ICPR' where booktitle like 'ICPR (%' or booktitle like 'ICPR' or booktitle like 'ICPR Contests';

update inproceedings set booktitle = 'FSKD' where booktitle like 'FSKD%';

update inproceedings set booktitle = 'KDD' where booktitle like 'KDD' or booktitle like 'KDD Workshop%' or booktitle like 'KDD Tutorial%';

update inproceedings set booktitle = 'INFOCOM' where booktitle like 'INFOCOM%';

update inproceedings set booktitle = 'CHI' where booktitle like 'CHI' or booktitle like 'CHI %';

update inproceedings set booktitle = 'Mobile HCI' where booktitle like 'Mobile HCI%';

update inproceedings set booktitle = 'CSCW' where booktitle like 'CSCW %' or booktitle like 'CSCW';

update inproceedings set booktitle = 'HUC' where booktitle like 'HUC' or booktitle like 'UbiComp%';

update inproceedings set booktitle = 'UIST' where booktitle like 'UIST%';

update inproceedings set booktitle = 'OOPSLA' where booktitle like '%OOPSLA%';

update inproceedings set booktitle = 'ICSE' where booktitle like 'ICSE' or booktitle like 'ICSEng' or booktitle like 'ICSE %' or booktitle like '%@ ICSE';

update inproceedings set booktitle = 'FSE' where booktitle like 'FSE' or booktitle like '%SIGSOFT FSE%';

update inproceedings set booktitle = 'JICSLP' where booktitle like 'ICLP%' or booktitle like '%JICSLP%' or booktitle like '%ILPS%';

--If made mistake
--update inproceedings set booktitle = 'FSE' where pubid in (select x.pubid as pubid from Publication x join Pub y on x.pubkey = y.k and y.p = 'inproceedings' left outer join Field u on x.pubkey = u.k and u.p='booktitle' where u.v like 'FSE' or u.v like '%SIGSOFT FSE%' group by x.pubid);

create table conferences (booktitle text, area varchar(10));
insert into conferences values ('POPL', 'PL'),('PLDI', 'PL'),('OOPSLA', 'PL'),('ICFP', 'PL'),('JICSLP', 'PL'),('ICSE', 'PL'),('FSE', 'PL'),('CAV', 'PL');
insert into conferences values ('CHI', 'HCI'), ('Mobile HCI', 'HCI'), ('CSCW', 'HCI'), ('HUC', 'HCI'), ('UIST', 'HCI');
insert into conferences values ('INFOCOM', 'NC'), ('MOBICOM', 'NC'), ('IPSN', 'NC'), ('SIGCOMM', 'NC'), ('ICNP', 'NC'), ('MobiHoc', 'NC');
insert into conferences values ('ICPR', 'ML'), ('FSKD', 'ML'), ('ICML', 'ML'), ('KDD', 'ML');
insert into conferences values ('ASPLOS', 'HA'), ('ISCA', 'HA'), ('ICCAD', 'HA'), ('DAC', 'HA'), ('MICRO', 'HA'), ('HPCA', 'HA'), ('FCCM', 'HA'), ('ISPD', 'HA');
insert into conferences values ('VLDB', 'DB'), ('SIGMOD', 'DB'), ('PODS', 'DB'), ('ICDE', 'DB'), ('CIKM', 'DB'), ('ICDT', 'DB');
insert into conferences values ('ICIP', 'GV'), ('SIGGRAPH', 'GV'), ('I3D', 'GV'), ('CGI', 'GV'), ('CVPR', 'GV'), ('ECCV', 'GV'), ('ICCV', 'GV'), ('VIS', 'GV');
insert into conferences values ('STOC', 'TH'), ('FOCS', 'TH'), ('COLT', 'TH'), ('LICS', 'TH'), ('SOCG', 'TH'), ('SODA', 'TH'), ('SPAA', 'TH'), ('ISSAC', 'TH');
insert into conferences values ('AAAI', 'AI'), ('IJCAI', 'AI'), ('ICRA', 'AI'), ('ICGA', 'AI'), ('KR', 'AI'), ('NIPS', 'AI'), ('UAI', 'AI'), ('AAMAS', 'AI'), ('ACL', 'AI'), ('IROS', 'AI');

alter table conferences add primary key(booktitle);
cluster conferences using conferences_pkey;

--Sanity check, should return all the article counts we have already
select c.area, i.booktitle, count(*) as count from inproceedings i, conferences c where i.booktitle=c.booktitle group by c.area, i.booktitle order by c.area, count(*) desc;
/*
AI | ICRA | 14565
 AI | IROS | 10871
 AI | AAAI |8014
 AI | IJCAI|5925
 AI | NIPS |4828
 AI | AAMAS|3599
 AI | ACL|3259
 AI | UAI|1815
 AI | KR | 830
 AI | ICGA | 497
 DB | ICDE |3989
 DB | CIKM |3075
 DB | SIGMOD |2903
 DB | VLDB |2504
 DB | PODS |1019
 DB | ICDT | 635
 GV | ICIP | 15125
 GV | CVPR |5699
 GV | ICCV |2828
 GV | ECCV |2615
 GV | SIGGRAPH |2357
 GV | VIS|1254
 GV | I3D| 129
 GV | CGI|16
 HA | DAC|6075
 HA | ICCAD|2812
 HA | ISCA |1553
 HA | MICRO| 908
 HA | FCCM | 890
 HA | HPCA | 673
 HA | ISPD | 581
 HA | ASPLOS | 535
 HCI| CHI|8497
 HCI| CSCW |1298
 HCI| Mobile HCI |1077
 HCI| HUC| 824
 HCI| UIST | 761
 ML | ICPR |6974
 ML | FSKD |4486
 ML | KDD|2261
 ML | ICML |2260
 NC | INFOCOM|6371
 NC | SIGCOMM|1041
 NC | IPSN | 676
 NC | ICNP | 675
 NC | MOBICOM| 535
 NC | MobiHoc| 474
 PL | ICSE |3789
 PL | OOPSLA |2127
 PL | JICSLP |1781
 PL | FSE|1377
 PL | POPL |1286
 PL | CAV|1187
 PL | PLDI | 906
 PL | ICFP | 584
 TH | FOCS |2839
 TH | STOC |2786
 TH | SODA |2630
 TH | SOCG |1417
 TH | ISSAC|1283
 TH | LICS |1273
 TH | SPAA |1029
 TH | COLT | 921
*/

select c.area, count(distinct(au.authorid)) from authored au, inproceedings i, conferences c where au.pubid = i.pubid and i.booktitle = c.booktitle group by c.area;
/*
AI | 54710
DB | 15921
GV | 33780
HA | 18127
HCI| 18131
ML | 26255
NC | 12573
PL | 14740
TH |9407

Total Unique: 168823
*/

--------------------------------------------------CREATE TOP 3 CONFERENCES TABLES

--top x number of conferences per area
create table topX as (select a.area, a.booktitle from conferences a where booktitle in (select i.booktitle from inproceedings i, conferences c where i.booktitle=c.booktitle and c.area=a.area group by i.booktitle order by count(*) desc limit 3) order by a.area);

select c.area, count(distinct(au.authorid)) from authored au, inproceedings i, topX c where au.pubid = i.pubid and i.booktitle = c.booktitle group by c.area;

/*
AI | 38728
DB | 13464
GV | 26302
HA | 14121
HCI| 15971
ML | 24096
NC | 11031
PL | 10038
TH |4939

Total Unique: 136736
*/

create table topauthor as (select distinct(a.authorid), a.name from author a, authored au, inproceedings i, topX c where a.authorid = au.authorid and au.pubid = i.pubid and i.booktitle = c.booktitle);

alter table topauthor add primary key(authorid);
analyze topauthor;

create table topauthored as (select au.authorid, i.pubid from authored au, inproceedings i, topX c where au.pubid = i.pubid and i.booktitle = c.booktitle);

create index topauthoredauthorid on topauthored(authorid);
create index topauthoredpubid on topauthored(pubid);
analyze topauthored;

create table topcoauthor as
select distinct x.authorid as id1, y.authorid as id2
from topauthored x, topauthored y
where x.pubid = y.pubid and x.authorid != y.authorid;

--------------------------------------------------QUERIES FOR MILESTONE

--Finds areas of authors as percentages
select a.authorid, replace(au.name, ' ', '_'), c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) from topaY as a, topauthor as au, inproceedings as i, topY as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by au.name, c.area;

--Find areas of authors as percentage removing out those contributing < 20 percent
select temp.authorid, temp.name2, temp.area, temp.count, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent2 from (
select a.authorid, au.name, replace(au.name, ' ', '_') name2, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) percent from topaY as a, topauthor as au, inproceedings as i, topY as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by c.area) as temp
where percent >= 0.2;

--create tables where top single conference
create temporary table topY as (select a.area, a.booktitle from conferences a where booktitle in (select i.booktitle from inproceedings i, conferences c where i.booktitle=c.booktitle and c.area=a.area group by i.booktitle order by count(*) desc limit 1) order by a.area);

select count(distinct(au.authorid)) from authored au, inproceedings i, topY c where au.pubid = i.pubid and i.booktitle = c.booktitle;

select count(distinct(a.name)) from author a, authored au, inproceedings i, topY c where a.authorid = au.authorid and au.pubid = i.pubid and i.booktitle = c.booktitle;

create temporary table topaY as (select au.authorid, i.pubid from authored au, inproceedings i, topY c where au.pubid = i.pubid and i.booktitle = c.booktitle);

create temporary table topcoY as
select distinct replace(x.name, ' ', '_') as id1, replace(y.name, ' ', '_') as id2
from topaY x, topaY y
where x.pubid = y.pubid and x.authorid != y.authorid;

--find authors who have published in multiple areas (a is authored table)

select temp.authorid, count(*) from (select a.authorid, au.name, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by a.authorid) count2 from topaX as a, topauthor as au, inproceedings as i, topX as c where au.authorid = a.authorid and a.pubid = i.pubid and i.booktitle = c.booktitle group by a.authorid, au.name, c.area order by au.name, c.area) temp group by temp.authorid having count(*) > 1;

--------------------------------------------------QUERIES FOR SAMPLING DATA DIFFERENTLY

--choose 1,000 random authors from each area
create temporary table topaY as
(select temp.authorid, temp.name, temp.pubid from (
select a.authorid, a.name, au.pubid, c.area, row_number() over (partition by c.area order by random()) rn from topauthor a, topauthored au, inproceedings i, topX c where a.authorid = au.authorid and au.pubid = i.pubid and i.booktitle = c.booktitle) temp
where rn <= 1000);

--number of distinct publications per area in topX
select c.area, count(distinct(i.pubid)) from inproceedings i, topX c where i.booktitle=c.booktitle group by c.area;
/*
 area | count 
------+-------
 AI   | 33450
 DB   |  9967
 GV   | 23652
 HA   | 10440
 HCI  | 10872
 ML   | 13721
 NC   |  8088
 PL   |  7697
 TH   |  8255

 This means we can select around 7500 articles for each conference
*/
--authors and titles from 7,500 random articles from each area; can use copy ... to in order to save as a csv file
(select a.authorid, temp.pubid, temp.title, temp.area from (
select i.pubid, p.title, c.area, row_number() over (partition by c.area order by random()) rn from inproceedings i, publication p, topX c where i.booktitle = c.booktitle and i.pubid = p.pubid) temp, topauthored a where temp.pubid = a.pubid and rn <= 1)

--coauthors from X random articles from each area; treats as directed edge so there will be row for author a with author b and one for author b with author a
create temporary table coaCluster as
(with pubs as
(select a.authorid, temp.pubid, temp.area from (
select i.pubid, c.area, row_number() over (partition by c.area order by random()) rn from inproceedings i, topX c where i.booktitle = c.booktitle) temp, topauthored a where temp.pubid = a.pubid and rn <= 500)
select distinct x.authorid as a1, y.authorid as a2 from pubs x, pubs y where x.pubid = y.pubid and x.authorid != y.authorid);

--coauthors from X random articles from each area; treats as an undirected edge so no duplicates
create temporary table coaCluster as
(with pubs as
(select a.authorid, temp.pubid, temp.area from (
select i.pubid, c.area, row_number() over (partition by c.area order by random()) rn from inproceedings i, topX c where i.booktitle = c.booktitle) temp, topauthored a where temp.pubid = a.pubid and rn <= 5000)
select distinct least(x.authorid,y.authorid) as a1, greatest(x.authorid,y.authorid) as a2 from pubs x, pubs y where x.pubid = y.pubid and x.authorid != y.authorid);

--coauthors from X random articles from each area with names; treats as an undirected edge so no duplicates
create temporary table coaCluster as
(with pubs as
(select a.authorid, temp.pubid, temp.area from (
select i.pubid, c.area, row_number() over (partition by c.area order by random()) rn from inproceedings i, topX c where i.booktitle = c.booktitle) temp, topauthored a where temp.pubid = a.pubid and rn <= 5000)
select distinct replace(least(ax.name,ay.name),' ', '_') as a1, replace(greatest(ax.name,ay.name),' ', '_') as a2 from pubs x, pubs y, topauthor ax, topauthor ay where x.pubid = y.pubid and x.authorid != y.authorid and x.authorid = ax.authorid and y.authorid = ay.authorid);

--finds areas of authors as percentages
select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percentage from topauthored as au, inproceedings as i, topX as c where au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by au.authorid, c.area;

--finds minimum and max percentage per author
select temp.authorid, min(percentage) min, max(percentage) max from 
(select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percentage from topauthored as au, inproceedings as i, topX as c where au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by au.authorid, c.area) as temp
group by temp.authorid;

--outputs research area of authors of interest with threshold
select temp.authorid, temp.area, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent from
(select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percent2 from topauthored au, inproceedings i, topX c where  au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by c.area) as temp
where temp.percent2 >= 0.2;

--outputs research area of particular author of interest with threshold
select temp.authorid, temp.area, (temp.count)/sum(temp.count) over (partition by temp.authorid) percent from
(select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percent2 from topauthored au, inproceedings i, topX c where au.authorid in (481717,13823,175838,555747,531381,728808,352489,720833) and au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by c.area) as temp
where temp.percent2 >= 0.2;

--create weighted coauthors
create temporary table coauthorsLarge as 
select  au.a1 as author1, au.a2 as author2, count(*) as weight
from coaCluster au, topauthored at1, topauthored at2
where au.a1 = at1.authorid and au.a2 = at2.authorid and at1.pubid = at2.pubid
group by au.a1, au.a2;

--finds number of research areas authors are in using different thresholds
select temp2.count, count(*) from
(select temp.authorid, count(*) count from
    (select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percent2 from topauthored au, inproceedings i, topX c where au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by c.area) as temp
where temp.percent2 >= 0.25 group by temp.authorid) as temp2
group by temp2.count order by temp2.count desc;

/*
With 0.05
 count | count  
-------+--------
     7 |      1
     6 |     43
     5 |    133
     4 |    575
     3 |   2569
     2 |  13223
     1 | 120192

With 0.1
 count | count  
-------+--------
     6 |      4
     5 |     59
     4 |    388
     3 |   2231
     2 |  13016
     1 | 121038

With 0.15
 count | count  
-------+--------
     5 |     13
     4 |    151
     3 |   1653
     2 |  12618
     1 | 122301

With 0.2
 count | count  
-------+--------
     5 |      3
     4 |     71
     3 |   1237
     2 |  12203
     1 | 123222

With 0.25
 count | count  
-------+--------
     4 |     36
     3 |    835
     2 |  11352
     1 | 124508
*/

-- create table for conference graph which create one row for every coauthorship (including authoring with oneself) where the value is the frequency
create temporary table tempA as 
(select  au.a1 as author1, au.a2 as author2, i.booktitle conference, count(*) as weight
from coaCluster au, topauthored at1, topauthored at2, inproceedings i
where au.a1 = at1.authorid and au.a2 = at2.authorid and at1.pubid = at2.pubid and at1.pubid = i.pubid
group by au.a1, au.a2, i.booktitle)
union
(select a.authorid author1, a2.authorid author2, i.booktitle conference, count(*) as weight
from topauthored a, topauthored a2, inproceedings i
where a.authorid in
    (select distinct(a1) from coaCluster)
    and a.pubid = a2.pubid and a2.pubid = i.pubid and a.authorid = a2.authorid
group by a.authorid, a2.authorid, i.booktitle);

select temp.authorid, temp.area from
(select au.authorid, c.area, count(*) count, (count(*))/sum(count(*)) over (partition by au.authorid) percent2 from topauthored au, inproceedings i, topX c where au.pubid = i.pubid and i.booktitle = c.booktitle group by au.authorid, c.area order by c.area) as temp
where temp.percent2 < 0.2;