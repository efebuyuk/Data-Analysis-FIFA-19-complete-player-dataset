/*
Developed by: Efe Buyuk
Dated by: 21/11/2020
*/

/* NOTES */
/*
-- let's say our team's formation will be 4-4-2
-- we need
---- a goalkeeper which is GK
---- 4 defenders in positions like DR, DL, DC and DC
---- 4 midfielders in positions like MR, ML, MC and MC
---- 2 strikers in positions like ST and ST
*/

/*
What are the most important attributes for a GK?
1. Reflexes
2. Diving
3. Positioning
4. Handling
5. Kicking
6. Speed
*/

-- Search for GK by comparing other GK's AVG values
WITH all_gk AS ( -- Create a temporary table for all GKs
    SELECT 'All Players', 'ALL GKs', 'Contract Valid Until',
        ROUND(AVG(gk.GKReflexes), 1) AS AVG_Reflexes, ROUND(AVG(gk.GKDiving), 1) AS AVG_Diving,
        ROUND(AVG(gk.Positioning), 1) AS AVG_Positioning, ROUND(AVG(gk.GKHandling), 1) AS AVG_Handling,
        ROUND(AVG(gk.GKKicking), 1) AS AVG_Kicking, ROUND(AVG(gk.SprintSpeed), 1) AS AVG_SprintSpeed
    FROM fifa19_dataset AS gk
    WHERE Position = 'GK'
)

-- Search for GK
SELECT  players.name, players.Position, players."Contract Valid Until", players.Value,
        GKReflexes, GKDiving, Positioning, GKHandling, GKKicking, SprintSpeed
FROM fifa19_dataset AS players
WHERE players.Position = 'GK'
    AND players.GKReflexes > (SELECT AVG_Reflexes FROM all_gk)
    AND players.GKDiving > (SELECT AVG_Diving FROM all_gk)
    AND players.Positioning > (SELECT AVG_Positioning FROM all_gk)
    AND players.GKHandling > (SELECT AVG_Handling FROM all_gk)
    AND players.GKKicking > (SELECT AVG_Kicking FROM all_gk)
    AND players.SprintSpeed > (SELECT AVG_SprintSpeed FROM all_gk)
    AND players."Contract Valid Until" < 2021
    AND players.Value LIKE '_1_M'; -- GK's value should be around 10M

/*
What are the most important attributes for a Defence Player?
1. Heights: ex - 5'7
2. Jumping
3. Agility
4. Long Passing
5. Short Passing
6. Ball Control
*/

-- Search for Defence Players by comparing other Defence Players' AVG values
WITH all_defence AS ( -- Create a temporary table for all Defence Players
    SELECT 'All Players', 'ALL Defence', 'Contract Valid Until',
        ROUND(AVG(d.Height), 1) AS AVG_Height, ROUND(AVG(d.Jumping), 1) AS AVG_Jumping,
        ROUND(AVG(d.Agility), 1) AS AVG_Agility, ROUND(AVG(d.LongPassing), 1) AS AVG_LPassing,
        ROUND(AVG(d.ShortPassing), 1) AS AVG_SPassing, ROUND(AVG(d.BallControl), 1) AS AVG_BControl
    FROM fifa19_dataset AS d
    WHERE (d.Position = 'CB' OR d.Position = 'RB' OR d.Position = 'LB')
)

-- Search for Defence Players
SELECT  players.name, players.Position, players."Contract Valid Until", players.Value,
        Height, Jumping, Agility, LongPassing, ShortPassing, BallControl
FROM fifa19_dataset AS players
WHERE (players.Position = 'CB' OR players.Position = 'RB' OR players.Position = 'LB')
    AND players.Height > (SELECT AVG_Height FROM all_defence)
    AND players.Jumping > (SELECT AVG_Jumping FROM all_defence)
    AND players.Agility > (SELECT AVG_Agility FROM all_defence)
    AND players.LongPassing > (SELECT AVG_LPassing FROM all_defence)
    AND players.ShortPassing > (SELECT AVG_SPassing FROM all_defence)
    AND players.BallControl > (SELECT AVG_BControl FROM all_defence)
    AND players."Contract Valid Until" < 2021
    AND players.Value LIKE '_1_M' -- Defense Players' value should be around 10M
;

/*
What are the most important attributes for a Midfielder Player?
1. high/high work rates
2. stamina
3. short passing
4. long shot
*/

/*
What are the most important attributes for a Attacker Player?
1. short passing
2. long shot
3. ball control
4. strength
5. finishing
*/


WITH -- Prepare temporary tables for defence, midfielder and striker(attacker) players
    all_defences AS ( -- Create a temporary table for all Defence Players
    SELECT  d.id, d.name, d.Position, d."Contract Valid Until", d.Value, d.ShortPassing, d.BallControl, d.LongShots -- common fields
            ,d.Height, d.Jumping, d.Agility, d.LongPassing -- extra fields for defenders
            ,d.Stamina, d."Work Rate" -- extra fields for midfielders
            ,d.Strength, d.Finishing -- extra fields for attackers
    FROM    fifa19_dataset AS d
    WHERE   (d.Position = 'CB' OR d.Position = 'RB' OR d.Position = 'LB')
),
    all_midfielders AS ( -- Create a temporary table for all Midfielder Players
        SELECT  m.id, m.name, m.Position, m."Contract Valid Until", m.Value, m.ShortPassing, m.BallControl, m.LongShots -- common fields
            ,m.Height, m.Jumping, m.Agility, m.LongPassing -- extra fields for defenders
            ,m.Stamina, m."Work Rate" -- extra fields for midfielders
            ,m.Strength, m.Finishing -- extra fields for attackers
    FROM    fifa19_dataset AS m
    WHERE   (m.Position = 'CM' OR m.Position = 'RM' OR m.Position = 'LM')
),
    all_attackers AS ( -- Create a temporary table for all Attacker Players
    SELECT  a.id, a.name, a.Position, a."Contract Valid Until", a.Value, a.ShortPassing, a.BallControl, a.LongShots -- common fields
            ,a.Height, a.Jumping, a.Agility, a.LongPassing -- extra fields for defenders
            ,a.Stamina, a."Work Rate" -- extra fields for midfielders
            ,a.Strength, a.Finishing -- extra fields for attackers
    FROM    fifa19_dataset AS a
    WHERE   a.Position = 'ST'
)

-- Search for Defense, Midfielder and Striker(Attacker) Players at once
SELECT *
FROM all_defences AS d
WHERE d.Height > 5 AND d.Jumping > 65 AND d.Agility > 65
    AND d.LongPassing > 65 AND d.ShortPassing > 65 AND d.BallControl > 65
    AND "Contract Valid Until" LIKE '%2021'
    AND (value LIKE '_1_M' OR value LIKE '_1_._M')
UNION ALL
SELECT *
FROM all_midfielders AS m
WHERE m."Work Rate" = 'High/ High' AND m.Stamina > 70 AND m.ShortPassing > 70
    AND m.LongShots > 70
    AND "Contract Valid Until" LIKE '%2021'
    AND (value LIKE '_1_M' OR value LIKE '_1_._M')
UNION ALL
SELECT *
FROM all_attackers AS a
WHERE a.ShortPassing > 70 AND a.LongShots > 70 AND a.BallControl >70
    AND a.Strength AND a.Finishing > 70
    AND "Contract Valid Until" LIKE '%2021'
    AND (value LIKE '_2_M' OR value LIKE '_2_._M')
ORDER BY Position DESC
;

