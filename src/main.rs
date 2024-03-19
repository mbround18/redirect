#[macro_use]
extern crate rocket;

use dotenv::dotenv;
use regex::Regex;
use rocket::response::Redirect;
use std::env;

const BASE_ENDPOINT: &str = "https://github.com/mbround18/redirect";

/// This is our base http endpoint
/// This calls a redirect to the base endpoint of mbround18's github.
#[get("/")]
fn base() -> Redirect {
    env::var("DEFAULT_ENDPOINT")
        .map(Redirect::to)
        .unwrap_or_else(|_| Redirect::to(BASE_ENDPOINT))
}

#[get("/<target>")]
fn director(target: &str) -> Redirect {
    let default_endpoint =
        env::var("DEFAULT_ENDPOINT").unwrap_or_else(|_| String::from(BASE_ENDPOINT));
    let matcher = Regex::new(r"[\n\s]+").unwrap();
    let mut redirects = env::var("REDIRECTS").unwrap_or(format!("base>{}", BASE_ENDPOINT));
    redirects = String::from(matcher.replace_all(&redirects, ""));

    println!("{}", &redirects);

    let redirect_info: Vec<Vec<&str>> = redirects
        .split('|')
        .map(|redir_data| redir_data.split('>').collect())
        .collect();

    let potential_endpoint = redirect_info
        .iter()
        .find(|segments| segments.first().unwrap_or(&"none").eq(&target));

    if let Some(endpoint) = potential_endpoint {
        let url = endpoint.get(1).unwrap().to_string();
        println!("Url: {}", &url);
        Redirect::to(url)
    } else {
        println!("Default Url: {}", &default_endpoint);
        Redirect::to(default_endpoint)
    }
}

#[launch]
fn rocket() -> _ {
    dotenv().ok();
    let figment = rocket::Config::figment().merge(("address", "0.0.0.0"));
    rocket::custom(figment).mount("/", routes![base, director])
}
