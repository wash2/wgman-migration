use std::{convert::TryInto, error::Error};
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

    println!("loading migrations");
    let m = Migrator::new(Path::new("./migrations")).await?;
    println!("running migrations");
    m.run(&pool).await?;
    let pw = var("WGMAN_DB_ROOT_PW")?;

    println!("getting root");
    let Admin { u_name: _, is_root: _ } = sqlx::query_as::<_, Admin>("SELECT * FROM public.admin WHERE u_name = 'root'")
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
    // dbg!(pbkdf2_hash);
    // dbg!(salt);


    println!("adding user password");
    sqlx::query("Insert INTO public.admin_password (u_name, password_hash, salt) Values ($1, $2, $3);")
    .bind(String::from("root"))
    .bind(&pbkdf2_hash[..])
    .bind(&salt[..])
    .execute(&pool)
    .await?;


    // let test = sqlx::query_as::<_, wgman_core::types::AdminPassword>("SELECT * FROM public.admin_password WHERE id = $1")
    // .bind(id)
    // .fetch_one(&pool)
    // .await?;
    // let entered_hash: [u8; 64] = test.password_hash[..].try_into().expect("oops");
    // let entered_salt: [u8; 64] = test.salt[..].try_into().expect("oops");
    // assert_eq!(pbkdf2_hash, entered_hash);
    // assert_eq!(salt, entered_salt);

    Ok(println!("Migration Complete"))
}
