CREATE TABLE user_groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150) UNIQUE,
    group_id INT REFERENCES user_groups(group_id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100),
    coach_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    date_of_birth DATE,
    position VARCHAR(50),
    team_id INT REFERENCES teams(team_id) ON DELETE SET NULL
);

CREATE TABLE tournaments (
    tournament_id SERIAL PRIMARY KEY,
    tournament_name VARCHAR(150) NOT NULL,
    sport_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    created_by INT REFERENCES users(user_id)
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    tournament_id INT REFERENCES tournaments(tournament_id),
    team1_id INT REFERENCES teams(team_id),
    team2_id INT REFERENCES teams(team_id),
    match_date TIMESTAMP,
    venue VARCHAR(150),
    CONSTRAINT different_teams CHECK (team1_id <> team2_id)
);

CREATE TABLE match_results (
    result_id SERIAL PRIMARY KEY,
    match_id INT REFERENCES matches(match_id) UNIQUE,
    team1_score INT DEFAULT 0,
    team2_score INT DEFAULT 0,
    winner_team_id INT REFERENCES teams(team_id)
);