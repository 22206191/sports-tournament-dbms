-- Query 1: All matches with team names
SELECT m.match_id, t.tournament_name, t1.team_name AS team1,
    t2.team_name AS team2, m.match_date, m.venue
FROM matches m
JOIN tournaments t ON m.tournament_id = t.tournament_id
JOIN teams t1 ON m.team1_id = t1.team_id
JOIN teams t2 ON m.team2_id = t2.team_id;

-- Query 2: Total matches per tournament
SELECT t.tournament_name, COUNT(m.match_id) AS total_matches
FROM tournaments t
LEFT JOIN matches m ON t.tournament_id = m.tournament_id
GROUP BY t.tournament_name
ORDER BY total_matches DESC;

-- Query 3: Teams with most wins
SELECT tm.team_name, COUNT(r.winner_team_id) AS total_wins
FROM match_results r
JOIN teams tm ON r.winner_team_id = tm.team_id
GROUP BY tm.team_name
ORDER BY total_wins DESC;

-- Query 4: Players per team
SELECT tm.team_name, COUNT(p.player_id) AS total_players
FROM teams tm
LEFT JOIN players p ON p.team_id = tm.team_id
GROUP BY tm.team_name
ORDER BY total_players DESC;

-- Query 5: Matches with scores and winner
SELECT t1.team_name AS team1, r.team1_score, r.team2_score,
    t2.team_name AS team2, COALESCE(tw.team_name, 'Draw') AS winner
FROM match_results r
JOIN matches m ON r.match_id = m.match_id
JOIN teams t1 ON m.team1_id = t1.team_id
JOIN teams t2 ON m.team2_id = t2.team_id
LEFT JOIN teams tw ON r.winner_team_id = tw.team_id;

-- Query 6: Users and their group roles
SELECT u.username, u.email, ug.group_name, ug.description
FROM users u
JOIN user_groups ug ON u.group_id = ug.group_id
ORDER BY ug.group_name;

-- Query 7: Tournament summary
SELECT t.tournament_name, t.sport_type, t.start_date, t.end_date,
    COUNT(DISTINCT m.match_id) AS total_matches,
    COUNT(DISTINCT r.result_id) AS matches_with_results
FROM tournaments t
LEFT JOIN matches m ON t.tournament_id = m.tournament_id
LEFT JOIN match_results r ON m.match_id = r.match_id
GROUP BY t.tournament_name, t.sport_type, t.start_date, t.end_date
ORDER BY t.start_date;

-- PL/SQL Block 1: Function - Get total wins for a team
CREATE OR REPLACE FUNCTION get_team_wins(p_team_id INT)
RETURNS INT AS $$
DECLARE win_count INT;
BEGIN
    SELECT COUNT(*) INTO win_count FROM match_results
    WHERE winner_team_id = p_team_id;
    RETURN win_count;
END;
$$ LANGUAGE plpgsql;

-- PL/SQL Block 2: Procedure - Add a new match
CREATE OR REPLACE PROCEDURE add_match(
    p_tournament_id INT, p_team1 INT, p_team2 INT,
    p_date TIMESTAMP, p_venue VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO matches (tournament_id, team1_id, team2_id, match_date, venue)
    VALUES (p_tournament_id, p_team1, p_team2, p_date, p_venue);
END;
$$;

-- PL/SQL Block 3: Trigger - Auto set winner
CREATE OR REPLACE FUNCTION set_winner()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.team1_score > NEW.team2_score THEN
        NEW.winner_team_id := (SELECT team1_id FROM matches WHERE match_id = NEW.match_id);
    ELSIF NEW.team2_score > NEW.team1_score THEN
        NEW.winner_team_id := (SELECT team2_id FROM matches WHERE match_id = NEW.match_id);
    ELSE
        NEW.winner_team_id := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_winner
BEFORE INSERT ON match_results
FOR EACH ROW EXECUTE FUNCTION set_winner();

-- PL/SQL Block 4: Function - Tournament standings
CREATE OR REPLACE FUNCTION tournament_standings(p_tournament_id INT)
RETURNS TABLE(team_name VARCHAR, wins BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT tm.team_name, COUNT(r.winner_team_id) AS wins
    FROM matches m
    JOIN match_results r ON m.match_id = r.match_id
    JOIN teams tm ON r.winner_team_id = tm.team_id
    WHERE m.tournament_id = p_tournament_id
    GROUP BY tm.team_name
    ORDER BY wins DESC;
END;
$$ LANGUAGE plpgsql;

-- PL/SQL Block 5: Trigger - Prevent same team match
CREATE OR REPLACE FUNCTION check_different_teams()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.team1_id = NEW.team2_id THEN
        RAISE EXCEPTION 'A team cannot play against itself!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_teams
BEFORE INSERT ON matches
FOR EACH ROW EXECUTE FUNCTION check_different_teams();