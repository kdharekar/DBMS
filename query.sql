--1--
select output.match_id, output.player_name, output.team_name, sum(wicket) as num_wickets 
from (SELECT ball_by_ball.match_id, player_name , team_name, player_out, 1 as wicket
  FROM ball_by_ball , wicket_taken,player, team
    where ball_by_ball.match_id = wicket_taken.match_id and ball_by_ball.over_id = wicket_taken.over_id and ball_by_ball.ball_id = wicket_taken.ball_id and ball_by_ball.innings_no = wicket_taken.innings_no and player_id = bowler and team_id = team_bowling  and 
case
when wicket_taken.kind_out = 1 then true
when  wicket_taken.kind_out = 2 then true
when wicket_taken.kind_out = 4 then true
when wicket_taken.kind_out = 6 then true
when wicket_taken.kind_out = 7 then true
when wicket_taken.kind_out = 8 then true
else false
end 
) as output
group by match_id,player_name,team_name
having  sum(wicket) >=5
order by num_wickets  desc ,player_name, team_name;

--2--
select player_name, sum(count1) as num_matches from 
(select match.match_id,player_name, 1 as count1
from match, player_match, player
where match.match_id = player_match.match_id and player_match.player_id = man_of_the_match and match_winner is not null and team_id != match_winner and player.player_id = player_match.player_id  ) as output
group by player_name 
order by num_matches desc, player_name
limit 3
;

--3--
select player_name, sum(count1) as catches 
from (select match.match_id,player_name, 1 as count1
from match, wicket_taken,player,player_match
where match.match_id = wicket_taken.match_id and season_id = 5 and player_match.match_id =match.match_id and player_match.player_id = player.player_id and wicket_taken.fielders = player_match.player_id and 
case when role_id = 1 then true
when role_id = 3 then true
else false
end
 and 
case when kind_out = 1 then true
when kind_out = 7 then true
else false
end
) as output
group by player_name
order by catches desc,player_name
limit 1;

--4--
select season_year, player_name , sum(count1) as num_matches
from (select season_year,player_name,1 as count1
from season,player_match,match,player
where player.player_id = player_match.player_id and match.match_id = player_match.match_id and season.season_id = match.season_id  and player.player_id = purple_cap
) as output
group by season_year, player_name
order by season_year;

--5--
select player_name  
from match, player_match, player, batsman_scored, ball_by_ball
where match.match_id = player_match.match_id and player_match.player_id = player.player_id and player_match.match_id = batsman_scored.match_id and player_match.match_id = ball_by_ball.match_id and ball_by_ball.over_id = batsman_scored.over_id and ball_by_ball.ball_id = batsman_scored.ball_id and ball_by_ball.innings_no = batsman_scored.innings_no and striker = player.player_id and match_winner = team_bowling and runs_scored>0 
group by match.match_id, player_name
having sum(runs_scored)>50
order by player_name
;

--6--
;

--7--
select team_name
from (select team_name, sum(count1) as count2
from (select team_name, 1 as count1
from match, team 
where season_id = 2 and match_winner is not null and team.team_id=match_winner 
) as output
group by team_name)
as output1
order by count2 desc, team_name; 

--8--
select team_name,player_name ,runs
from (
select team_name,player_name , sum(runs_scored) as runs,  RANK() over (
partition by team_name
order by sum(runs_scored) desc
)
from match, player_match, player, batsman_scored, ball_by_ball,team
where team.team_id = player_match.team_id and match.match_id = player_match.match_id and player_match.player_id = player.player_id and player_match.match_id = batsman_scored.match_id and player_match.match_id = ball_by_ball.match_id and ball_by_ball.over_id = batsman_scored.over_id and ball_by_ball.ball_id = batsman_scored.ball_id and ball_by_ball.innings_no = batsman_scored.innings_no and striker = player.player_id and runs_scored>0 and season_id = 3 
group by team_name, player_name
order by runs desc
, player_name) as value
where rank = 1;


--9--
select ta.team_name as team_name,tb.team_name as opponent_team_name,  floor(sum(runs_scored/6)) as "number of sixes", match.match_id
from team as ta,team as tb,  match , batsman_scored , ball_by_ball
where ta.team_id = team_batting and ball_by_ball.match_id = batsman_scored.match_id and ball_by_ball.match_id = match.match_id and ball_by_ball.over_id = batsman_scored.over_id and ball_by_ball.ball_id = batsman_scored.ball_id and  ball_by_ball.innings_no = batsman_scored.innings_no 
and runs_scored=6 and season_id = 1 and tb.team_id = team_bowling
group by ta.team_name, tb.team_name,match.match_id
order by "number of sixes" desc, ta.team_name
limit 3;

--10--
;

--11--
select t3.season_year,t3.player_name,t1.num_wickets,runs
from (select season_year,player.player_id, sum(1) as num_wickets
from player, match , player_match, ball_by_ball, wicket_taken , season
where player.player_id = player_match.player_id and match.match_id = player_match.match_id and player_match.match_id = ball_by_ball.match_id and player_match.match_id = wicket_taken.match_id and wicket_taken.over_id = ball_by_ball.over_id and wicket_taken.ball_id = ball_by_ball.ball_id and  wicket_taken.innings_no = ball_by_ball.innings_no and batting_hand = 1 and season.season_id = match.season_id and bowler = player.player_id and 
case
when wicket_taken.kind_out = 3 then false
when wicket_taken.kind_out = 5 then false
when wicket_taken.kind_out = 9 then false
else true
end
group by season_year,player.player_id) as t1 , 

(select season_year,player.player_id, sum(runs_scored) as runs 
from player, match , player_match, ball_by_ball, batsman_scored , season
where player.player_id = player_match.player_id and match.match_id = player_match.match_id and player_match.match_id = ball_by_ball.match_id and player_match.match_id = batsman_scored.match_id and batsman_scored.over_id = ball_by_ball.over_id and batsman_scored.ball_id = ball_by_ball.ball_id and  batsman_scored.innings_no = ball_by_ball.innings_no and batting_hand = 1 and season.season_id = match.season_id and striker = player.player_id 
group by season_year,player.player_id) as t2 ,
(select season_year,player.player_id,player.player_name ,sum(1) as played
from player,match,player_match , season
where
player.player_id = player_match.player_id and match.match_id = player_match.match_id and batting_hand=1 and season.season_id = match.season_id 
group by season_year,player.player_id,player.player_name )
as t3
where t2.runs >= 150 and t1.num_wickets>=5 and t3.played >= 10 and t3.player_id = t1.player_id and t3.player_id = t2.player_id and t1.season_year = t2.season_year and t1.season_year = t3.season_year
group by t3.season_year,t3.player_name,runs,num_wickets
order by num_wickets desc, runs desc, player_name;

--12--
;

--13--
;

--14--
;

--15--
;

--16--
;

--17--
;

--18--
;

--19--
;

--20--
;

--21--
;

--22--
;
