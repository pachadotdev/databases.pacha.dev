CREATE INDEX sj_all_revenue_small_player_id ON sj_all_revenue_small (player_id);
CREATE INDEX sj_all_revenue_small_session_id ON sj_all_revenue_small (session_id);
CREATE INDEX sj_all_revenue_small_f_player_id ON sj_all_revenue_small_f (player_id);
CREATE INDEX sj_all_revenue_small_f_session_id ON sj_all_revenue_small_f (session_id);

CREATE INDEX sj_all_sessions_small_player_id ON sj_all_sessions_small (player_id);
CREATE INDEX sj_all_sessions_small_session_id ON sj_all_sessions_small (session_id);
CREATE INDEX sj_all_sessions_small_f_player_id ON sj_all_sessions_small_f (player_id);
CREATE INDEX sj_all_sessions_small_f_session_id ON sj_all_sessions_small_f (session_id);

CREATE INDEX sj_user_summary_small_player_id ON sj_user_summary_small (player_id);
CREATE INDEX sj_user_summary_small_f_player_id ON sj_user_summary_small_f (player_id);

CREATE INDEX sj_users_daily_small_player_id ON sj_users_daily_small (player_id);
CREATE INDEX sj_users_daily_small_f_player_id ON sj_users_daily_small_f (player_id);
