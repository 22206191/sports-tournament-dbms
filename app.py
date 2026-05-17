import streamlit as st
import psycopg2

# ── Database connection ──────────────────────────────────────────
def get_connection():
    return psycopg2.connect(
        host="aws-1-ap-northeast-2.pooler.supabase.com",
        database="postgres",
        user="postgres.taoudtrnioqednjicvnq",
        password="Nazarov2002@",
        port="5432"
    )
# ── Page config ──────────────────────────────────────────────────
st.set_page_config(page_title="Sports Tournament", layout="wide")

# ── Sidebar navigation ───────────────────────────────────────────
st.sidebar.title("🏆 Sports Tournament")
page = st.sidebar.radio("Navigate", [
    "🏠 Home",
    "👥 Teams",
    "🧑 Players",
    "🏟️ Tournaments & Matches",
    "📊 Results & Statistics"
])

# ════════════════════════════════════════════════════════════════
# PAGE 1 — HOME
# ════════════════════════════════════════════════════════════════
if page == "🏠 Home":
    st.title("🏆 Sports Tournament Database Management System")
    st.markdown("Welcome! Use the sidebar to navigate between sections.")

    conn = get_connection()
    cur = conn.cursor()

    col1, col2, col3, col4 = st.columns(4)

    cur.execute("SELECT COUNT(*) FROM teams")
    col1.metric("Total Teams", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM players")
    col2.metric("Total Players", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM tournaments")
    col3.metric("Total Tournaments", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM matches")
    col4.metric("Total Matches", cur.fetchone()[0])

    conn.close()

# ════════════════════════════════════════════════════════════════
# PAGE 2 — TEAMS
# ════════════════════════════════════════════════════════════════
elif page == "👥 Teams":
    st.title("👥 Teams Management")
    conn = get_connection()
    cur = conn.cursor()

    # Show existing teams
    st.subheader("All Teams")
    cur.execute("SELECT * FROM teams")
    teams = cur.fetchall()
    for t in teams:
        st.write(f"**{t[1]}** — {t[2]} | Coach: {t[3]}")

    st.markdown("---")

    # Add new team
    st.subheader("➕ Add New Team")
    name = st.text_input("Team Name")
    city = st.text_input("City")
    coach = st.text_input("Coach Name")
    if st.button("Add Team"):
        cur.execute("INSERT INTO teams (team_name, city, coach_name) VALUES (%s, %s, %s)", (name, city, coach))
        conn.commit()
        st.success(f"Team '{name}' added!")

    st.markdown("---")

    # Delete team
    st.subheader("🗑️ Delete Team")
    team_names = [t[1] for t in teams]
    selected = st.selectbox("Select team to delete", team_names)
    if st.button("Delete Team"):
        cur.execute("DELETE FROM teams WHERE team_name = %s", (selected,))
        conn.commit()
        st.warning(f"Team '{selected}' deleted!")

    conn.close()

# ════════════════════════════════════════════════════════════════
# PAGE 3 — PLAYERS
# ════════════════════════════════════════════════════════════════
elif page == "🧑 Players":
    st.title("🧑 Players Management")
    conn = get_connection()
    cur = conn.cursor()

    # Show players with team names
    st.subheader("All Players")
    cur.execute("""
        SELECT p.full_name, p.position, p.date_of_birth, t.team_name
        FROM players p
        LEFT JOIN teams t ON p.team_id = t.team_id
    """)
    players = cur.fetchall()
    for p in players:
        st.write(f"**{p[0]}** | {p[1]} | DOB: {p[2]} | Team: {p[3]}")

    st.markdown("---")

    # Add new player
    st.subheader("➕ Add New Player")
    full_name = st.text_input("Full Name")
    dob = st.date_input("Date of Birth")
    position = st.selectbox("Position", ["Forward", "Midfielder", "Defender", "Goalkeeper"])

    cur.execute("SELECT team_id, team_name FROM teams")
    teams = cur.fetchall()
    team_dict = {t[1]: t[0] for t in teams}
    selected_team = st.selectbox("Team", list(team_dict.keys()))

    if st.button("Add Player"):
        cur.execute(
            "INSERT INTO players (full_name, date_of_birth, position, team_id) VALUES (%s, %s, %s, %s)",
            (full_name, dob, position, team_dict[selected_team])
        )
        conn.commit()
        st.success(f"Player '{full_name}' added!")

    conn.close()

# ════════════════════════════════════════════════════════════════
# PAGE 4 — TOURNAMENTS & MATCHES
# ════════════════════════════════════════════════════════════════
elif page == "🏟️ Tournaments & Matches":
    st.title("🏟️ Tournaments & Matches")
    conn = get_connection()
    cur = conn.cursor()

    # Show tournaments
    st.subheader("All Tournaments")
    cur.execute("SELECT * FROM tournaments")
    tournaments = cur.fetchall()
    for t in tournaments:
        st.write(f"**{t[1]}** | {t[2]} | {t[3]} → {t[4]}")

    st.markdown("---")

    # Add tournament
    st.subheader("➕ Add New Tournament")
    tname = st.text_input("Tournament Name")
    sport = st.text_input("Sport Type")
    start = st.date_input("Start Date")
    end = st.date_input("End Date")
    if st.button("Add Tournament"):
        cur.execute(
            "INSERT INTO tournaments (tournament_name, sport_type, start_date, end_date, created_by) VALUES (%s, %s, %s, %s, 1)",
            (tname, sport, start, end)
        )
        conn.commit()
        st.success(f"Tournament '{tname}' added!")

    st.markdown("---")

    # Show matches
    st.subheader("All Matches")
    cur.execute("""
        SELECT t1.team_name, t2.team_name, m.match_date, m.venue, tr.tournament_name
        FROM matches m
        JOIN teams t1 ON m.team1_id = t1.team_id
        JOIN teams t2 ON m.team2_id = t2.team_id
        JOIN tournaments tr ON m.tournament_id = tr.tournament_id
    """)
    matches = cur.fetchall()
    for m in matches:
        st.write(f"**{m[0]}** vs **{m[1]}** | {m[2]} | {m[3]} | Tournament: {m[4]}")

    conn.close()

# ════════════════════════════════════════════════════════════════
# PAGE 5 — RESULTS & STATISTICS
# ════════════════════════════════════════════════════════════════
elif page == "📊 Results & Statistics":
    st.title("📊 Results & Statistics")
    conn = get_connection()
    cur = conn.cursor()

    # Match results
    st.subheader("Match Results")
    cur.execute("""
        SELECT t1.team_name, r.team1_score, r.team2_score, t2.team_name,
               COALESCE(tw.team_name, 'Draw') AS winner
        FROM match_results r
        JOIN matches m ON r.match_id = m.match_id
        JOIN teams t1 ON m.team1_id = t1.team_id
        JOIN teams t2 ON m.team2_id = t2.team_id
        LEFT JOIN teams tw ON r.winner_team_id = tw.team_id
    """)
    results = cur.fetchall()
    for r in results:
        st.write(f"**{r[0]}** {r[1]} — {r[2]} **{r[3]}** | Winner: 🏆 {r[4]}")

    st.markdown("---")

    # Team wins stats
    st.subheader("🏆 Team Win Statistics")
    cur.execute("""
        SELECT tm.team_name, COUNT(r.winner_team_id) AS wins
        FROM match_results r
        JOIN teams tm ON r.winner_team_id = tm.team_id
        GROUP BY tm.team_name
        ORDER BY wins DESC
    """)
    stats = cur.fetchall()
    for s in stats:
        st.write(f"**{s[0]}** — {s[1]} wins")

    conn.close()