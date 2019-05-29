/* The following SQL script uses a country club database with three tables,
providing details on the Facilities, Bookings, and Members. The main goal is to 
show the use of SQL to answer business and organizational questions and improve
decision making when it comes to resource allocation and revenue
 */

--Cases

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT f.name
FROM country_club.Facilities f
WHERE membercost !=0

/* OUTPUT
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(f.name) AS facilities_no_charge
FROM country_club.Facilities f
WHERE f.membercost =0

-- OUTPUT: 4

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance
FROM country_club.Facilities f
WHERE membercost < (monthlymaintenance*.20)


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
CASE WHEN monthlymaintenance < 100 THEN 'cheap'
  ELSE 'expensive' END AS costs
FROM country_club.Facilities

/*
name            costs
Tennis Court 1  expensive
Tennis Court 2  expensive
Badminton Court cheap
Table Tennis    cheap
Massage Room 1  expensive
Massage Room 2  expensive
Squash Court    cheap
Snooker Table   cheap
Pool Table      cheap */


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname, firstname
FROM country_club.Members
ORDER BY joindate DESC

/* PARTIAL OUTPUT:
surname     firstname
Smith       Darren
Crumpet     Erica
Hunt        John
Tupperware  Hyacinth
Purview     Millicent
*/


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(m.surname, ', ',m.firstname) as full_name,
f.name as court_name
FROM Facilities f
JOIN Bookings b 
ON b.facid = f.facid JOIN Members m
ON b.memid = m.memid
WHERE b.facid IN (0,1)
ORDER BY full_name

/*
PARTIAL OUTPUT
full_name         court_name
Bader, Florence   Tennis Court 1
Bader, Florence   Tennis Court 2
Baker, Anne       Tennis Court 2
Baker, Anne       Tennis Court 1
Baker, Timothy    Tennis Court 2
Baker, Timothy    Tennis Court 1
Boothe, Tim       Tennis Court 1
*/

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name as facility_name, CONCAT(m.surname, ', ',m.firstname) as member_name,
  CASE WHEN m.surname LIKE '%GUEST%' THEN b.slots * f.guestcost
    WHEN m.surname NOT LIKE '%GUEST%' THEN b.slots * f.membercost
  END as day_cost  
FROM country_club.Bookings b
JOIN country_club.Facilities f
ON b.facid = f.facid
JOIN country_club.Members m
ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
HAVING day_cost >30
ORDER BY day_cost DESC
LIMIT 100

/* OUTPUT

facility_name     member_name     day_cost Descending
Massage Room 2    GUEST, GUEST    320.0
Massage Room 1    GUEST, GUEST    160.0
Massage Room 1    GUEST, GUEST    160.0
Massage Room 1    GUEST, GUEST    160.0
Tennis Court 2    GUEST, GUEST    150.0
Tennis Court 1    GUEST, GUEST    75.0
Tennis Court 1    GUEST, GUEST    75.0
Tennis Court 2    GUEST, GUEST    75.0
Squash Court      GUEST, GUEST    70.0
Massage Room 1    Farrell, Jemima 39.6
Squash Court      GUEST, GUEST    35.0
Squash Court      GUEST, GUEST    35.0

*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT s.facility_name, CONCAT(m.surname, ', ',m.firstname) as member_name, day_cost
FROM country_club.Members m
JOIN(
    SELECT m.memid, f.name as facility_name,
    CASE WHEN m.surname LIKE '%GUEST%' THEN b.slots * f.guestcost
      WHEN m.surname NOT LIKE '%GUEST%' THEN b.slots * f.membercost
      END as day_cost  
    FROM country_club.Bookings b
	JOIN country_club.Facilities f
	ON b.facid = f.facid
	JOIN country_club.Members m
	ON b.memid = m.memid
	WHERE b.starttime LIKE '2012-09-14%'
    ) s
ON m.memid = s.memid
HAVING s.day_cost >30
ORDER BY s.day_cost DESC
LIMIT 100


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT s.facility_name, SUM(s.day_cost) as revenue
FROM (
    SELECT f.name as facility_name, b.starttime,
    CASE WHEN m.surname LIKE '%GUEST%' THEN b.slots * f.guestcost
      WHEN m.surname NOT LIKE '%GUEST%' THEN b.slots * f.membercost
      END as day_cost  
    FROM country_club.Bookings b
	JOIN country_club.Facilities f
	ON b.facid = f.facid
	JOIN country_club.Members m
	ON b.memid = m.memid
    ) s
GROUP BY s.facility_name
HAVING revenue < 1000
ORDER BY s.day_cost DESC
LIMIT 100