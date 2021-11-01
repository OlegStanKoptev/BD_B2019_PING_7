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
select countries.name, qty_players_by_country_vowels.cnt * 100.0 / qty_players_by_country.cnt as percentage
from countries, (
        select players.country_id, count(players.country_id) as cnt
        from players
        group by players.country_id
        order by count(players.country_id)
        desc
    ) as qty_players_by_country, (
        select players.country_id, count(players.country_id) as cnt
        from players
        where players.name similar to '(A|E|I|O|U)%'
        group by players.country_id
        order by count(players.country_id)
        desc
    ) as qty_players_by_country_vowels
where countries.country_id = qty_players_by_country.country_id
      and qty_players_by_country.country_id = qty_players_by_country_vowels.country_id
order by percentage desc, countries.country_id
limit 1;
```  
5.  Для Олимпийских игр 2000 года найдите 5 стран с минимальным соотношением количества групповых медалей к численности населения.  
```sql
select countries.country_id
from (
    select players.country_id, count(players.country_id) as qty_group_medal
    from olympics, events, results, players
    where olympics.year = 2004
        and events.olympic_id = olympics.olympic_id
        and events.event_id = results.event_id
        and events.is_team_event = 1
        and results.player_id = players.player_id
    group by players.country_id
    ) as group_medals_by_countries, countries
where group_medals_by_countries.country_id = countries.country_id
order by group_medals_by_countries.qty_group_medal * 1.0 / countries.population
limit 5;
```  
