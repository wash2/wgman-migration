use std::error::Error;
use dao::User;
use wgman::{config::get_db_cfg, dao, auth};
use sqlx::migrate::{Migrator};
use std::path::Path;

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

    let pool = match dao::connect(db_cfg).await {
        Ok(u) => {u},
        Err(_) => {
            std::process::exit(1);
        }
    };

    let m = Migrator::new(Path::new("./migrations")).await?;
    m.run(&pool).await?;

    let User {id, name: _, is_admin: _ }: User = dao::get_user_by_name(&pool, String::from("admin")).await?;
    let auth::Hash { pbkdf2_hash, salt}: auth::Hash = match auth::encrypt("dummy pw") {
        Ok(hash) => hash,
        Err(_) => {
            println!("Failed to encrypt password for wgman admin user. No UserPassword entry was created.");
            std::process::exit(1);
        },
    };

    let _rec = sqlx::query!("Insert INTO public.\"UserPassword\" (id, password_hash, salt) Values ($1, $2, $3);", id, std::str::from_utf8(&pbkdf2_hash[..])?, std::str::from_utf8(&salt[..])?)
    .fetch_one(&pool)
    .await?;

    Ok(println!("Migration Complete"))
}
