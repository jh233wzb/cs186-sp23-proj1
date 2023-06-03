-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era) FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE namefirst LIKE '% %' ORDER BY namefirst, namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*) FROM people GROUP BY birthyear ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*) FROM people GROUP BY birthyear HAVING AVG(height) > 70 ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, playerid, yearid 
  FROM people 
  NATURAL JOIN HallofFame 
  WHERE HallofFame.inducted = 'Y' 
  ORDER BY yearid DESC, playerid ASC
;

-- Question 2ii
DROP VIEW IF EXISTS CAcollege;
CREATE VIEW IF NOT EXISTS CAcollege(playerid, schoolid)
AS
  SELECT c.playerid, c.schoolid
  FROM CollegePlaying c  INNER JOIN schools s
  ON c.schoolid = s.schoolid
  WHERE s.schoolState = 'CA'
;

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, schoolid, yearid
  FROM q2i q JOIN CAcollege c
/*
  (
    SELECT c.playerid, c.schoolid FROM CollegePlaying c INNER JOIN schools s ON c.schoolid = s.schoolid WHERE s.schoolState = 'CA'
  ) c 
*/
  ON c.playerid = q.playerid
  ORDER BY yearid DESC, schoolid, q.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid 
  FROM q2i q LEFT JOIN CollegePlaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid
;

-- Question 3i
DROP VIEW IF EXISTS slg;
CREATE VIEW IF NOT EXISTS slg(playerid, yearid, AB, slgval)
AS
  SELECT playerid, yearid, AB, CAST((H + H2B + 2 * H3B + 3 * HR) AS FLOAT) / CAST(AB AS FLOAT)
-- (H + H2B + 2 * H3B + 3 * HR + 0.0) / (AB + 0.0)
  FROM batting
;

CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.yearid, s.slgval
  FROM people p INNER JOIN slg s
  ON p.playerid = s.playerid
  WHERE s.AB > 50
  ORDER BY s.slgval DESC, s.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
DROP VIEW IF EXISTS lslg;
CREATE VIEW IF NOT EXISTS lslg(playerid, lslgval)
AS 
  SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0) / (SUM(AB) + 0.0)
  FROM batting
  GROUP BY playerid
  HAVING SUM(AB) > 50
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  ORDER BY l.lslgval DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst, p.namelast, l.lslgval
  FROM people p JOIN lslg l
  ON p.playerid = l.playerid
  WHERE l.lslgval > (
    SELECT lslgval
    FROM lslg
    WHERE playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(s.salary), MAX(s.salary), AVG(s.salary)
  FROM people p JOIN salaries s
  ON p.playerid = s.playerid
  GROUP BY yearid
  ORDER BY yearid ASC 
;

-- Question 4ii
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS stat_2016;
CREATE VIEW IF NOT EXISTS stat_2016(min_, width_)
AS
  SELECT MIN(s.salary) AS min_ , CAST(((MAX(s.salary)-MIN(s.salary))/10) AS INT) AS width_ 
  FROM salaries s
  WHERE yearid = '2016'
;
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, min_ + binid * width_, min_ + (binid+1) * width_, count(*)
  FROM binids JOIN (salaries JOIN  stat_2016)
  WHERE yearid = '2016' AND (salary BETWEEN min_ + binid * width_ AND min_ + (binid+1) * width_)
  GROUP BY binid
;

-- Question 4iii
DROP VIEW IF EXISTS stat;
CREATE VIEW IF NOT EXISTS stat(yearid, min_, max_, avg_)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries 
  GROUP BY yearid;
;
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, (s1.min_ - s2.min_), (s1.max_ - s2.max_), (s1.avg_ - s2.avg_)
  FROM stat s1 INNER JOIN stat s2
  WHERE s1.yearid - 1 = s2.yearid
  ORDER BY s1.yearid
;

-- Question 4iv
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS max_sa;
CREATE VIEW IF NOT EXISTS max_sa(playerid, salary, yearid)
AS
  SELECT playerid, salary, yearid
  FROM salaries
  WHERE (yearid = 2000 AND salary = (SELECT MAX(salary) FROM salaries s1 WHERE yearid = 2000)) 
        OR (yearid = 2001 AND salary = (SELECT MAX(salary) FROM salaries s2 WHERE yearid = 2001))
;
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, m.salary, m.yearid
  FROM people p NATURAL JOIN max_sa m
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, (MAX(s.salary) - MIN(s.salary))
  FROM allstarfull a JOIN salaries s
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

