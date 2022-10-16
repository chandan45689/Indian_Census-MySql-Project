use indian_census;

select * from ds1;

select * from ds2;

-- number of rows into our dataset

select count(*) from ds1;
select count(*) from ds2;

-- dataset for jharkhand and bihar

select * from ds1 where state in ("jharkhand", "Bihar");
select * from ds2 where state in ("jharkhand", "Bihar");

-- population of India

select sum(population) Total_Population from ds2;

-- avg growth rate of India

select state, avg(growth) from ds1 group by state;

-- avg sex ratio

select state, round(avg(sex_ratio),0) sex_ratio from ds1 group by state order by sex_ratio desc;

-- avg literacy rate

select state, round(avg(literacy),0) from ds1 
group by state having round(avg(literacy),0)   > 90 order by literacy desc;

-- Top 3 state having highest growth ratio

select state, avg(growth) from ds1 group by state order by state desc limit 3;

-- bottom 3 state having lowest sex_ratio

select state, avg(sex_ratio) from ds1 group by state order by state  limit 3;

-- top and bottom 3 states in literacy rate
create table topstates(state varchar(50), topstate float);

insert into topstates(
select state, avg(literacy) from ds1 
group by state order by literacy desc limit 3
);

select * from topstates;

drop table topstates;
create table bottomstates(state varchar(50), bottomstate float);

insert into bottomstates(
select state, avg(literacy) from ds1 
group by state  order by literacy limit 3
);

select * from bottomstates;

-- union operator

select * from topstates 
union
select * from bottomstates;

-- states starting with letter 'a'

select * from ds1 where state like 'a%';
select * from ds2 where state like 'a%';

select * from ds1 where state like 'a%' and state like '%b';


-- joining two tables
select d.district, d.state, sum(d.males) total_males, sum(d.females) total_females from
(select c.district, c.state, round(c.population/(c.sex_ratio+1)*1000,0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1)*1000,0) females from 
(select a.district, a.state, sex_ratio, population from ds1 a inner join ds2 b on a.district=b.district)c)d
group by d.state;

-- Total Literacy rate
select d.district, d.state, sum(total_literate_people), sum(total_illiterate_people) from
(select c.district, c.state, round(c.population*c.literacy_ratio,0) total_literate_people, round((1 - c.literacy_ratio)* c.population,0) total_illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio,  b.population from ds1 a inner join ds2 b on a.district=b.district)c)d
group by d.state;


-- population in previous censor

select sum(e.previous_census_population), sum(e.current_census_population) from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population)
current_census_population from
(select c.district, c.state, round(c.population/(1 + c.growth)*1000,0) previous_census_population, c.population current_census_population from 
(select a.district, a.state, a.growth growth, b.population from ds1 a inner join ds2 b on a.district=b.district)c)d
group by d.state)e;

-- population vs area_km2
select j.total_area/j.previous_census_population as previous_census_population_vs_area, j.total_area/j.current_census_population as current_census_population_vs_area from
(select h.*, i.total_area from
(select '1' as keyy, f.* from
(select sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population)
current_census_population from
(select c.district, c.state, round(c.population/(1 + c.growth)*1000,0) previous_census_population, c.population current_census_population from 
(select a.district, a.state, a.growth growth, b.population from ds1 a inner join ds2 b on a.district=b.district)c)d
group by d.state)e)f)h
inner join (
select '1' as keyy, g.* from 
(select sum(area_km2) total_area from ds2)g)i on h.keyy = i.keyy)j;