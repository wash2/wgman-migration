use std::error::Error;
use sqlx::{Pool, Postgres, migrate::{Migrator}, postgres::PgPoolOptions};
use std::path::Path;
use wgman_core::{config::get_db_cfg, types::Admin, auth};
use std::env::{var};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    //db setup
    println!("loading config");
    let db_cfg = match get_db_cfg() {
        Ok(cfg) => {cfg}
        Err(err) => {
            dbg!(err);
            std::process::exit(1);
        }
    };

    let db_url = &format!("postgres://{}:{}@{}:{}/{}", db_cfg.user, db_cfg.pw, db_cfg.host, db_cfg.port, db_cfg.name);
    println!("connecting to pool at {}", db_url);
    let pool: Pool<Postgres> = PgPoolOptions::new()
    .max_connections(20)
    .connect(db_url)
    .await?;

    println!("running migrations");
    let m = Migrator::new(Path::new("./migrations")).await?;
    m.run(&pool).await?;
    let pw = var("WGMAN_DB_ROOT_PW")?;

    println!("getting root");
    let Admin { id, u_name: _, is_root: _ } = sqlx::query_as::<_, Admin>("SELECT * FROM public.admin WHERE u_name = 'root'")
    .fetch_one(&pool)
    .await?;

    println!("hashing pw");
    let auth::Hash { pbkdf2_hash, salt}: auth::Hash = match auth::encrypt(&pw) {
        Ok(hash) => hash,
        Err(_) => {
            println!("Failed to encrypt password for wgman admin user. No UserPassword entry was created.");
            std::process::exit(1);
        },
    };

    
    

    println!("adding user password");
    sqlx::query("Insert INTO public.admin_password (id, password_hash, salt) Values ($1, $2, $3);")
    .bind(id)
    .bind(&pbkdf2_hash[..])
    .bind(&salt[..])
    .execute(&pool)
    .await?;

    Ok(println!("Migration Complete"))
}
