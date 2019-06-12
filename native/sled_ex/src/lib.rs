#[macro_use]
extern crate rustler;
#[macro_use]
extern crate rustler_codegen;
extern crate sled;
#[macro_use]
extern crate err_derive;

use rustler::{Env, Term};

mod atoms;
mod config;
mod db;
mod error;

type SledExResult<T> = Result<T, error::SledExError>;

rustler_export_nifs! {
    "Elixir.Sled.Native",
    [("start_default", 1, db::start_default),("set", 3, db::set),("get", 2, db::get),("del", 2, db::del),("scan", 3, db::scan),("iter_next", 1, db::iter_next)],
    Some(on_load)
}

fn on_load<'a>(env: Env<'a>, _info: Term) -> bool {
    resource_struct_init!(db::DBHandle, env);
    resource_struct_init!(db::Cursor, env);
    true
}
