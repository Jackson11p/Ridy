-- ATDE-39-T10: un token nunca en dos perfiles, ni con dos set_push_token concurrentes (READ COMMITTED):
-- el segundo choca con 23505 en vez de duplicar. set_push_token sigue quitando el token de otros antes de ponerlo.
create unique index profiles_push_token_key on public.profiles (push_token) where push_token is not null;
