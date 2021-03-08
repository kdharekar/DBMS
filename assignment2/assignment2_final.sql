--PREAMBLE--

--1--
with recursive reacheable(carrier,destairportid) as (
       select carrier,destairportid from 
	flights
	where originairportid =  10140 

union	
select flights.carrier,flights.destairportid 
	from flights, reacheable
	where reacheable.destairportid = flights.originairportid and flights.carrier = reacheable.carrier 
)

select city
from reacheable , airports
where reacheable.destairportid = airportid
order by city
;

--2--
with recursive reacheable(day,destairportid) as (
       select dayofweek,destairportid from 
	flights
	where originairportid =  10140 

union	
select day,flights.destairportid 
	from flights, reacheable
	where reacheable.destairportid = flights.originairportid and day = dayofweek 
)

select city
from reacheable , airports
where reacheable.destairportid = airportid
order by city
;

--3--
  WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, array[originairportid] as seen  , false as cycle
        FROM flights
	where originairportid =  10140 
        UNION ALL
        SELECT prev.originairportid,flights.destairportid, seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
	
    )
	select city	
  from (SELECT destairportid , count(*)
    FROM prev
    group by destairportid
	having count(*)=1) as c , airports
	where c.destairportid = airports.airportid
	order by city
;

--4--
  WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, 1 as depth ,array[originairportid] as seen  , false as cycle
        FROM flights
	where originairportid =  10140 
        UNION ALL
        SELECT prev.originairportid,flights.destairportid,prev.depth + 1 ,seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
    )
	select case  length when  NULL then 0 else v.length END  as length from(
	select max(depth) -1 as length
	from prev
	where prev.originairportid = prev.destairportid
)  as v
;

--5--
    WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, 1 as depth ,array[originairportid] as seen  , false as cycle
        FROM flights
        UNION ALL
        SELECT prev.originairportid,flights.destairportid,prev.depth + 1 ,seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
    )
	select case  length when  NULL then 0 else v.length END  as length from(
	select max(depth) -1 as length from prev where cycle = true and prev.originairportid = prev.destairportid )as v
;

--6--
 WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, array[originairportid] as seen  , false as cycle
        FROM flights
	where originairportid =  10140 
        UNION ALL
        SELECT prev.originairportid,flights.destairportid, seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
	
    )
select count	
from (SELECT originairportid,destairportid , count(*) 
    FROM prev,airports
	where airports.airportid=destairportid and airports.city = 'Chicago' 
    group by destairportid ,originairportid
	) as v

;

--7--
 WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, array[originairportid] as seen  , false as cycle
        FROM flights
	where originairportid =  10140 
        UNION ALL
        SELECT prev.originairportid,flights.destairportid, seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
	
    )
select count	
from (SELECT originairportid,destairportid , count(*) 
    FROM prev,airports,(select airportid as bet from airports where airports.city = 'Washington') as u 
	where airports.airportid=destairportid and airports.city = 'Chicago' and bet = any(seen)
    group by destairportid ,originairportid
	) as v

;

--8--
WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid, array[originairportid] as seen  , false as cycle
        FROM flights
        UNION ALL
        SELECT prev.originairportid,flights.destairportid, seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false 
    )
     ( select a1.city as name1, a2.city as name2
	from airports as a1 , airports as a2
	where a1.city != a2.city
   except 
	select a1.city as name1 , a2.city as name2 from prev,airports as a1 , airports as a2
	where prev.originairportid = a1.airportid and prev.destairportid = a2.airportid
)
order by name1 , name2
 ;

--9--
select dayofmonth as day
from(
select dayofmonth,sum(departuredelay+arrivaldelay) as delay from flights where 
originairportid = 10140
group by dayofmonth
order by delay,dayofmonth) as v
order by v.delay,v.dayofmonth;

--10--
select v2.city1 as name from ( 
select city1 , sum(val)
from (
select a1.city as city1 , a2.city, 1 as val
from flights, (select * from airports where  state = 'New York') as a1, (select * from airports where  state = 'New York') as a2 
where a1.city != a2.city and a1.airportid = originairportid and a2.airportid = destairportid
group by a1.city , a2.city
) as v
group by city1
having sum(val) = (select count(*) from airports as a1 where a1.state = 'New York')-1) as v2
order by city1;

--11--
WITH RECURSIVE prev AS (
        SELECT originairportid,destairportid,(arrivaldelay + departuredelay) as delay,1 as depth,  array[originairportid] || array[destairportid] as seen  , false as cycle
        FROM flights
        UNION ALL
        SELECT prev.originairportid,flights.destairportid,(arrivaldelay + departuredelay) as delay, depth +1,seen || flights.destairportid as seen,
            flights.destairportid = any(seen) as cycle
        FROM prev
        INNER JOIN flights on prev.destairportid = flights.originairportid
        AND prev.cycle = false and flights.arrivaldelay+flights.departuredelay >= prev.delay
    )
     select originairportid as name1, destairportid as name2 
     from prev 
	where depth > 1
	group by originairportid,destairportid
	order by name1,name2
 ;

--12--
WITH RECURSIVE prev AS (
        SELECT l.authorid as a1,k.authorid as a2,1 as depth, array[l.authorid]||array[k.authorid] as seen  , false as cycle
        FROM authorpaperlist as l , authorpaperlist as k
	where l.paperid = k.paperid and l.authorid = 1235 and l.authorid != k.authorid
        UNION ALL
        SELECT a1,k.authorid,depth + 1,p1.seen || k.authorid as seen,
            k.authorid = any(seen) as cycle
        FROM prev as p1 inner join  authorpaperlist as l on p1.a2 = l.authorid 
	 inner join authorpaperlist as k on l.paperid = k.paperid and l.authorid != k.authorid
         where a1 = 1235 
        AND p1.cycle = false 
    )  
select a2 as authorid , max(minimum) as length from
(select a2,min(depth) as minimum 
from prev
group by a1,a2
union
select authorid as a2, -1 as minimum
from authordetails)
as v1
group by a2
order by length desc , a2
;

--13--

--14--

--15--

--16--

--17--

--18--

--19--

--20--

--21--

--22--

--CLEANUP--
