# Задание 

1. Для Олимпийских игр 2004 года сгенерируйте список (год рождения, количество игроков, количество золотых медалей), содержащий годы, в которые родились игроки, количество игроков, родившихся в каждый из этих лет, которые выиграли по крайней мере одну золотую медаль, и количество золотых медалей, завоеванных игроками, родившимися в этом году.  
```sql
select extract(year from birthdate) as "year", count(players.player_id) as "players", sum(golden_medals) as "golden_medals"
from players, (
         select results.player_id, count(results.player_id) as "golden_medals"
         from results
         where results.event_id in (
             select event_id
             from events,
                  olympics
             where olympics.year = 2004
               and events.olympic_id = olympics.olympic_id
         )
           and results.medal = 'GOLD'
         group by results.player_id
         having count(results.player_id) > 0
     ) as gold_medalists
where players.player_id = gold_medalists.player_id
group by extract(year from birthdate);
```  
2. Перечислите все индивидуальные (не групповые) соревнования, в которых была ничья в счете, и два или более игрока выиграли золотую медаль.  
```sql
select event_id
from results
where results.event_id in (
        select events.event_id
        from events
        where is_team_event = 0
    )
group by event_id, result
having count(result) > 1
intersect
select event_id
from results
where results.event_id in (
        select events.event_id
        from events
        where is_team_event = 0
    )
    and medal = 'GOLD'
group by event_id
having count(event_id) > 1;
```  
3. Найдите всех игроков, которые выиграли хотя бы одну медаль (GOLD, SILVER и
BRONZE) на одной Олимпиаде. (player-name, olympic-id).  
```sql
select players.name, olympic_id
from players, results, events
where players.player_id = results.player_id
    and results.event_id = events.event_id
group by players.name, olympic_id;
```  
4. В какой стране был наибольший процент игроков (из перечисленных в наборе данных), чьи имена начинались с гласной?  
```sql
select countries.country_id
from countries, players
where players.name similar to '(A|E|I|O|U)%'
  and countries.country_id = players.country_id
group by countries.country_id
order by count(1)
desc limit 1
```  
5.  Для Олимпийских игр 2000 года найдите 5 стран с минимальным соотношением количества групповых медалей к численности населения.  
```sql
```  
