USE intendo;

CREATE INDEX sj_all_revenue_large_player_id ON sj_all_revenue_large (player_id(255));
CREATE INDEX sj_all_revenue_large_session_id ON sj_all_revenue_large (session_id(255));
CREATE INDEX sj_all_revenue_large_f_player_id ON sj_all_revenue_large_f (player_id(255));
CREATE INDEX sj_all_revenue_large_f_session_id ON sj_all_revenue_large_f (session_id(255));

CREATE INDEX sj_all_sessions_large_player_id ON sj_all_sessions_large (player_id(255));
CREATE INDEX sj_all_sessions_large_session_id ON sj_all_sessions_large (session_id(255));
CREATE INDEX sj_all_sessions_large_f_player_id ON sj_all_sessions_large_f (player_id(255));
CREATE INDEX sj_all_sessions_large_f_session_id ON sj_all_sessions_large_f (session_id(255));

CREATE INDEX sj_user_summary_large_player_id ON sj_user_summary_large (player_id(255));
CREATE INDEX sj_user_summary_large_f_player_id ON sj_user_summary_large_f (player_id(255));

CREATE INDEX sj_users_daily_large_player_id ON sj_users_daily_large (player_id(255));
CREATE INDEX sj_users_daily_large_f_player_id ON sj_users_daily_large_f (player_id(255));
