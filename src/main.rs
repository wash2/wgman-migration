use std::error::Error;
use sqlx::{Pool, Postgres, migrate::{Migrator}, postgres::PgPoolOptions};
use std::path::Path;
use wgman_core::{config::get_db_cfg, types::User, auth};
use std::env::{var};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    //db setup
    let db_cfg = match get_db_cfg() {
        Ok(cfg) => {cfg}
        Err(err) => {
            dbg!(err);
            std::process::exit(1);
        }
    };

    let pool: Pool<Postgres> = PgPoolOptions::new()
    .max_connections(20)
    .connect(&format!("postgres://{}:{}@{}:{}/{}", db_cfg.user, db_cfg.pw, db_cfg.host, db_cfg.port, db_cfg.name))
    .await?;

    let m = Migrator::new(Path::new("./migrations")).await?;
    m.run(&pool).await?;

    let User { id, name: _, is_admin: _ } = sqlx::query_as::<_, User>("SELECT id FROM public.\"User\" Where name = $1")
    .bind("admin")
    .fetch_one(&pool)
    .await?;

    let pw = var("WGMAN_DB_ADMIN_PW")?;

    let auth::Hash { pbkdf2_hash, salt}: auth::Hash = match auth::encrypt(&pw) {
        Ok(hash) => hash,
        Err(_) => {
            println!("Failed to encrypt password for wgman admin user. No UserPassword entry was created.");
            std::process::exit(1);
        },
    };

    let _rec = sqlx::query("Insert INTO public.\"UserPassword\" (id, password_hash, salt) Values ($1, $2, $3);")
    .bind(id)
    .bind(std::str::from_utf8(&pbkdf2_hash[..])?)
    .bind(std::str::from_utf8(&salt[..])?)
    .fetch_one(&pool)
    .await?;

    Ok(println!("Migration Complete"))
}
