INSERT INTO user_groups (group_name, description) VALUES
('admin', 'Full system access'),
('referee', 'Manages and enters match results'),
('team_manager', 'Manages team and player data'),
('spectator', 'Read-only access to tournament info');

INSERT INTO users (username, password_hash, email, group_id) VALUES
('admin1', 'pass123', 'admin@sports.com', 1),
('referee1', 'pass123', 'referee1@sports.com', 2),
('manager1', 'pass123', 'manager1@sports.com', 3),
('spectator1', 'pass123', 'spectator1@sports.com', 4);

INSERT INTO teams (team_name, city, coach_name) VALUES
('Thunder FC', 'Istanbul', 'Ahmet Yilmaz'),
('Storm United', 'Ankara', 'Mehmet Kaya'),
('Fire Eagles', 'Izmir', 'Ali Demir'),
('Ice Wolves', 'Bursa', 'Hasan Celik');

INSERT INTO players (full_name, date_of_birth, position, team_id) VALUES
('Kemal Arslan', '1998-03-15', 'Forward', 1),
('Burak Sahin', '2000-07-22', 'Midfielder', 1),
('Emre Yildiz', '1997-11-05', 'Defender', 2),
('Can Ozturk', '1999-04-18', 'Goalkeeper', 2),
('Serkan Polat', '2001-09-30', 'Forward', 3),
('Murat Akin', '1996-01-12', 'Midfielder', 4);

INSERT INTO tournaments (tournament_name, sport_type, start_date, end_date, created_by) VALUES
('Spring Cup 2025', 'Football', '2025-03-01', '2025-03-31', 1),
('Summer League 2025', 'Football', '2025-06-01', '2025-06-30', 1);

INSERT INTO matches (tournament_id, team1_id, team2_id, match_date, venue) VALUES
(1, 1, 2, '2025-03-05 15:00:00', 'Istanbul Stadium'),
(1, 3, 4, '2025-03-06 17:00:00', 'Izmir Arena'),
(1, 1, 3, '2025-03-12 15:00:00', 'Istanbul Stadium'),
(2, 2, 4, '2025-06-05 18:00:00', 'Ankara Arena');

INSERT INTO match_results (match_id, team1_score, team2_score, winner_team_id) VALUES
(1, 3, 1, 1),
(2, 0, 2, 4),
(3, 1, 1, NULL);