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
--233
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
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT 1, 1, 1, 1, 1 -- replace this line
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT 1, 1 -- replace this line
;

